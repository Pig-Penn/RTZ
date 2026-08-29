#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the AI units qualified to run a specialist errand:
 * alive, on foot, not a player and not led by one, holding one of the required
 * unit traits AND carrying one of the required items. Shared filter behind
 * rtz_repair's engineers and rtz_mine's mine layers, which previously
 * each carried their own copy of it.
 *
 * The selection goes through FUNC(collectUnits) first, so a selected VEHICLE
 * contributes its crew — pick a squad's truck and its dismounting engineer still
 * qualifies for the order.
 *
 * Both lists are OR'd within themselves and AND'd against each other: rtz_repair's
 * repairmen need the engineer trait AND a toolkit. An empty list is
 * treated as "no requirement" so a caller can filter on traits alone.
 *
 * Locality is deliberately NOT filtered — this runs on the curator's client,
 * where a server-owned AI unit is never local. The order itself is targeted at
 * each unit's own machine (see rtz_loot's collectLootGroups for the same note).
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 * 1: Required Unit Traits <ARRAY of STRING> — any one qualifies (default [])
 * 2: Required Items <ARRAY of STRING> — any one qualifies (default [])
 *
 * Return Value:
 * Qualified units <ARRAY of OBJECT>
 *
 * Example:
 * [_objects, ["engineer"], ["ToolKit"]] call rtz_common_fnc_collectSpecialists
 *
 * Public: No
 */

params [["_objects", [], [[]]], ["_traits", [], [[]]], ["_items", [], [[]]]];

([_objects] call FUNC(collectUnits)) select {
    private _unit = _x;

    alive _unit && {isNull objectParent _unit}
    && {!isPlayer _unit} && {!isPlayer (leader _unit)}
    && {_traits isEqualTo [] || {_traits findIf {_unit getUnitTrait _x} != -1}}
    // `items` covers the uniform, vest and backpack, so a toolkit stowed in a
    // pack still counts
    && {
        _items isEqualTo [] || {
            private _carried = items _unit;
            _items findIf {_x in _carried} != -1
        }
    }
}
