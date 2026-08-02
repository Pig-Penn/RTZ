#include "script_component.hpp"
/*
 * Author: Maxim
 * Does this selection contain anything the surrender toggle can act on?
 * Condition for the context action (CfgContext.hpp).
 *
 * Deliberately NOT `FUNC(collectSurrenderUnits) isNotEqualTo []`, which is what
 * this used to be. ZEN builds the context menu by running every action's
 * modifier and then its condition, so a curator with a company selected paid two
 * full passes over the selection — each allocating a list — every time he opened
 * the menu, to answer a question that the first eligible unit settles. findIf
 * stops there.
 *
 * Arguments:
 * 0: Objects from a ZEN action's selection + hovered entity <ARRAY>
 *
 * Return Value:
 * At least one unit can be toggled <BOOL>
 *
 * Example:
 * [_objects] call rtz_captive_fnc_canSurrender
 *
 * Public: No
 */

params ["_objects"];

// The type screen has to come first: a hovered group or waypoint arrives here
// through the same array, and isKindOf inside the macro type-errors on those.
(_objects findIf {_x isEqualType objNull && {CAN_SURRENDER(_x)}}) > -1
