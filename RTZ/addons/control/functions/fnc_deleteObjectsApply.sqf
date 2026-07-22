#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(deleteObjects) (server only). Deletes the objects and
 * cleans up the groups they emptied.
 *
 * Deleting through the Zeus interface refunds a share of the placement cost
 * (rtz_economy's "delete" curator coefficient); a scripted deleteVehicle goes
 * around that system entirely, so this action is free by construction. The
 * points are snapshotted and restored on the next frame anyway, so the
 * curators' bars stay put no matter what the engine credits for a removal.
 *
 * Arguments:
 * 0: Objects to delete <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_targets] call rtz_control_fnc_deleteObjectsApply
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

// Groups emptied by the deletion would otherwise linger against the group limit
{
    if (local _x && { units _x isEqualTo [] }) then { deleteGroup _x };
} forEach _groups;

[{
    {
        _x params ["_curator", "_before"];
        if (!isNull _curator) then {
            _curator addCuratorPoints (_before - curatorPoints _curator);
        };
    } forEach _this;
}, _points] call CBA_fnc_execNextFrame;
