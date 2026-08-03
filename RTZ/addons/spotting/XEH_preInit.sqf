#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// Client-side toggle state, initialized here rather than in FUNC(spottingClient)
// because that function is setting-gated (CBA_settingsInitialized →
// GVAR(enableSpottingSystem)) while the context action's modifierFunction is NOT:
// ZEN runs modifierFunction BEFORE condition (zen_context_menu_fnc_getActiveActions),
// so with the spotting system disabled FUNC(chevronsActionModifier) would read a nil
// GVAR(chevronsEnabled) and throw on every context-menu open. Same reasoning as
// rtz_hud's preInit block.
//   chevronsEnabled    — master switch for the individual chevrons (FUNC(toggleChevrons))
//   officerZonesVisible — officer editing-area ring overlay (no UI toggle yet; console-flippable)
//   chevronNames       — CBA setting mirror; guarded so a value CBA already synced is never clobbered
//   rcDisplay          — remote-control store, unitNetId -> [unit, colorArray]
//
// rcDisplay is created HERE, not only in FUNC(remoteControlIndicator), because two
// different renderers read it under two different gates: FUNC(remoteControlIndicator)
// creates it behind the RC setting, while EFUNC(hud,drawSpots) — registered by
// FUNC(spottingClient) behind the SPOTTING setting — reads it to suppress a chevron
// under an RC icon. With the RC system off, that read found nothing, so it was
// spelled with a `createHashMap` default: an argument SQF evaluates eagerly, which
// allocated and discarded a fresh hashmap on every curator's every frame. Existing
// unconditionally, it is now a plain read — matching EFUNC(hud,drawRcIndicator),
// which already read it with no default.
if (hasInterface) then {
    GVAR(chevronsEnabled) = true;
    GVAR(officerZonesVisible) = true;
    GVAR(rcDisplay) = createHashMap;
    if (isNil QGVAR(chevronNames)) then { GVAR(chevronNames) = false };
};

ADDON = true;
