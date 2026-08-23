#include "script_component.hpp"
/*
 * Author: Maxim
 * Validates an airstrike order and sends it to the machine that owns the aircraft,
 * then draws the curator his confirmation.
 *
 * The gate here is the SAME one FUNC(canStrike) ran, deliberately re-run rather than
 * trusted. Several seconds pass while a curator draws a bearing, and the aircraft can
 * die, land, run dry or change hands inside that window — the context menu's verdict
 * is a snapshot from before the gesture started.
 *
 * Arguments:
 * 0: Aim point ASL <ARRAY>
 * 1: Selected objects <ARRAY>
 * 2: Weapon row as [vehicle, weapon, turretPath, type] <ARRAY>
 * 3: Bearing — direction of FLIGHT in degrees, or -1 for the aircraft's current
 *    heading <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_aim, _objects, _args, 270] call rtz_airstrike_fnc_orderStrike
 *
 * Public: No
 */

params ["_aim", "_objects", "_args", ["_bearing", -1]];
_args params ["_vehicle", "_weapon", "_turretPath", "_type"];

private _current = [_objects] call FUNC(strikeAircraft);

if (_current isNotEqualTo _vehicle) exitWith {
    [LSTRING(StrikeUnavailable)] call zen_common_fnc_showMessage;
};

// Re-run through FUNC(strikeWeapons) rather than a bare `ammo _weapon` read: `ammo`
// takes no turret path, so twin symmetric pylons sharing one weapon classname across
// two turret paths would borrow each other's counts, and it reports only the loaded
// magazine rather than the weapon's total. Matching on BOTH weapon and turret path
// also catches the pylon having disappeared entirely, not merely run dry.
private _stillArmed = ([_vehicle] call FUNC(strikeWeapons)) findIf {
    (_x select 0 isEqualTo _weapon) && {(_x select 1) isEqualTo _turretPath}
} != -1;

if (!_stillArmed) exitWith {
    [LSTRING(NoOrdnance)] call zen_common_fnc_showMessage;
};

// TEMPORARY GATE — remove with Task 4, and nothing else here changes.
// This function is the last thing that runs on the curator's client; the
// QGVAR(execute) dispatch below targets the aircraft's owner, and NOTHING registers
// a handler for it yet (see XEH_postInit). Left alone, the whole gesture ends in a
// confirmation hint for a strike that will never happen — a silent no-op that reads
// as success. Refuse honestly instead.
//
// Sits BELOW both checks above on purpose: an aircraft that has changed hands or run
// dry still earns its own specific rejection, and only an otherwise-valid order falls
// through to this one.
if (true) exitWith {
    [LSTRING(NotImplemented)] call zen_common_fnc_showMessage;
};

// A click with no meaningful drag means "come in the way you are already pointing",
// which keeps the gesture usable as a plain click.
if (_bearing < 0) then {_bearing = getDir _vehicle};

[
    QGVAR(execute),
    [_vehicle, _aim, _bearing, [_weapon, _turretPath, _type]],
    _vehicle
] call CBA_fnc_targetEvent;

// Where it will hit, and which way the run comes in. The line runs from BEHIND the
// aim point along the bearing, so it reads as an approach rather than a departure.
private _from = _aim vectorAdd [-(sin _bearing) * HINT_ARROW, -(cos _bearing) * HINT_ARROW, 0];

[
    [
        ["ICON", [ASLToAGL _aim, ICON_STRIKE, COLOR_STRIKE, 1]],
        ["LINE", [ASLToAGL _from, ASLToAGL _aim, COLOR_STRIKE]]
    ],
    HINT_DURATION
] call zen_common_fnc_drawHint;
