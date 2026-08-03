#include "script_component.hpp"
/*
 * Author: Maxim
 * Release a loot errand unit back to his group. Shared tail of every way an errand
 * can end - the plan running out, the target vanishing under him, the walk timing
 * out, or the unit dying on the way. The generic half of the release (force move
 * flag, stance, formation) is EFUNC(common,clearErrand); this only adds what the loot
 * errand itself put on him.
 *
 * NOT called when the curator re-tasks a unit mid-errand. A newer order owns him by
 * then and rejoining formation on top of it would cancel it, so FUNC(lootStep) drops
 * those silently instead - the same contract rtz_repair's worker release works under.
 *
 * Extra arguments are ignored, so this can be handed to EFUNC(common,approach)
 * directly as its onFail hook, whose args carry the errand's target after the unit.
 *
 * Arguments:
 * 0: Unit <OBJECT> - objNull is a no-op
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_loot_fnc_clearErrand
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit) exitWith {};

// Drop the watch FUNC(lootTarget) put on the target, or the unit keeps staring at the
// corpse all the way back into formation
if (alive _unit) then {
    _unit doWatch objNull;
};

[_unit] call EFUNC(common,clearErrand);
