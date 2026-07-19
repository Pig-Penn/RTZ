#include "script_component.hpp"
/*
 * Author: Maxim
 * Shows a Zeus feedback message with the cost of the class the curator has
 * selected for placement. Runs as a per-frame handler tick while the curator
 * display is open; group, module and marker placement have no single
 * CfgVehicles class and are ignored.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_economy_fnc_placementToast
 *
 * Public: No
 */

if (!GVAR(enable) || {!GVAR(placementToast)}) exitWith {};

if (!(call zen_common_fnc_isPlacementActive)) exitWith {GVAR(toastClass) = ""};

// Only the unit and recent trees hold one placeable class per entry
RscDisplayCurator_sections params ["_mode"];
if !(_mode in [CURATOR_MODE_UNITS, CURATOR_MODE_RECENT]) exitWith {GVAR(toastClass) = ""};

private _ctrlTree = call zen_common_fnc_getActiveTree;
private _class = _ctrlTree tvData (tvCurSel _ctrlTree);

if (_class isEqualTo GVAR(toastClass)) exitWith {};
GVAR(toastClass) = _class;

// The recent tree also lists groups, modules and markers
if (!isClass (configFile >> "CfgVehicles" >> _class) || {_class isKindOf "Logic"}) exitWith {};

[str (_class call FUNC(getCost))] call zen_common_fnc_showMessage;
