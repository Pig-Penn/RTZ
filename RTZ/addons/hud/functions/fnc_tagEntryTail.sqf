#include "script_component.hpp"
/*
 * Author: Maxim
 * Composes the shared tail of both head-tag cache entries: joins the enabled
 * field segments into one line, splices in the separately-coloured LAMBS tactic
 * and status chunks with the separators they need, and measures all three for
 * the draw pass.
 *
 * FUNC(buildTagEntry) and FUNC(buildVtagEntry) differ entirely in which fields
 * they collect and not at all in what they do with them afterwards. This is that
 * afterwards.
 *
 * THREE CHUNKS, EACH CARRYING ITS OWN SEPARATORS. drawIcon3D cannot colour part
 * of a string, so a line that wants three colours has to be three draws
 * (FUNC(drawTagLine)) — tactic, main line, status, in that left-to-right order.
 * Separators are owned by the MAIN LINE chunk, not by whichever chunk precedes
 * them: _mainSep carries a leading " · " when a tactic comes before it and a
 * trailing " · " when a status follows it, and _tacticSep is the bare tactic
 * word with nothing appended. This is deliberate, not incidental — the tactic
 * and status chunks are coloured (COL_TACTIC amber, urgency red/white), while
 * the main line is always neutral COL_NORMAL, so parking every separator dot on
 * the main-line chunk is what keeps every " · " reading as neutral punctuation
 * instead of borrowing its neighbour's colour. When the tactic is shown but the
 * main line has nothing (every main-line field toggled off), _mainSep still
 * carries the connector on its own — a bare " · " drawn in its usual neutral
 * colour — rather than leaving the dot to the tactic chunk. Both are fixed by
 * the entry, because FUNC(drawVehicleTags) was rebuilding `_mainText + _sep` per
 * vehicle per FRAME for a string this entry settles once per cache generation.
 *
 * The widths are measured here for the same reason: the draw pass reads them
 * back to place the coloured chunks (FUNC(drawTagLine)) and, for unit tags, the
 * icons. A size change dirties the cache, so they stay in step with the setting.
 *
 * Note _mainSep is empty EXACTLY when there is neither a main line NOR a bridge
 * to carry (i.e. no tactic-to-status connector needed), and _tacticSep exactly
 * when the tactic is: callers testing "is there anything to draw" can test the
 * composed strings directly.
 *
 * Visual order is tactic, then main line, then status — the tactic identifies
 * the unit/vehicle's current order at a glance, so it leads the tag.
 *
 * REDUNDANT STATUS COLLAPSE. The tactic is a GROUP-scope fact and the status a
 * UNIT-scope one, but FUNC(loadTagLabels) deliberately maps whole families of
 * LAMBS strings onto one display word, so for most tactics the unit actually
 * executing it reports a task resolving to the SAME word ("Suppressing" and
 * "Group Suppress" are both "Suppress"; likewise Assault, Flank, Hide,
 * Garrison, CQB, Attack, Reinforce). A tag reading "Suppress · Suppress" spends
 * width to say nothing and trains the eye past the second word — which is the
 * word that matters in the case that IS informative, a unit whose task diverges
 * from its group's tactic ("Flank · Suppress": that one is base-of-fire, not
 * manoeuvre). So an equal status is dropped and the TACTIC kept: the tactic is
 * the order Zeus issued, and COL_TACTIC already identifies it on sight.
 *
 * The comparison is on the RESOLVED labels, not the raw LAMBS strings, so
 * re-wording a row in FUNC(loadTagLabels) keeps the collapse in step with what
 * the reader actually sees. Nothing urgent can be swallowed: DOWN / FLEEING
 * pre-empt the task in FUNC(buildTagEntry) and DAMAGED / LOW FUEL do in
 * FUNC(buildVtagEntry), and no such label is ever a tactic. Callers must read
 * the status BACK from here (return value 2) instead of shipping the one they
 * passed in — the widths are measured against the collapsed string.
 *
 * Arguments:
 * 0: Field segments, in display order <ARRAY of STRING>
 * 1: LAMBS tactic label, "" for none <STRING>
 * 2: Status word, "" for none <STRING>
 * 3: Tag text size, this system's size setting <NUMBER>
 *
 * Return Value:
 * 0: Main line, with a leading separator when a tactic precedes it and a
 *    trailing one when a status follows — a bare " · " when there is a tactic
 *    and a status but no main-line text of its own <STRING>
 * 1: Bare tactic word, no separator <STRING>
 * 2: Status word — the one passed in, or "" when it merely repeated the tactic
 *    and was collapsed into it; THIS is what the caller renders <STRING>
 * 3: Measured width of the main line (+ its separators) <NUMBER>
 * 4: Measured width of the bare tactic <NUMBER>
 * 5: Measured width of the status word <NUMBER>
 *
 * Example:
 * ([_segs, _tactic, _status, GVAR(tagSize)] call rtz_hud_fnc_tagEntryTail) params ["_mainSep", "_tacticSep", "_status", "_wMainSep", "_wTacticSep", "_wStatus"]
 *
 * Public: No
 */

params ["_segs", "_tactic", "_status", "_size"];

// Redundant status collapse — see the header. Done FIRST, before the separators
// are chosen and the widths measured, so a collapsed status takes its " · " and
// its width with it rather than leaving a dangling dot on the main line.
if (_status == _tactic) then { _status = "" };

private _mainText = _segs joinString " · ";
// The tactic carries no separator of its own — see the header comment. Its
// connector to whatever comes next (main line, or status directly when the
// main line is empty) is prepended to _mainSep instead, so it draws in the
// main line's neutral colour rather than the tactic's amber.
private _tacticSep = _tactic;
private _leadSep    = ["", " · "] select (_tactic != "" && { _mainText != "" || _status != "" });
private _trailSep   = ["", " · "] select (_mainText != "" && { _status != "" });
private _mainSep    = _leadSep + _mainText + _trailSep;

[
    _mainSep,
    _tacticSep,
    _status,
    [_mainSep,   _size] call FUNC(textWidth),
    [_tacticSep, _size] call FUNC(textWidth),
    [_status,    _size] call FUNC(textWidth)
]
