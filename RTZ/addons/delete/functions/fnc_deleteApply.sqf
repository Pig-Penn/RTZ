#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(delete) (server only). Deletes the objects and hands
 * the groups they emptied to FUNC(cleanupGroupsApply).
 *
 * This action never refunds curator points, and no longer has to defend itself
 * against the engine doing so: it used to snapshot every curator's points and
 * restore them a frame later, in case a removal was credited. Nothing credits
 * it. A scripted deleteVehicle goes around the curator economy entirely, and
 * the engine's "delete" coefficient is held at zero regardless
 * (EFUNC(economy,applyCoefs)) — a Zeus-interface deletion is refunded from
 * script instead, off an event this path does not fire. The snapshot cost an
 * allCurators pass per action and would have reverted any other credit (an
 * income payout, say) that landed in the same frame.
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
