#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the vehicles the dismount lock can actually act
 * on: EFUNC(common,collectVehicles) (a selected man resolves to the vehicle he
 * is in, a selected vehicle is itself) minus static weapons, which have no
 * cargo to hold in place and no bail-out behaviour to suppress.
 *
 * Single source of truth for the context action: its condition, statement and
 * modifierFunction all go through here, so the three can never disagree about
 * which vehicles a click will touch. Callers pass the hovered entity in with the
 * selection (`_objects + [_hoveredEntity]`); collectVehicles drops objNull and
 * non-object entries itself.
 *
 * Arguments:
 * 0: Selected objects, hovered entity included <ARRAY>
 *
 * Return Value:
 * Unique non-static vehicles <ARRAY>
 *
 * Example:
 * [_objects + [_hoveredEntity]] call rtz_control_fnc_collectDismountVehicles
 *
 * Public: No
 */

params ["_objects"];

([_objects] call EFUNC(common,collectVehicles)) select {!(_x isKindOf "StaticWeapon")}
