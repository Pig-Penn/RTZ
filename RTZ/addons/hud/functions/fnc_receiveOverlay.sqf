#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Default snapshot receiver, and the one every AI-state overlay uses:
 * stores the server's entries RAW and marks them dirty for the draw function to
 * bake on its next frame.
 *
 * Baking lazily rather than here is what lets the snapshot carry an absolute
 * reference time instead of pre-computed ages — an age would change every tick and
 * defeat FUNC(streamServer)'s send diff, while a frozen timestamp diffs away and is
 * aged client-side every frame, which also makes the fade smooth instead of
 * stepping once per poll.
 *
 * Record layout stored per stream id in GVAR(streamData):
 *
 *   [_entries, _rxTime, _dirty, _refTime]
 *     _entries — raw server entries, replaced in place by their baked form
 *     _rxTime  — CBA_missionTime the snapshot landed, for client-side ageing
 *     _dirty   — set here, cleared by the draw function once baked
 *     _refTime — server clock at send, the zero point of any age in _entries
 *
 * Every overlay entry, raw or baked, keeps the watched entity at index 0 — that is
 * what the in-flight filter below and the deselect prune in FUNC(selectionPoll)
 * both test.
 *
 * Arguments:
 * 0: Stream id <STRING>
 * 1: Snapshot entries <ARRAY>
 * 2: Server clock at send <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_stream, _entries, _refTime] call rtz_hud_fnc_receiveOverlay
 *
 * Public: No
 */

params ["_stream", "_entries", "_refTime"];

// Entities deselected while the snapshot was in flight are dropped here rather
// than surviving to the draw and being rendered against a selection that no
// longer holds them.
private _hulls = GVAR(selHulls);
_entries = _entries select {!isNull (_x select 0) && {(_x select 0) in _hulls}};

GVAR(streamData) set [_stream, [_entries, CBA_missionTime, true, _refTime]];
