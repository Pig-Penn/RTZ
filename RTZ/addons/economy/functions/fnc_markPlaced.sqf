#include "script_component.hpp"
/*
 * Author: Maxim
 * Marks what a curator has just placed as paid for, which is what makes it
 * refundable when it is deleted again (see FUNC(refundDeleted)). Registered on
 * both CuratorObjectPlaced and CuratorGroupPlaced, whose arguments differ only
 * in whether the second element is an object or a group.
 *
 * The engine bills a placement against the cost table this component builds but
 * reports nothing about what it charged, so "paid for" has to be inferred from
 * the placement event rather than read back. Everything else a curator can
 * delete — mission-placed units, script-spawned units, and every corpse and
 * wreck the fighting leaves behind — never carries the mark, and so can never
 * be sold back.
 *
 * Public rather than local: the curator who deletes an object is often not the
 * one who placed it, and FUNC(refundDeleted) runs on the deleting curator's
 * machine.
 *
 * Arguments:
 * 0: Curator module <OBJECT>
 * 1: Placed object <OBJECT> or group <GROUP>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_curator, _entity] call rtz_economy_fnc_markPlaced
 *
 * Public: Yes
 */

params ["", "_entity"];

// A group placement is billed per unit and refunded per unit, so it is marked
// per unit as well. CuratorObjectPlaced does not fire for the members.
if (_entity isEqualType grpNull) exitWith {
    {
        _x setVariable [QGVAR(paid), true, true];
    } forEach units _entity;
};

if (isNull _entity) exitWith {};

_entity setVariable [QGVAR(paid), true, true];
