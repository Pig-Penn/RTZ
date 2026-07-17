#include "script_component.hpp"
/*
 * rtz_control_fnc_squadHideToggle
 *
 * Context-menu statement: flips the "hidden & frozen" state of every group in
 * the selection. Reads the current state from the FIRST group and applies the
 * inverse uniformly to all of them (matching the label shown by the modifier).
 *
 * The actual hideObjectGlobal / enableSimulationGlobal calls must run on the
 * server, so the work is dispatched there via CBA_fnc_serverEvent
 * (QGVAR(squadHideApply), registered in XEH_postInit). The server also
 * broadcasts the per-group state variable so every client's modifier reads the
 * correct label.
 *
 * Parameters:
 *   0: Array — selection objects (curatorSelected + hovered entity)
 */

params ["_objects"];
private _grps = [_objects] call EFUNC(common,collectSquads);
if (_grps isEqualTo []) exitWith {
    [LLSTRING(MsgNoUnitsSelected)] call zen_common_fnc_showMessage;
};

// New state derived from the first group, so a mixed selection follows the
// label the curator just clicked.
private _hide = !((_grps select 0) getVariable [QGVAR(squadHidden), false]);

{ [QGVAR(squadHideApply), [_x, _hide]] call CBA_fnc_serverEvent; } forEach _grps;

private _msg = [LLSTRING(MsgSimulationEnabled), LLSTRING(MsgSimulationDisabled)] select _hide;
if (count _grps > 1) then { _msg = format ["%1  x%2", _msg, count _grps]; };
[_msg] call zen_common_fnc_showMessage;
