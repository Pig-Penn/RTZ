#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler for QGVAR(loadCasualty) (registered in XEH_postInit). Finds the
 * nearest friendly, crewed medical vehicle within GVAR(loadRadius) that has a free
 * cargo seat for one downed casualty, and flips his state to "LOADED" (which pauses
 * the bleed-out clock — see FUNC(manageCasualties)). On failure it toasts the
 * ordering curator only.
 *
 * The state check and vehicle search are authoritative against the server-only
 * GVAR(casualties) registry, so they stay here — but the actual moveInCargo is a
 * local-effect command that must run where the casualty is local (NOT necessarily
 * the server: AI in a player-led group is local to that player's machine), so it
 * is dispatched TARGETED AT THE CASUALTY via FUNC(loadCasualtyMoveIn) (registered
 * on every machine).
 *
 * A medical vehicle is one whose config "attendant" == 1 (same test the spotting
 * system uses to draw the medical symbol). It must be crewed (someone drove it there)
 * and friendly to the casualty.
 *
 * Arguments:
 * 0: The casualty <OBJECT>
 * 1: The ordering curator's player, for the failure toast <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _orderer] call rtz_casualty_fnc_loadCasualtyApply
 *
 * Public: No
 */

params ["_unit", "_orderer"];
if (isNull _unit) exitWith {};
if !(_unit getVariable [QGVAR(isCasualty), false]) exitWith {};

private _entry = GVAR(casualties) getOrDefault [netId _unit, []];
if (_entry isEqualTo []) exitWith {};
if ((_entry select 2) != "DOWN") exitWith {};   // already aboard something

private _r    = GETGVAR(loadRadius,15);
private _side = side _unit;

// Nearest qualifying medical vehicle around the casualty.
private _veh  = objNull;
private _best = 1e9;
{
    if (getNumber (configOf _x >> "attendant") == 1
        && {alive _x}
        && {({alive _x} count crew _x) > 0}                          // manned = it was driven here
        && {(_side getFriend side (effectiveCommander _x)) >= 0.6}   // friendly medical
        && {(_x emptyPositions "cargo") > 0}                         // room for one more
    ) then {
        private _d = _x distance _unit;
        if (_d < _best) then { _best = _d; _veh = _x };
    };
} forEach (_unit nearEntities [["Car", "Tank", "Air", "Ship"], _r]);

if (isNull _veh) exitWith {
    if (!isNull _orderer) then {
        [QGVAR(casualtyMsg), [LSTRING(MsgNoMedicalVehicle)], _orderer] call CBA_fnc_targetEvent;
    };
};

[QGVAR(loadCasualtyMoveIn), [_unit, _veh], _unit] call CBA_fnc_targetEvent;
// Keep the original deadline value; the LOADED state simply stops it being checked, so
// bleed-out is effectively paused until (and unless) he is dropped back to DOWN.
GVAR(casualties) set [netId _unit, [_unit, _entry select 1, "LOADED"]];

[QGVAR(casualtyToast), [LSTRING(MsgCasualtyLoaded), _side]] call CBA_fnc_globalEvent;

// Refresh the indicator immediately (blue = aboard) rather than waiting a tick.
[] call FUNC(manageCasualties);
