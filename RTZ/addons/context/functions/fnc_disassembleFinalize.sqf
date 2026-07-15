#include "script_component.hpp"
/*
 * rtz_fnc_disassembleFinalize
 *
 * SERVER: clear the pack errand state after a static weapon is disassembled.
 * Shared by both pack paths in FUNC(disassemblePack) — the real-animation path
 * (the "WeaponDisassembled" engine EH) and the deterministic fallback — so they
 * converge on one cleanup. Thin wrapper naming the disassemble ctx var for
 * FUNC(clearErrandState); mirror of FUNC(assembleWeaponFinalize)'s clear half.
 *
 * Parameters:
 *   0: Object — gunner
 *   1: Object — assistant (objNull for single-bag)
 */

params ["_gunner", "_assistant"];
[[_gunner, _assistant], [QGVAR(disCtx)]] call FUNC(clearErrandState);
