#include "script_component.hpp"

// Applies retroactively so units already on the map at mission start are
// covered too; runs for every spawned man-class unit from any source
["CAManBase", "InitPost", LINKFUNC(initMan), true, [], true] call CBA_fnc_addClassEventHandler;

// Stance orders are executed where the unit is local (setUnitPos is a
// local-effect command; FUNC(switchStance) targets each unit's own machine)
[QGVAR(switchStance), {
    params ["_unit", "_stance"];
    _unit setUnitPos _stance;
}] call CBA_fnc_addEventHandler;

// Fly-height orders are executed where the aircraft is local (flyInHeight is
// a local-effect command). The engine exposes no flyInHeight getter, so the
// ordered height is tracked in a per-vehicle variable, seeded from the
// aircraft's current altitude on the first adjustment (and re-seeded if the
// aircraft changes locality — it starts again from where it is flying).
[QGVAR(adjustHeliHeight), {
    params ["_heli", "_delta"];

    private _height = ((_heli getVariable [QGVAR(flyHeight), round ((getPosATL _heli) select 2)]) + _delta) max FLY_HEIGHT_MIN;
    _heli setVariable [QGVAR(flyHeight), _height];
    _heli flyInHeight [_height, true];
}] call CBA_fnc_addEventHandler;
