#include "script_component.hpp"

// Applies retroactively so units already on the map at mission start are
// covered too; runs for every spawned man-class unit from any source.
["CAManBase", "InitPost", LINKFUNC(initMan), true, [], true] call CBA_fnc_addClassEventHandler;
