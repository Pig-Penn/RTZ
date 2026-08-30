#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Invalidate a tag system's built-entry cache, so its renderer rebuilds
 * from the new data on its next frame — either WHOLESALE, or for named entities
 * only.
 *
 * Silently does nothing for a system that is not running — the master settings
 * gate each system independently, so a receiver may well be storing packets for a
 * display the curator switched off, and that is not an error worth guarding at
 * every call site (docs/Knowledge Base/Gotchas.md §2 — a nil read would abort the
 * receiver).
 *
 * TWO MODES, because the two callers are asking different questions.
 *
 *   WHOLESALE (no ids) — sets TAG_DIRTY and the renderer swaps in a fresh cache.
 *     What a SETTINGS change needs: every entry was built against the old settings
 *     and none of them is still valid. FUNC(applyTagVisibility) is the other writer
 *     of that flag and means exactly this.
 *
 *   PER ENTITY (ids given) — drops just those keys. What a SNAPSHOT needs.
 *     EFUNC(core,streamServer) diffs at the SNAPSHOT level, so one unit changing
 *     sends all of them, and in a firefight morale, suppression, currentCommand,
 *     ammo and health all move continuously — at least one packet always differs.
 *     Marking the whole cache dirty on that meant FUNC(buildTagEntry) re-ran for
 *     every selected unit at the poll rate (0.3 s) for the whole of every
 *     engagement: ~10 settings reads, several `format`s, a `joinString` and THREE
 *     `getTextWidth` calls (FUNC(tagEntryTail)) each, to rebuild entries that were
 *     byte-identical to the ones thrown away. The receivers know which packets
 *     actually changed — they are already walking the snapshot — so they say so.
 *
 * The ids are deleted from TAG_CACHE HERE rather than queued on the record for the
 * renderer to apply. A system whose renderer is not running (its display switched
 * off) would let such a queue grow for the rest of the mission, which is the class
 * of unbounded store this codebase caps everywhere else. A later wholesale swap is
 * simply a superset of any pending per-entity invalidation, so the two modes cannot
 * disagree.
 *
 * THE MODE IS CHOSEN BY WHETHER AN ARRAY IS PASSED, NOT BY WHETHER IT IS EMPTY.
 * An omitted argument means wholesale; an EMPTY array means "I checked, and nothing
 * changed" and correctly invalidates nothing. Keying the branch on `isEqualTo []`
 * instead would collapse those two into each other and make a snapshot in which
 * nothing changed — which is reachable, since EFUNC(core,selectionPoll) delivers an
 * empty snapshot to a receiver whose slice has stopped being reported — rebuild the
 * entire cache, i.e. the exact behaviour this function exists to stop.
 *
 * Arguments:
 * 0: System id, as passed to FUNC(startTagSystem) <STRING>
 * 1: netIds whose entries are stale. OMIT to invalidate the whole cache; an empty
 *    array invalidates nothing <ARRAY> (default: omitted)
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(unitTags), _dirty] call rtz_hud_fnc_markTagsDirty
 *
 * Public: No
 */

params ["_id", ["_ids", objNull]];

private _sys = GVAR(tagSystems) get _id;
if (isNil "_sys") exitWith {};

// objNull is the "no list given" sentinel — see the note above on why this is a TYPE
// test and not an emptiness test.
if !(_ids isEqualType []) exitWith { _sys set [TAG_DIRTY, true] };

private _cache = _sys select TAG_CACHE;
{ _cache deleteAt _x } forEach _ids;
