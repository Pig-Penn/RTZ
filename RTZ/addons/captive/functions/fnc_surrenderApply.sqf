#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(surrenderApply) (registered on EVERY machine in
 * XEH_postInit; the sender targets the event at the unit, so it runs where
 * the unit is local — required by setCaptive / disableAI / playMoveNow).
 * Forces one unit into, or restores it out of, a scripted surrender:
 * captive (ignored as a target), AI targeting/movement/animation disabled,
 * and the vanilla hands-up pose. disableAI "ANIM" locks the pose in place
 * without a per-frame watcher, so the feature costs nothing while active —
 * this is a one-shot state change, not a loop. Players are refused: since
 * the event lands on the unit's own machine, this would otherwise seize a
 * human's controls.
 *
 * Authoritative guards (the client-side toggle already filters, but this is
 * where the unit is local, so it has the last word): a captured prisoner can
 * never be toggled, and a stand-down inside the lock window is refused.
 * Every state flip is reported to the server's capture watch list over
 * QGVAR(registerSurrender).
 *
 * Arguments:
 * 0: Unit to toggle <OBJECT>
 * 1: True to surrender, false to restore normal AI behaviour <BOOLEAN>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, true] call rtz_captive_fnc_surrenderApply
 *
 * Public: No
 */

params ["_unit", "_surrender"];
if (isNull _unit || {!alive _unit} || {isPlayer _unit}) exitWith {};
if (_unit getVariable [QGVAR(captured), false]) exitWith {};
if (
    !_surrender
    && {CBA_missionTime - (_unit getVariable [QGVAR(surrenderTime), -1e9]) < GVAR(standDownLockTime)}
) exitWith {};

// Broadcast the unit state so every client's modifier reads the right label,
// and stamp the lock clock (CBA_missionTime is synced across machines).
SETPVAR(_unit,GVAR(surrendered),_surrender);

if (_surrender) then {
    SETPVAR(_unit,GVAR(surrenderTime),CBA_missionTime);
    _unit setCaptive true;
    _unit disableAI "MOVE";
    _unit disableAI "TARGET";
    _unit disableAI "AUTOTARGET";
    _unit disableAI "ANIM";
    _unit setUnitPos "UP";
    _unit playMoveNow "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
} else {
    SETPVAR(_unit,GVAR(surrenderTime),nil);
    _unit setCaptive false;
    _unit enableAI "MOVE";
    _unit enableAI "TARGET";
    _unit enableAI "AUTOTARGET";
    _unit enableAI "ANIM";
    _unit setUnitPos "AUTO";
    _unit switchMove "";
};

// Keep the server's capture watch list in sync — this handler runs on the
// unit's owner machine, which is not necessarily the server.
[QGVAR(registerSurrender), [_unit, _surrender]] call CBA_fnc_serverEvent;
