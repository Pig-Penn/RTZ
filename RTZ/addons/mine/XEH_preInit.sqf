#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Spotted-mine marker state. GVAR(mines) holds bare draw POSITIONS, not the mine
// objects: FUNC(refreshMines) revalidates and prunes the list every few seconds,
// so re-testing each entry in the draw handlers would only re-do that work once
// per mine per frame.
GVAR(mines) = [];

GVAR(pfh) = -1;

// Zeus map Draw handler id. The control it sits on belongs to the curator display
// and is never stored (controls are not serializable, and one left in the mission
// namespace trips an engine warning on save) — FUNC(start) re-resolves it. The id
// is dropped when the display closes so the next one re-attaches.
GVAR(mapEH) = -1;

// Both filled in XEH_preStart, where the config scans they come from are paid once
// per game session instead of once per mission.
GVAR(muzzles) = GETUVAR(GVAR(muzzles),createHashMap);
GVAR(icon) = GETUVAR(GVAR(icon),ICON_FALLBACK);

#include "initSettings.inc.sqf"

ADDON = true;
