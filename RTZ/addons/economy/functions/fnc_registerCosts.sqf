#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds the curator cost table for the CuratorObjectRegistered event.
 * The engine calls this with every CfgVehicles class each time a player
 * enters the curator interface, so costs always follow the current settings.
 *
 * Mission makers can override single classes (in points), either by filling
 * the table the component already created:
 * rtz_economy_overrides set ["B_Soldier_F", 2];
 *
 * or by replacing it wholesale:
 * missionNamespace setVariable [
 *     "rtz_economy_overrides",
 *     createHashMapFromArray [["B_Soldier_F", 2]]
 * ];
 *
 * Keys are matched case-insensitively (see FUNC(getCost)).
 *
 * Arguments:
 * 0: Curator module <OBJECT>
 * 1: Class names <ARRAY of STRING>
 *
 * Return Value:
 * Cost entries, [show, cost] or [show, cost, costWithCrew] per class <ARRAY>
 *
 * Example:
 * [_curator, ["B_Soldier_F"]] call rtz_economy_fnc_registerCosts
 *
 * Public: No
 */

params ["", "_classes"];

// Read once rather than per class: this walks every CfgVehicles class.
private _hide = GVAR(cleanModuleTree);
private _costFree = !GVAR(enable);

// if/then/else rather than exitWith: exitWith inside an apply block yields no
// value at all, leaving a nil element the engine then ignores. Same family as
// the exitWith-in-forEach trap in docs/Knowledge Base/Gotchas.md §2.
//
// A vehicle costs the same placed with or without its crew, so a single
// cost (charged for both cases by the engine) is enough for every class.
// Hiding wins over cost: a hidden module has no cost to show.
_classes apply {
    private _class = _x;

    if (_hide && {(toLowerANSI _class) in HIDDEN_MODULES}) then {
        [false, 0]
    } else {
        [true, if (_costFree) then {0} else {(_class call FUNC(getCost)) / POINTS_MAX}]
    }
}
