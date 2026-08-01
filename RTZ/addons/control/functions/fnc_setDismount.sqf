#include "script_component.hpp"
/*
 * Author: Maxim
 * Pushes a chosen allow-state to vehicles, routing the apply event to each
 * vehicle's locality owner so setUnloadInCombat / allowCrewInImmobile run where
 * they are authoritative (see FUNC(dismountApply)).
 *
 * Arguments:
 * 0: Vehicle objects to update <ARRAY>
 * 1: True for vanilla bail-out, false to make crew/cargo stay put <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicles, false] call rtz_control_fnc_setDismount
 *
 * Public: No
 */

params ["_vehicles", "_allow"];

{
    SETPVAR(_x,GVAR(dismountAllowed),_allow);                   // public, JIP-consistent intent
    [QGVAR(dismount), [_x, _allow], _x] call CBA_fnc_targetEvent;   // runs where the vehicle is local
} forEach _vehicles;
