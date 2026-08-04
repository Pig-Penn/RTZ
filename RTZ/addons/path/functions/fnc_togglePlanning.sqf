#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: opens path planning for the Zeus selection, or closes an
 * open session. One key for both halves is the gesture that makes the mode quick
 * to use — tap, trace, tap — and it is the one Wargame trains its users into.
 *
 * Returns whether it consumed the press, so a key that this handler declines to
 * act on still reaches whatever would normally receive it (rtz_orders and
 * rtz_reverse do the same).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * call rtz_path_fnc_togglePlanning
 *
 * Public: No
 */

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

// Off by default (see initSettings.inc.sqf) — an admin who has not opted in
// gets the key back rather than a mode that silently can't commit anything.
if (!GVAR(enable)) exitWith {false};

// Second press executes. Escape is the path that closes without ordering
// anything (FUNC(handleInput)).
if (GVAR(planning)) exitWith {
    [true] call FUNC(endPlanning);
    true
};

call FUNC(beginPlanning)
