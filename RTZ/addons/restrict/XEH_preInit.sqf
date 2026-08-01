#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// Statement source -> target scope for every servicing row, filled from ZEN's
// attribute registry by FUNC(initGate) at postInit
GVAR(gatedRows) = createHashMap;

// FUNC(canEdit)'s verdict cache: slot 0 is the frame it was built on, slots
// 1..SCOPE_COUNT are -1 unresolved / 0 blocked / 1 allowed per scope
GVAR(cache) = [-1, -1, -1, -1, -1];

// Frame of the last refusal message, so one confirm produces one message
GVAR(blockedFrame) = -1;

ADDON = true;
