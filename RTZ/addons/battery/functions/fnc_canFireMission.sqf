#include "script_component.hpp"
/*
 * Author: Maxim
 * Condition for the fire mission context action: whether the selection holds at
 * least one crewed artillery piece or VLS.
 *
 * Gated on GVAR(enableFireMission), never on GVAR(enabled) — that one governs
 * counter-battery detection, is Global and defaults off (see initSettings.inc.sqf).
 *
 * Arguments:
 * 0: Selected objects <ARRAY>
 *
 * Return Value:
 * The order can be given <BOOL>
 *
 * Example:
 * private _ok = [_objects] call rtz_battery_fnc_canFireMission
 *
 * Public: No
 */

params ["_objects"];

if (!GVAR(enableFireMission)) exitWith { false };

([_objects] call FUNC(fireMissionGuns)) isNotEqualTo []
