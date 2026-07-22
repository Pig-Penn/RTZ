#include "script_component.hpp"

// setDamage, setFuel and setVehicleAmmo all have global effect, so the whole
// order runs on one machine regardless of where the serviced vehicles are
// local. The server is picked because it owns the AI supply vehicles anyway.
if (isServer) then {
    [QGVAR(resupply), {
        {_x call FUNC(serviceVehicles)} forEach _this;
    }] call CBA_fnc_addEventHandler;
};
