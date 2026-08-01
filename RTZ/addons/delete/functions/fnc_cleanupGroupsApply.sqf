#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(cleanupGroups) (registered on EVERY machine in
 * XEH_postInit). Deletes the groups in the batch that are local here and have
 * been left empty by a deletion, ignoring the rest.
 *
 * Empty groups are not free: they count against the engine's per-side group cap
 * (144), and a curator who spends a session cleaning up wrecks and bodies can
 * exhaust it — after which nothing on that side can be placed at all. deleteGroup
 * only works where the group is local, and Zeus places units local to the curator
 * who placed them, so most of the groups a deletion empties belong to a client,
 * not the server. The server therefore broadcasts the whole batch and every
 * machine filters it down to its own.
 *
 * Arguments:
 * 0: Groups to consider (whole batch; non-local entries skipped) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_groups] call rtz_delete_fnc_cleanupGroupsApply
 *
 * Public: No
 */

params ["_grps"];

_grps = _grps select { !isNull _x && { local _x } };
if (_grps isEqualTo []) exitWith {};

// Deferred: the deletions are issued on the server and land here a network tick
// later, so counting members right now would still see them and skip a group
// that is about to be empty. See GROUP_CLEANUP_DELAY.
[{
    {
        if (!isNull _x && { units _x isEqualTo [] }) then { deleteGroup _x };
    } forEach _this;
}, _grps, GROUP_CLEANUP_DELAY] call CBA_fnc_waitAndExecute;
