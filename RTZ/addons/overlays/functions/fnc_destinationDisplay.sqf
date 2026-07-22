#include "script_component.hpp"
/*
 * Author: Maxim
 * Expected-destination overlay: while toggled on (FUNC(destinationToggle)),
 * draws a line + move icon from each unit the local curator has SELECTED to
 * its AI pathing destination, labelled with distance and pathing mode when
 * the cursor is near the icon (modelled on the LAMBS debug renderer).
 *
 * expectedDestination reads AI pathing state, which only exists where the
 * unit is local. Normal AI is server-local, so the SERVER polls each
 * curator's watched units and streams per-curator snapshots via
 * CBA_fnc_targetEvent; non-server-local units (remote control, headless
 * clients) are skipped. Per-curator streams also keep it PvP-fair — a Zeus
 * only watches units they can select.
 *
 * Runs once per machine from XEH_postInit (after CBA_settingsInitialized),
 * gated on GVAR(enableDestinationDisplay); client state comes from
 * XEH_preInit, draw/poll constants from script_component.hpp.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_overlays_fnc_destinationDisplay
 *
 * Public: No
 */

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — selection sync + draw handler + snapshot receiver
// ─────────────────────────────────────────────────────────────────────────────
if (hasInterface) then {

    // Engine planningMode → short label. Keys are normalized (uppercase,
    // spaces stripped) because the engine reports e.g. "LEADER PLANNED" at
    // runtime while the wiki documents "LeaderPlanned".
    GVAR(destModeLabels) = createHashMapFromArray [
        ["LEADERPLANNED",      LLSTRING(ModePlanned)],
        ["LEADERDIRECT",       LLSTRING(ModeDirect)],
        ["FORMATIONPLANNED",   LLSTRING(ModeFormation)],
        ["DONOTPLAN",          LLSTRING(ModeDirect)],
        ["DONOTPLANFORMATION", LLSTRING(ModeFormation)]
    ];

    addMissionEventHandler ["Draw3D", {
        if (!GVAR(destEnabled)) exitWith {};

        // The live selection drives the watch set: sync on change (covers
        // select, deselect and Zeus closing, which reads as an empty selection).
        // Watched entities are hulls — crews resolve to their vehicle; the
        // server re-resolves whoever steers it every tick, so seat changes
        // between selection syncs stay covered.
        private _inZeus = !isNull (findDisplay 312);
        private _sel = if (_inZeus) then { SELECTED_OBJECTS } else { [] };
        if (_sel isNotEqualTo GVAR(destSelection)) then {
            GVAR(destSelection) = _sel;
            private _units = [];
            {
                if (!isNull _x) then { _units pushBackUnique (vehicle _x) };
            } forEach _sel;
            GVAR(destWatchedUnits) = createHashMapFromArray (_units apply { [netId _x, true] });
            // Deselected units' lines drop on the spot rather than after a tick.
            GVAR(destDisplay) = GVAR(destDisplay) select {
                (netId (_x select 0)) in GVAR(destWatchedUnits)
            };
            [QGVAR(destWatch), [player, _units]] call CBA_fnc_serverEvent;
        };

        // Curator-view overlay only — never bleed into first person / plain map.
        if (!_inZeus) exitWith {};
        if (GVAR(destDisplay) isEqualTo []) exitWith {};

        private _camPos = positionCameraToWorld [0, 0, 0];
        private _mouse  = getMousePosition;

        {
            _x params ["_unit", "_dest", "_label"];
            if (isNull _unit || { !alive _unit }) then { continue };

            // Anchor on the vehicle so mounted crews draw from the hull, and read
            // the position live each frame — only the destination is snapshotted.
            private _veh     = vehicle _unit;
            private _from    = (getPosATLVisual _veh) vectorAdd [0, 0, 0.5];
            private _camDist = _camPos distance _from;
            if (_camDist > MAX_DRAW_DIST && { _camPos distance _dest > MAX_DRAW_DIST }) then { continue };

            // The unit keeps walking between server ticks — drop the line once it
            // has effectively arrived rather than drawing a stub to its feet.
            private _distLeft = _veh distance _dest;
            if (_distLeft < ARRIVE_RADIUS) then { continue };
            private _destLift = _dest vectorAdd [0, 0, 0.1];

            // Distant overlays recede instead of stacking into clutter.
            private _alpha = linearConversion [FADE_NEAR, MAX_DRAW_DIST, _camDist, 1, 0.3, true];
            private _color = [1, 1, 1, _alpha];
            drawLine3D [_from, _destLift, _color];

            // Label only near the cursor — a screenful of distance readouts is noise.
            private _text = "";
            private _scr  = worldToScreen _destLift;
            if (_scr isNotEqualTo [] && { _mouse distance2D _scr < LABEL_CURSOR_RADIUS }) then {
                _text = format ["%1m — %2", floor _distLeft, _label];
            };

            private _iconSize = if (GVAR(destGrowWithSpeed)) then {
                linearConversion [0, ICON_SPEED_MAX, speed _veh, ICON_SIZE_MIN, ICON_SIZE_MAX, true]
            } else {
                ICON_SIZE_FIXED
            };
            drawIcon3D [
                [ICON_VEHICLE, ICON_FOOT] select (_veh isKindOf "CAManBase"),
                _color,
                _destLift,
                _iconSize, _iconSize, 0,
                _text,
                1, LABEL_TEXT_SIZE, LABEL_FONT
            ];
        } forEach GVAR(destDisplay);
    }];

    // Full snapshot from the server. Filter and format ONCE here rather than per
    // frame: drop units deselected while the snapshot was in flight, and bake the
    // pathing-mode label (distance changes every frame, so it stays in the loop).
    [QGVAR(destUpdate), {
        params ["_entries"];
        private _display = [];
        {
            _x params ["_unit", "_dest", "_mode", "_forceReplan"];
            if (isNull _unit) then { continue };
            if !((netId _unit) in GVAR(destWatchedUnits)) then { continue };

            private _key   = toUpper (_mode splitString " " joinString "");
            private _label = GVAR(destModeLabels) getOrDefault [_key, _mode];
            if (_forceReplan) then {
                _label = format ["%1 (%2)", _label, LLSTRING(ModeReplanning)];
            };
            _display pushBack [_unit, _dest, _label];
        } forEach _entries;
        GVAR(destDisplay) = _display;
    }] call CBA_fnc_addEventHandler;
};

