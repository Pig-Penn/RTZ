#include "script_component.hpp"
/*
 * Author: Maxim
 * Closes the route planning session and returns every resource it took: the
 * tick, the curator-display handlers, and the soft hold on any unit that was
 * frozen for the duration.
 *
 * Safe to call when no session is open, and safe to call from inside the tick —
 * removing a per-frame handler from within its own body is legal in CBA and is
 * how rtz_reverse's engine takes itself down.
 *
 * Every exit path routes through here rather than tearing down in place, which
 * is what makes "Zeus closed under us" and "the curator pressed Escape" the same
 * code. Anything less and a session ended the unusual way leaks its display
 * handlers and wedges GVAR(planning) true, after which the mode can never be
 * opened again.
 *
 * Arguments:
 * 0: Order the routes that were drawn, rather than discarding them <BOOL>
 *    (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [true] call rtz_route_fnc_endPlanning
 *
 * Public: No
 */

params [["_execute", false, [false]]];

if (!GVAR(planning)) exitWith {};

GVAR(planning) = false;

// Committed BEFORE the session state is cleared — FUNC(commitRoutes) reads
// GVAR(routes), and every path out of here below empties it
private _ordered = if (_execute) then {call FUNC(commitRoutes)} else {0};

GVAR(routes) = [];
GVAR(grabbed) = objNull;
GVAR(hovered) = objNull;
GVAR(hoveredPoint) = [];
GVAR(mods) = [false, false, false];

if (GVAR(planPfh) != -1) then {
    [GVAR(planPfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(planPfh) = -1;
};

// With every renderer gone the frame loop never builds a camera basis, which is
// what makes a closed session cost nothing rather than a little
[QGVAR(routes3D), RENDER_WORLD] call EFUNC(core,unregisterRenderer);

// Removed by id, one at a time. The display may already be gone — Zeus closing
// is one of the ways a session ends — in which case its handlers went with it.
private _display = findDisplay IDD_RSCDISPLAYCURATOR;
if (!isNull _display) then {
    {
        _display displayRemoveEventHandler _x;
    } forEach GVAR(inputEHs);

    if (GVAR(mapEH) != -1) then {
        private _mapCtrl = _display displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP;
        if (!isNull _mapCtrl) then {
            _mapCtrl ctrlRemoveEventHandler ["Draw", GVAR(mapEH)];
        };
    };
};
GVAR(inputEHs) = [];
GVAR(mapEH) = -1;

// Release exactly the units this session held, from a recorded list rather than
// by re-reading the setting: an admin toggling it mid-session would otherwise
// leave the selection stopped with nothing left to release it.
{
    [QGVAR(hold), [_x, false], _x] call CBA_fnc_targetEvent;
} forEach GVAR(held);
GVAR(held) = [];

// A session closed with nothing drawn reports as cancelled whichever key closed
// it, because that is what happened
if (_ordered > 0) then {
    [LLSTRING(MsgExecuting), _ordered] call EFUNC(common,showCountMessage);
} else {
    [LLSTRING(MsgCancelled)] call EFUNC(common,showCountMessage);
};
