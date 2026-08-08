#include "script_component.hpp"
/*
 * Author: Maxim
 * Joins the non-empty segments of a selection-dialog row, header or group
 * descriptor into one spaced line, dropping the blanks.
 *
 * Dropping empties is the whole point: every caller assembles a fixed list of
 * segments and blanks the ones that do not apply to this unit, rather than
 * branching on which are present — so a unit at full health and a unit at 40%
 * build their line the same way and only the join differs.
 *
 * A function rather than a macro because the preprocessor splits macro arguments
 * on commas without regard to square brackets: a JOIN([_a, _b]) would arrive as
 * two arguments and silently lose the second. It was an inline closure rebuilt on
 * every call before the dialog was split — at 4 Hz, once per open row model.
 *
 * Arguments:
 * 0..n: Segments, "" for any that does not apply <STRING>
 *
 * Return Value:
 * The joined line <STRING>
 *
 * Example:
 * ["Rifleman", "", "HP 62"] call rtz_hud_fnc_joinRow
 *
 * Public: No
 */

(_this select { _x != "" }) joinString ROW_SEP
