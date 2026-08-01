#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(delete) (server only). Deletes the objects and hands
 * the groups they emptied to FUNC(cleanupGroupsApply).
 *
 * Deleting through the Zeus interface refunds a share of the placement cost
 * (rtz_economy's "delete" curator coefficient, see EFUNC(economy,applyCoefs));
 * a scripted deleteVehicle goes around that system entirely, so this action is
 * free by construction. The points are snapshotted and restored on the next
 * frame anyway, so the curators' bars stay put no matter what the engine
 * credits for a removal — one allCurators pass per action, not per object.
 *
 * Arguments:
 * 0: Objects to delete <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_targets] call rtz_delete_fnc_deleteApply
 *
 * Public: No
 */

params ["_targets"];

private _points = allCurators apply { [_x, curatorPoints _x] };

private _groups = [];
{
    if (!isNull _x) then {
        private _group = group _x;
        if (!isNull _group) then { _groups pushBackUnique _group };

        deleteVehicle _x;
    };
} forEach _targets;

// Groups emptied by the deletion would otherwise linger against the engine's
// per-side group cap. deleteGroup needs the group local and Zeus places units
// local to the curator who placed them, so these usually belong to a client —
// broadcast and let each machine sweep its own (see FUNC(cleanupGroupsApply)).
if (_groups isNotEqualTo []) then {
    [QGVAR(cleanupGroups), [_groups]] call CBA_fnc_globalEvent;
};

[{
    {
        _x params ["_curator", "_before"];
        if (!isNull _curator) then {
            _curator addCuratorPoints (_before - curatorPoints _curator);
        };
    } forEach _this;
}, _points] call CBA_fnc_execNextFrame;
