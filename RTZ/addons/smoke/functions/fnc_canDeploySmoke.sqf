#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a deploy-countermeasures order is possible: the selection resolves
 * to at least one vehicle with a countermeasure weapon. Drives the visibility
 * of the context menu action (CfgZenContext.hpp), which ZEN evaluates on
 * right-click rather than per frame.
 *
 * FUNC(findCountermeasureWeapons) is called in first-hit mode, so the
 * per-menu-open scan stops at the first countermeasure weapon found.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 * 1: Hovered Entity <OBJECT>
 *
 * Return Value:
 * Order Possible <BOOL>
 *
 * Example:
 * [_objects, _hoveredEntity] call rtz_smoke_fnc_canDeploySmoke
 *
 * Public: No
 */

params ["_objects", "_hoveredEntity"];

([_objects + [_hoveredEntity]] call EFUNC(common,collectVehicles)) findIf {
    ([_x, true] call FUNC(findCountermeasureWeapons)) isNotEqualTo []
} != -1
