#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// There is deliberately no capabilities cache here any more. What a vehicle can
// hand out used to be read from its transport* config entries, which depend only
// on the class name and so were worth caching; FUNC(supplyCapabilities) now reads
// getRepairCargo / getFuelCargo / getAmmoCargo instead, which are per OBJECT and
// fall as the truck is used. Caching that by class would have been wrong, not
// merely stale — it is the very quantity the depletion model is built on.
//
// The magazine-capacity cache the rearm test needs is shared rather than kept
// here: rtz_control and rtz_hud ask the same question, so it lives in
// EFUNC(common,magazineCapacity).

// ── Target picker state ──────────────────────────────────────────────────────
// Live only while FUNC(orderResupply)'s picker is open, and read by the two ring
// renderers. GVAR(ringTrucks) is what those renderers gate on, so clearing it is
// half of the teardown; GVAR(ringOffsets) carries the circle baked once when the
// picker opens, so a frame costs one vectorAdd per segment and no trigonometry.
GVAR(ringTrucks)  = [];
GVAR(ringOffsets) = [];

// Zeus map Draw handler id. The control it sits on belongs to the curator display
// and is never stored (controls are not serializable, and one left in the mission
// namespace trips an engine warning on save) — FUNC(orderResupply) re-resolves it
// at both ends of the pick.
GVAR(ringMapEH) = -1;

#include "initSettings.inc.sqf"

ADDON = true;
