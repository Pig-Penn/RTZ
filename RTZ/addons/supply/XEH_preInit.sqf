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

#include "initSettings.inc.sqf"

ADDON = true;
