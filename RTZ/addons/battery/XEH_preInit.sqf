#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// Handler ids, initialized on EVERY machine because FUNC(startSystem) runs
// everywhere and tests both before touching them. -1 is "not attached".
//
// GVAR(missionEH) is what makes this component genuinely free while switched off:
// a MISSION event handler can be removed by id, unlike the class event handler
// rtz_spotting's fire-blink is stuck runtime-gating (a class EH cannot be removed
// once added, so it pays a variable read on every shot in the mission forever).
GVAR(missionEH) = -1;
GVAR(mapEH) = -1;

if (!hasInterface) exitWith {
    ADDON = true;
};

// Client state, created HERE rather than in the settings-gated FUNC(startSystem).
// ZEN runs a context action's modifierFunction BEFORE its condition
// (zen_context_menu_fnc_getActiveActions), so with the system disabled
// FUNC(displayActionModifier) would read a nil GVAR(visible) and throw on every
// context-menu open. Same reasoning as rtz_spotting's and rtz_hud's preInit blocks.
//
//   contacts   — trackId -> contact record; see FUNC(receiveContact) for the layout
//   nextExpiry — the earliest expiry currently in the store, so FUNC(drawMap) can
//                skip the prune walk with one float compare on almost every frame.
//                1e11 rather than a nil/-1 sentinel: it is compared against
//                CBA_missionTime directly, so "nothing to expire" is simply a time
//                no mission reaches.
//   visible    — the per-curator overlay toggle (FUNC(toggleDisplay))
//   hooked     — once-flag for the receiver and curator-display registrations
//                FUNC(startSystem) makes on the first enable
GVAR(contacts) = createHashMap;
GVAR(nextExpiry) = 1e11;
GVAR(visible) = true;
GVAR(hooked) = false;

ADDON = true;
