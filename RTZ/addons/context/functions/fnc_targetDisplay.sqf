#include "script_component.hpp"
/*
 * rtz_fnc_targetDisplay
 *
 * Renders the current engagement target of the units the local curator has
 * SELECTED while the overlay is toggled on (FUNC(targetToggle)): a side-coloured
 * line from the unit to where it BELIEVES its target is, capped with an impact
 * icon, labelled with the target's name and knowledge freshness when the cursor
 * is near it — modelled on the LAMBS Danger debug renderer
 * (lambs_main_fnc_debugDraw, targetKnowledge lines), same architecture as
 * FUNC(destinationDisplay).
 *
 * The line ends at the AI's ESTIMATED target position (targetKnowledge), not
 * the target's true position — stale knowledge visibly points at where the
 * target was last seen, and the whole overlay dims as the sighting ages.
 *
 * The watch set follows the live Zeus selection: selecting units draws their
 * targets, deselecting removes them, closing Zeus counts as an empty selection.
 * The toggle is just a master switch for this behaviour.
 *
 * Locality: assignedTarget / targetKnowledge read AI sensor state, which only
 * exists on the machine that owns the unit (LAMBS guards its debug draw the
 * same way). Normal AI is server-local, so the SERVER polls targets for each
 * curator's watched units and streams per-curator snapshots via
 * CBA_fnc_targetEvent; units that are not server-local (Zeus remote control,
 * headless clients) are skipped. Per-curator streams also keep it PvP-fair —
 * a Zeus can only watch units they can select, i.e. their own, and only sees
 * what those units actually know.
 *
 * Requirements: CBA_A3 (drawing needs no ZEN, but toggling does — see
 * FUNC(targetContext)).
 * Loading: spawned from XEH_postInit after CBA_settingsInitialized, gated on
 * GVAR(enableTargetDisplay). Self-guards locality like the main addon's
 * spottingSystem. Client state containers come from XEH_preInit.
 */

// Camera cull and fade, matching the destination overlay so the two read as one
// system. STALE_DIM_TIME is how long after the last sighting the overlay bottoms
// out at its dimmest — old intel visibly recedes. Labels only render while the
// cursor is within LABEL_CURSOR_RADIUS of the icon (GUI screen units). Macros,
// not privates — event handler code blocks don't see this scope.
#define MAX_DRAW_DIST       2500
#define FADE_NEAR           800
#define LABEL_CURSOR_RADIUS 0.05
#define STALE_DIM_TIME      30
#define ICON_TARGET         "\a3\ui_f\data\igui\cfg\targeting\impactpoint_ca.paa"

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — selection sync + draw handler + snapshot receiver
// ─────────────────────────────────────────────────────────────────────────────
if (hasInterface) then {

    addMissionEventHandler ["Draw3D", {
        if (!GVAR(tgtEnabled)) exitWith {};

        // The live selection drives the watch set: sync on change (covers
        // select, deselect and Zeus closing, which reads as an empty selection).
        private _inZeus = !isNull (findDisplay 312);
        private _sel = if (_inZeus) then { SELECTED_OBJECTS } else { [] };
        if (_sel isNotEqualTo GVAR(tgtSelection)) then {
            GVAR(tgtSelection) = _sel;
            // Resolve to the entities that actually hold a target: a man on
            // foot fights for himself; a crewman or a vehicle resolves to the
            // vehicle, which engages as one (dedupes whole selected crews).
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
            // A kill between 2 s server ticks drops the line on the spot rather
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
                0.9, 0.9, 0,
                _text,
                1, 0.03, "RobotoCondensed"
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
            private _seenTxt = if (_seenAgo < 1) then { "in sight" } else {
                format ["seen %1s ago", round _seenAgo]
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

private _CHECK_INTERVAL = 2;   // Seconds between snapshots. Targets switch
                               // constantly in contact; 2 s tracks that without
                               // flooding the network (one event/watcher/tick).

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

// Unscheduled per-frame handler (RTZ server-loop convention, cf.
// FUNC(destinationDisplay) / remoteControlIndicator) rather than a spawned
// while/sleep: no scheduler starvation, and the send cadence is exactly
// _CHECK_INTERVAL. Bails cheaply when nobody is subscribed. The body uses no
// suspending commands, so it is safe in the unscheduled per-frame context.
[{
    if (count GVAR(tgtWatchers) > 0) then {
        private _toDrop = [];
        {
            // _x = player netId (key), _y = [player, units, sentEmpty] (value).
            _y params ["_player", "_units", "_sentEmpty"];
            // Disconnected players can't receive targetEvents — drop them here so
            // a vanished watcher can never null-error the send below.
            if (isNull _player) then { _toDrop pushBack _x; continue };

            private _entries = [];
            // A watched man may have mounted a watched vehicle since the
            // selection sync — both resolve to the same hull, which fights as
            // one, so only the first draws.
            private _vehSeen = createHashMap;
            {
                if (isNull _x || { !alive _x }) then { continue };
                // Crews engage through their vehicle (seats can change between
                // selection syncs, so re-resolve here every tick).
                private _veh = vehicle _x;
                private _vk  = netId _veh;
                if (_vk in _vehSeen) then { continue };
                _vehSeen set [_vk, true];
                // assignedTarget / targetKnowledge are only meaningful where
                // the unit is local; skips remote-controlled and HC-offloaded.
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
                if (_veh distance _estPos > 6000) then { continue };   // LAMBS sanity cap

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
    };
}, _CHECK_INTERVAL] call CBA_fnc_addPerFrameHandler;
