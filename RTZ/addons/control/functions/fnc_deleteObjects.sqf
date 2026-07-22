#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: deletes every object in the selection, corpses and
 * wrecks included.
 *
 * deleteVehicle has a global effect but is only reliable from the machine
 * owning the object, and the curator point safeguard needs the (server-local)
 * curator modules, so the whole selection is handed to the server via
 * QGVAR(deleteObjects) (registered in XEH_postInit).
 *
 * Arguments:
 * 0: Selection objects <ARRAY>
 * 1: Selection groups <ARRAY>
 * 2: Hovered entity <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects, _groups, _hoveredEntity] call rtz_control_fnc_deleteObjects
 *
 * Public: No
 */

params ["_objects", "_groups", "_hoveredEntity"];

private _targets = [_objects + [_hoveredEntity], _groups] call FUNC(collectDeletables);
if (_targets isEqualTo []) exitWith {};

[QGVAR(deleteObjects), [_targets]] call CBA_fnc_serverEvent;

private _msg = LLSTRING(MsgDeleted);
if (count _targets > 1) then { _msg = format ["%1  x%2", _msg, count _targets]; };
[_msg] call zen_common_fnc_showMessage;
