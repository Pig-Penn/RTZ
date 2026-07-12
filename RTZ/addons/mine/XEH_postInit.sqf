#include "script_component.hpp"

// Orders are executed where the ordered unit is local
[QGVAR(place), {_this call FUNC(placeMine)}] call CBA_fnc_addEventHandler;
[QGVAR(disarm), {_this call FUNC(disarmMine)}] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

// Only mark spotted mines while the Zeus display is open
["zen_curatorDisplayLoaded", {_this call FUNC(start)}] call CBA_fnc_addEventHandler;
["zen_curatorDisplayUnloaded", {call FUNC(stop)}] call CBA_fnc_addEventHandler;
