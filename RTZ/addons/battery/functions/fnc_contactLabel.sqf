#include "script_component.hpp"
/*
 * Author: Maxim
 * One contact's map label, rebuilt only when the displayed second changes and
 * cached in the record itself.
 *
 * The static half — the gun name and the round count — was already built by
 * FUNC(receiveContact), so what is left is the age, and an age changes continuously.
 * Quantising it to whole displayed seconds turns a `format` per contact per FRAME
 * into one per contact per second, and only for contacts actually being drawn. On
 * every other frame this function is an integer compare and a return.
 *
 * The age is measured from the track's most recent ROUND, not its first: what a
 * curator needs off this label is how stale the fix is, and a battery still firing
 * should read as live no matter how long it has been in action. It is also the
 * quantity the contact's expiry is measured against, so the number counts toward
 * something visible.
 *
 * Mutates the record in place — it is the caller's own array, held by the store, so
 * the write is the cache.
 *
 * Kept a function rather than inlined into FUNC(drawMap) as a macro, which is the
 * opposite of the call made for HEAD_POS in main/script_macros.hpp. The reasoning
 * there was a read run per UNIT per frame, where a `call`'s fresh scope and `params`
 * destructure are a real per-entity cost; here the loop is over CONTACTS, of which a
 * mission has a handful. What inlining would cost instead is a second copy of the
 * "has the displayed second changed" rule, in the renderer, next to the cache it
 * guards — a twice-written rule of exactly the shape this codebase's audits keep
 * finding bugs in.
 *
 * Arguments:
 * 0: Contact record, mutated <ARRAY>
 * 1: Current mission time <NUMBER>
 *
 * Return Value:
 * Label text <STRING>
 *
 * Example:
 * private _text = [_record, CBA_missionTime] call rtz_battery_fnc_contactLabel
 *
 * Public: No
 */

params ["_record", "_now"];

private _age = floor (_now - (_record # 3));

// -1 is the sentinel FUNC(receiveContact) seeds, which floor() of a non-negative
// age cannot produce — so a fresh record always misses here and builds its label.
if (_age == (_record # 7)) exitWith { _record # 6 };

private _ageText = if (_age < 60) then {
    format [LLSTRING(AgeSeconds), _age]
} else {
    format [LLSTRING(AgeMinutes), floor (_age / 60), _age % 60]
};

private _text = format [LLSTRING(ContactLabel), _record # 5, _ageText];

_record set [6, _text];
_record set [7, _age];

_text
