#include "script_component.hpp"
/*
 * Author: Maxim
 * Release errand units back to their group and wipe the transient state
 * stashed on the lead unit. Shared tail of the build (FUNC(finishBuild)) and pack
 * (FUNC(finishPack)) paths: drop the LAMBS force move flag, restore stance and
 * rejoin formation for every unit still alive and on foot, then nil the given
 * variables on the first unit.
 *
 * Arguments:
 * 0: Errand Units <ARRAY of OBJECT> - the first entry owns the variables, objNull
 *    entries are skipped
 * 1: Variable Names to clear on the first unit <ARRAY of STRING> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [[_gunner, _assistant], [QGVAR(buildCtx)]] call rtz_assemble_fnc_clearErrand
 *
 * Public: No
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
    {
        _owner setVariable [_x, nil];
    } forEach _varNames;
};
