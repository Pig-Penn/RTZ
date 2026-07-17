#include "script_component.hpp"
/*
 * rtz_control_fnc_lambsResetApply
 *
 * Handler body for QGVAR(lambsReset) (registered on EVERY machine in
 * XEH_postInit). Clears the LAMBS Danger FSM state of each group via
 * lambs_wp_fnc_taskReset, which must run where the group is local. The client
 * action (FUNC(lambsResetContext)) sends one event TARGETED AT THE GROUPS;
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
 * But taskReset knows nothing about the states RTZ layers on top, and its
 * blanket enableAI / setUnitPos / playMove silently un-does three of them. So
 * once it returns we restore what a reset should NOT have disturbed, in the same
 * synchronous pass (the units are local here, same as the group — no flicker):
 *   1. Vehicle dismount locks (EGVAR(dismount,unloadInCombat)) — taskReset wipes the LAMBS
 *      bail-out guard, which would silently re-enable dismount-in-combat; re-tag
 *      every locked vehicle in the group.
 *   2. Surrendered / captured units (EGVAR(captive,surrendered) — captured units
 *      keep that flag set) — re-assert setCaptive + AI-lock + hands-up pose so
 *      prisoners stay prisoners. Mirrors the surrender branch of
 *      EFUNC(captive,surrenderApply), but deliberately does NOT re-stamp
 *      surrenderTime, so the stand-down lock window is preserved, not extended.
 *   3. Downed casualties (EGVAR(casualty,isCasualty)) — re-assert unconscious +
 *      setCaptive + AI-off (mirrors EFUNC(casualty,makeCasualty)) so a reset does
 *      not animate a body; the casualty manager would re-heal this within a tick,
 *      but restoring it here avoids the visible twitch.
 * All three are plain getVariable reads defaulting to false, so they cost nothing
 * and no-op when the feature is off or its addon absent — context takes no hard
 * dependency on captive/casualty and stays a leaf below them.
 *
 * Parameters:
 *   0: Array — groups to reset (whole selection; non-local entries skipped)
 */
params ["_grps"];
{
    private _grp = _x;
    if (!isNull _grp && { local _grp }) then {
        [_grp, true, true] call lambs_wp_fnc_taskReset;

        private _units = units _grp;

        // (1) Re-lock dismount-locked vehicles — taskReset wiped the guard that
        // holds their crew in place; re-apply the lock (idempotent, re-tags the
        // occupants) on every locked vehicle in the group.
        private _vehs = [];
        {
            private _v = objectParent _x;
            if (!isNull _v) then { _vehs pushBackUnique _v };
        } forEach _units;
        {
            if !(_x getVariable [QEGVAR(dismount,unloadInCombat), true]) then {
                [QEGVAR(dismount,applyUnloadFlags), [_x, false], _x] call CBA_fnc_targetEvent;
            };
        } forEach _vehs;

        // (2) + (3) Re-assert curator-imposed incapacitation that taskReset's
        // blanket enableAI / setUnitPos / playMove just un-did, so those units end
        // up exactly as they were (as if the reset skipped them).
        {
            private _u = _x;
            if (!isPlayer _u) then {
                // Surrendered or captured — restore the surrender pose/lock. Order
                // mirrors the surrender branch of EFUNC(captive,surrenderApply);
                // surrenderTime is intentionally left alone so the stand-down lock
                // window is preserved, not reset.
                if (_u getVariable [QEGVAR(captive,surrendered), false]) then {
                    _u setCaptive true;
                    _u disableAI "MOVE";
                    _u disableAI "TARGET";
                    _u disableAI "AUTOTARGET";
                    _u disableAI "ANIM";
                    _u setUnitPos "UP";
                    _u playMoveNow "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
                };

                // Downed casualty — restore the unconscious ragdoll. Mirrors
                // EFUNC(casualty,makeCasualty).
                if (_u getVariable [QEGVAR(casualty,isCasualty), false]) then {
                    _u setCaptive true;
                    _u setUnconscious true;
                    _u disableAI "MOVE";
                    _u disableAI "AUTOTARGET";
                    _u disableAI "TARGET";
                    _u disableAI "FSM";
                    _u disableAI "PATH";
                };
            };
        } forEach _units;
    };
} forEach _grps;
