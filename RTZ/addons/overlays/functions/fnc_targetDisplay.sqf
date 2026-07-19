#include "script_component.hpp"
/*
 * Author: Maxim
 * Engagement-target overlay: while toggled on (FUNC(targetToggle)), draws a
 * side-coloured line from each unit the local curator has SELECTED to where
 * it BELIEVES its target is, capped with an impact icon, labelled with the
 * target's name and knowledge freshness when the cursor is near it (modelled
 * on the LAMBS debug renderer; same architecture as FUNC(destinationDisplay)).
 *
 * The line ends at the AI's ESTIMATED target position (targetKnowledge), not
 * the target's true position — stale knowledge visibly points at where the
 * target was last seen, and the overlay dims as the sighting ages.
 *
 * assignedTarget / targetKnowledge read AI sensor state, which only exists
 * where the unit is local. Normal AI is server-local, so the SERVER polls
 * each curator's watched units and streams per-curator snapshots via
 * CBA_fnc_targetEvent; non-server-local units (remote control, headless
 * clients) are skipped. Per-curator streams also keep it PvP-fair — a Zeus
 * only watches units they can select, and only sees what those units know.
 *
 * Runs once per machine from XEH_postInit (after CBA_settingsInitialized),
 * gated on GVAR(enableTargetDisplay); client state comes from XEH_preInit,
 * draw/poll constants from script_component.hpp.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_overlays_fnc_targetDisplay
 *
 * Public: No
 */

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — selection sync + draw handler + snapshot receiver
// ─────────────────────────────────────────────────────────────────────────────
if (hasInterface) then {

    addMissionEventHandler ["Draw3D", {
        if (!GVAR(tgtEnabled)) exitWith {};

        // The live selection drives the watch set: sync on change (covers
        // select, deselect and Zeus closing, which reads as an empty selection).
        // Watched entities are hulls — a man on foot fights for himself; a
        // crewman or a vehicle resolves to the vehicle, which engages as one.
        private _inZeus = !isNull (findDisplay 312);
        private _sel = if (_inZeus) then { SELECTED_OBJECTS } else { [] };
        if (_sel isNotEqualTo GVAR(tgtSelection)) then {
            GVAR(tgtSelection) = _sel;
            private _units = [];
            {
                if (!isNull _x) then { _units pushBackUnique (vehicle _x) };
            } forEach _sel;
            GVAR(tgtWatchedUnits) = createHashMapFromArray (_units apply { [netId _x, true] });
            // Deselected units' lines drop on the spot rather than after a tick.
            GVAR(tgtDisplay) = GVAR(tgtDisplay) select {
                (netId (_x select 0)) in GVAR(tgtWatchedUnits)
            };
            [QGVAR(tgtWatch), [player, _units]] call CBA_fnc_serverEvent;
        };

        // Curator-view overlay only — never bleed into first person / plain map.
        if (!_inZeus) exitWith {};
        if (GVAR(tgtDisplay) isEqualTo []) exitWith {};

        private _camPos = positionCameraToWorld [0, 0, 0];
        private _mouse  = getMousePosition;

        {
            _x params ["_unit", "_target", "_estPos", "_rgb", "_freshAlpha", "_label"];
            if (isNull _unit || { !alive _unit }) then { continue };
            // A kill between server ticks drops the line on the spot rather
            // than pointing at the corpse until the next snapshot.
            if (isNull _target || { !alive _target }) then { continue };

            // Anchor on the vehicle so mounted crews draw from the hull, and read
            // the position live each frame — only the target end is snapshotted.
            private _from    = (getPosATLVisual (vehicle _unit)) vectorAdd [0, 0, 0.5];
            private _camDist = _camPos distance _from;
            if (_camDist > MAX_DRAW_DIST && { _camPos distance _estPos > MAX_DRAW_DIST }) then { continue };

            // Distant overlays recede instead of stacking into clutter; stale
            // sightings dim on top of that (freshness baked at snapshot time).
            private _alpha = (linearConversion [FADE_NEAR, MAX_DRAW_DIST, _camDist, 1, 0.3, true]) * _freshAlpha;
            private _color = _rgb + [_alpha];
            drawLine3D [_from, _estPos, _color];

            // Label only near the cursor — a screenful of contact reports is noise.
            private _text = "";
            private _scr  = worldToScreen _estPos;
            if (_scr isNotEqualTo [] && { _mouse distance2D _scr < LABEL_CURSOR_RADIUS }) then {
                _text = _label;
            };

            drawIcon3D [
                ICON_TARGET,
                _color,
                _estPos,
                ICON_SIZE_TARGET, ICON_SIZE_TARGET, 0,
                _text,
                1, LABEL_TEXT_SIZE, LABEL_FONT
            ];
        } forEach GVAR(tgtDisplay);
    }];

    // Full snapshot from the server. Filter and format ONCE here rather than per
    // frame: drop units deselected while the snapshot was in flight, and bake the
    // target-side colour, freshness dim and label (only the unit anchor moves
    // between snapshots, so everything else is per-tick constant).
    [QGVAR(tgtUpdate), {
        params ["_entries"];
        private _display = [];
        {
            _x params ["_unit", "_target", "_estPos", "_seenAgo", "_posError", "_tSide"];
            if (isNull _unit) then { continue };
            if !((netId _unit) in GVAR(tgtWatchedUnits)) then { continue };

            // Line and icon carry the TARGET's side colour — red line means
            // "shooting at OPFOR", matching the spotting palette semantics.
            private _rgb        = ([_tSide, false] call EFUNC(common,sideColor)) select [0, 3];
            private _freshAlpha = linearConversion [0, STALE_DIM_TIME, _seenAgo, 1, 0.45, true];

            private _name    = ([_target] call EFUNC(common,classInfo)) select 0;
            private _seenTxt = if (_seenAgo < 1) then { LLSTRING(LabelInSight) } else {
                format [LLSTRING(LabelSeenAgo), round _seenAgo]
            };
            private _label = format ["%1 — %2", _name, _seenTxt];
            if (_posError > 5) then {
                _label = format ["%1 (±%2m)", _label, round _posError];
            };

            _display pushBack [_unit, _target, _estPos, _rgb, _freshAlpha, _label];
        } forEach _entries;
        GVAR(tgtDisplay) = _display;
    }] call CBA_fnc_addEventHandler;
};

