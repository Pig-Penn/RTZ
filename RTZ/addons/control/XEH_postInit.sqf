#include "script_component.hpp"

// Server-only receivers. hideObjectGlobal / enableSimulationGlobal,
// enableDynamicSimulation, and the ownership trio (setOwner / setGroupOwner /
// owner) are all server-only commands, so every order here is dispatched with
// CBA_fnc_serverEvent.
if (isServer) then {
    [QGVAR(squadHide), LINKFUNC(squadHideApply)] call CBA_fnc_addEventHandler;
    [QGVAR(disableDynamicSimulation), LINKFUNC(disableDynamicSimulationApply)] call CBA_fnc_addEventHandler;
    [QGVAR(takeOwnership), LINKFUNC(takeOwnershipApply)] call CBA_fnc_addEventHandler;
};

// Everywhere-receivers. Both bodies need the group LOCAL, and local does not
// mean the server: AI in a player-led group is local to that player, and a
// curator's freshly placed units are local to him. The senders use
// CBA_fnc_targetEvent aimed at the groups, so CBA delivers one copy per owning
// machine and each handler filters the batch down to its own.
//   — reloadSquad: the `reload` command needs unit locality (units share their
//     group's locality).
//   — reset: lambs_wp_fnc_taskReset must run where the group is local, and its
//     hard-reset path creates the replacement group on that same machine so
//     ownership carries over. LAMBS is always loaded alongside RTZ, so this
//     registers unconditionally.
[QGVAR(reloadSquad), LINKFUNC(reloadSquadApply)] call CBA_fnc_addEventHandler;
[QGVAR(reset), LINKFUNC(resetApply)] call CBA_fnc_addEventHandler;

// Dismount lock. setUnloadInCombat / allowCrewInImmobile both need the VEHICLE
// local, so FUNC(setDismount) aims a targetEvent at each vehicle and this
// handler runs on its owner — which on a dedicated server or HC has no
// interface, hence no hasInterface guard here.
//
// Registered unconditionally, NOT behind GVAR(enableDismount): the context
// action's condition reads that setting LIVE, so gating registration on it
// would surface a working-looking action on machines that never registered the
// receiver, and every order would land on a machine that was not listening. An
// idle CBA event handler costs nothing while the feature stays switched off.
[QGVAR(dismount), LINKFUNC(dismountApply)] call CBA_fnc_addEventHandler;

// Remote-control animation reset. ZEN raises "zen_remoteControlStopped" LOCALLY
// on the ex-controller's client (zen_remote_control_fnc_start), which is also the
// machine holding that curator's per-client GVAR(enableRcReset) — so the sender
// is registered there and the receiver everywhere, since the released unit can be
// owned by a headless client or the server. Both unconditional, for the same
// reason as the dismount receiver above: an idle handler costs nothing, and the
// setting is read live inside FUNC(rcReset) rather than gating registration.
["zen_remoteControlStopped", LINKFUNC(rcReset)] call CBA_fnc_addEventHandler;
[QGVAR(rcReset), LINKFUNC(rcResetApply)] call CBA_fnc_addEventHandler;
