#include "script_component.hpp"
/*
 * rtz_fnc_assembleBuild
 *
 * SERVER: raise the static weapon at the gunner's current position using the real
 * engine assemble action (authentic kneel-and-assemble animation, lifted from the
 * vanilla / LAMBS flow). The engine fires "WeaponAssembled" when the animation
 * completes; the EH claims the build and hands off to FUNC(assembleWeaponFinalize)
 * (seat, face, grant to curators).
 *
 * The engine action can silently no-op (indoors, steep ground, AI not ready, an
 * assistant still out of reach), so a deterministic fallback fires after
 * BUILD_TIMEOUT: if the weapon never appeared it is built directly (the old
 * createVehicle + moveInGunner path) so a Zeus command never fails quietly. The
 * state slot of the shared QGVAR(assembleCtx) on the gunner makes the EH and the
 * fallback mutually exclusive — whichever fires first claims "done" and the other
 * bails. BUILD_TIMEOUT sits comfortably past a normal assemble (~3-4 s) so a valid
 * engine build always wins the race; the fallback only runs when the engine truly
 * didn't — and it aborts (instead of building off a corpse) if the gunner died
 * inside the animation window.
 *
 * Called by FUNC(assembleWeaponApply) on arrival at (or timeout walking to) the
 * picked spot.
 *
 * Parameters:
 *   0: Object — gunner (on foot at the build spot, carrying the weapon bag)
 *   1: String — class to build (assembleInfo >> assembleTo)
 *   2: Object — assistant carrying the support bag (objNull for single-bag)
 *   3: Number — facing (deg) chosen in the placement preview; -1 = auto-face enemy
 *   4: Object — ordering curator's player (feedback toasts; may be objNull)
 */

// Seconds to wait for the engine "WeaponAssembled" before forcing the build.
#define BUILD_TIMEOUT 6

params ["_gunner", "_staticClass", "_assistant", ["_dir", -1], ["_curator", objNull]];

if (isNull _gunner || {!alive _gunner} || {lifeState _gunner isEqualTo "INCAPACITATED"}) exitWith {
    // Gunner down mid-errand — abort and clear any errand state.
    [objNull, _gunner, _assistant] call FUNC(assembleWeaponFinalize);
    [_curator, "Aborted"] call FUNC(assembleToast);
};

_gunner doWatch objNull;
doStop _gunner;
if (!isNull _assistant && {alive _assistant}) then { doStop _assistant; };

// One transient context var on the gunner: [state, assistant, curator, facing, EH id].
// SQF arrays are by reference, so the EH-id slot set below is seen by the stored
// copy. "pending" until the EH or the fallback claims the build; the finalize args
// ride along because the EH's own scope can't capture them from here.
private _ctx = ["pending", _assistant, _curator, _dir, -1];
_gunner setVariable [QGVAR(assembleCtx), _ctx];

// Deterministic build: consume the bags and place the static in front of the
// gunner directly, no engine animation. Shared by the instant path (below) and
// the timeout fallback — the ctx state slot keeps it mutually exclusive with the
// "WeaponAssembled" EH, so whichever fires first claims "done".
private _fnc_directBuild = {
    params ["_gunner", "_staticClass", "_assistant", ["_dir", -1]];
    if (isNull _gunner) exitWith {};
    private _ctx = _gunner getVariable [QGVAR(assembleCtx), []];
    if ((_ctx param [0, ""]) isNotEqualTo "pending") exitWith {};
    _ctx set [0, "done"];
    private _eh = _ctx param [4, -1];
    if (_eh >= 0) then { _gunner removeEventHandler ["WeaponAssembled", _eh]; };

    // Gunner died inside the animation window — abort, don't build off a corpse.
    if (!alive _gunner) exitWith {
        private _curator = _ctx param [2, objNull];
        [objNull, _gunner, _assistant] call FUNC(assembleWeaponFinalize);
        [_curator, "Aborted"] call FUNC(assembleToast);
    };

    // Honour the preview facing when one was chosen; otherwise face where the gunner does.
    private _buildDir = if (_dir >= 0) then { _dir } else { getDir _gunner };
    private _p = getPosATL _gunner;
    removeBackpackGlobal _gunner;
    if (!isNull _assistant) then { removeBackpackGlobal _assistant; };
    private _static = createVehicle [_staticClass, [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _static setDir _buildDir;
    _static setPosATL (_p vectorAdd [sin _buildDir, cos _buildDir, 0]);
    _gunner assignAsGunner _static;
    _gunner moveInGunner _static;

    [_static, _gunner, _assistant, _ctx param [2, objNull]] call FUNC(assembleWeaponFinalize);
};

// Instant assembly (CBA setting): skip the engine animation, build immediately.
if (GETGVAR(instantAssemble,false)) exitWith {
    [_gunner, _staticClass, _assistant, _dir] call _fnc_directBuild;
};

// EH: the engine finished the animation and spawned the (empty) weapon.
private _eh = _gunner addEventHandler ["WeaponAssembled", {
    params ["_unit", "_weapon"];
    private _ctx = _unit getVariable [QGVAR(assembleCtx), []];
    if ((_ctx param [0, ""]) isEqualTo "pending") then {
        _ctx set [0, "done"];
        _unit removeEventHandler ["WeaponAssembled", _thisEventHandler];
        [_weapon, _unit, _ctx param [1, objNull], _ctx param [2, objNull]] call FUNC(assembleWeaponFinalize);
    };
}];
_ctx set [4, _eh];

// Issue the real assemble action.
if (isNull _assistant) then {
    // Single-bag weapon (e.g. Mk6 mortar): the gunner assembles his own bag.
    _gunner action ["Assemble", unitBackpack _gunner];
} else {
    // Two-bag: drop the assistant's support bag, then assemble it.
    _gunner action ["PutBag", _assistant];
    _gunner action ["Assemble", unitBackpack _assistant];
};

// Deterministic fallback: if the engine never fired, build it directly.
[_fnc_directBuild, [_gunner, _staticClass, _assistant, _dir], BUILD_TIMEOUT] call CBA_fnc_waitAndExecute;
