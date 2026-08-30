#include "script_component.hpp"
/*
 * Author: Maxim
 * Closes a placement session, optionally moving the units first.
 *
 * EVERY exit path routes through here rather than tearing down in place: the
 * second Shift + T, Enter, Escape, and Zeus closing out from under the session.
 * Anything less and a session ended the unusual way leaks its display handlers,
 * leaves its ghost models and Logic helpers in the world, and wedges
 * GVAR(placing) true — after which the mode can never be opened again, and ZEN's
 * own pickers and context menu stay stood down for the rest of the mission.
 *
 * Order matters. GVAR(placing) is cleared FIRST, so any handler that fires
 * during the removals below sees a closed session and declines. The commit runs
 * BEFORE GVAR(ghosts) is emptied, because that array is what it reads. The ghost
 * models and helpers are deleted last, after nothing can still be looking at
 * them. rtz_path's endPlanning sequences its teardown the same way.
 *
 * Safe to call on an already-closed session: the guard below makes a second call
 * a no-op, which is what lets FUNC(placeTick) call it on the same frame a
 * handler already did.
 *
 * Arguments:
 * 0: Move the units to their ghosts <BOOL> (default: false — cancel)
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call rtz_place_fnc_endPlacement
 *
 * Public: No
 */

params [["_commit", false, [false]]];

if (!GVAR(placing)) exitWith {};

// First, so anything firing during the teardown below sees a closed session
GVAR(placing) = false;
GVAR(grabbed) = -1;
GVAR(hovered) = -1;

// Before GVAR(ghosts) is emptied — this is the array it reads
if (_commit) then {
    call FUNC(commitPlacement);
};

// Remove the PFH by stored id, and reset the sentinel so a stale handle can
// never be removed twice
if (GVAR(placePfh) != -1) then {
    [GVAR(placePfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(placePfh) = -1;
};

[QGVAR(ghosts), RENDER_WORLD] call EFUNC(core,unregisterRenderer);

// One at a time, by stored id. NEVER displayRemoveAllEventHandlers: ZEN has its
// own handlers on this same display and they must survive this session.
private _display = findDisplay IDD_RSCDISPLAYCURATOR;
if (!isNull _display) then {
    {
        _x params ["_type", "_id"];
        _display displayRemoveEventHandler [_type, _id];
    } forEach GVAR(inputEHs);
};
GVAR(inputEHs) = [];

// Both, always. The model is attached to the helper, but attachment does not
// make deleting the parent delete the child — a helper deleted on its own leaves
// a simulation-disabled copy of a soldier standing in the world for the rest of
// the mission, invisible to Zeus because it was never curator-editable.
{
    _x params ["", "_helper", "_model"];
    deleteVehicle _model;
    deleteVehicle _helper;
} forEach GVAR(ghosts);
GVAR(ghosts) = [];

// Cleared outright rather than restored to a remembered value: the entry guard in
// FUNC(beginPlacement) refuses to start while ZEN's picker is active, so this was
// false before this session set it.
zen_common_selectPositionActive = false;
