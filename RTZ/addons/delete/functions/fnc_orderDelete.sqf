#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: deletes every object in the selection, corpses and
 * wrecks included.
 *
 * deleteVehicle has a global effect but is only reliable from the machine
 * owning the object, and the curator point safeguard needs the (server-local)
 * curator modules, so the whole selection is handed to the server via
 * QGVAR(delete) (registered in XEH_postInit).
 *
 * Shared by the context action and the Shift+Delete keybind
 * (FUNC(deleteSelected)), so both paths get the same protections.
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
 * [_objects, _groups, _hoveredEntity] call rtz_delete_fnc_orderDelete
 *
 * Public: No
 */

params ["_objects", "_groups", "_hoveredEntity"];

private _targets = [_objects + [_hoveredEntity], _groups] call FUNC(collectDeletables);
if (_targets isEqualTo []) exitWith {};

[QGVAR(delete), [_targets]] call CBA_fnc_serverEvent;

[LLSTRING(MsgDeleted), count _targets] call EFUNC(common,showCountMessage);
