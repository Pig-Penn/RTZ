#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// Client stream state, shared by every overlay:
//   active    — stream ids currently switched on for this curator
//   selection — last synced raw curatorSelected, the change detector
//   watched   — that selection resolved to hulls, the snapshot filter
//   data      — stream id -> [entries, rxTime, dirty, refTime] (record layout
//               documented in FUNC(streamClient))
// Initialized here so the context actions, the toggle and the draw half can all
// assume the containers exist regardless of registration order.
if (hasInterface) then {
    GVAR(active)    = [];
    GVAR(selection) = [];
    GVAR(watched)   = [];
    GVAR(data)      = createHashMap;
};

ADDON = true;
