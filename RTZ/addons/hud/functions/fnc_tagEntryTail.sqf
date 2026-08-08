#include "script_component.hpp"
/*
 * Author: Maxim
 * Composes the shared tail of both head-tag cache entries: joins the enabled
 * field segments into one line, decides whether a separator is needed before the
 * status word, and measures both halves for the draw pass.
 *
 * FUNC(buildTagEntry) and FUNC(buildVtagEntry) differ entirely in which fields
 * they collect and not at all in what they do with them afterwards. This is that
 * afterwards.
 *
 * The main line is returned ALREADY CONCATENATED with its separator, because both
 * are fixed by the entry: FUNC(drawVehicleTags) was rebuilding `_mainText + _sep`
 * per vehicle per FRAME (and `_mainText + _sep + _statusText` again in its
 * fallback branch) for a string this entry settles once per cache generation.
 * FUNC(buildTagEntry) already baked it; the vehicle path inherits that here.
 * Nothing downstream needs the two pieces apart, so neither is returned — they
 * were dead slots in the unit entry's layout.
 *
 * The widths are measured here for the same reason: the draw pass reads them back
 * to place the coloured status split (FUNC(drawTagLine)) and, for unit tags, the
 * icons. A size change dirties the cache, so they stay in step with the setting.
 *
 * Note _mainSep is empty EXACTLY when the main line is: the separator is only
 * added when both halves are non-empty, so callers testing "is there anything to
 * draw" can test _mainSep directly.
 *
 * Arguments:
 * 0: Field segments, in display order <ARRAY of STRING>
 * 1: Status word, "" for none <STRING>
 * 2: Tag text size, this system's size setting <NUMBER>
 *
 * Return Value:
 * 0: Main line including its trailing separator <STRING>
 * 1: Measured width of it <NUMBER>
 * 2: Measured width of the status word <NUMBER>
 *
 * Example:
 * ([_segs, _status, GVAR(tagSize)] call rtz_hud_fnc_tagEntryTail) params ["_mainSep", "_wMainSep", "_wStatus"]
 *
 * Public: No
 */

params ["_segs", "_status", "_size"];

private _mainText = _segs joinString " · ";
private _sep = ["", " · "] select (_mainText != "" && { _status != "" });
private _mainSep = _mainText + _sep;

[
    _mainSep,
    [_mainSep, _size] call FUNC(textWidth),
    [_status,  _size] call FUNC(textWidth)
]
