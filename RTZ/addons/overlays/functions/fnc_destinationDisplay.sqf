#include "script_component.hpp"
/*
 * rtz_fnc_destinationDisplay
 *
 * Renders the expected movement destination of the units the local curator has
 * SELECTED while the overlay is toggled on (FUNC(destinationToggle)): a white
 * line from the unit to its destination plus a move icon, labelled with
 * distance and pathing mode when the cursor is near it — modelled on the LAMBS
 * Danger debug renderer (lambs_main_fnc_debugDraw, RenderExpectedDestination).
 *
 * The watch set follows the live Zeus selection: selecting units draws their
 * destinations, deselecting removes them, closing Zeus counts as an empty
 * selection. The toggle is just a master switch for this behaviour.
 *
 * Locality: expectedDestination reads AI pathing state, which only exists on
 * the machine that owns the unit (LAMBS and Zeus Wargame both only read it
 * unit-locally). Normal AI is server-local, so the SERVER polls destinations
 * for each curator's watched units and streams per-curator snapshots via
 * CBA_fnc_targetEvent; units that are not server-local (Zeus remote control,
 * headless clients) are skipped. Per-curator streams also keep it PvP-fair —
 * a Zeus can only watch units they can select, i.e. their own.
 *
 * Requirements: CBA_A3 (drawing needs no ZEN, but toggling does — see
 * FUNC(destinationContext)).
 * Loading: spawned from XEH_postInit after CBA_settingsInitialized, gated on
 * GVAR(enableDestinationDisplay). Self-guards locality like the main addon's
 * spottingSystem. Client state containers come from XEH_preInit.
 */

// Camera cull, matches the spotting wedge outer cap; overlays start fading at
// FADE_NEAR and bottom out at MAX_DRAW_DIST. Labels only render while the
// cursor is within LABEL_CURSOR_RADIUS of the icon (GUI screen units). Macros,
// not privates — event handler code blocks don't see this scope.
#define MAX_DRAW_DIST       2500
#define FADE_NEAR           800
#define LABEL_CURSOR_RADIUS 0.05
#define ARRIVE_RADIUS       3
#define ICON_FOOT           "\a3\ui_f\data\igui\cfg\simpletasks\types\walk_ca.paa"
#define ICON_VEHICLE        "\a3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa"
// Icon scale: foot/vehicle swap by unit type (see ICON_FOOT/ICON_VEHICLE use
// below); when GVAR(destGrowWithSpeed) is on the size ramps ICON_SIZE_MIN→
// ICON_SIZE_MAX across 0→ICON_SPEED_MAX km/h (the LAMBS debug look), otherwise
// it holds at ICON_SIZE_FIXED.
#define ICON_SPEED_MAX      30
#define ICON_SIZE_MIN       0.3
#define ICON_SIZE_MAX       0.9
#define ICON_SIZE_FIXED     0.65

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — selection sync + draw handler + snapshot receiver
// ─────────────────────────────────────────────────────────────────────────────
if (hasInterface) then {

    // Engine planningMode → short label shown next to the distance. Keys are
    // normalized (uppercase, spaces stripped) because the engine reports e.g.
    // "LEADER PLANNED" at runtime while the wiki documents "LeaderPlanned".
    GVAR(destModeLabels) = createHashMapFromArray [
        ["LEADERPLANNED",      "Planned"],
        ["LEADERDIRECT",       "Direct"],
        ["FORMATIONPLANNED",   "Formation"],
        ["DONOTPLAN",          "Direct"],
        ["DONOTPLANFORMATION", "Formation"]
    ];

    addMissionEventHandler ["Draw3D", {
        if (!GVAR(destEnabled)) exitWith {};

        // The live selection drives the watch set: sync on change (covers
        // select, deselect and Zeus closing, which reads as an empty selection).
        private _inZeus = !isNull (findDisplay 312);
        private _sel = if (_inZeus) then { SELECTED_OBJECTS } else { [] };
        if (_sel isNotEqualTo GVAR(destSelection)) then {
            GVAR(destSelection) = _sel;
            // Resolve to the units that actually own a path: a man on foot is
            // his own pilot; anything mounted or a vehicle resolves to whoever
            // steers it (an empty vehicle has nobody, so it drops out).
            private _units = [];
            {
                if (!isNull _x) then {
                    private _veh  = vehicle _x;
                    private _unit = if (_veh isKindOf "CAManBase") then { _veh } else { effectiveCommander _veh };
                    if (!isNull _unit) then { _units pushBackUnique _unit };
                };
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

            // Foot/vehicle texture swaps by unit type; the size only ramps
            // with speed when the curator opts in (GVAR(destGrowWithSpeed)).
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
                1, 0.03, "RobotoCondensed"
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
            if (_forceReplan) then { _label = _label + " (replanning)"; };
            _display pushBack [_unit, _dest, _label];
        } forEach _entries;
        GVAR(destDisplay) = _display;
    }] call CBA_fnc_addEventHandler;
};

if (!isServer) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — watcher registry + destination poll loop
// ─────────────────────────────────────────────────────────────────────────────

private _CHECK_INTERVAL = 2;   // Seconds between snapshots. Destinations replan
                               // constantly in contact; 2 s tracks that without
                               // flooding the network (one event/watcher/tick).

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

// Unscheduled per-frame handler (RTZ server-loop convention, cf.
// remoteControlIndicator) rather than a spawned while/sleep: no scheduler
// starvation, and the send cadence is exactly _CHECK_INTERVAL. Bails cheaply
// when nobody is subscribed.
[{
    if (count GVAR(destWatchers) == 0) exitWith {};

    private _toDrop = [];
    {
        // _x = player netId (key), _y = [player, units, sentEmpty] (value).
        _y params ["_player", "_units", "_sentEmpty"];
        // Disconnected players can't receive targetEvents — drop them here so
        // a vanished watcher can never null-error the send below.
        if (isNull _player) then { _toDrop pushBack _x; continue };

        private _entries = [];
        {
            if (isNull _x || { !alive _x }) then { continue };
            if (isPlayer _x) then { continue };
            // expectedDestination is only meaningful where the unit is
            // local; skips remote-controlled and HC-offloaded units.
            if (!local _x) then { continue };
            // Crews follow their vehicle's path, so only whoever steers it
            // draws. The client resolves selections the same way, but seats
            // can change between selection syncs.
            private _veh = vehicle _x;
            if (_veh != _x && { _x != effectiveCommander _veh }) then { continue };

            (expectedDestination _x) params ["_dest", "_mode", "_forceReplan"];
            if (_dest isEqualTo [0, 0, 0]) then { continue };            // no plan at all
            if (_x distance _dest < ARRIVE_RADIUS) then { continue };    // idle / arrived
            if (_x distance _dest > 6000) then { continue };            // LAMBS sanity cap

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
}, _CHECK_INTERVAL] call CBA_fnc_addPerFrameHandler;
