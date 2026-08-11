#include "script_component.hpp"
/*
 * Author: Maxim
 * Applies the built-in overall skill level for the unit's classname,
 * if the class has an entry in the default skill table.
 *
 * The skill may be passed in pre-resolved: FUNC(initMan) already has to look
 * it up to decide whether this call is worth deferring at all, so it hands the
 * value over rather than making the table pay for a second lookup a frame
 * later. Called with just a unit, the lookup happens here as before.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Pre-resolved skill on the engine's 0..1 scale, or SKILL_NONE to look the
 *    unit's class up in the table <NUMBER> (default: SKILL_NONE)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_skill_fnc_applySkill
 *
 * Public: No
 */

params ["_unit", ["_skill", SKILL_NONE]];

// `local` as well as `alive`, and re-tested HERE rather than trusted from the
// caller. FUNC(initMan) does check locality — but it then defers this call by a
// frame with CBA_fnc_execNextFrame, and a frame is a window in which the unit
// can change hands (Gotchas §1: state goes stale across a suspension). setSkill
// takes a LOCAL argument — ZEN routes every one of its own through a
// targetEvent aimed at the unit for exactly that reason — so a handover in that
// window would leave this a silent no-op and the unit permanently on its
// config default skill, with nothing in the log to say the table was skipped.
if (!alive _unit || {!local _unit}) exitWith {};

if (_skill == SKILL_NONE) then {
    _skill = GVAR(defaultSkills) getOrDefault [toLowerANSI typeOf _unit, SKILL_NONE];
};

if (_skill == SKILL_NONE) exitWith {};

// Overall skill: sets every sub-skill to this value at once
_unit setSkill _skill;
