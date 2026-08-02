#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Capture watch state. Declared on EVERY machine, not just the server, and
// unconditionally rather than behind the enable setting: the alternative is a
// nil read the first time anything touches them, and a nil `if` aborts the whole
// enclosing scope rather than failing where it happened. Both are server-owned
// in practice — nothing off-server writes them — but costing two variables to
// remove a class of silent init-order failure is a trade worth making.
//
// GVAR(pfh) is -1 while the engine does not exist. It is created by the first
// surrender and destroyed by the last (FUNC(registerSurrender) /
// FUNC(captureTick)), so a mission where nobody ever surrenders never runs a
// single tick of this component.
GVAR(surrenderedUnits) = [];
GVAR(pfh) = -1;

#include "initSettings.inc.sqf"

ADDON = true;
