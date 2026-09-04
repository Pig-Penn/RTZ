#include "script_component.hpp"
/*
 * Author: Maxim
 * Applies the action cost coefficients to a curator module. Only placing costs
 * points; every other action, deleting included, is free to the engine. Must be
 * called on the server.
 *
 * Deleting DOES refund, but not through the engine: a coefficient prices a
 * deletion off the class alone, which makes a corpse worth exactly what the
 * living soldier cost and clearing a battlefield of enemy dead free income.
 * The refund is paid from script instead, where it can be told what deserves
 * one — see FUNC(refundDeleted).
 *
 * Arguments:
 * 0: Curator module <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_curator] call rtz_economy_fnc_applyCoefs
 *
 * Public: No
 */

params ["_curator"];

{
    _curator setCuratorCoef _x;
} forEach [
    ["place", -1],
    ["edit", 0],
    ["destroy", 0],
    ["group", 0],
    ["synchronize", 0],
    ["delete", 0]
];
