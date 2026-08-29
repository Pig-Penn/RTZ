#include "script_component.hpp"
/*
 * Author: Maxim
 * Gate in front of ZEN's Create Target module, installed by overriding the module's
 * `function` entry in CfgVehicles.hpp — the same hook, for the same reason, as
 * EFUNC(restrict,moduleArsenal): zen_modules_fnc_initModule resolves a module's
 * function through getText (configOf _logic >> "function"), and the function itself
 * is compiled final by CBA and cannot be wrapped by reassignment.
 *
 * A target FUNC(selectFireMission) created has already been named and registered by
 * the time this runs, so ZEN's naming dialog would be a second dialog asking for
 * something already decided. Everything else — a curator dragging Create Target out
 * of the module tree — reaches ZEN untouched, including the attach-laser option.
 *
 * The flag is safe to set after createVehicle has returned even though the `init`
 * event handler fires DURING creation: initModule defers the module function by a
 * frame (CBA_fnc_execNextFrame), so the write always lands first. It is also only
 * ever read here, on the machine the logic is local to, which is the machine that
 * set it — hence a local setVariable rather than a broadcast one.
 *
 * Arguments:
 * 0: Logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * _logic call rtz_battery_fnc_createTarget
 *
 * Public: No
 */

params ["_logic"];

if (_logic getVariable [QGVAR(silentTarget), false]) exitWith {};

_this call zen_modules_fnc_moduleCreateTarget
