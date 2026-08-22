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
 * THREE CHUNKS, EACH CARRYING ITS OWN TRAILING SEPARATOR. drawIcon3D cannot
 * colour part of a string, so a line that wants three colours has to be three
 * draws (FUNC(drawTagLine)) — main line, tactic, status. Each chunk is returned
 * ALREADY CONCATENATED with the " · " that follows it, because both are fixed by
 * the entry: FUNC(drawVehicleTags) was rebuilding `_mainText + _sep` per vehicle
 * per FRAME for a string this entry settles once per cache generation. A chunk
 * only gets a separator when something actually follows it, so a tag ending on
 * the tactic carries no dangling " · ".
 *
 * The widths are measured here for the same reason: the draw pass reads them
 * back to place the coloured chunks (FUNC(drawTagLine)) and, for unit tags, the
 * icons. A size change dirties the cache, so they stay in step with the setting.
 *
 * Note _mainSep is empty EXACTLY when the main line is, and _tacticSep exactly
 * when the tactic is: a separator is only ever appended to a non-empty chunk, so
 * callers testing "is there anything to draw" can test the composed strings
 * directly.
 *
 * Arguments:
 * 0: Field segments, in display order <ARRAY of STRING>
 * 1: LAMBS tactic label, "" for none <STRING>
 * 2: Status word, "" for none <STRING>
 * 3: Tag text size, this system's size setting <NUMBER>
 *
 * Return Value:
 * 0: Main line including its trailing separator <STRING>
 * 1: Tactic including its trailing separator <STRING>
 * 2: Measured width of the main line + separator <NUMBER>
 * 3: Measured width of the tactic + separator <NUMBER>
 * 4: Measured width of the status word <NUMBER>
 *
 * Example:
 * ([_segs, _tactic, _status, GVAR(tagSize)] call rtz_hud_fnc_tagEntryTail) params ["_mainSep", "_tacticSep", "_wMainSep", "_wTacticSep", "_wStatus"]
 *
 * Public: No
 */

params ["_segs", "_tactic", "_status", "_size"];

private _mainText = _segs joinString " · ";
// Each chunk is followed by a separator only when a later chunk actually
// renders — the tactic sits between the main line and the status word, so the
// main line's separator has to look past it.
private _mainSep   = _mainText + (["", " · "] select (_mainText != "" && { _tactic != "" || _status != "" }));
private _tacticSep = _tactic   + (["", " · "] select (_tactic != "" && { _status != "" }));

[
    _mainSep,
    _tacticSep,
    [_mainSep,   _size] call FUNC(textWidth),
    [_tacticSep, _size] call FUNC(textWidth),
    [_status,    _size] call FUNC(textWidth)
]
