#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu condition for the "Reset" action: true when the selection holds
 * at least one group with an AI member. Pure-player groups are excluded —
 * FUNC(resetApply) would leave them exactly as they are, so offering the action
 * would promise a no-op.
 *
 * Extracted from CfgContext.hpp, where it had grown into a two-branch one-liner
 * that scanned the tree-selected groups and the object-derived groups with two
 * separate copies of the same predicate.
 *
 * Arguments:
 * 0: Selection objects <ARRAY>
 * 1: ZEN's selected groups <ARRAY>
 * 2: Hovered entity <OBJECT>
 *
 * Return Value:
 * Selection has a resettable group <BOOL>
 *
 * Example:
 * [_objects, _groups, _hoveredEntity] call rtz_control_fnc_canReset
 *
 * Public: No
 */

params ["_objects", "_groups", "_hoveredEntity"];

// Short-circuits on the tree-selected groups, which cost nothing to test, so a
// right-click on a group node never pays for the object expansion at all.
if (_groups findIf {units _x findIf {!isPlayer _x} != -1} != -1) exitWith {true};

([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) findIf {
    units _x findIf {!isPlayer _x} != -1
} != -1
