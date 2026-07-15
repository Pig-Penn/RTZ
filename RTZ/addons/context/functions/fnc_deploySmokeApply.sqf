#include "script_component.hpp"
/*
 * rtz_fnc_deploySmokeApply
 *
 * Handler body for QGVAR(deploySmoke) (registered on EVERY machine in
 * XEH_postInit). Fires one of the vehicle's countermeasure weapons
 * (FUNC(findCountermeasureWeapons)) via BIS_fnc_fire. Firing needs vehicle
 * locality, so the sender targets the event at the vehicles and this filters
 * to the ones local to this machine.
 *
 * Parameters:
 *   0: Array — vehicles to fire (whole selection; non-local entries skipped)
 */

params ["_vehs"];

{
    if (!isNull _x && { local _x }) then {
        private _weapons = [_x] call FUNC(findCountermeasureWeapons);
        if (_weapons isNotEqualTo []) then {
            [_x, selectRandom _weapons] call BIS_fnc_fire;
        };
    };
} forEach _vehs;
