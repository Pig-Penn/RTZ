#include "script_component.hpp"
/*
 * Author: Maxim
 * Applies the action cost coefficients to a curator module. Only placing
 * costs points, deleting refunds a settings-defined share of the cost and
 * every other action is free. Must be called on the server.
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
    ["delete", (GVAR(deleteRefund) / 100)]
];
