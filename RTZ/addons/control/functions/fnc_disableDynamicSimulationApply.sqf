#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler body for QGVAR(disableDynamicSimulation) (registered in
 * XEH_postInit). Turns off Arma's Dynamic Simulation for a batch of entities.
 * Dynamic Simulation is only ever switched on by mission placement in the
 * editor and RTZ never re-enables it, so this is a one-way action — once
 * cleared, FUNC(squadHideActionModifier) falls through to the ordinary
 * hide/freeze toggle for good.
 *
 * An entity here is a GROUP or a VEHICLE. Arma flags Dynamic Simulation per
 * entity — CfgDynamicSimulation has separate "Group", "Vehicle" and
 * "EmptyVehicle" categories — and enableDynamicSimulation takes either, so the
 * mixed batch from FUNC(collectHideEntities) is cleared in one uniform pass.
 * Clearing only the crew's group left the vehicle itself simulated.
 *
 * enableDynamicSimulation is a server-only command, so the client toggle
 * (FUNC(squadHideToggle)) dispatches here via CBA_fnc_serverEvent — one event
 * for the whole selection, hence the array rather than a single entity. The
 * state is also broadcast per-entity so every client's modifier reads the
 * right label without depending on how promptly the engine's own Dynamic
 * Simulation state propagates.
 *
 * Arguments:
 * 0: Groups and/or vehicles to disable Dynamic Simulation for <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [[_group, _vehicle]] call rtz_control_fnc_disableDynamicSimulationApply
 *
 * Public: No
 */

params ["_entities"];

{
    if (!isNull _x) then {
        _x enableDynamicSimulation false;
        SETPVAR(_x,GVAR(dynSimDisabled),true);
    };
} forEach _entities;
