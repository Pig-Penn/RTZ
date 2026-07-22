#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// Client draw/condition state, created eagerly so the Draw3D handler and the context
// action's condition never read a nil GVAR (a bare nil read aborts the caller).
if (hasInterface) then {
    GVAR(casualtyList)   = [];              // [[unit, side, state], ...] latest server snapshot
    GVAR(casualtyStates) = createHashMap;   // unit netId -> state ("DOWN" / "LOADED")
    GVAR(zoneCounter)    = 0;               // per-machine counter for unique Medical Zone marker names
};

ADDON = true;
