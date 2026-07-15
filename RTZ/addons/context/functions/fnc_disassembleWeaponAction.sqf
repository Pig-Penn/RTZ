#include "script_component.hpp"
/*
 * rtz_fnc_disassembleWeaponAction
 *
 * Context-menu statement: packs every selected manned static weapon back into
 * the backpacks its crew carries. The deleteVehicle / moveOut / addBackpackGlobal
 * calls must run where the units are local (the server, for AI in Zeus PvP), so
 * each set is dispatched there via CBA_fnc_serverEvent (QGVAR(disassembleWeaponApply),
 * registered in XEH_postInit). Mirror of FUNC(assembleWeaponAction).
 *
 * Parameters:
 *   0: Array — selection objects (curatorSelected + hovered entity)
 */

params ["_objects"];
private _sets = [_objects] call FUNC(collectDisassembleSets);
if (_sets isEqualTo []) exitWith {
    ["Select a manned static weapon to disassemble"] call zen_common_fnc_showMessage;
};

// Append the ordering curator's player so the server can toast failures back.
{ [QGVAR(disassembleWeaponApply), _x + [player]] call CBA_fnc_serverEvent; } forEach _sets;

private _msg = "Disassembling";
if (count _sets > 1) then { _msg = format ["%1  x%2", _msg, count _sets]; };
[_msg] call zen_common_fnc_showMessage;
