#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(refund) (server only). Prices a batch of deleted
 * classes and credits the curator with the settings-defined share of it.
 *
 * The classes arrive from the deleting curator's machine (FUNC(refundDeleted));
 * the price and the share are read here, so the size of a refund is the
 * server's to decide rather than a client's to claim.
 *
 * Arguments:
 * 0: Curator module <OBJECT>
 * 1: Class names of the deleted objects <ARRAY of STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_curator, ["B_Soldier_F"]] call rtz_economy_fnc_refundApply
 *
 * Public: No
 */

params ["_curator", "_classes"];

if (isNull _curator) exitWith {};
if (!GVAR(enable) || {GVAR(deleteRefund) <= 0}) exitWith {};

private _refund = 0;
{
    _refund = _refund + (_x call FUNC(getCost));
} forEach _classes;

_refund = _refund * (GVAR(deleteRefund) / 100);
if (_refund <= 0) exitWith {};

// Points, not the engine's normalized scale, and capped at a full bar there
[_curator, _refund] call FUNC(addPoints);
