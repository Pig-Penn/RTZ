#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: take one surrendered unit prisoner (called by FUNC(captureWatch)
 * when an enemy closes inside the capture radius). Capture is permanent:
 * QGVAR(captured) is broadcast so every machine's collect/apply guards lock
 * the unit out of the surrender toggle for good.
 *
 * Both sides are paid from the economy price list (EFUNC(economy,getCost) —
 * the same table placement charges from): the CAPTURING curators split half
 * the unit's value, the OWNING curators split the other half. Curator
 * ownership is resolved through curatorEditableObjects; curator modules are
 * server-local, so the direct addCuratorPoints / add-remove editable calls
 * are valid here. Control of the prisoner transfers to the capturing
 * curators — the owner lost him. A curator who somehow owns both units
 * (e.g. an admin Zeus who can edit everything) sits in both lists and
 * simply collects both halves.
 *
 * Arguments:
 * 0: The surrendered unit being captured <OBJECT>
 * 1: The enemy man who closed within the capture radius <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _capturer] call rtz_captive_fnc_captureUnit
 *
 * Public: No
 */

params ["_unit", "_capturer"];
if (_unit getVariable [QGVAR(captured), false]) exitWith {};

SETPVAR(_unit,GVAR(captured),true);
GVAR(surrenderedUnits) = GVAR(surrenderedUnits) - [_unit];

private _value = (typeOf _unit) call EFUNC(economy,getCost);
private _owners  = allCurators select { !isNull _x && {_unit in curatorEditableObjects _x} };
private _captors = allCurators select { !isNull _x && {_capturer in curatorEditableObjects _x} };

// The prisoner now belongs to the capturing side's curators.
{ _x addCuratorEditableObjects [[_unit], false] } forEach _captors;
{ _x removeCuratorEditableObjects [[_unit], false] } forEach (_owners - _captors);

private _name = ([_unit] call EFUNC(common,classInfo)) select 0;
private _payOut = {
    params ["_curators", "_msgKey"];
    if (_curators isEqualTo []) exitWith {};
    private _share = (_value * 0.5) / count _curators;
    {
        _x addCuratorPoints _share;
        private _player = getAssignedCuratorUnit _x;
        if (!isNull _player) then {
            [QGVAR(captureMsg), [_msgKey, _name, round _share], _player] call CBA_fnc_targetEvent;
        };
    } forEach _curators;
};
[_captors, LSTRING(MsgCaptured)] call _payOut;
[_owners,  LSTRING(MsgTakenPrisoner)] call _payOut;
