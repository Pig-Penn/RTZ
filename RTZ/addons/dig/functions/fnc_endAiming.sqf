#include "script_component.hpp"
/*
 * Author: Maxim
 * Closes the drawing session. The single exit path: commit, right-click, Escape and
 * the curator display closing under the session all route through here.
 *
 * That concentration is the point. A session leaves two pieces of state behind it —
 * four handlers on the curator display and one renderer on rtz_core's shared frame
 * loop — and both outlive the session, for the rest of the mission, if any single
 * exit forgets them.
 *
 * The handler ids removed are the ones FUNC(handleAimInput) reported, never
 * displayRemoveAllEventHandlers: ZEN has its own handlers on the same display and
 * they must survive this.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_dig_fnc_endAiming
 *
 * Public: No
 */

if (GVAR(aiming) isEqualTo []) exitWith {};

private _handlers = GVAR(aiming) select AIM_HANDLERS;

// Cleared BEFORE the handlers are removed, so a handler that fires during removal
// sees a closed session rather than a half-torn-down one.
GVAR(aiming) = [];

// Hand ZEN's pickers back. Cleared outright rather than restored to a remembered
// value: FUNC(beginAiming) refuses to open while ZEN's picker is active, so this
// was false before that session set it. Past the early exit above, so a call with
// no session open cannot clear a flag it does not own.
zen_common_selectPositionActive = false;

private _display = findDisplay IDD_RSCDISPLAYCURATOR;

if (!isNull _display) then {
    {
        _x params ["_type", "_id"];
        _display displayRemoveEventHandler [_type, _id];
    } forEach _handlers;
};

[QGVAR(aim), RENDER_WORLD] call EFUNC(core,unregisterRenderer);
