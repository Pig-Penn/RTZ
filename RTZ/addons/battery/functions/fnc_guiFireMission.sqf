#include "script_component.hpp"
/*
 * Author: Maxim
 * Wrapper around ZEN's fire mission display, installed by overriding the display's
 * `function` entry in gui.hpp. Adds one Unload handler and then hands the display to
 * ZEN unchanged.
 *
 * The handler is what keeps the target list from filling up with targets nobody
 * fired at. FUNC(selectFireMission) has to create and register the target BEFORE the
 * dialog opens — a target that is not in zen_position_logics' list cannot be selected
 * in the dialog's combo — so a curator who opens the action, looks at the ETA and
 * presses Escape would otherwise leave a target behind on every attempt.
 *
 * Only GVAR(pendingTarget) is touched, so this is inert for a fire mission opened the
 * normal way, from the module tree: nothing is pending, and the handler returns
 * immediately. One variable rather than a registry is enough because a display is
 * modal — the curator cannot have two fire mission dialogs open at once.
 *
 * ZEN's own early exits (no unit, not artillery, no gunners) close the display with
 * IDC_CANCEL, which is the correct verdict here too: no mission was ordered, so the
 * target goes.
 *
 * Arguments:
 * 0: Display <DISPLAY>
 * 1: Logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display, _logic] call rtz_battery_fnc_guiFireMission
 *
 * Public: No
 */

params ["_display"];

_display displayAddEventHandler ["Unload", {
    params ["", "_exitCode"];

    private _target = GVAR(pendingTarget);
    if (isNull _target) exitWith {};

    GVAR(pendingTarget) = objNull;

    // Confirmed: the guns have been given the target, and it stays in the list as a
    // named target the curator can fire at again without picking it a second time.
    if (_exitCode == IDC_OK) exitWith {};

    // Not a bare deleteVehicle: by now initModule has moved the logic into one of
    // BI's function-module groups from the server, so it is not safe to assume it is
    // still local to the curator who picked it. FUNC(discardTarget) routes to
    // whichever machine owns it. ZEN's list keeps the emptied slot until the server's
    // own Deleted handler runs, but zen_position_logics_fnc_get filters nulls, so
    // neither the combo nor the index lookup ever sees it.
    [_target] call FUNC(discardTarget);
}];

_this call zen_modules_fnc_gui_fireMission
