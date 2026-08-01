#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the selected units able to lay a mine: alive AI on foot, not player-led.
 * No trait or item is required — laying a mine only takes carrying one, which the
 * caller checks against the specific magazine it is offering.
 *
 * Shared by the context menu children (FUNC(placeActions)) and the order they fire
 * (FUNC(orderPlace)) so the two can never resolve to different sets — the menu
 * offering a magazine nobody in the resolved selection is actually carrying was
 * exactly the failure this consolidates away. Both used to filter the raw ZEN
 * selection themselves, which also meant a selected VEHICLE contributed nothing;
 * going through EFUNC(common,collectSpecialists) expands it to its crew, so a
 * squad's truck now offers the mines its passengers carry.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Capable units <ARRAY of OBJECT>
 *
 * Example:
 * [_objects] call rtz_mine_fnc_getLayers
 *
 * Public: No
 */

params [["_objects", [], [[]]]];

[_objects] call EFUNC(common,collectSpecialists)
