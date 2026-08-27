#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler body for QGVAR(rcHandover) (registered in XEH_postInit). The tail of
 * FUNC(rcRebuild): hides the replacement if the original was hidden, hands it the
 * original's curators, and only THEN deletes the original.
 *
 * ALL THREE ARE SERVER COMMANDS, which is why they are one hop rather than three lines
 * back in FUNC(rcRebuild):
 *
 *   hideObjectGlobal — server-only, exactly like the enableSimulationGlobal it sits
 *     beside in FUNC(squadHideApply), and for the same reason that function is reached
 *     through a CBA_fnc_serverEvent at all. ACE3 and ZEN both wrap it in `isServer` and
 *     publish a server event for everyone else (ace_common_hideObjectGlobal /
 *     zen_common_hideObjectGlobal); Zeus Wargame's rebuild remoteExecs it to 2. Called
 *     from a curator's client — which is where a curator's own units are local, so it is
 *     the NORMAL machine for a rebuild — it does not take, and a hidden unit comes back
 *     visible to everyone.
 *
 *   grantCurators — curator modules are server-local, so EFUNC(common,grantCurators)
 *     hops here by itself when called anywhere else.
 *
 *   deleteVehicle — FUNC(rcRebuild) runs during the ownership handover a remote-control
 *     release starts, so the machine that owned the unit one frame ago may not own it
 *     the next. rtz_delete hands its whole selection to the server for this same reason.
 *
 * THE ORDER IS THE POINT. EFUNC(common,curatorsOf) reads the ORIGINAL's editable-set
 * membership, so the grant has to complete before the delete. Back in FUNC(rcRebuild)
 * those were two statements on two machines: the grant hopped here over a network
 * message while `deleteVehicle` ran on the very next line on the caller, so on the
 * common client-local path the original was already gone when this arrived,
 * `curatorsOf` matched nobody, and grantCurators' "all live curators" fallback took
 * over. Per-officer ownership did not survive a single release — it silently widened to
 * every curator in the mission, which in a multi-curator operation hands a rival Zeus
 * edit rights over units they never owned. Two statements on one machine cannot race.
 *
 * Arguments:
 * 0: Replacement unit <OBJECT>
 * 1: Original unit <OBJECT>
 * 2: Whether the original was hidden <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_new, _unit, _hidden] call rtz_control_fnc_rcHandover
 *
 * Public: No
 */

// Type-checked for the same reason FUNC(rcClaim)'s payload is: a client-fired server
// event, and a malformed one must miss its guards rather than throw past them.
params [["_new", objNull, [objNull]], ["_old", objNull, [objNull]], ["_hidden", false, [false]]];

if (!isNull _new) then {
    _new hideObjectGlobal _hidden;
};

// Runs even with the original already gone — grantCurators' documented fallback is
// every live curator, so the replacement is never left orphaned and un-editable.
[_new, _old] call EFUNC(common,grantCurators);

if (!isNull _old) then {
    deleteVehicle _old;
};
