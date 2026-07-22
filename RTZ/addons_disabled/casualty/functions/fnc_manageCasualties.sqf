#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: one pass over the live casualty registry, run as a ~1 s CBA per-frame handler
 * (started by FUNC(makeCasualty), and called once immediately on each new casualty).
 *
 * Per casualty:
 *   DOWN   — bleed-out: once the deadline passes, clear the flag and kill him for real
 *            (the bonus expired; no extra penalty beyond the death he'd have had).
 *   LOADED — if he fell out / the vehicle is gone or not medical, resume a fresh
 *            bleed-out clock; if the medical vehicle has reached a friendly safe zone,
 *            revive him (evacuation complete).
 *
 * After processing it broadcasts the current list to every client for the 3D indicator,
 * and removes itself when no casualties remain — so it costs nothing while none exist.
 *
 * HashMap forEach: _x is the key (netId), _y the value ([unit, deadline, state]). Only
 * existing values are `set` during iteration (safe); key removals are deferred.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_casualty_fnc_manageCasualties
 *
 * Public: No
 */

if (!isServer) exitWith {};

private _now       = CBA_missionTime;
private _bleedout  = GETGVAR(bleedoutTime,300);
private _toRemove  = [];   // [netId, msgKey]  msgKey: "" silent, else the toast stringtable key

{
    _y params ["_unit", "_deadline", "_state"];

    // Died some other way (Zeus deletion, finished off before the flag applied, etc.).
    if (isNull _unit || {!alive _unit}) then {
        _toRemove pushBack [_x, ""];
        continue;
    };

    switch (_state) do {
        case "DOWN": {
            if (_now >= _deadline) then {
                // Bled out. Clear the flag first so the HandleDamage cap doesn't fight
                // the kill, then apply lethal damage (setDamage does not fire HandleDamage).
                SETPVAR(_unit,GVAR(isCasualty),false);
                _unit setDamage 1;
                _toRemove pushBack [_x, LSTRING(MsgCasualtyBledOut)];
            };
        };
        case "LOADED": {
            private _veh = vehicle _unit;
            if (_veh == _unit || {isNull _veh} || {!alive _veh} || {getNumber (configOf _veh >> "attendant") != 1}) then {
                // Dropped / ejected / vehicle destroyed — back to DOWN on a fresh clock.
                GVAR(casualties) set [_x, [_unit, _now + _bleedout, "DOWN"]];
            } else {
                private _owner = GVAR(casualtyOwner) getOrDefault [_x, ""];
                if ([getPosATL _veh, side _unit, _owner] call FUNC(findSafeZone)) then {
                    // Evacuation complete — stabilise and return him to play, wounded.
                    SETPVAR(_unit,GVAR(isCasualty),false);
                    _unit setUnconscious false;
                    _unit setCaptive false;
                    { _unit enableAI _x } forEach ["MOVE", "AUTOTARGET", "TARGET", "FSM", "PATH"];
                    _unit setDamage 0.5;
                    _toRemove pushBack [_x, LSTRING(MsgCasualtyEvacuated)];
                };
            };
        };
    };
} forEach GVAR(casualties);

// Apply removals + fire outcome toasts.
{
    _x params ["_key", "_msgKey"];
    private _entry = GVAR(casualties) getOrDefault [_key, []];
    GVAR(casualties) deleteAt _key;
    GVAR(casualtyOwner) deleteAt _key;
    if (_msgKey != "" && {_entry isNotEqualTo []}) then {
        private _side = side (_entry select 0);
        [QGVAR(casualtyToast), [_msgKey, _side]] call CBA_fnc_globalEvent;
    };
} forEach _toRemove;

// Broadcast the current snapshot for the client Draw3D indicator. Small list; sent once
// per tick while any casualty exists (also covers JIP — a late client is current within
// a tick). One final empty broadcast clears every client when the list empties.
private _payload = [];
{
    _y params ["_u", "", "_st"];
    _payload pushBack [_u, side _u, _st];
} forEach GVAR(casualties);
[QGVAR(casualtySync), [_payload]] call CBA_fnc_globalEvent;

// Idle out when empty; FUNC(makeCasualty) restarts the loop on the next casualty.
if (count GVAR(casualties) == 0 && {GVAR(managerHandle) >= 0}) then {
    [GVAR(managerHandle)] call CBA_fnc_removePerFrameHandler;
    GVAR(managerHandle) = -1;
};
