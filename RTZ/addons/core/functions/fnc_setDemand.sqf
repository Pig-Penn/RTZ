#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Declare (or withdraw) one consumer's interest in the infantry slice of
 * the curator's selection, and in the expensive per-unit intel.
 *
 * The infantry feed is the costliest thing the engine streams — a packet per
 * selected unit per tick — and the "detailed" flag on top of it gates the two
 * genuinely expensive server reads (targetsQuery, checkVisibility). Neither is
 * worth gathering when nothing is looking, so FUNC(selectionPoll) reports the
 * slice only while at least one consumer asks for it.
 *
 * A REGISTRY rather than a flag, for two reasons. The engine had been reading two
 * of rtz_hud's display globals by name to decide this, which is exactly the
 * display knowledge that kept the engine welded to one component. And two
 * consumers genuinely overlap — the head tags and the selection dialog both want
 * the slice, the dialog additionally wants the intel — so a pair of booleans set
 * independently would let the tags being hidden switch the open dialog's own feed
 * off underneath it. Keyed demand makes the OR correct without either consumer
 * knowing the other exists.
 *
 * Withdrawing is setting both to false, not a separate call: the entry is dropped
 * so an idle curator's registry is genuinely empty rather than full of falses.
 *
 * Arguments:
 * 0: Consumer id — unique per display <STRING>
 * 1: Wants the infantry slice at all <BOOL>
 * 2: Wants the expensive per-unit intel too <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(unitTags), true] call rtz_core_fnc_setDemand
 *
 * Public: No
 */

params ["_id", "_wantsUnits", ["_wantsDetailed", false]];

if (!hasInterface) exitWith {};

if (!_wantsUnits && {!_wantsDetailed}) exitWith {
    GVAR(demands) deleteAt _id;
};

GVAR(demands) set [_id, [_wantsUnits, _wantsDetailed]];
