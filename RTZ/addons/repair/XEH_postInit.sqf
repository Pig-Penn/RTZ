#include "script_component.hpp"

// The order is executed where the ordered engineer is local
[QGVAR(repair), {_this call FUNC(repairVehicle)}] call CBA_fnc_addEventHandler;
