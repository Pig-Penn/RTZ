#include "script_component.hpp"
/*
 * Author: Maxim
 * Gate in front of ZEN's Arsenal module, installed by overriding the module's
 * `function` entry in CfgVehicles.hpp. zen_modules_fnc_initModule resolves a
 * module's function through getText (configOf _logic >> "function"), so the
 * config entry is the only hook available — the function itself is compiled
 * final by CBA and cannot be wrapped by reassignment.
 *
 * The attached unit is read without consuming the logic, so an allowed
 * placement can hand the logic straight to ZEN and be indistinguishable from
 * stock. ZEN's own function deletes the logic, then owns the null, non-infantry
 * and dead cases and their messages — including a logic dropped on empty
 * ground, which has a null attachedTo and falls through to it here. Only the
 * refused path deletes the logic, because ZEN never gets to.
 *
 * Module functions run only where the logic is local, which for a Zeus-placed
 * module is the placing curator's client — so the curator FUNC(canEditEntity)
 * resolves against is the one who placed this.
 *
 * Arguments:
 * 0: Logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_logic] call rtz_restrict_fnc_moduleArsenal
 *
 * Public: No
 */

params ["_logic"];

private _unit = attachedTo _logic;

if (GVAR(arsenal) && {!isNull _unit} && {!([_unit] call FUNC(canEditEntity))}) exitWith {
    deleteVehicle _logic;

    [LSTRING(MsgOutsideZone)] call zen_common_fnc_showMessage;
};

_this call zen_modules_fnc_moduleArsenal
