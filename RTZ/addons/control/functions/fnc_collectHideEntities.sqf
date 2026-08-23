#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the entities the hide/freeze action acts on.
 *
 * Arma tracks Dynamic Simulation per ENTITY — CfgDynamicSimulation carries
 * separate "Group", "Vehicle" and "EmptyVehicle" categories — so a vehicle
 * holds its own flag, independent of whatever its crew's group holds.
 * Resolving the selection to groups alone (which this action used to do) left
 * every vehicle dynamically simulated no matter how often the curator clicked,
 * and left a crewless vehicle with no action at all.
 *
 * The list is deliberately MIXED and flat: dynamicSimulationEnabled and
 * enableDynamicSimulation both take an Object or a Group, so the whole batch
 * can be tested and cleared uniformly. Vehicles come first, then groups, so the
 * order is stable; callers that need the two kinds apart split on
 * `isEqualType grpNull`.
 *
 * Single source of truth for the context action: its condition, statement and
 * modifierFunction all go through here, so the three can never disagree about
 * what a click will touch — see FUNC(collectDismountVehicles) for why that
 * matters. Callers pass the hovered entity in with the selection
 * (`_objects + [_hoveredEntity]`); the common collectors drop objNull and
 * non-object entries themselves.
 *
 * Arguments:
 * 0: Selected objects, hovered entity included <ARRAY>
 *
 * Return Value:
 * Unique vehicles followed by unique groups <ARRAY>
 *
 * Example:
 * [_objects + [_hoveredEntity]] call rtz_control_fnc_collectHideEntities
 *
 * Public: No
 */

params ["_objects"];

// pushBack, not pushBackUnique: the two collectors return disjoint types, so no
// group can already be in the vehicle list.
private _entities = [_objects] call EFUNC(common,collectVehicles);
{ _entities pushBack _x } forEach ([_objects] call EFUNC(common,collectSquads));

_entities
