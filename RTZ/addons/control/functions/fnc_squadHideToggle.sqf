#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement for the squad hide/freeze action. If the FIRST
 * selected group is still under the editor-placed Dynamic Simulation system,
 * this click turns that off instead — see FUNC(squadHideActionModifier) for
 * why that check comes first and why it only ever fires once per group.
 * Otherwise it flips the "hidden & frozen" state of every group in the
 * selection, reading the current state from the FIRST group and applying the
 * inverse uniformly to all of them (matching the label shown by the
 * modifier).
 *
 * The actual enableDynamicSimulation / hideObjectGlobal / enableSimulationGlobal
 * calls must run on the server, so the work is dispatched there via
 * CBA_fnc_serverEvent (QGVAR(disableDynamicSimulation) / QGVAR(squadHide),
 * both registered in XEH_postInit) as ONE event carrying the whole group
 * array — a selection box over a company used to send one packet per group.
 * The server also broadcasts the per-group state variables so every client's
 * modifier reads the correct label.
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
private _grps = [_objects] call EFUNC(common,collectSquads);
if (_grps isEqualTo []) exitWith {
    [LLSTRING(MsgNoUnitsSelected)] call zen_common_fnc_showMessage;
};

private _grp = _grps select 0;

if (dynamicSimulationEnabled _grp && {!(_grp getVariable [QGVAR(dynSimDisabled), false])}) exitWith {
    [QGVAR(disableDynamicSimulation), [_grps]] call CBA_fnc_serverEvent;
    [LLSTRING(MsgDynamicSimulationDisabled), count _grps] call EFUNC(common,showCountMessage);
};

// New state derived from the first group, so a mixed selection follows the
// label the curator just clicked.
private _hide = !(_grp getVariable [QGVAR(squadHidden), false]);

[QGVAR(squadHide), [_grps, _hide]] call CBA_fnc_serverEvent;

private _msg = [LLSTRING(MsgSimulationEnabled), LLSTRING(MsgSimulationDisabled)] select _hide;
[_msg, count _grps] call EFUNC(common,showCountMessage);
