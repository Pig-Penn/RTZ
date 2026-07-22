#include "script_component.hpp"
/*
 * Author: Maxim
 * Pushes a chosen allow-state to vehicles, routing the apply event to each
 * vehicle's locality owner so setUnloadInCombat / allowCrewInImmobile run
 * where they are authoritative.
 *
 * Arguments:
 * 0: Vehicle objects to update <ARRAY>
 * 1: True for vanilla bail-out, false to make crew/cargo stay put <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicles, false] call rtz_dismount_fnc_setUnloadInCombat
 *
 * Public: No
 */
params ["_vehicles", "_allow"];
{
    SETPVAR(_x,GVAR(unloadInCombat),_allow);                   // public, JIP-consistent intent
    [QGVAR(applyUnloadFlags), [_x, _allow], _x] call CBA_fnc_targetEvent;   // runs where the vehicle is local
} forEach _vehicles;
