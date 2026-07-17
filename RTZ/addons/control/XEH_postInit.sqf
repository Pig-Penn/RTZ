#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is visible
// in the RPT. This is a separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] control postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Squad hide/freeze — hideObjectGlobal/enableSimulationGlobal are server-only.
if (isServer) then {
    [QGVAR(squadHideApply), LINKFUNC(squadHideApply)] call CBA_fnc_addEventHandler;
};

// Reload squad — the "reload" command needs unit locality (server, HC, or a
// player leading AI), so the receiver registers on every machine.
[QGVAR(reloadSquad), LINKFUNC(reloadSquadApply)] call CBA_fnc_addEventHandler;

// LAMBS AI-state reset. Not setting-gated (present whenever LAMBS + ZEN are
// loaded), so it registers unconditionally — LAMBS is a soft dependency (not
// in requiredAddons), so the whole feature is gated on lambs_wp actually being
// loaded. lambs_wp_fnc_taskReset must run where each group is local (not
// necessarily the server — AI in a player-led group is local to that player),
// so the receiver is registered on every machine.
if (isClass (configFile >> "CfgPatches" >> "lambs_wp")) then {
    [QGVAR(lambsReset), LINKFUNC(lambsResetApply)] call CBA_fnc_addEventHandler;
};
