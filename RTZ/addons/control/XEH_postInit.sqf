#include "script_component.hpp"

// Squad hide/freeze — hideObjectGlobal/enableSimulationGlobal are server-only.
if (isServer) then {
    [QGVAR(squadHideApply), LINKFUNC(squadHideApply)] call CBA_fnc_addEventHandler;
};

// Pull a squad's simulation back onto a curator's machine (the "Init" action).
// setOwner / setGroupOwner / owner are all server-only commands.
if (isServer) then {
    [QGVAR(initControl), LINKFUNC(initControlApply)] call CBA_fnc_addEventHandler;
};

// Delete objects. deleteVehicle is only reliable from the owning machine and
// the curator point safeguard needs the (server-local) curator modules.
if (isServer) then {
    [QGVAR(deleteObjects), LINKFUNC(deleteObjectsApply)] call CBA_fnc_addEventHandler;
};

// Reload squad — the "reload" command needs unit locality (server, HC, or a
// player leading AI), so the receiver registers on every machine.
[QGVAR(reloadSquad), LINKFUNC(reloadSquadApply)] call CBA_fnc_addEventHandler;

// AI-state reset. LAMBS is always loaded alongside RTZ, so this registers
// unconditionally. lambs_wp_fnc_taskReset must run where each group is local
// (not necessarily the server — AI in a player-led group is local to that
// player), and its hard-reset path creates the replacement group on that same
// machine so ownership carries over, so the receiver is registered on every
// machine.
[QGVAR(reset), LINKFUNC(resetApply)] call CBA_fnc_addEventHandler;
