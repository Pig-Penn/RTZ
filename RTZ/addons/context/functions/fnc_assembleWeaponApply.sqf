#include "script_component.hpp"
/*
 * rtz_fnc_assembleWeaponApply
 *
 * SERVER handler body for QGVAR(assembleWeaponApply) (registered in XEH_postInit).
 * Routes one carried assemble-set to its build path:
 *   - a UAV operator's bag deploys instantly into an autonomous drone on the spot
 *     (FUNC(assembleUAV) — lightweight, no walk, no animation);
 *   - a manned static weapon is walked to the picked cursor spot by its gunner +
 *     assistant, then raised with the real engine assemble animation
 *     (arrival — or walk-timeout — hands off to FUNC(assembleBuild)).
 *
 * doMove / createVehicle / the assemble action all run where the units are local
 * (the server, for AI in Zeus PvP), so the whole errand lives here. The client
 * action (FUNC(assembleWeaponAction)) dispatches each set via CBA_fnc_serverEvent.
 *
 * Parameters:
 *   0: Object — gunner (carries the primary weapon bag)
 *   1: String — class to build (assembleInfo >> assembleTo)
 *   2: Object — assistant carrying the support bag (objNull for single-bag / UAV)
 *   3: Array  — world position to build at (the cursor spot)
 *   4: Number — facing (deg) chosen in the placement preview; -1 = auto-face enemy
 *   5: Object — ordering curator's player (feedback toasts; may be objNull)
 */

params ["_gunner", "_staticClass", "_assistant", ["_pos", []], ["_dir", -1], ["_curator", objNull]];
if (isNull _gunner || {!alive _gunner}) exitWith {};
if (!isClass (configFile >> "CfgVehicles" >> _staticClass)) exitWith {};
if (!local _gunner) exitWith {
    [_curator, "Gunner is not on this machine"] call FUNC(assembleToast);
};

// A UAV operator's bag becomes an autonomous drone deployed on the spot — no
// tripod to walk in, no gunner seat. Lightweight, instant, separate path.
if (!(_staticClass isKindOf "StaticWeapon")) exitWith {
    [_gunner, _staticClass] call FUNC(assembleUAV);
};

// Guard against a double right-click queueing two builds for the same gunner.
if (_gunner getVariable [QGVAR(assembling), false]) exitWith {};
_gunner setVariable [QGVAR(assembling), true];

if (_pos isEqualTo []) then { _pos = getPosATL _gunner; };

// Instant assembly (CBA setting): skip the walk — put the gunner at the picked
// spot and build now (FUNC(assembleBuild) likewise skips the engine animation, so
// the weapon appears at the cursor at once).
if (GETGVAR(instantAssemble,false)) exitWith {
    _gunner setPosATL _pos;
    [_gunner, _staticClass, _assistant, _dir, _curator] call FUNC(assembleBuild);
};

// Walk the crew to the spot, then raise the weapon (FUNC(assembleBuild)). On
// timeout build where the gunner got to, so a Zeus command always completes.
private _crew = [_gunner];
if (!isNull _assistant && {alive _assistant}) then { _crew pushBack _assistant; };
// Arrival radius 4 m; walk timeout 12 s scaled by distance. Build on arrival, or
// in place on the gunner's death/timeout, so a Zeus command always completes.
[
    _crew, _pos, 4, 12 + (_gunner distance2D _pos) * 0.5,
    LINKFUNC(assembleBuild),
    LINKFUNC(assembleBuild),
    [_gunner, _staticClass, _assistant, _dir, _curator],
    true,
    _curator,
    "Crew couldn't reach the spot - building in place"
] call EFUNC(common,approach);
