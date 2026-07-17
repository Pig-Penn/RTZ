#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is visible
// in the RPT. This is a separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] overlays postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Everything here is setting-gated, so it is deferred until CBA_settingsInitialized
// — a CLIENT's synced value arrives a frame or more after postInit, so a bare read
// here would race the sync (see rtz_officer for the same pattern).
["CBA_settingsInitialized", {
    // Per-squad expected-destination overlay. The context action itself is
    // declared in CfgContext.hpp; expectedDestination must be read where the
    // unit is local (the server, for AI in Zeus PvP), so FUNC(destinationDisplay)
    // starts the server-side watcher registry + poll loop that streams
    // snapshots to subscribed curators. Also runs its client half (hasInterface
    // branch) when a client is present.
    if (GVAR(enableDestinationDisplay)) then {
        [] spawn FUNC(destinationDisplay);
    };

    // Per-squad engagement-target overlay. Same architecture as the destination
    // overlay above.
    if (GVAR(enableTargetDisplay)) then {
        [] spawn FUNC(targetDisplay);
    };
}] call CBA_fnc_addEventHandler;
