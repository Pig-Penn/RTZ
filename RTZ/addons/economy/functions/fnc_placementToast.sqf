#include "script_component.hpp"
/*
 * Author: Maxim
 * Shows a Zeus feedback message with the cost of the class the curator has
 * just selected for placement. Attached as a TreeSelChanged handler to every
 * create tree whose leaves are single CfgVehicles classes (IDCS_CREATE_TREES);
 * group, module and marker placement has no such class and is never hooked.
 *
 * Arguments:
 * 0: Create tree <CONTROL>
 * 1: Path of the newly selected entry <ARRAY of NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrlTree, [0, 1, 2]] call rtz_economy_fnc_placementToast
 *
 * Public: No
 */

if (!GVAR(enable) || {!GVAR(placementToast)}) exitWith {};

params ["_ctrlTree", "_path"];

private _class = _ctrlTree tvData _path;

// Category nodes carry no data, and the recent tree also lists groups and markers
if (_class isEqualTo "") exitWith {};
if (!isClass (configFile >> "CfgVehicles" >> _class) || {_class isKindOf "Logic"}) exitWith {};

[str (_class call FUNC(getCost))] call zen_common_fnc_showMessage;
