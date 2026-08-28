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

// The gear animation is driven where the man is local (playActionNow is
// argument-local), by the engine's own AnimDone event rather than by a timer.
// That is the technique behind the continuous gear animation ZEN's
// zen_common_disableGearAnim setting exists to switch OFF: an animation that is
// re-applied the instant the last one ENDS has no gap in it, while a fixed
// interval must either guess the animation's length or leave one. ZEN's ambient
// animation module (zen_modules_fnc_moduleAmbientAnimStart) and ACE3's repair
// loop (ace_repair_fnc_repair) both keep their animations alive exactly this way.
//
// What is deliberately NOT copied from ZEN is the disableAI ["ANIM", "FSM",
// "MOVE", "TARGET", "AUTOTARGET"] that precedes its switchMove. ZEN is pinning a
// man in a chosen pose and accepts a switched-off soldier as the price; this is a
// cosmetic touch on a unit that must go on fighting, so the animation yields to
// the man instead of the other way round (see FUNC(playGearAnim)).
[QGVAR(gearAnimStart), {
    params ["_actor"];

    if (!alive _actor) exitWith {};

    // Re-opening the same man's gear must not stack a second handler on him.
    if (!isNil {_actor getVariable QGVAR(gearAnimEH)}) exitWith {};

    _actor setVariable [QGVAR(gearAnimEH), _actor addEventHandler ["AnimDone", {
        params ["_actor"];
        [_actor] call FUNC(playGearAnim);
    }]];

    [_actor] call FUNC(playGearAnim);
}] call CBA_fnc_addEventHandler;

[QGVAR(gearAnimStop), {
    params ["_actor"];

    if (isNull _actor) exitWith {};

    // Dropped even on a dead man: the handler outlives him, and the watcher that
    // sends this is the only thing that will ever come to take it off.
    private _eh = _actor getVariable [QGVAR(gearAnimEH), -1];
    if (_eh > -1) then {
        _actor removeEventHandler ["AnimDone", _eh];
    };

    _actor setVariable [QGVAR(gearAnimEH), nil];
    _actor setVariable [QGVAR(gearAnimLast), nil];
}] call CBA_fnc_addEventHandler;
