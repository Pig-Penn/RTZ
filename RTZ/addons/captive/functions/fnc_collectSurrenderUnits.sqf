#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the unique list of units the surrender toggle can
 * act on. Eligibility itself lives in CAN_SURRENDER (script_component.hpp),
 * shared with the action's condition, its modifier and the authoritative guard
 * in FUNC(surrenderApply).
 *
 * This used to expand a selected vehicle to `crew _x`, mirroring
 * EFUNC(common,collectUnits). That branch was dead code and always had been:
 * every crewman has an objectParent, which the on-foot half of CAN_SURRENDER
 * rejects — a seated unit cannot be posed with its hands up. A selected vehicle
 * therefore contributes nothing, and expanding it only bought an allocation per
 * vehicle to throw the result away.
 *
 * Arguments:
 * 0: Objects from curatorSelected / a ZEN action's selection + hovered entity <ARRAY>
 *
 * Return Value:
 * Units eligible to surrender <ARRAY>
 *
 * Example:
 * [_objects] call rtz_captive_fnc_collectSurrenderUnits
 *
 * Public: No
 */

params ["_objects"];

private _units = [];
{
    // Type screen first — a hovered group or waypoint reaches this array and
    // isKindOf inside the macro would type-error on it.
    if (_x isEqualType objNull && {CAN_SURRENDER(_x)}) then {
        // Unique: the hovered entity is appended to the selection by the caller
        // and is very often already in it.
        _units pushBackUnique _x;
    };
} forEach _objects;

_units
