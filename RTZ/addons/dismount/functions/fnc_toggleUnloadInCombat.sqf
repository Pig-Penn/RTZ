#include "script_component.hpp"
/*
 * Author: Maxim
 * Flips the resolved selection between vanilla bail-out and locked-in, driving
 * the whole set to one state. Reports the new state as a toast.
 *
 * Arguments:
 * 0: Objects from curatorSelected (hovered entity included) or a keybind handler <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_dismount_fnc_toggleUnloadInCombat
 *
 * Public: No
 */

params ["_objects"];

private _vehicles = [_objects] call FUNC(collectDismountVehicles);
if (_vehicles isEqualTo []) exitWith {
    [LLSTRING(MsgNoVehicleSelected)] call zen_common_fnc_showMessage;
};

// Any-unlocked wins: while a single vehicle in the set can still bail out, the
// click locks all of them; only an already-fully-locked set is released. Reading
// the state off _vehicles select 0 instead made a mixed selection depend on
// whichever vehicle ZEN happened to list first — and hovering reorders that.
// FUNC(dismountActionModifier) applies the same rule, so the label on the menu
// entry always predicts what the click does.
private _newAllow = (_vehicles findIf {_x getVariable [QGVAR(unloadInCombat), true]}) == -1;
[_vehicles, _newAllow] call FUNC(setUnloadInCombat);

private _msg = [LLSTRING(MsgDismountForbidden), LLSTRING(MsgDismountAllowed)] select _newAllow;
if (count _vehicles > 1) then { _msg = format ["%1  x%2", _msg, count _vehicles]; };
[_msg] call zen_common_fnc_showMessage;
