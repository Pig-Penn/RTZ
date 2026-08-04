#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(reset) (registered on EVERY machine in XEH_postInit).
 * Resets each group via lambs_wp_fnc_taskReset, which must run where the group
 * is local. The client action (FUNC(reset)) sends one event TARGETED AT THE
 * GROUPS; CBA delivers it once per owning machine, so this filters the batch
 * down to the groups local to this machine and ignores the rest.
 *
 * HARD reset — the same call LAMBS' own reset module (lambs_wp_fnc_moduleReset)
 * and its ZEN action (lambs_wp_fnc_setReset) make: taskReset with NO flags. This
 * is deliberate and is the whole point of the function. taskReset's soft mode
 * ([_grp, true, true]) leaves the units in their original group, and LAMBS' long
 * running task loops (taskHunt / taskRush / taskCreep) are scheduled waitUntil
 * loops whose ONLY exit condition is that the group has no live members —
 * they keep issuing `_group move` orders on their own cycle and silently undo a
 * soft reset seconds after it lands. The hard reset builds a new group, adopts
 * the old group's id / formation / dynamic-simulation state, joinSilents the AI
 * across and marks the old group deleteGroupWhenEmpty: the old group empties,
 * those loops see no live units and terminate for good. taskDefend / taskGarrison
 * additionally watch the waypoint count, which is why a soft reset appeared to
 * work on garrisons but never on hunt / rush.
 *
 * Consequences of the hard reset, all inherited from LAMBS by design:
 *   — Only non-player units move to the new group. A player in a mixed group is
 *     left behind in the old (now player-only) group; his AI subordinates end up
 *     in an identically named new group. LAMBS behaves the same way.
 *   — The old group and everything hung on it is discarded, so any RTZ attack
 *     order (the DESTROY waypoint from EFUNC(attack,orderDestroy)) and any
 *     per-group state — including EGVAR(orders,holdFire) fire discipline — is
 *     gone. A reset group reverts to a fresh group's defaults (behaviour AWARE).
 *   — createGroup counts against the engine's per-side group cap (144). At the
 *     cap the reset cannot build the replacement group; same exposure as LAMBS'
 *     own reset module.
 *   — taskReset nils lambs_danger_disableAI on every member, which is the lever
 *     FUNC(dismountApply) uses to hold a locked transport's cargo in place. The
 *     vehicle keeps its engine-level flags (setUnloadInCombat /
 *     allowCrewInImmobile) and its QGVAR(dismountAllowed) marker, but LAMBS'
 *     scripted force-eject is no longer suppressed until the curator re-toggles
 *     the lock.
 *
 * Waypoints are cleared up front rather than left to taskReset's _resetWaypoints
 * flag (which hard mode ignores, since it throws the group away). It costs one
 * command and it is the only thing that clears a stale attack order off the
 * remainder group when a player was in the selection.
 *
 * Arguments:
 * 0: Groups to reset (whole selection; non-local entries skipped) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_groups] call rtz_control_fnc_resetApply
 *
 * Public: No
 */

params ["_grps"];

{
    private _grp = _x;
    if (!isNull _grp && { local _grp }) then {
        // Drop the group's orders before the group itself goes away, so a
        // player left behind in the remainder group isn't still holding an RTZ
        // DESTROY waypoint. Also flips the waypoint count taskDefend /
        // taskGarrison poll, so those loops bail on their next tick.
        [_grp] call CBA_fnc_clearWaypoints;

        // Hard reset: no flags — LAMBS' module / ZEN default. Returns the new
        // group the units were carried across into; needed below to find them,
        // since after this line the old group is empty.
        private _grpNew = [_grp] call lambs_wp_fnc_taskReset;

        // taskReset does not clear the watch direction. It resets stance, speed,
        // animation, the AI subsystems and its own variables, and it doMove /
        // doFollow's everyone back into formation — but a doWatch survives all of
        // that, so the units re-form facing wherever the pre-reset task pointed
        // them and keep staring at it. LAMBS' other reset paths (tacticsGarrison,
        // tacticsHide, doAssaultUnitReset) all clear it by hand for this reason;
        // taskReset is the one that forgot, so do it here.
        //
        // objNull, not [0,0,0]: objNull hands the direction back to the unit's own
        // AI, a zero position would be a watch order pointed at the map corner.
        // lookAt as well — the head/aim look (brainHide, taskCQB, doAssault) is a
        // separate engine channel from doWatch and outlives it.
        //
        // Vehicles are watched as the vehicle, not the crewman (brainVehicle,
        // doVehicleRotate, taskAssault all target the vehicle object), so every
        // occupied vehicle in the group needs the same clear — once, not once per
        // seat.
        private _watchers = +(units _grpNew);
        {
            private _veh = objectParent _x;
            if (!isNull _veh) then { _watchers pushBackUnique _veh };
        } forEach (units _grpNew);

        {
            _x doWatch objNull;
            _x lookAt objNull;
        } forEach _watchers;
    };
} forEach _grps;
