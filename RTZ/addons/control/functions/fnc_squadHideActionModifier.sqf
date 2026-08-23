#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the squad hide/freeze toggle (see
 * CfgContext.hpp). Sets the action's label, icon and tint to reflect the
 * selection's state:
 *   anything under Dynamic Simulation → blue   "Disable Dynamic Simulation"
 *   visible                           → orange "Disable Simulation"
 *   hidden                            → green  "Enable Simulation"
 *
 * Dynamic Simulation is only ever turned on by mission placement in the
 * editor, never at runtime, so an entity either starts under it or never is —
 * this branch is checked first and, once cleared, never resurfaces.
 *
 * The check runs over GROUPS AND VEHICLES alike, because Arma flags Dynamic
 * Simulation on each separately (FUNC(collectHideEntities)): a crewed vehicle
 * can be simulated while its crew's group is not, and reading only the group
 * hid that state from the curator entirely.
 *
 * Arguments:
 * 0: The action array (mutated in place) <ARRAY>
 * 1: Selection objects + hovered entity (pre-combined by the caller) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_control_fnc_squadHideActionModifier
 *
 * Public: No
 */

params ["_action", "_objects"];

private _entities = [_objects] call FUNC(collectHideEntities);
if (_entities isEqualTo []) exitWith {};

// findIf, not select: this only needs to know whether anything is still
// simulated, and it short-circuits on the first hit. FUNC(squadHideToggle)
// applies the same predicate to build the batch it clears.
if (_entities findIf {dynamicSimulationEnabled _x && {!(_x getVariable [QGVAR(dynSimDisabled), false])}} != -1) exitWith {
    SET_ACTION(_action,LLSTRING(ActionDisableDynamicSimulation),ICON_SHOW,COLOR_DYNSIM);
};

// Groups first, so a mixed selection reports its infantry's state — the same
// entity FUNC(squadHideToggle) derives the new state from. With no group at all
// — a crewless vehicle on its own — the first vehicle carries the variable
// itself, set by FUNC(squadHideApply). Mirrors the toggle exactly; see the note
// there on why `param` with a default is wrong for a mixed-type array.
private _grps = _entities select {_x isEqualType grpNull};
private _first = if (_grps isEqualTo []) then {_entities select 0} else {_grps select 0};

private _hidden = _first getVariable [QGVAR(squadHidden), false];
if (_hidden) then {
    // green — currently hidden, will restore
    SET_ACTION(_action,LLSTRING(ActionEnableSimulation),ICON_SHOW,COLOR_SHOW);
} else {
    // orange — will hide & freeze
    SET_ACTION(_action,LLSTRING(ActionDisableSimulation),ICON_HIDE,COLOR_HIDE);
};
