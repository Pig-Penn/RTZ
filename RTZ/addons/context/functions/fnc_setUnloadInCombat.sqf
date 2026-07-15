#include "script_component.hpp"
/*
 * rtz_fnc_setUnloadInCombat
 *
 * Pushes a chosen allow-state to vehicles, routing the apply event to each
 * vehicle's locality owner so setUnloadInCombat / allowCrewInImmobile run
 * where they are authoritative.
 *
 * Parameters:
 *   0: Array   — vehicle objects to update
 *   1: Boolean — true = vanilla bail-out; false = crew/cargo stay put
 */
params ["_vehicles", "_allow"];
{
    SETPVAR(_x,GVAR(unloadInCombat),_allow);                   // public, JIP-consistent intent
    [QGVAR(applyUnloadFlags), [_x, _allow], _x] call CBA_fnc_targetEvent;   // runs where the vehicle is local
} forEach _vehicles;
