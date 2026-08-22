#include "script_component.hpp"
/*
 * Author: Maxim
 * Condition for the root airstrike context action: whether the current selection is
 * one AI-flown, airborne plane holding at least one usable ground-attack weapon.
 *
 * Arguments:
 * 0: Context position ASL <ARRAY> (unused; ZEN's context signature)
 * 1: Selected objects <ARRAY>
 *
 * Return Value:
 * The order can be given <BOOL>
 *
 * Example:
 * private _ok = [_position, _objects] call rtz_airstrike_fnc_canStrike
 *
 * Public: No
 */

params ["", "_objects"];

if (!GVAR(enabled)) exitWith {false};

!isNull ([_objects] call FUNC(strikeAircraft))
