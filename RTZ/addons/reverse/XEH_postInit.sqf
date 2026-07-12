#include "script_component.hpp"

// Reverse orders are executed where the vehicle is local
[QGVAR(reverse), {_this call FUNC(reverseTo)}] call CBA_fnc_addEventHandler;
