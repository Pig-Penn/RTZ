#include "script_component.hpp"
/*
 * rtz_fnc_attackOrderApply
 *
 * Handler body for QGVAR(attackOrder) (registered on EVERY machine in
 * XEH_postInit). Orders each group to destroy the target: reveals the target
 * to every unit (accuracy 4 — without it the AI silently ignores orders
 * against an unseen target) and adds a DESTROY waypoint attached to the
 * target, made current so it overrides the group's existing plan.
 * waypointAttachVehicle keeps the waypoint tracking a moving target and
 * auto-completes it when the target dies. Waypoint commands must run where
 * the group is local, so the sender targets the event at the groups and this
 * filters the batch down to the ones local to this machine. Each group's
 * previous attack waypoint (if any, tracked via QGVAR(attackWp)) is deleted
 * first, so repeated orders don't pile up stale DESTROY waypoints over a
 * long session.
 *
 * Parameters:
 *   0: Array — groups to order (whole selection; non-local entries skipped)
 *   1: Object — target unit or vehicle
 */
params ["_grps", "_target"];

if (isNull _target || { !alive _target }) exitWith {};

{
    private _grp = _x;
    if (!isNull _grp && { local _grp }) then {
        { _x reveal [_target, 4] } forEach units _grp;

        // A stored waypoint is just [group, index]: after the old DESTROY waypoint
        // auto-completed (target died) or the list was cleared (LAMBS taskReset),
        // the index can point at a DIFFERENT waypoint — or none. Only delete when
        // it still is the DESTROY waypoint we placed; anything else is skipped
        // (the variable is overwritten below either way).
        private _oldWp = _grp getVariable QGVAR(attackWp);
        if (!isNil "_oldWp" && { waypointType _oldWp == "DESTROY" }) then { deleteWaypoint _oldWp };

        private _wp = _grp addWaypoint [getPosATL _target, 0];
        _wp setWaypointType "DESTROY";
        _wp waypointAttachVehicle _target;
        _wp setWaypointBehaviour "COMBAT";
        _wp setWaypointCombatMode "RED";
        _grp setCurrentWaypoint _wp;
        _grp setVariable [QGVAR(attackWp), _wp];
    };
} forEach _grps;
