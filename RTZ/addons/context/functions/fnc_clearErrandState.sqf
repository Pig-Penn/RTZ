#include "script_component.hpp"
/*
 * rtz_fnc_clearErrandState
 *
 * SERVER: release errand units back to their group and wipe the transient state
 * stashed on the lead unit. Shared tail of both assemble paths
 * (FUNC(assembleWeaponFinalize)) and both disassemble paths
 * (FUNC(disassembleFinalize)), which previously duplicated this block: drop the
 * LAMBS force-move flag, restore stance and rejoin formation for every unit that
 * is still alive and on foot, then nil the given variables on the first unit.
 *
 * Parameters:
 *   0: Array — errand units (gunner first — the variable owner; objNull entries ok)
 *   1: Array — variable names to nil on the first unit (default [])
 */

params ["_units", ["_varNames", []]];

{
    if (!isNull _x) then {
        _x setVariable ["lambs_danger_forceMove", nil];
        if (alive _x && {isNull objectParent _x}) then {
            _x setUnitPosWeak "AUTO";
            _x doFollow (leader _x);
        };
    };
} forEach _units;

private _owner = _units param [0, objNull];
if (!isNull _owner) then {
    { _owner setVariable [_x, nil] } forEach _varNames;
};
