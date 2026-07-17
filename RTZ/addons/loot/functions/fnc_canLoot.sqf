#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a loot order is possible: the selection resolves to at least one squad
 * with a dismounted AI unit AND something lootable sits within GVAR(radius) of that
 * squad's leader. Drives the visibility of the context menu action, which ZEN
 * evaluates on right-click rather than per frame.
 *
 * FUNC(collectLootables) is called with a limit of 1, so the per-menu-open scan
 * stops at the first hit.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 * 1: Hovered Entity <OBJECT>
 *
 * Return Value:
 * Order Possible <BOOL>
 *
 * Example:
 * [_objects, _hoveredEntity] call rtz_loot_fnc_canLoot
 *
 * Public: No
 */

params ["_objects", "_hoveredEntity"];

if (!GVAR(enabled)) exitWith {false};

private _radius = GVAR(radius);

([_objects, _hoveredEntity] call FUNC(collectLootGroups)) findIf {
    ([getPosATL leader _x, _radius, 1] call FUNC(collectLootables)) isNotEqualTo []
} != -1
