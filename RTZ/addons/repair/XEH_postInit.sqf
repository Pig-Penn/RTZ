#include "script_component.hpp"

// The walk and the working pose are local-effect commands, so they run where the
// ordered engineer is local — the server for Zeus AI, a headless client if the
// group was offloaded to one.
[QGVAR(repair), LINKFUNC(repairVehicle)] call CBA_fnc_addEventHandler;
[QGVAR(finish), LINKFUNC(finishRepair)] call CBA_fnc_addEventHandler;

// The repair itself is one job per vehicle held on a single machine. The server is
// picked because setDamage has global effect and it owns the AI vehicles anyway,
// so an engineer local to a headless client still repairs a server-owned vehicle
// (the same split rtz_supply uses).
if (isServer) then {
    [QGVAR(join), LINKFUNC(repairJob)] call CBA_fnc_addEventHandler;
};

// No toast receiver here: the unreachable-vehicle message is raised by
// EFUNC(common,approach), which fires it on rtz_common's own channel — see the
// handler in that component's XEH_postInit.
