#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(reloadSquad) (registered on EVERY machine in
 * XEH_postInit). Orders every alive AI unit in each group to reload its
 * current weapon via the "reload" scripted command. Units with no spare
 * magazine, or with their hands full (e.g. already reloading), simply
 * ignore the command — this is a fire-and-forget order, not a queued/animated
 * sequence. The command needs unit locality, so the sender targets the event
 * at the groups and this filters to the ones local to this machine; players
 * are skipped so a curator can never force a human's reload animation.
 *
 * Arguments:
 * 0: Groups to order (whole selection; non-local entries skipped) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_groups] call rtz_control_fnc_reloadSquadApply
 *
 * Public: No
 */

params ["_grps"];

{
    if (!isNull _x && { local _x }) then {
        { if (alive _x && { !isPlayer _x }) then { reload _x } } forEach units _x;
    };
} forEach _grps;
