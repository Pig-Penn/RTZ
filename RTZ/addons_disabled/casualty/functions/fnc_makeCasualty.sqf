#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: convert a unit into a downed casualty. Called from FUNC(handleLethalDamage)
 * when the survival roll succeeds (that handler runs where the unit is local — the
 * server, for AI — so setUnconscious/disableAI are valid here).
 *
 * Sets the casualty flag (public, so clients' checks + the indicator see it), drops the
 * unit unconscious and non-combatant, records the bleed-out deadline, starts the server
 * manager loop if idle, and toasts + syncs so friendly curators see the new casualty.
 *
 * Arguments:
 * 0: The infantryman to down <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_casualty_fnc_makeCasualty
 *
 * Public: No
 */

params ["_unit"];
if (!isServer) exitWith {};
if (isNull _unit) exitWith {};
if (_unit getVariable [QGVAR(isCasualty), false]) exitWith {};

// Public so the client indicator / context condition and the HandleDamage cap on other
// machines all agree this unit is a casualty.
SETPVAR(_unit,GVAR(isCasualty),true);

// Down + out of the fight: unconscious ragdoll, non-combatant so hostiles disengage,
// AI subsystems off so the body doesn't twitch toward targets.
_unit setCaptive true;
_unit setUnconscious true;
{ _unit disableAI _x } forEach ["MOVE", "AUTOTARGET", "TARGET", "FSM", "PATH"];

private _deadline = CBA_missionTime + (GETGVAR(bleedoutTime,300));
GVAR(casualties) set [netId _unit, [_unit, _deadline, "DOWN"]];

// Record which curator commands this unit (the one who can edit it). Only that
// curator's own Medical Zone modules will count as a valid evac point for him — see
// FUNC(findSafeZone) path 3. "" if no curator owns the unit (HQ / shared markers only).
private _owner = "";
{
    private _cl = getAssignedCuratorLogic _x;
    if (!isNull _cl && {_unit in curatorEditableObjects _cl}) exitWith { _owner = netId _cl };
} forEach allPlayers;
GVAR(casualtyOwner) set [netId _unit, _owner];

// Alert friendly curators. The client handler gates on curator + friendliness and
// localizes the stringtable key it receives.
[QGVAR(casualtyToast), [LSTRING(MsgCasualtyDown), side _unit]] call CBA_fnc_globalEvent;

// Start the manager PFH if this is the first casualty; then run one pass immediately so
// the indicator appears without waiting a full tick.
if (GVAR(managerHandle) < 0) then {
    GVAR(managerHandle) = [FUNC(manageCasualties), 1, []] call CBA_fnc_addPerFrameHandler;
};
[] call FUNC(manageCasualties);
