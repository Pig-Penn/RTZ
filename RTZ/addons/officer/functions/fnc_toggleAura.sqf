#include "script_component.hpp"
/*
 * Author: Maxim
 * Toggles the command-aura state of the officers among the given objects.
 * Mirrors FUNC(toggleArea): reads the current state from the FIRST officer
 * and applies the inverse to all of them, so a mixed selection follows the
 * label the curator just clicked (see FUNC(modifyAuraAction)).
 *
 * Unlike editing areas the aura registry lives on the SERVER (FUNC(applyAura))
 * — an aura is a world effect, not per-curator state — so this dispatches one
 * request and all feedback except the local pre-check comes back via
 * EFUNC(common,notifyCurator): only the server knows whether a request applied.
 *
 * Arguments:
 * N: Objects <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_object] call rtz_officer_fnc_toggleAura
 *
 * Public: No
 */

private _officers = _this call FUNC(getOfficers);
if (_officers isEqualTo []) exitWith {};

private _enable = !GETVAR(_officers select 0,GVAR(auraActive),false);

// An officer with an editing area cannot take an aura (mutually exclusive
// zones). Areas THIS client placed are dropped here for an instant message;
// FUNC(applyAura) still enforces the rule authoritatively — another curator's
// area is only visible server-side.
if (_enable) then {
    _officers = _officers select {!(netId _x in GVAR(areas))};
};

if (_officers isEqualTo []) exitWith {
    [LSTRING(MsgAuraBlockedArea)] call zen_common_fnc_showMessage;
};

[QGVAR(applyAura), [["remove", "add"] select _enable, _officers, player]] call CBA_fnc_serverEvent;
