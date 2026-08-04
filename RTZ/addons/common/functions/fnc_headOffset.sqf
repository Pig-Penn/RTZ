#include "script_component.hpp"
/*
 * Author: Maxim
 * Model-space position of a man's head selection, memoized per class.
 *
 * `selectionPosition` resolves a named selection against the MODEL, so for a given
 * class the answer is a constant — it cannot change for the life of the mission. It
 * was being asked per unit, per frame, by three separate renderers at once
 * (EFUNC(hud,drawUnitTags), EFUNC(spotting,drawSpots), EFUNC(spotting,drawRcIndicator)),
 * so a unit that was tagged, chevroned and remote-controlled paid for it three times
 * every frame. Cached the same way EFUNC(common,classInfo) caches its config reads,
 * and bounded the same way: one entry per man class in CfgVehicles, not one per unit.
 *
 * Returns the offset only. The caller still runs modelToWorldVisual itself, because
 * THAT genuinely changes every frame — and must still test the result for [] before
 * using it, since the model may not have resolved on this machine yet (Gotchas §3).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Head position in model space <ARRAY>
 *
 * Example:
 * private _pos = _unit modelToWorldVisual ([_unit] call rtz_common_fnc_headOffset)
 *
 * Public: No
 */

params ["_unit"];

private _class = typeOf _unit;

// Closed over rather than read from `_this`: getOrDefaultCall runs its default block
// with _this set to [key, hashMap], not the key (Gotchas §3).
GVAR(headOffsetCache) getOrDefaultCall [_class, {_unit selectionPosition "Head"}, true]
