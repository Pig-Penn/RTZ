#include "script_component.hpp"
/*
 * Author: Maxim
 * Canonical RTZ side palette (alpha 1). One source of truth for every marker /
 * indicator colour, shared by the spotting system, the target overlay and the
 * remote-control indicator.
 *
 * The leader palette is the brighter "own-group" set used for NCOs — units
 * whose class display name contains "leader" (see FUNC(classInfo)) — so
 * leadership reads at a glance.
 *
 * The palette itself is built once per machine at preInit
 * (initSideColors.inc.sqf); this is a pure lookup with no allocation, because
 * it is called per-unit-per-frame from the draw passes.
 *
 * IMPORTANT: the returned array is a SHARED reference into that palette, not a
 * copy. Treat it as read-only — build a new array (`_rgb + [_alpha]`,
 * `select [0, 3]`, …) to vary the alpha rather than writing into this one.
 *
 * Arguments:
 * 0: Unit's side <SIDE>
 * 1: Use the brighter NCO/leader palette <BOOL> (default: false)
 *
 * Return Value:
 * Color <ARRAY> — [r, g, b, 1], shared and read-only
 *
 * Example:
 * [west, true] call rtz_common_fnc_sideColor
 *
 * Public: No
 */

params ["_side", ["_isLeader", false]];

// Civilian, and any modded side, falls through to the default column
private _index = GVAR(sideColorOrder) find _side;
if (_index < 0) then {_index = SIDE_COLOR_DEFAULT};

(GVAR(sideColors) select _isLeader) select _index
