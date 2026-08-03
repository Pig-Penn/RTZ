#include "script_component.hpp"

// Stance orders are executed where the unit is local (setUnitPos is a
// local-effect command; FUNC(switchStance) targets each unit's own machine)
[QGVAR(switchStance), {
    params ["_unit", "_stance"];
    _unit setUnitPos _stance;
}] call CBA_fnc_addEventHandler;

// Fly-height orders are executed where the aircraft is local (flyInHeight is
// a local-effect command). The engine exposes no flyInHeight getter, so the
// ordered height is tracked in a public per-vehicle variable, seeded from the
// aircraft's current altitude on the first adjustment. Broadcast so the height
// survives locality changes (remote control) and the server-side vehicle
// overlay (rtz_hud's STREAM_VEH feed) can read it.
[QGVAR(adjustHeliHeight), {
    params ["_heli", "_delta"];

    private _height = ((_heli getVariable [QGVAR(flyHeight), round ((getPosATL _heli) select 2)]) + _delta) max FLY_HEIGHT_MIN;
    _heli setVariable [QGVAR(flyHeight), _height, true];
    _heli flyInHeight [_height, true];
}] call CBA_fnc_addEventHandler;

// Combat mode orders are executed where the group is local (setCombatMode is
// a local-effect command). The engine exposes no reliable cross-locality
// combatMode getter, so the ordered fire discipline is tracked in a public
// per-group variable so the curator's next read (FUNC(toggleCombatMode)) is
// authoritative even when the group is local to a dedicated server / headless
// client.
[QGVAR(toggleCombatMode), {
    params ["_grp", "_mode", "_hold"];
    _grp setCombatMode _mode;
    _grp setVariable [QGVAR(holdFire), _hold, true];
}] call CBA_fnc_addEventHandler;
