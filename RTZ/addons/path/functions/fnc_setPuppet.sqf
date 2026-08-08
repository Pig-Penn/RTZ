#include "script_component.hpp"
/*
 * Author: Maxim
 * Puts a man into the scripted-move executor, swaps which animation he is
 * walking on, or takes him out again — all three, because they are one state
 * machine and splitting them is how a unit ends up left with MOVE disabled.
 *
 * Inside this executor the unit is a PUPPET: MOVE and ANIM are off, he is
 * carried by a directional movement animation rather than by his own navigation,
 * and his hull is turned by hand each tick. That is what makes a drawn infantry
 * path get walked as drawn, and it is Wargame's executor — every infantry path
 * it runs is this. It is also the only thing in RTZ that disables a unit's AI to
 * move it, which is why FUNC(combatPause) and FUNC(openDoors) exist and why the
 * whole executor sits behind a setting.
 *
 * Two handlers are installed on entry and removed on exit, and they are a pair:
 * AnimDone re-loops the movement animation (without it the man plays one stride
 * and stops), and Hit remembers whoever shot him so the tick can decide whether
 * to break off. Both are stored in the RECORD rather than only on the unit, so
 * teardown does not depend on an event having fired or on a variable surviving a
 * machine change.
 *
 * Called with "" to leave. Leaving is idempotent and safe on a unit that is
 * dead, deleted or no longer local — FUNC(endFollow) calls it on every abort
 * path, including the ones where none of that is true any more.
 *
 * The animation name rides on a unit variable as well as in the record, because
 * the AnimDone handler that re-loops it cannot capture locals and the record is
 * not reachable from inside it. The record's copy is what the tick compares
 * against, so the common case — same animation as last tick — costs a string
 * compare rather than a getVariable.
 *
 * On locality: disableAI does not travel with ownership (Gotchas §4), so a unit
 * that changes hands mid-path arrives at its new owner with its AI intact and
 * the enableAI calls here become a no-op on a machine that no longer owns it.
 * That is the right outcome either way, and it is why this does not refuse to
 * run when the unit has gone non-local — refusing would leave the handlers
 * installed on this machine forever.
 *
 * Arguments:
 * 0: Follow record, mutated in place <ARRAY>
 * 1: Animation to walk on, or "" to leave the executor <STRING>
 *
 * Return Value:
 * The state changed <BOOL>
 *
 * Example:
 * [_record, _anim] call rtz_path_fnc_setPuppet
 *
 * Public: No
 */

params ["_record", "_anim"];

private _current = _record select FOLLOW_ANIM;

// Same animation as last tick, or already out — the overwhelmingly common case
// on both sides
if (_anim isEqualTo _current) exitWith {false};

private _unit = _record select FOLLOW_UNIT;

if (_anim isEqualTo "") exitWith {
    // Leaving. Everything here has to be safe on a unit that has since died or
    // moved machine, because that is exactly when it is most important that it
    // runs.
    if (!isNull _unit) then {
        private _animEH = _record select FOLLOW_ANIM_EH;
        if (_animEH != -1) then {
            _unit removeEventHandler ["AnimDone", _animEH];
        };

        private _hitEH = _record select FOLLOW_HIT_EH;
        if (_hitEH != -1) then {
            _unit removeEventHandler ["Hit", _hitEH];
        };

        _unit setVariable [QGVAR(anim), nil];
        _unit setVariable [QGVAR(threat), nil];

        _unit enableAI "MOVE";
        _unit enableAI "ANIM";

        // Let go of the animation as well as of the AI. Without this the man is
        // handed back mid-stride and stays in that pose until something else
        // moves him — playMoveNow put him there, and only a switchMove takes him
        // off it. Wargame ends its scripted move the same way.
        if (alive _unit) then {
            _unit switchMove "";
        };

        // The path aimed the unit somewhere; hand the direction back to his own
        // AI rather than leaving him staring down the last azimuth for the rest
        // of the mission. objNull, not a position — a zero position is a watch
        // order pointed at the map corner (see rtz_control's fnc_resetApply).
        _unit doWatch objNull;
    };

    _record set [FOLLOW_ANIM, ""];
    _record set [FOLLOW_ANIM_EH, -1];
    _record set [FOLLOW_HIT_EH, -1];
    _record set [FOLLOW_TARGET, objNull];
    true
};

if (isNull _unit || {!alive _unit}) exitWith {false};

// Entering, as opposed to swapping animation within a path
if (_current isEqualTo "") then {
    _unit disableAI "MOVE";
    _unit disableAI "ANIM";

    // Re-loops whatever the record is currently walking on. Reads the unit
    // variable rather than closing over the name, because handler code does not
    // capture locals — and reads it EVERY time rather than once, so a direction
    // change part-way through the path is picked up by the next loop instead of
    // needing the handler torn down and rebuilt.
    //
    // This handler is deliberately not the thing that ends the path: it stops
    // looping when the variable is cleared, but FUNC(setPuppet) is what restores
    // the AI. An event that is merely likely to fire cannot own the only path
    // back (Gotchas §1).
    _record set [FOLLOW_ANIM_EH, _unit addEventHandler ["AnimDone", {
        params ["_unit"];
        private _looping = _unit getVariable [QGVAR(anim), ""];
        if (_looping isEqualTo "") exitWith {};
        _unit playMoveNow _looping;
    }]];

    // Being shot at is the one threat a puppet cannot discover for itself: its
    // AI is off, so it is not looking. The handler does nothing but REMEMBER —
    // deciding whether the shot is worth stopping for belongs to
    // FUNC(combatPause), which runs on the record's stagger and has the range
    // rules and the cooldown in front of it. Wargame does the same split.
    _record set [FOLLOW_HIT_EH, _unit addEventHandler ["Hit", {
        params ["_unit", "", "", "_instigator"];
        if (isNull _instigator || {_instigator isEqualTo _unit}) exitWith {};
        if (_unit distance _instigator > ENGAGE_HIT_RANGE) exitWith {};
        _unit setVariable [QGVAR(threat), _instigator];
    }]];
};

_unit setVariable [QGVAR(anim), _anim];
_unit playMoveNow _anim;

_record set [FOLLOW_ANIM, _anim];

true
