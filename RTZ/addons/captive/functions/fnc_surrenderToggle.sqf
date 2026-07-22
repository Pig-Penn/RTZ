#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: flips the surrendered state of every unit in the
 * selection. Reads the current state from the FIRST unit and applies the
 * inverse uniformly to all of them (matching the label shown by
 * FUNC(surrenderActionModifier)).
 *
 * A stand-down is refused for units still inside the stand-down lock window
 * (GVAR(standDownLockTime) seconds after surrendering) — surrender is a
 * commitment. The lock is checked here for the toast, and again
 * authoritatively in FUNC(surrenderApply) where the unit is local.
 *
 * setCaptive / disableAI / the hands-up animation must run where the unit is
 * local, so each unit's QGVAR(surrenderApply) event is TARGETED AT THE UNIT —
 * CBA runs it on the unit's owner (server, HC, or a player's machine for AI
 * in his group; handler registered on every machine in XEH_postInit). The
 * handler also broadcasts the per-unit state variable so every client's
 * modifier reads the correct label.
 *
 * Arguments:
 * 0: Objects from a ZEN action's selection + hovered entity <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_captive_fnc_surrenderToggle
 *
 * Public: No
 */

params ["_objects"];
private _units = [_objects] call FUNC(collectSurrenderUnits);
if (_units isEqualTo []) exitWith {
    [LLSTRING(MsgNoUnitsSelected)] call zen_common_fnc_showMessage;
};

// New state derived from the first unit, so a mixed selection follows the
// label the curator just clicked.
private _surrender = !((_units select 0) getVariable [QGVAR(surrendered), false]);

// Standing down: drop units still inside the lock window. The remaining time
// is computed from the first still-locked unit for the refusal toast.
private _locked = [];
if (!_surrender) then {
    _locked = _units select {
        CBA_missionTime - (_x getVariable [QGVAR(surrenderTime), -1e9]) < GVAR(standDownLockTime)
    };
    _units = _units - _locked;
};
if (_units isEqualTo []) exitWith {
    private _remaining = ceil (GVAR(standDownLockTime)
        - (CBA_missionTime - ((_locked select 0) getVariable [QGVAR(surrenderTime), CBA_missionTime])));
    [LLSTRING(MsgStandDownLocked), _remaining] call zen_common_fnc_showMessage;
};

{ [QGVAR(surrenderApply), [_x, _surrender], _x] call CBA_fnc_targetEvent; } forEach _units;

private _msg = [LLSTRING(MsgStandingDown), LLSTRING(MsgSurrendering)] select _surrender;
if (count _units > 1) then { _msg = format ["%1  x%2", _msg, count _units]; };
[_msg] call zen_common_fnc_showMessage;
