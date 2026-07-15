#include "script_component.hpp"

if (!hasInterface) exitWith {};

// Only draw while the Zeus display is open, tracked vehicles are kept between sessions
["zen_curatorDisplayLoaded", {call FUNC(start)}] call CBA_fnc_addEventHandler;
["zen_curatorDisplayUnloaded", {call FUNC(stop)}] call CBA_fnc_addEventHandler;
