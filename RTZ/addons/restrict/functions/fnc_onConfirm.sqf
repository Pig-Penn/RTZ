#include "script_component.hpp"
/*
 * Author: Maxim
 * Per-row confirm hook installed by FUNC(gateDisplay), and the point where the
 * servicing restriction is actually enforced.
 *
 * zen_attributes_fnc_confirm runs each row as
 *
 *     _controlsGroup call (_controlsGroup getVariable ["...fnc_onConfirm", {}]);
 *     private _value = _controlsGroup getVariable "zen_attributes_value";
 *     if (!isNil "_value" && {_entity call _condition}) then {...call _statement};
 *
 * so dropping the pending value here refuses this row and only this row —
 * ZEN's statement never runs, and every ungated row on the same window still
 * applies normally. Because it runs at confirm rather than at open, a zone lost
 * while the window sat open is caught.
 *
 * Arguments:
 * 0: Attribute row controls group <CONTROL> (passed as _this by ZEN)
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctrlGroup call rtz_restrict_fnc_onConfirm
 *
 * Public: No
 */

// ZEN calls this as `_controlsGroup call _fnc_onConfirm`, so _this is the
// control itself rather than an array around it
private _ctrlGroup = _this;

// Whatever handler this row already had gets the first word — it is what turns
// control state into the pending value we then decide on. Called bare so it
// still sees the controls group as _this.
call (_ctrlGroup getVariable [QGVAR(chained), {}]);

// Row was left untouched, so there is nothing to refuse
private _value = _ctrlGroup getVariable ZEN_VAR_VALUE;
if (isNil "_value") exitWith {};

if ([_ctrlGroup getVariable [QGVAR(scope), -1]] call FUNC(canEdit)) exitWith {};

_ctrlGroup setVariable [ZEN_VAR_VALUE, nil];

// One message per confirm rather than one per refused row: a window with
// health, fuel, ammo and skill all changed would otherwise stack four identical
// toasts. Every row of a confirm is processed inside the same frame.
if (GVAR(blockedFrame) == diag_frameNo) exitWith {};
GVAR(blockedFrame) = diag_frameNo;

[LSTRING(MsgOutsideZone)] call zen_common_fnc_showMessage;
