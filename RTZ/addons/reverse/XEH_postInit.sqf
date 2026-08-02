#include "script_component.hpp"

// Reverse orders are executed where the vehicle is local — setVelocity only
// moves an object on the machine that owns it
[QGVAR(reverse), LINKFUNC(reverseTo)] call CBA_fnc_addEventHandler;
