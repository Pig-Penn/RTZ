#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is visible
// in the RPT. This is a separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] context postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// LAMBS AI-state reset. Not setting-gated (present whenever LAMBS + ZEN are
// loaded), so it registers straight from postInit — LAMBS is a soft dependency
// (not in requiredAddons), so the whole feature is gated on lambs_wp actually
// being loaded. The context action is client-only; lambs_wp_fnc_taskReset must
// run where each group is local — NOT necessarily the server: AI in a
// player-led group is local to that player, HC-offloaded AI to the HC. The
// action fires QGVAR(lambsReset) TARGETED AT THE GROUPS (CBA delivers once per
// owning machine) and the handler filters to its local groups, so it registers
// on every machine.
if (isClass (configFile >> "CfgPatches" >> "lambs_wp")) then {
    if (hasInterface) then {
        [] call FUNC(lambsResetContext);
    };
    [QGVAR(lambsReset), LINKFUNC(lambsResetApply)] call CBA_fnc_addEventHandler;
};

// Everything setting-gated is deferred until the CBA_settingsInitialized event.
// Reading a setting straight from postInit is a race: a CLIENT's values arrive
// from the server a frame or more later, so a bare read is nil (aborting the whole
// postInit) while a defensive default silently ignores a server-side "disabled" —
// the feature registers anyway. CBA fires the event one frame after postInit, once
// every GVAR(enable*) holds the server's synced value.
// NOTE: CBA has no CBA_fnc_runAfterSettingsInit — that helper is ACE3/ZEN-only
// (ace_common_fnc_/zen_common_fnc_); calling the CBA_ name is a silent nil no-op.
["CBA_settingsInitialized", {
    if (GVAR(enableDismountControl)) then {
        [] spawn FUNC(unloadInCombat);
    };

    #include "initKeybinds.inc.sqf"

    // Squad hide/freeze. The context action is client-only; the actual global
    // hide/simulation calls must run on the server, so register the receiver there.
    if (GVAR(enableSquadHide)) then {
        if (hasInterface) then {
            [] call FUNC(squadHideContext);
        };
        if (isServer) then {
            [QGVAR(squadHideApply), LINKFUNC(squadHideApply)] call CBA_fnc_addEventHandler;
        };
    };

    // Reload squad. The context action is client-only; the ReloadMagazine
    // action must run where each unit is local (units share their group's
    // locality — server, HC, or a player leading AI). The action fires
    // QGVAR(reloadSquad) TARGETED AT THE GROUPS and the handler filters to
    // its local groups, so it registers on every machine.
    if (GVAR(enableReloadSquad)) then {
        if (hasInterface) then {
            [] call FUNC(reloadSquadContext);
        };
        [QGVAR(reloadSquad), LINKFUNC(reloadSquadApply)] call CBA_fnc_addEventHandler;
    };

    // Squad loot sweep. The context action is client-only; the sweep itself
    // (doMove / take actions / loadout transfers) must run where the units are
    // local (the server, for AI in Zeus PvP), so register the receiver there.
    if (GVAR(enableLootNearby)) then {
        if (hasInterface) then {
            [] call FUNC(lootNearbyContext);
        };
        if (isServer) then {
            [QGVAR(lootNearbyApply), LINKFUNC(lootNearbyApply)] call CBA_fnc_addEventHandler;
        };
    };

    // Per-squad expected-destination overlay. The context action is client-only;
    // expectedDestination must be read where the unit is local (the server, for AI
    // in Zeus PvP), so FUNC(destinationDisplay) also starts the server-side watcher
    // registry + poll loop that streams snapshots to subscribed curators.
    if (GVAR(enableDestinationDisplay)) then {
        if (hasInterface) then {
            [] call FUNC(destinationContext);
        };
        [] spawn FUNC(destinationDisplay);
    };

    // Per-squad engagement-target overlay. Same architecture as the destination
    // overlay above: the context action is client-only; assignedTarget /
    // targetKnowledge must be read where the unit is local (the server, for AI
    // in Zeus PvP), so FUNC(targetDisplay) also starts the server-side watcher
    // registry + poll loop that streams snapshots to subscribed curators.
    if (GVAR(enableTargetDisplay)) then {
        if (hasInterface) then {
            [] call FUNC(targetContext);
        };
        [] spawn FUNC(targetDisplay);
    };

    // Assemble a disassembled static weapon a squad carries as backpacks (and the
    // reverse). "Assemble Here" walks the crew to the picked spot and raises the
    // weapon with the real engine animation; the walk / createVehicle / assemble
    // action must run where the units are local (the server, for AI in Zeus PvP),
    // so register the receiver there. assembleMsg toasts the ordering curator when
    // the crew can't reach the spot or the gunner goes down.
    if (GVAR(enableAssembleWeapon)) then {
        if (hasInterface) then {
            [] call FUNC(assembleWeaponContext);
            [] call FUNC(disassembleWeaponContext);
            [QGVAR(assembleMsg), { _this call zen_common_fnc_showMessage }] call CBA_fnc_addEventHandler;
        };
        if (isServer) then {
            [QGVAR(assembleWeaponApply),    LINKFUNC(assembleWeaponApply)]    call CBA_fnc_addEventHandler;
            [QGVAR(disassembleWeaponApply), LINKFUNC(disassembleWeaponApply)] call CBA_fnc_addEventHandler;
        };
    };
}] call CBA_fnc_addEventHandler;