if (!isServer) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — watcher registry + destination poll loop
// ─────────────────────────────────────────────────────────────────────────────

// Subscribed curators: player netId → [player, units, sentEmpty] where units is
// the client's resolved selection (replaced wholesale on every selection change)
// and sentEmpty flags that the last snapshot sent was empty — the client is
// already clear, so consecutive empties are skipped.
GVAR(destWatchers) = createHashMap;

// Replace-set semantics: the client sends its full resolved selection whenever
// it changes; an empty set unsubscribes.
[QGVAR(destWatch), {
    params ["_player", "_units"];
    if (isNull _player) exitWith {};
    private _pk = netId _player;
    _units = _units select { !isNull _x };
    if (_units isEqualTo []) exitWith {
        if (_pk in GVAR(destWatchers)) then {
            GVAR(destWatchers) deleteAt _pk;
            // Final empty snapshot so the client's overlay clears immediately.
            [QGVAR(destUpdate), [[]], _player] call CBA_fnc_targetEvent;
        };
    };
    // sentEmpty=false so a fresh subscription always gets at least one snapshot.
    GVAR(destWatchers) set [_pk, [_player, _units, false]];
}] call CBA_fnc_addEventHandler;

// Unscheduled per-frame handler (RTZ server-loop convention) rather than a
// spawned while/sleep: no scheduler starvation. Ticks at POLL_TICK and
// self-gates on the live GVAR(pollInterval) setting, so admins can retune the
// cadence mid-mission. Bails cheaply when nobody is subscribed; no suspending
// commands in the body.
[{
    (_this select 0) params ["_nextRun"];
    if (CBA_missionTime < _nextRun) exitWith {};
    (_this select 0) set [0, CBA_missionTime + ((GETGVAR(pollInterval,2)) max POLL_TICK)];
    if (count GVAR(destWatchers) == 0) exitWith {};

    private _toDrop = [];
    {
        // _x = player netId (key), _y = [player, units, sentEmpty] (value).
        _y params ["_player", "_units", "_sentEmpty"];
        // Disconnected players can't receive targetEvents — drop them here so
        // a vanished watcher can never null-error the send below.
        if (isNull _player) then { _toDrop pushBack _x; continue };

        private _entries = [];
        // A watched man may have mounted a watched vehicle since the selection
        // sync — both resolve to the same hull, which moves as one.
        private _vehSeen = createHashMap;
        {
            if (isNull _x || { !alive _x }) then { continue };
            private _veh = vehicle _x;
            private _vk  = netId _veh;
            if (_vk in _vehSeen) then { continue };
            _vehSeen set [_vk, true];

            // Only whoever steers owns a path: a man on foot is his own pilot;
            // a vehicle paths through its effective commander (an empty
            // vehicle has nobody, so it drops out). Player judgement isn't AI
            // state, and expectedDestination is only meaningful where the
            // pathing unit is local — skips remote-controlled and HC-offloaded.
            private _pathUnit = if (_veh isKindOf "CAManBase") then { _veh } else { effectiveCommander _veh };
            if (isNull _pathUnit || { isPlayer _pathUnit } || { !local _pathUnit }) then { continue };

            (expectedDestination _pathUnit) params ["_dest", "_mode", "_forceReplan"];
            if (_dest isEqualTo [0, 0, 0]) then { continue };            // no plan at all
            private _dist = _veh distance _dest;
            if (_dist < ARRIVE_RADIUS) then { continue };                // idle / arrived
            if (_dist > KNOWLEDGE_MAX_DIST) then { continue };

            _entries pushBack [_x, _dest, _mode, _forceReplan];
        } forEach _units;

        // One empty snapshot clears the client; resending "nothing to draw"
        // every tick while the units idle is wasted traffic.
        if (_entries isNotEqualTo [] || { !_sentEmpty }) then {
            [QGVAR(destUpdate), [_entries], _player] call CBA_fnc_targetEvent;
            _y set [2, _entries isEqualTo []];
        };
    } forEach GVAR(destWatchers);

    { GVAR(destWatchers) deleteAt _x } forEach _toDrop;
}, POLL_TICK, [0]] call CBA_fnc_addPerFrameHandler;
