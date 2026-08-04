#include "script_component.hpp"
/*
 * Author: Maxim
 * The one per-frame handler an open planning session runs — not one per unit.
 * Created by FUNC(beginPlanning) and destroyed by FUNC(endPlanning), so the idle
 * cost between sessions is not "small", it is nothing.
 *
 * Runs at frame rate because tracing a path is a per-frame sample of the cursor.
 * Everything here that is NOT that sample is throttled to PRUNE_INTERVAL on the
 * clock carried in the handler's own argument array, the same way rtz_reverse
 * staggers its per-maneuver checks.
 *
 * Three responsibilities:
 *
 *  - Sample the cursor into the path whose handle is being dragged. Most
 *    samples are refused by FUNC(appendPoint) — that is the design, not a
 *    failure. Reading the cursor through ZEN's helper rather than screenToWorld
 *    directly is what makes tracing work on the Zeus MAP as well as in the 3D
 *    view, since that helper answers with the map position while the map is up.
 *
 *  - Notice the curator display going away. Zeus can close without any of this
 *    mode's handlers firing (its own keybind, the curator dying, remote control
 *    being taken), and a session left open then has no way to be closed. The
 *    session is CANCELLED rather than executed on that path: nothing the curator
 *    drew was confirmed, and silently ordering a selection to march because Zeus
 *    blinked is the worse failure.
 *
 *  - Drop paths whose subject stopped being pathable — killed, deleted by
 *    rtz_delete, driven off by its crew, or taken over by a player. The check is
 *    FUNC(pathKind) itself, so "still pathable" cannot drift away from the
 *    definition that admitted the unit in the first place.
 *
 * Arguments:
 * 0: Handler arguments as [nextPruneTime, previousMousePosition] <ARRAY>
 * 1: Handler id <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [rtz_path_fnc_planTick, 0, [0, [0.5, 0.5]]] call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

params ["_args"];

// Zeus closed under the session. endPlanning removes this handler.
if (isNull (findDisplay IDD_RSCDISPLAYCURATOR)) exitWith {
    [] call FUNC(endPlanning);
};

private _paths = GVAR(paths);

// Trace. The grabbed handle is held as the UNIT rather than as the record, so
// that pruning a path cannot leave a live reference to a record no longer in
// the list; the lookup that costs is a findIf over at most MAX_PATHS entries.
private _grabbed = GVAR(grabbed);
if (!isNull _grabbed) then {
    private _index = _paths findIf {(_x select PATH_UNIT) isEqualTo _grabbed};
    if (_index != -1) then {
        private _path = _paths select _index;

        // An aircraft path needs three numbers from a two-number cursor, so it
        // has a resolver of its own (FUNC(airTarget)) and needs to know how far
        // the mouse moved since the last frame to read a vertical drag.
        private _target = if ((_path select PATH_KIND) == KIND_AIR) then {
            [_path, _args select 1] call FUNC(airTarget)
        } else {
            [nil, 1] call zen_common_fnc_getPosFromScreen
        };

        [_path, _target] call FUNC(appendPoint);
    };
};

// Recorded every frame, not only while dragging: a drag that begins with the
// modifier already held would otherwise measure its first step against wherever
// the mouse was when the session opened.
_args set [1, getMousePosition];

_args params ["_pruneAt"];
if (CBA_missionTime < _pruneAt) exitWith {};
_args set [0, CBA_missionTime + PRUNE_INTERVAL];

// Backwards, so a dropped path does not disturb the indices of the ones not
// visited yet
for "_i" from (count _paths) - 1 to 0 step -1 do {
    private _path = _paths select _i;
    _path params ["_unit", "_hull"];

    if ([_hull] call FUNC(pathKind) == KIND_NONE) then {
        // A grab or hover pointing at the path being dropped has to go with it,
        // or the input handlers keep a live reference to a unit that no longer
        // has one
        if (GVAR(grabbed) isEqualTo _unit) then {GVAR(grabbed) = objNull};
        if (GVAR(hovered) isEqualTo _unit) then {GVAR(hovered) = objNull};
        if (GVAR(hoveredPoint) param [0, objNull] isEqualTo _unit) then {GVAR(hoveredPoint) = []};

        _paths deleteAt _i;
        continue;
    };

    // Re-point at whoever is driving NOW. A crew swap mid-session would
    // otherwise leave the path addressed to a man who is no longer at the
    // controls, and the order would land on someone who cannot act on it.
    private _driver = if (_hull isKindOf "CAManBase") then {_hull} else {driver _hull};
    if (_driver isNotEqualTo _unit) then {
        _path set [PATH_UNIT, _driver];
    };
};

// Last subject gone — close rather than leave an empty session running
if (_paths isEqualTo []) then {
    [] call FUNC(endPlanning);
};
