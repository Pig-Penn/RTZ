#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: take one surrendered unit prisoner (called by FUNC(captureTick) when
 * an enemy closes inside the capture radius). Capture is permanent:
 * QGVAR(captured) is broadcast so every machine's eligibility test locks the unit
 * out of the surrender toggle for good.
 *
 * Four things happen to the prisoner, in an order that matters:
 *
 *  1. Flagged captured, before anything else can re-enter this function.
 *  2. Disarmed — on his own machine, over QGVAR(captureApply); inventory
 *     commands belong where the unit is local and this function is pinned to the
 *     server by the curator lookups below.
 *  3. Handed to the capturing unit's group. The prisoner is his captor's problem
 *     now, and his old squad stops counting him as strength. He stays frozen:
 *     joining a group does not re-enable the AI that FUNC(surrenderApply)
 *     disabled, so his new leader can order him about all he likes.
 *  4. Handed to the capturing side's CURATORS.
 *
 * Both sides are paid from the economy price list (EFUNC(economy,getCost) — the
 * same table placement charges from): the CAPTURING curators split half the
 * unit's value, the OWNING curators split the other half. Curator ownership is
 * resolved through EFUNC(common,curatorsOf); curator modules are server-local,
 * so that lookup and the direct EFUNC(economy,addPoints) / add-remove editable
 * calls are all valid here. A curator who somehow owns both units (an admin Zeus
 * who can edit everything) sits in both lists and simply collects both halves.
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

[QGVAR(captureApply), [_unit], _unit] call CBA_fnc_targetEvent;

// Resolved BEFORE the group move, so "who owned him" still means the side that
// lost him rather than the side that just took him.
private _owners = [_unit] call EFUNC(common,curatorsOf);
private _captors = [_capturer] call EFUNC(common,curatorsOf);

[_unit] joinSilent (group _capturer);

// Zeus ownership only moves when there is somewhere to move it TO. A capturer
// belonging to no curator at all — mission-placed AI, or one whose curator lost
// editability — used to strip every previous owner and grant nobody, leaving a
// prisoner that no Zeus on the server could edit again. QGVAR(captured) locks him
// out of the toggle permanently, so nothing could undo it either. Leaving him
// with his old curator is the strictly better failure: the capture still
// happened, the points still paid, only the transfer had no destination.
if (_captors isNotEqualTo []) then {
    {_x addCuratorEditableObjects [[_unit], false]} forEach _captors;
    {_x removeCuratorEditableObjects [[_unit], false]} forEach (_owners - _captors);
};

private _value = (typeOf _unit) call EFUNC(economy,getCost);
private _name = ([_unit] call EFUNC(common,classInfo)) select 0;

private _fnc_payOut = {
    params ["_curators", "_msgKey"];
    if (_curators isEqualTo []) exitWith {};

    // _value is in economy points, not the engine's normalized curator scale —
    // addPoints does that conversion (and the full-bar cap) for us.
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
            [_player, [_msgKey, _name, round _share]] call EFUNC(common,notifyCurator);
        };
    } forEach _curators;
};

[_captors, LSTRING(MsgCaptured)] call _fnc_payOut;
[_owners, LSTRING(MsgTakenPrisoner)] call _fnc_payOut;
