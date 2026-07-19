#include "script_component.hpp"
/*
 * rtz_control_fnc_lambsResetApply
 *
 * Handler body for QGVAR(lambsReset) (registered on EVERY machine in
 * XEH_postInit). Clears the LAMBS Danger FSM state of each group via
 * lambs_wp_fnc_taskReset, which must run where the group is local. The client
 * action (FUNC(lambsReset)) sends one event TARGETED AT THE GROUPS;
 * CBA delivers it once per owning machine, so this filters the batch down to
 * the groups local to this machine and ignores the rest.
 *
 * taskReset is a whole-group soft reset [_grp, true, true]: units keep their
 * group, and on every non-player member it re-enables all AI subsystems, resets
 * stance (setUnitPos AUTO) and speed (forceSpeed -1), re-animates to an idle
 * stand, doFollows the leader, clears the group's waypoints (CBA_fnc_clearWaypoints
 * — which also drops any RTZ attackOrder DESTROY waypoint) and nils LAMBS' own
 * danger vars. Calling it directly is the full LAMBS reset, inherited verbatim.
 *
 * But taskReset knows nothing about the state RTZ layers on top: it wipes the
 * LAMBS bail-out guard, which would silently re-enable dismount-in-combat on
 * dismount-locked vehicles. So once it returns, every locked vehicle in the
 * group is re-tagged in the same synchronous pass (the units are local here,
 * same as the group — no flicker). A plain getVariable read defaulting to
 * false, so it costs nothing and no-ops when the feature is off.
 *
 * Parameters:
 *   0: Array — groups to reset (whole selection; non-local entries skipped)
 */
params ["_grps"];
{
    private _grp = _x;
    if (!isNull _grp && { local _grp }) then {
        [_grp, true, true] call lambs_wp_fnc_taskReset;

        // Re-lock dismount-locked vehicles — taskReset wiped the guard that
        // holds their crew in place; re-apply the lock (idempotent, re-tags the
        // occupants) on every locked vehicle in the group.
        private _vehs = [];
        {
            private _v = objectParent _x;
            if (!isNull _v) then { _vehs pushBackUnique _v };
        } forEach units _grp;
        {
            if !(_x getVariable [QEGVAR(dismount,unloadInCombat), true]) then {
                [QEGVAR(dismount,applyUnloadFlags), [_x, false], _x] call CBA_fnc_targetEvent;
            };
        } forEach _vehs;
    };
} forEach _grps;
