#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Config lookup behind FUNC(needsReload) — the reload action's condition, so it
// is hit once per class per right-click and never again. Filled lazily on the
// curator clients that open the menu; the machine that executes the order never
// reads it. The magazine-capacity half of that function's config reads is NOT
// here: rtz_supply and rtz_hud ask the identical question, so it lives in
// EFUNC(common,magazineCapacity). This one has no caller outside this component.
GVAR(weaponMagazines) = createHashMap;  // weapon class -> compatible magazines

// SERVER-side arbitration state for FUNC(rcClaim): released unit netId -> the
// CBA_missionTime its rebuild was claimed, so a release can only ever be claimed once.
// Declared unconditionally with the rest of preInit's state rather than behind isServer,
// which is where the receiver is gated; an empty hashmap on a client costs nothing and a
// global that exists only on some machines is the kind of asymmetry that reads as a bug
// the next time someone greps for it. Bounded by pruning on write, not by a cap — see
// FUNC(rcClaim).
GVAR(rcClaims) = createHashMap;

#include "initSettings.inc.sqf"

ADDON = true;
