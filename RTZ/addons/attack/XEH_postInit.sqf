#include "script_component.hpp"

// Orders are executed where the ordered group is local
[QGVAR(destroy), {_this call FUNC(addWaypoint)}] call CBA_fnc_addEventHandler;
