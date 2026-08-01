#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: flips the "hidden & frozen" state of every group in
 * the selection. Reads the current state from the FIRST group and applies the
 * inverse uniformly to all of them (matching the label shown by the modifier).
 *
 * The actual hideObjectGlobal / enableSimulationGlobal calls must run on the
 * server, so the work is dispatched there via CBA_fnc_serverEvent
 * (QGVAR(squadHide), registered in XEH_postInit) as ONE event carrying the
 * whole group array — a selection box over a company used to send one packet
 * per group. The server also broadcasts the per-group state variable so every
 * client's modifier reads the correct label.
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

// New state derived from the first group, so a mixed selection follows the
// label the curator just clicked.
private _hide = !((_grps select 0) getVariable [QGVAR(squadHidden), false]);

[QGVAR(squadHide), [_grps, _hide]] call CBA_fnc_serverEvent;

private _msg = [LLSTRING(MsgSimulationEnabled), LLSTRING(MsgSimulationDisabled)] select _hide;
[_msg, count _grps] call EFUNC(common,showCountMessage);
