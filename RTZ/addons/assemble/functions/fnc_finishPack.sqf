#include "script_component.hpp"
/*
 * Author: Maxim
 * Clear the pack errand state after a static weapon is disassembled. Shared
 * by both pack paths in FUNC(packWeapon) - the real animation path (the
 * "WeaponDisassembled" engine event handler) and the deterministic fallback - so
 * they converge on one cleanup. Thin wrapper naming the pack ctx var for
 * FUNC(clearErrand), mirror of FUNC(finishBuild)'s clear half.
 *
 * The QGVAR(packing) double-click guard needs no clear here: it lives on the weapon,
 * which the pack has just deleted.
 *
 * Arguments:
 * 0: Gunner <OBJECT>
 * 1: Assistant <OBJECT> - objNull for single bag weapons
 *
 * Return Value:
 * None
 *
 * Example:
 * [_gunner, _assistant] call rtz_assemble_fnc_finishPack
 *
 * Public: No
 */

params ["_gunner", "_assistant"];

[[_gunner, _assistant], [QGVAR(packCtx)]] call FUNC(clearErrand);
