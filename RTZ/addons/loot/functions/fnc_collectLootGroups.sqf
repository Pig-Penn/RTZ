#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the groups a loot order can actually reach: those
 * with at least one live, dismounted AI unit able to walk over and loot. Shared by
 * the context menu condition (FUNC(canLoot)) and its statement (FUNC(orderLoot)) so
 * the entry can never offer an order that resolves to nothing.
 *
 * Locality is deliberately NOT filtered here - this runs on the curator's client,
 * where a server-owned unit is never local. FUNC(lootSquads) drops non-local units
 * on the machine that actually runs the errand.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 * 1: Hovered Entity <OBJECT> (default: objNull)
 *
 * Return Value:
 * Groups <ARRAY of GROUP>
 *
 * Example:
 * [_objects, _hoveredEntity] call rtz_loot_fnc_collectLootGroups
 *
 * Public: No
 */

params ["_objects", ["_hoveredEntity", objNull]];

([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) select {
    (units _x) findIf {alive _x && {!isPlayer _x} && {isNull objectParent _x}} != -1
}
