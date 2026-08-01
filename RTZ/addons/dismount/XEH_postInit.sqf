#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is
// visible in the RPT. A separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] dismount postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Registered here and now — no CBA_settingsInitialized fork, no
// GVAR(enableDismountControl) gate. Two reasons:
//   — FUNC(initUnloadInCombat) reads no setting, so there is nothing to wait for.
//     The deferral only existed to make the (now removed) gate read a synced value.
//   — The gate was wrong: the context action's condition reads the setting LIVE,
//     so an admin enabling it mid-mission surfaced a working-looking action on
//     machines that never registered the QGVAR(applyUnloadFlags) receiver, and
//     every order landed on a machine that was not listening. Registering one
//     idle event handler costs nothing while the feature stays switched off.
// `call`, not `spawn`: the body registers one CBA event handler and returns.
// Spawning parked the receiver behind a scheduler slot, so an order issued in
// that window hit a machine that was not listening yet.
call FUNC(initUnloadInCombat);
