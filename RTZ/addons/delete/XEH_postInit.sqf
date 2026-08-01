#include "script_component.hpp"

// deleteVehicle is only reliable from the machine owning the object and the
// curator-point safeguard needs the (server-local) curator modules, so the
// whole selection is handed to the server.
if (isServer) then {
    [QGVAR(delete), LINKFUNC(deleteApply)] call CBA_fnc_addEventHandler;
};

// Group cleanup runs wherever the emptied group happens to be local. Zeus
// places units local to the curator who placed them, so the groups left behind
// by a deletion usually belong to a client rather than the server — hence a
// global event with a locality filter in the handler, not an isServer gate.
[QGVAR(cleanupGroups), LINKFUNC(cleanupGroupsApply)] call CBA_fnc_addEventHandler;