if (!isServer) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — watcher registry + target poll loop
// ─────────────────────────────────────────────────────────────────────────────

// Subscribed curators: player netId → [player, units, sentEmpty] where units is
// the client's resolved selection (replaced wholesale on every selection change)
// and sentEmpty flags that the last snapshot sent was empty — the client is
// already clear, so consecutive empties are skipped.
GVAR(tgtWatchers) = createHashMap;

// Replace-set semantics: the client sends its full resolved selection whenever
// it changes; an empty set unsubscribes.
[QGVAR(tgtWatch), {
    params ["_player", "_units"];
    if (isNull _player) exitWith {};
    private _pk = netId _player;
    _units = _units select { !isNull _x };
    if (_units isEqualTo []) exitWith {
        if (_pk in GVAR(tgtWatchers)) then {
            GVAR(tgtWatchers) deleteAt _pk;
            // Final empty snapshot so the client's overlay clears immediately.
            [QGVAR(tgtUpdate), [[]], _player] call CBA_fnc_targetEvent;
        };
    };
    // sentEmpty=false so a fresh subscription always gets at least one snapshot.
    GVAR(tgtWatchers) set [_pk, [_player, _units, false]];
}] call CBA_fnc_addEventHandler;

// Unscheduled per-frame handler (RTZ server-loop convention) rather than a
// spawned while/sleep: no scheduler starvation, and the send cadence is exactly
// POLL_INTERVAL. Bails cheaply when nobody is subscribed; no suspending
// commands in the body.
[{
    if (count GVAR(tgtWatchers) == 0) exitWith {};

    private _toDrop = [];
    {
        // _x = player netId (key), _y = [player, units, sentEmpty] (value).
        _y params ["_player", "_units", "_sentEmpty"];
        // Disconnected players can't receive targetEvents — drop them here so
        // a vanished watcher can never null-error the send below.
        if (isNull _player) then { _toDrop pushBack _x; continue };

        private _entries = [];
        // A watched man may have mounted a watched vehicle since the selection
        // sync — both resolve to the same hull, which fights as one.
        private _vehSeen = createHashMap;
        {
            if (isNull _x || { !alive _x }) then { continue };
            private _veh = vehicle _x;
            private _vk  = netId _veh;
            if (_vk in _vehSeen) then { continue };
            _vehSeen set [_vk, true];
            // assignedTarget / targetKnowledge are only meaningful where the
            // unit is local; skips remote-controlled and HC-offloaded.
            if (!local _veh) then { continue };

            // Whoever aims the weapon holds the sensor knowledge: the man
            // himself on foot, the gunner (or failing that the commander /
            // driver) for a vehicle. Player judgement isn't AI state.
            private _kUnit = if (_veh isKindOf "CAManBase") then { _veh } else {
                private _g = gunner _veh;
                if (isNull _g) then { effectiveCommander _veh } else { _g }
            };
            if (isNull _kUnit || { isPlayer _kUnit }) then { continue };

            private _target = assignedTarget _kUnit;
            if (isNull _target || { !alive _target }) then { continue };
            // Friendly "targets" (watch/cover assignments) are noise.
            private _tSide = side _target;
            if (_tSide isEqualTo side group _kUnit) then { continue };

            // Where the AI believes the target is: index 2 = time of the
            // last sighting, 5 = position error (m), 6 = estimated position
            // ASL (indices per the LAMBS debug renderer).
            private _kn = _kUnit targetKnowledge _target;
            private _estPos = ASLToAGL (_kn select 6);
            // Degenerate knowledge position while actively suppressing —
            // fall back to the true position (same fix as LAMBS).
            if (_estPos distanceSqr [0, 0, 0] < 1) then {
                _estPos = getPosATL _target;
            };
            if (_veh distance _estPos > KNOWLEDGE_MAX_DIST) then { continue };

            private _seenAgo = (time - (_kn select 2)) max 0;
            _entries pushBack [_x, _target, _estPos, _seenAgo, _kn select 5, _tSide];
        } forEach _units;

        // One empty snapshot clears the client; resending "nothing to draw"
        // every tick while the units hold fire is wasted traffic.
        if (_entries isNotEqualTo [] || { !_sentEmpty }) then {
            [QGVAR(tgtUpdate), [_entries], _player] call CBA_fnc_targetEvent;
            _y set [2, _entries isEqualTo []];
        };
    } forEach GVAR(tgtWatchers);

    { GVAR(tgtWatchers) deleteAt _x } forEach _toDrop;
}, POLL_INTERVAL] call CBA_fnc_addPerFrameHandler;
