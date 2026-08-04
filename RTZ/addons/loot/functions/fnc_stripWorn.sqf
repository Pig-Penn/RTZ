#include "script_component.hpp"
/*
 * Author: Maxim
 * Removes one piece of WORN gear from a body, on the machine that owns it.
 *
 * Exists because the worn-gear slots have no *Global command. `removeWeaponGlobal`
 * and `removeBackpackGlobal` do the right thing from anywhere, but `removeVest`,
 * `removeHeadgear` and `removeItem` are argument-local AND effect-local, so calling
 * them against a body owned elsewhere silently does nothing. FUNC(forceTake) then
 * added the vest to the looter while the corpse kept its copy — item duplication.
 *
 * The looter is guaranteed local to the caller (FUNC(lootSquads) filters on it), but
 * the TARGET is not: bodies of AI owned by a headless client or by a player-led group
 * are local on that other machine. So only this half is routed, and the add half stays
 * with the caller — the two objects are independent, and the contents read that feeds
 * the carry-across happens before the strip is dispatched.
 *
 * Arguments:
 * 0: Target body <OBJECT>
 * 1: Kind <STRING> - the FUNC(lootPlan) step kind
 * 2: Class <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(strip), [_body, "vest", "V_PlateCarrier1_rgr"], _body] call CBA_fnc_targetEvent
 *
 * Public: No
 */

params ["_target", "_kind", "_class"];

// Ownership can change between the send and the receive, so re-check here rather
// than trusting the routing (Gotchas §1: state goes stale across a suspension).
if (isNull _target || {!local _target}) exitWith {};

switch (_kind) do {
    case "vest": {removeVest _target};
    case "headgear": {removeHeadgear _target};
    // nvg and item both hold the class in the ordinary inventory
    default {_target removeItem _class};
};
