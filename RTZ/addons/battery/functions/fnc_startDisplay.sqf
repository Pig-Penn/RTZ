#include "script_component.hpp"
/*
 * Author: Maxim
 * Attaches — or detaches — the counter-battery map overlay. Called when the curator
 * display opens, when the master setting changes, and whenever the curator flips
 * the overlay toggle.
 *
 * Running this IS the toggle. The handler is registered only while the overlay is
 * genuinely wanted and removed again when it is not, rather than registered once
 * and left to test a flag on every frame — which is what makes a hidden overlay
 * cost exactly zero, and why FUNC(drawMap) never re-tests its own settings. Same
 * shape as EFUNC(mine,start).
 *
 * The handler lives on a control of the curator display, so it dies with the
 * display and needs no removal on close — but its stored id does have to be
 * dropped, which is FUNC(stopDisplay)'s whole job.
 *
 * Added and removed BY ID rather than with ctrlRemoveAllEventHandlers, which would
 * take ZEN's own Draw handlers on the same map with it.
 *
 * Arguments:
 * 0: Curator Display <DISPLAY> — omitted on a setting or toggle refresh
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call rtz_battery_fnc_startDisplay
 *
 * Public: No
 */

params [["_display", displayNull]];

// Re-resolved from the display on every call rather than cached in a GVAR: a
// CONTROL cannot be serialized, and the engine warns about — and drops — any such
// handle left in the mission namespace when the mission state is saved. The lookup
// is two commands and only runs on display open, a setting change or a toggle.
if (isNull _display) then {
    _display = findDisplay IDD_RSCDISPLAYCURATOR;
};

private _mapCtrl = _display displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP;

if (isNull _mapCtrl) exitWith {};

if (GVAR(enabled) && {GVAR(visible)}) then {
    if (GVAR(mapEH) == -1) then {
        GVAR(mapEH) = _mapCtrl ctrlAddEventHandler ["Draw", {_this call FUNC(drawMap)}];
    };
} else {
    if (GVAR(mapEH) != -1) then {
        _mapCtrl ctrlRemoveEventHandler ["Draw", GVAR(mapEH)];
        GVAR(mapEH) = -1;
    };
};
