#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether the Dig Trench action should appear for this selection.
 *
 * Gated on engineers specifically, the way rtz_repair gates its repair errand and
 * rtz_mine gates on carrying the magazine: a curator without engineers cannot dig,
 * which is the resource pressure the order exists to create.
 *
 * Arguments:
 * 0: Context position ASL <ARRAY> (unused; ZEN's context signature)
 * 1: Selected objects <ARRAY>
 *
 * Return Value:
 * Show the action <BOOL>
 *
 * Example:
 * [_position, _objects] call rtz_dig_fnc_canDig
 *
 * Public: No
 */

params ["", "_objects"];

GVAR(enabled)
&& {([_objects, ["engineer"]] call EFUNC(common,collectSpecialists)) isNotEqualTo []}
