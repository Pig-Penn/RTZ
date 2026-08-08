#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Declare (or withdraw) one consumer's interest in the selection slices
 * the engine streams, and in the expensive per-unit intel.
 *
 * The selection feeds are the costliest thing the engine streams — a packet per
 * selected entity per tick — and the "detailed" flag on top of the infantry feed
 * gates the two genuinely expensive server reads (targetsQuery, checkVisibility).
 * None of it is worth gathering when nothing is looking, so FUNC(buildReport)
 * reports a slice only while at least one consumer asks for it.
 *
 * A REGISTRY rather than a flag, for two reasons. The engine had been reading two
 * of rtz_hud's display globals by name to decide this, which is exactly the
 * display knowledge that kept the engine welded to one component. And two
 * consumers genuinely overlap — the head tags and the selection dialog both want
 * the infantry slice, the dialog additionally wants the intel — so a pair of
 * booleans set independently would let the tags being hidden switch the open
 * dialog's own feed off underneath it. Keyed demand makes the OR correct without
 * either consumer knowing the other exists.
 *
 * Slices are named with the engine's own SRC_* constants rather than a positional
 * boolean per feed. This started as [id, wantsUnits, wantsDetailed], which meant
 * the infantry slice was consumer-gated and the vehicle slice was not — so hiding
 * the vehicle tags unregistered their renderer and left the server gathering and
 * pushing a vehicle packet per selected vehicle per tick to a client that drew
 * none of them. A list makes every slice gateable by the same mechanism, and adds
 * no third parameter to get the order of.
 *
 * SRC_HULLS is not a demand — see script_macros_core.hpp. Passing it is harmless
 * and ignored.
 *
 * Withdrawing is passing an empty slice list, not a separate call: the entry is
 * dropped so an idle curator's registry is genuinely empty rather than full of
 * falses.
 *
 * Arguments:
 * 0: Consumer id — unique per display <STRING>
 * 1: Slices wanted, SRC_UNITS / SRC_VEHS; [] to withdraw <ARRAY> (default: [])
 * 2: Wants the expensive per-unit intel too <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(unitTags), [SRC_UNITS]] call rtz_core_fnc_setDemand
 *
 * Public: No
 */

params ["_id", ["_slices", []], ["_wantsDetailed", false]];

if (!hasInterface) exitWith {};

if (_slices isEqualTo [] && {!_wantsDetailed}) exitWith {
    GVAR(demands) deleteAt _id;
};

GVAR(demands) set [_id, [_slices, _wantsDetailed]];
