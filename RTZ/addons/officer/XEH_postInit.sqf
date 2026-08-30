#include "script_component.hpp"

// NOTHING here is gated on GVAR(enable) / GVAR(auraEnable), and nothing waits for
// CBA_settingsInitialized. Both were wrong, and wrong in the way rtz_captive and
// rtz_control each document having already fixed for themselves.
//
// Both master switches are live, no-restart globals that this component's context
// actions read on EVERY menu build (CfgContext.hpp: `condition = QUOTE(GVAR(enable)
// && {...})` and the same for GVAR(auraEnable)). So an admin turning either feature
// on mid-mission got a working-looking action — visible, clickable, with a real
// selection behind it — on a server that had never registered the receiver the
// order is sent to, and FUNC(toggleArea) / FUNC(toggleAura) fired a
// CBA_fnc_serverEvent into nothing. GVAR(auraEnable) DEFAULTS TO FALSE, so turning
// it on mid-mission is the ordinary way to enable auras, not an edge case.
//
// Registering unconditionally costs nothing to give up: every receiver below is
// inert until an order is sent to it, both monitor loops self-gate on empty state
// (FUNC(monitorAuras) exits on two counts, FUNC(monitorAreas) on a null curator or
// an empty area map), and FUNC(initCuratorDisplay) re-reads GETGVAR(auraEnable)
// itself. The enable checks stay where they can still refuse cheaply — the action
// conditions, and the settings-reading bodies themselves.
//
// Dropping the CBA_settingsInitialized wrapper is safe for the same reason: no
// install path below reads a setting. The values that ARE read — GVAR(areaRadius),
// GVAR(auraRadius) — are read at ORDER time, long after settings have synced.

if (isServer) then {
    // Server-side registry of every RTZ area per module: curatorNetId ->
    // HashMap(areaId -> officerNetId). The engine has no getter for a module's
    // editing areas and the per-client tracking map dies with the session, so
    // this is what lets "clear" wipe orphans off a rejoined curator's module.
    GVAR(areasByCurator) = createHashMap;

    // Cross-addon contract (plain global, not GVAR — rtz_spotting reads it
    // without depending on rtz_officer): officerNetId -> [plantedCenter,
    // radius], so a spotted enemy officer's zone ring can ride his chevron
    // payload and be drawn where the area actually sits (see rtz_spotting's
    // fnc_spotCheck) — areas never move once planted, so the stored center
    // stays authoritative. Also the mutual-exclusion source FUNC(applyAura)
    // checks — an officer with an editing area cannot take a command aura —
    // so it exists even with editing areas disabled.
    RTZ_officerZoneMap = createHashMap;

    // officerNetId -> aura radius. No stored position — the zone is
    // derived live from the officer each pass, so the aura follows him.
    GVAR(auras) = createHashMap;

    // groupNetId -> group, for every group held by ANY aura — the diff
    // baseline of FUNC(monitorAuras)
    GVAR(auraHeld) = createHashMap;

    [QGVAR(applyArea), LINKFUNC(applyArea)] call CBA_fnc_addEventHandler;
    [QGVAR(applyAura), LINKFUNC(applyAura)] call CBA_fnc_addEventHandler;

    // Areas are normally torn down by the placing client's
    // FUNC(monitorAreas) — including the wipe it runs when that client's
    // assigned curator changes. A client that DISCONNECTS never runs
    // either, so without this its areas stay registered here forever:
    // GVAR(areasByCurator) leaks, and RTZ_officerZoneMap keeps
    // feeding rtz_spotting zone rings for areas that no longer have an
    // owner to remove them. Resolve the module off allCurators rather
    // than the unit — allCurators is a handful of entries and the
    // assignment is what we actually need to reverse.
    addMissionEventHandler ["HandleDisconnect", {
        params ["_unit"];

        // A bodyless disconnect — a headless client, or a player who
        // leaves from the lobby / slot screen — reports objNull here.
        // getAssignedCuratorUnit also returns objNull for every
        // UNASSIGNED curator module, and objNull isEqualTo objNull is
        // true, so without this guard such a disconnect matched every
        // vacant module and cleared areas belonging to curators who
        // never left. Tested on _unit rather than isPlayer on the
        // assigned body: by the time this fires the engine may already
        // have deassigned the player, which would make the match never
        // succeed and reinstate the leak this handler exists to close.
        if (isNull _unit) exitWith {false};

        {
            if (getAssignedCuratorUnit _x isEqualTo _unit) then {
                ["clear", _x] call FUNC(applyArea);
            };
        } forEach allCurators;

        // Never return true here — that would keep the disconnecting
        // player's body in the world
        false
    }];

    // Idle cost is two counts per AURA_INTERVAL pass while no aura exists.
    call FUNC(monitorAuras);
};

// allowFleeing needs group locality (server, HC, or a player leading AI),
// so the effect receiver registers on EVERY machine — the monitor targets
// the event at each group and CBA routes it to the owner.
[QGVAR(applyAuraEffects), LINKFUNC(applyAuraEffects)] call CBA_fnc_addEventHandler;

// Per-client curator lifecycle + prune loop (guards hasInterface itself)
call FUNC(monitorAreas);

if (!hasInterface) exitWith {};

// No aura-feedback receiver here any more. Aura verdicts are sent by
// FUNC(applyAura) through EFUNC(common,notifyCurator), which is the one
// receiver the whole mod shares (registered in rtz_common's postInit) —
// this component's own copy was the one that had drifted, unwrapping
// `_this select 0` where the other three passed `_this` straight through.
// (The GVAR(auraZones) map-ring mirror and its QGVAR(auraZone) handler
// are NOT here either — they must be up before CBA's JIP replay, so they
// live in XEH_preInit.)

// Normally attached by FUNC(initCuratorDisplay) via the XEH DisplayLoad
// event each time the curator display is created. If Zeus is somehow already
// open when this runs, attach now.
//
// THIS one stays settings-deferred, unlike everything above it. It is not a
// receiver that must exist before an order can arrive — it is a one-shot
// catch-up whose only job is to cover a display that already exists, and
// FUNC(initCuratorDisplay) refuses outright while GETGVAR(auraEnable,false)
// reads false. Running it at plain postInit would therefore always no-op on a
// client whose settings have not synced yet, which is exactly when it would be
// needed. It is idempotent per display (QGVAR(auraDrawAttached)), so overlapping
// with the DisplayLoad path is harmless.
["CBA_settingsInitialized", {
    private _curatorDisplay = findDisplay IDD_RSCDISPLAYCURATOR;
    if (!isNull _curatorDisplay) then {
        [_curatorDisplay] call FUNC(initCuratorDisplay);
    };
}] call CBA_fnc_addEventHandler;

// Reset cooldown, client-side. rtz_control raises QEGVAR(control,resetDone)
// globally on every reset; FUNC(resetCooldown) works on GVAR(areas) and this
// client's own curator module, so each curator machine handles its own areas —
// hence below the hasInterface guard rather than above it with the order
// receivers. Subscribed by name only: QEGVAR builds the string at compile time,
// so this adds no dependency on rtz_control, the same arrangement
// RTZ_officerZoneMap uses in the other direction for rtz_spotting.
[QEGVAR(control,resetDone), LINKFUNC(resetCooldown)] call CBA_fnc_addEventHandler;
