#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement for the squad hide/freeze action. If ANY resolved
 * entity is still under the editor-placed Dynamic Simulation system, this click
 * turns that off instead — see FUNC(squadHideActionModifier) for why that check
 * comes first and why it only ever fires once per entity. Otherwise it flips the
 * "hidden & frozen" state of everything in the selection, reading the current
 * state from the first entity and applying the inverse uniformly to all of them
 * (matching the label shown by the modifier).
 *
 * "Entity" is a group OR a vehicle, because Arma flags Dynamic Simulation on
 * each separately — see FUNC(collectHideEntities). Clearing it on a crewed
 * vehicle's group alone left the vehicle itself dynamically simulated, which is
 * what made this action look inert on vehicles.
 *
 * The actual enableDynamicSimulation / hideObjectGlobal / enableSimulationGlobal
 * calls must run on the server, so the work is dispatched there via
 * CBA_fnc_serverEvent (QGVAR(disableDynamicSimulation) / QGVAR(squadHide),
 * both registered in XEH_postInit) as ONE event carrying the whole batch — a
 * selection box over a company used to send one packet per group. The server
 * also broadcasts the per-entity state variables so every client's modifier
 * reads the correct label.
 *
 * Arguments:
 * 0: Selection objects (curatorSelected + hovered entity) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_control_fnc_squadHideToggle
 *
 * Public: No
 */

params ["_objects"];

private _entities = [_objects] call FUNC(collectHideEntities);
if (_entities isEqualTo []) exitWith {
    [LLSTRING(MsgNoUnitsSelected)] call zen_common_fnc_showMessage;
};

// Every entity still under Dynamic Simulation, not just the first: a crewed
// vehicle and its crew's group are flagged independently, so both can need
// clearing on the same click. Only those are sent, so the toast reports the
// count that actually changed. Mirrors FUNC(squadHideActionModifier).
private _dynSim = _entities select {
    dynamicSimulationEnabled _x && {!(_x getVariable [QGVAR(dynSimDisabled), false])}
};
if (_dynSim isNotEqualTo []) exitWith {
    [QGVAR(disableDynamicSimulation), [_dynSim]] call CBA_fnc_serverEvent;
    [LLSTRING(MsgDynamicSimulationDisabled), count _dynSim] call EFUNC(common,showCountMessage);
};

private _grps = _entities select {_x isEqualType grpNull};
// A CREWED vehicle rides along with its crew inside FUNC(squadHideApply), which
// refuses any vehicle whose crew is not wholly in the batch; sending it here as
// well would bypass that guard and hide a vehicle around live, visible crew.
// Only crewless vehicles — which contribute no group at all — go on their own.
private _vehs = _entities select {_x isEqualType objNull && {crew _x isEqualTo []}};

// New state derived from the first group, so a mixed selection follows the
// label the curator just clicked; with no group at all — a crewless vehicle on
// its own — the first vehicle carries the state instead. Same expression as
// FUNC(squadHideActionModifier), so the label and the effect cannot disagree.
//
// Not `param` with a default: a default doubles as a TYPE check there, and a
// Group element measured against an Object default would silently hand back
// the default.
private _first = if (_grps isEqualTo []) then {_entities select 0} else {_grps select 0};
private _hide = !(_first getVariable [QGVAR(squadHidden), false]);

[QGVAR(squadHide), [_grps, _vehs, _hide]] call CBA_fnc_serverEvent;

private _msg = [LLSTRING(MsgSimulationEnabled), LLSTRING(MsgSimulationDisabled)] select _hide;
[_msg, (count _grps) + (count _vehs)] call EFUNC(common,showCountMessage);
