#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a loot order is possible: the selection resolves to at least one squad with
 * a dismounted AI unit AND something lootable sits within GVAR(radius) of that squad's
 * leader. Drives the visibility of the context menu action, which ZEN evaluates on
 * right-click rather than per frame.
 *
 * Deliberately OPTIMISTIC. This asks only whether there is anything in reach at all,
 * not whether any particular unit would take something from it - that is
 * FUNC(lootPlan)'s question, it costs far more to answer, and FUNC(lootSquads) asks it
 * before anyone is actually sent walking. Being slightly generous here keeps the menu
 * responsive; being strict there is what stops a squad crossing a field for nothing.
 *
 * The scan behind this is memoized for SCAN_CACHE_TTL, so repeated right-clicks on a
 * stationary selection cost one sweep rather than one per open, and the findIf stops
 * at the first group that has something in reach.
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
    ([leader _x, _radius] call FUNC(collectLootables)) isNotEqualTo []
} != -1
