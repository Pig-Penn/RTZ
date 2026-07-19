#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds the curator cost table for the CuratorObjectRegistered event.
 * The engine calls this with every CfgVehicles class each time a player
 * enters the curator interface, so costs always follow the current settings.
 *
 * Mission makers can override single classes (in points) with:
 * missionNamespace setVariable [
 *     "rtz_economy_overrides",
 *     createHashMapFromArray [["B_Soldier_F", 2]]
 * ];
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

// Disabled: keep the full asset tree and make everything free
if (!GVAR(enable)) exitWith {_classes apply {[true, 0]}};

// A vehicle costs the same placed with or without its crew, so a single
// cost (charged for both cases by the engine) is enough for every class
_classes apply {[true, (_x call FUNC(getCost)) / POINTS_MAX]}
