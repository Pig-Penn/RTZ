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

// Zeus map Draw handler. The control belongs to the curator display, so both are
// dropped when that display closes and re-resolved when it next opens.
GVAR(mapCtrl) = controlNull;
GVAR(mapEH) = -1;

// Both filled in XEH_preStart, where the config scans they come from are paid once
// per game session instead of once per mission.
GVAR(muzzles) = GETUVAR(GVAR(muzzles),createHashMap);
GVAR(icon) = GETUVAR(GVAR(icon),ICON_FALLBACK);

#include "initSettings.inc.sqf"

ADDON = true;
