#include "script_component.hpp"
/*
 * Author: Maxim
 * Release errand units back to their group: drop the LAMBS force move flag, then
 * restore stance and rejoin formation for every unit still alive and on foot.
 * Shared tail of every RTZ walk errand (rtz_assemble's build/pack, rtz_mine's
 * mine laying, rtz_loot's looting), which previously each carried their own copy.
 *
 * The mirror of the setup FUNC(approach) performs — anything that function forces
 * on a unit for the duration of a walk is undone here. Extra arguments are
 * ignored, so this can be handed to FUNC(approach) directly as its onFail hook,
 * whose _args normally carry the errand's own payload after the unit.
 *
 * Arguments:
 * 0: Errand Units <ARRAY of OBJECT, or OBJECT> - objNull entries are skipped
 *
 * Return Value:
 * None
 *
 * Example:
 * [[_gunner, _assistant]] call rtz_common_fnc_clearErrand
 *
 * Public: No
 */

params ["_units"];

if (_units isEqualType objNull) then {_units = [_units]};

{
    if (!isNull _x) then {
        _x setVariable ["lambs_danger_forceMove", nil];

        if (alive _x && {isNull objectParent _x}) then {
            _x setUnitPosWeak "AUTO";
            _x doFollow (leader _x);
        };
    };
} forEach _units;
