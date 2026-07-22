#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the unique list of men who can surrender: AI
 * only (the apply event runs on the unit's owner machine, so a player here
 * would have his controls seized), alive, conscious, on foot (not mounted —
 * forcing the hands-up pose on a seat makes no sense), and not already taken
 * prisoner (a captured unit is permanently out of its former curator's
 * hands). A selected man contributes himself; a selected vehicle contributes
 * any dismounted crew (nothing, in practice, since crew is by definition
 * mounted — mirrors EFUNC(common,collectUnits)'s expansion shape, with the
 * extra AI/alive/foot/uncaptured filters this feature needs on top).
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
    // Skip non-objects (a hovered group/waypoint can arrive here via a modifier).
    if (_x isEqualType objNull) then {
        private _cands = if (_x isKindOf "CAManBase") then { [_x] } else { crew _x };
        {
            if (
                alive _x
                && {!isPlayer _x}
                && {lifeState _x isNotEqualTo "INCAPACITATED"}
                && {isNull objectParent _x}
                && {!(_x getVariable [QGVAR(captured), false])}
            ) then {
                _units pushBackUnique _x;
            };
        } forEach _cands;
    };
} forEach _objects;

_units
