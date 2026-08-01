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
 * ownership is resolved through EFUNC(common,curatorsOf); curator modules are
 * server-local, so that lookup and the direct EFUNC(economy,addPoints) /
 * add-remove editable calls are all valid here. Control of the prisoner transfers to the capturing
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
private _owners  = [_unit] call EFUNC(common,curatorsOf);
private _captors = [_capturer] call EFUNC(common,curatorsOf);

// The prisoner now belongs to the capturing side's curators.
{ _x addCuratorEditableObjects [[_unit], false] } forEach _captors;
{ _x removeCuratorEditableObjects [[_unit], false] } forEach (_owners - _captors);

private _name = ([_unit] call EFUNC(common,classInfo)) select 0;
private _payOut = {
    params ["_curators", "_msgKey"];
    if (_curators isEqualTo []) exitWith {};
    // _value is in economy points, not the engine's normalized curator scale —
    // addPoints does that conversion (and the full-bar cap) for us
    private _share = (_value * 0.5) / count _curators;
    {
        [_x, _share] call EFUNC(economy,addPoints);
        private _player = getAssignedCuratorUnit _x;
        // isPlayer, not isNull: a curator module bound to a departed player keeps
        // returning that player's leftover AI body (a playable Zeus slot whose AI
        // is not disabled leaves the object behind). That body is server-local, so
        // `owner` is 2 and the message would be delivered to the server — silently
        // dropped on a dedicated server, but rendered by a listen-server host as its
        // own payout notification. `isPlayer objNull` is false, so this still covers
        // the null case. Same guard as rtz_spotting's curator resolution.
        if (isPlayer _player) then {
            [QGVAR(captureMsg), [_msgKey, _name, round _share], _player] call CBA_fnc_targetEvent;
        };
    } forEach _curators;
};
[_captors, LSTRING(MsgCaptured)] call _payOut;
[_owners,  LSTRING(MsgTakenPrisoner)] call _payOut;
