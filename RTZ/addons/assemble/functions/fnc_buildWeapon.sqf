#include "script_component.hpp"
/*
 * Author: Maxim
 * Raise the static weapon at the gunner's current position using the real
 * engine assemble action (the authentic kneel-and-assemble animation, lifted from
 * the vanilla / LAMBS flow). The engine fires "WeaponAssembled" when the animation
 * completes, the event handler claims the build and hands off to FUNC(finishBuild).
 *
 * The engine action can silently no-op (indoors, on steep ground, with the AI not
 * ready, or an assistant still out of reach), so a deterministic fallback fires
 * after BUILD_TIMEOUT: if the weapon never appeared it is built directly (a plain
 * createVehicle + moveInGunner) so a Zeus order never fails quietly. The state slot
 * of the shared QGVAR(buildCtx) on the gunner makes the event handler and the
 * fallback mutually exclusive - whichever fires first claims "done" and the other
 * bails. BUILD_TIMEOUT sits comfortably past a normal assemble (~3-4s) so a valid
 * engine build always wins the race, the fallback only runs when the engine truly
 * didn't - and it aborts, rather than building off a corpse, if the gunner died
 * inside the animation window.
 *
 * Called by FUNC(assembleWeapon) on arrival at, or timeout walking to, the picked
 * spot. Must be executed where the gunner is local.
 *
 * Arguments:
 * 0: Gunner <OBJECT> - on foot at the build spot, carrying the weapon bag
 * 1: Static Class <STRING> - assembleInfo >> assembleTo
 * 2: Assistant <OBJECT> - carries the support bag, objNull for single bag weapons
 * 3: Direction <NUMBER> - facing chosen in the placement preview, -1 auto-faces the
 *    nearest known enemy (default: -1)
 * 4: Curator's Player <OBJECT> - feedback toasts (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_gunner, "B_HMG_01_F", _assistant, 180, player] call rtz_assemble_fnc_buildWeapon
 *
 * Public: No
 */

params ["_gunner", "_staticClass", "_assistant", ["_direction", -1], ["_curator", objNull]];

// Gunner down mid-errand, abort and clear any errand state
if (isNull _gunner || {!alive _gunner} || {lifeState _gunner isEqualTo "INCAPACITATED"}) exitWith {
    [objNull, _gunner, _assistant] call FUNC(finishBuild);
    [_curator, LLSTRING(Aborted)] call FUNC(notifyCurator);
};

_gunner doWatch objNull;
doStop _gunner;

if (!isNull _assistant && {alive _assistant}) then {
    doStop _assistant;
};

// One transient context var on the gunner: [state, assistant, curator, facing, EH id].
// SQF arrays are by reference, so the EH id slot set below is seen by the stored
// copy. "pending" until the event handler or the fallback claims the build, the
// finalize arguments ride along because the event handler's own scope can't capture
// them from here
private _ctx = ["pending", _assistant, _curator, _direction, -1];
_gunner setVariable [QGVAR(buildCtx), _ctx];

// Deterministic build: consume the bags and place the static in front of the gunner
// directly, no engine animation. Shared by the instant path below and the timeout
// fallback - the ctx state slot keeps it mutually exclusive with the
// "WeaponAssembled" handler, so whichever fires first claims "done"
private _fnc_directBuild = {
    params ["_gunner", "_staticClass", "_assistant", ["_direction", -1]];

    if (isNull _gunner) exitWith {};

    private _ctx = _gunner getVariable [QGVAR(buildCtx), []];
    if ((_ctx param [0, ""]) isNotEqualTo "pending") exitWith {};
    _ctx set [0, "done"];

    private _eh = _ctx param [4, -1];

    if (_eh >= 0) then {
        _gunner removeEventHandler ["WeaponAssembled", _eh];
    };

    // Gunner died inside the animation window, don't build off a corpse
    if (!alive _gunner) exitWith {
        [objNull, _gunner, _assistant] call FUNC(finishBuild);
        [_ctx param [2, objNull], LLSTRING(Aborted)] call FUNC(notifyCurator);
    };

    // Honour the preview facing when one was chosen, otherwise face where the gunner does
    private _buildDirection = if (_direction >= 0) then {_direction} else {getDir _gunner};
    private _position = getPosATL _gunner;

    removeBackpackGlobal _gunner;

    if (!isNull _assistant) then {
        removeBackpackGlobal _assistant;
    };

    private _weapon = createVehicle [_staticClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _weapon setDir _buildDirection;
    _weapon setPosATL (_position vectorAdd [sin _buildDirection, cos _buildDirection, 0]);
    _gunner assignAsGunner _weapon;
    _gunner moveInGunner _weapon;

    [_weapon, _gunner, _assistant, _ctx param [2, objNull]] call FUNC(finishBuild);
};

// Instant assembly: skip the engine animation, build immediately
if (GVAR(instant)) exitWith {
    [_gunner, _staticClass, _assistant, _direction] call _fnc_directBuild;
};

// The engine finished the animation and spawned the (empty) weapon
private _eh = _gunner addEventHandler ["WeaponAssembled", {
    params ["_unit", "_weapon"];

    private _ctx = _unit getVariable [QGVAR(buildCtx), []];

    if ((_ctx param [0, ""]) isEqualTo "pending") then {
        _ctx set [0, "done"];
        _unit removeEventHandler ["WeaponAssembled", _thisEventHandler];
        [_weapon, _unit, _ctx param [1, objNull], _ctx param [2, objNull]] call FUNC(finishBuild);
    };
}];
_ctx set [4, _eh];

// Issue the real assemble action
if (isNull _assistant) then {
    // Single bag weapon such as the Mk6 mortar, the gunner assembles his own bag
    _gunner action ["Assemble", unitBackpack _gunner];
} else {
    // Two bag: drop the assistant's support bag, then assemble it
    _gunner action ["PutBag", _assistant];
    _gunner action ["Assemble", unitBackpack _assistant];
};

// Deterministic fallback: if the engine never fired, build it directly
[_fnc_directBuild, [_gunner, _staticClass, _assistant, _direction], BUILD_TIMEOUT] call CBA_fnc_waitAndExecute;
