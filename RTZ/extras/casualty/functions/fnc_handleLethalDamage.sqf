#include "script_component.hpp"
/*
 * Author: Maxim
 * Body of the raw HandleDamage event handler attached (server-side) to every local,
 * non-player infantryman. Returns the damage the engine should apply, so it MUST
 * always return a number.
 *
 * On a would-be-fatal hit it rolls GVAR(chance): on success the unit is diverted into
 * a downed casualty (FUNC(makeCasualty)) and the fatal blow is capped so the engine
 * never kills him; on failure the real damage passes through and he dies normally.
 *
 * Performance: the hot path is a single `_damage < 1` compare per hit (every graze),
 * returning immediately. The roll only runs on genuinely fatal blows, which are rare.
 * When the master switch is off this handler is never attached at all (see XEH_postInit).
 *
 * Arguments (HandleDamage): 0 unit, 1 hitSelection, 2 damage, ... (rest unused)
 *
 * Return Value:
 * Final damage for this selection <NUMBER>
 *
 * Example:
 * [_unit, _hitSelection, _damage] call rtz_casualty_fnc_handleLethalDamage
 *
 * Public: No
 */

params ["_unit", "_hitSelection", "_damage"];

// Already a casualty: keep him from dying of stray damage while down or aboard a
// vehicle — the bleed-out clock and the evacuation flow are the only exits. Cap all
// incoming damage below lethal. Stays first so protection holds even if the setting
// is toggled off mid-mission.
if (_unit getVariable [QGVAR(isCasualty), false]) exitWith { _damage min 0.9 };

// Non-fatal blow (the overwhelming majority of calls) — pass straight through.
if (_damage < 1) exitWith { _damage };

// Cheap runtime kill-switch so toggling the setting off mid-mission stops conversions
// even though the handlers remain attached. Only paid on would-be-fatal hits.
if !(GETGVAR(enable,false)) exitWith { _damage };

// Only the truly fatal selections kill a man; a lethal limb hit alone does not.
if !(_hitSelection in ["", "head", "body"]) exitWith { _damage };

// On-foot infantry only — a crewman/passenger in a vehicle is out of scope.
if (!isNull objectParent _unit) exitWith { _damage };

// Decide at most once per damage event. Every selection call of one hit shares this
// frame's number, so a decision already made this frame is authoritative — a later
// selection must not re-roll into a contradictory outcome.
if ((_unit getVariable [QGVAR(rolledFrame), -1]) == diag_frameNo) exitWith { _damage };
_unit setVariable [QGVAR(rolledFrame), diag_frameNo];

// The roll. Failure (the common case) lets the fatal damage through unchanged.
if (random 1 >= (GETGVAR(chance,0))) exitWith { _damage };

// Success — divert to a casualty and cap this blow so the engine keeps him alive.
[_unit] call FUNC(makeCasualty);
_damage min 0.9
