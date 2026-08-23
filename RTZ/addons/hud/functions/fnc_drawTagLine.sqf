#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Draws one head tag's text line: the main line, the LAMBS tactic and
 * the trailing status word, each in its own colour, split at MEASURED text
 * boundaries so the composed line still reads as centred on the entity.
 *
 * Shared by FUNC(drawUnitTags) and FUNC(drawVehicleTags), which carried the same
 * boundary arithmetic, the same textAlign trick and the same degenerate-scale
 * fallback in two copies. They must produce identical geometry or the two tag
 * families stop reading as one system.
 *
 * How the split works. drawIcon3D has no way to colour part of a string, so the
 * line is up to three draws laid end to end from its left edge: leftEdge =
 * centre - halfWidth(all three chunks), then each chunk is anchored at the
 * running cursor and the cursor advances by that chunk's measured width, walking
 * tactic, then main line, then status left to right. UI-x
 * offsets convert to world metres through _perMetre. textAlign names the SIDE of
 * the anchor the text sits on — NOT typographic alignment — so "right" STARTS at
 * the anchor, which is what makes a left-to-right walk possible at all. The
 * " · " separators are already baked into each chunk (FUNC(tagEntryTail)) and
 * carry the spacing, so pushing the chunks further apart double-spaces the line.
 *
 * OFFSET IN ASL, NEVER IN THE AGL THE ENGINE DRAWS WITH. drawIcon3D and
 * worldToScreen both take PositionAGL, whose Z is measured from the terrain
 * DIRECTLY UNDER THE POINT, so `agl vectorAdd horizontalVector` holds height
 * above ground constant and walks the anchor up and down the hill instead of
 * sliding it sideways. A chunk offset is tens of metres of world at tag range
 * (a 0.1 UI-x chunk 150 m out is ~20 m), so on any slope the three chunks
 * landed metres apart in altitude: the line came apart vertically, and because
 * an altitude change also moves each anchor's DEPTH under a pitched camera, the
 * horizontal spacing went with it. The two-draw version this replaced put both
 * halves on ONE anchor and so shared one terrain sample, which is why the break
 * arrived with the three-anchor walk and not before it. The centre therefore
 * arrives as ASL and each anchor converts back at the draw itself.
 *
 * Falls back to a single centred draw when the main line is the only chunk with
 * anything in it, or when the caller could not measure a usable screen scale.
 *
 * Arguments:
 * 0: World position to centre on, ASL <ARRAY>
 * 1: UI-x per metre of camera-right at this depth; <= 0 forces the fallback <NUMBER>
 * 2: Camera-right unit vector, CTX_CAMRIGHT <ARRAY>
 * 3: Main line, with its neighbouring separators already baked in by
 *    FUNC(tagEntryTail) <STRING>
 * 4: Bare tactic word, no separator, "" for none <STRING>
 * 5: Status word, "" for none <STRING>
 * 6: Main line colour, RGBA <ARRAY>
 * 7: Tactic colour, RGBA <ARRAY>
 * 8: Status word colour, RGBA <ARRAY>
 * 9: Text size <NUMBER>
 * 10: Measured width of the main line + separator <NUMBER>
 * 11: Measured width of the tactic + separator <NUMBER>
 * 12: Measured width of the status word <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_posASL, _perMetre, _camRight, _mainSep, _tacticSep, _status, _colMain, _colTactic, _colStatus, _size, _wMainSep, _wTacticSep, _wStatus] call rtz_hud_fnc_drawTagLine
 *
 * Public: No
 */

params [
    "_posASL", "_perMetre", "_camRight", "_mainSep", "_tacticSep", "_status",
    "_colMain", "_colTactic", "_colStatus", "_size", "_wMainSep", "_wTacticSep", "_wStatus"
];

if ((_tacticSep == "" && {_status == ""}) || {_perMetre <= 1e-6}) exitWith {
    drawIcon3D ["", _colMain, ASLToAGL _posASL, 0, 0, 0, _mainSep + _tacticSep + _status, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
};

// Left edge of the composed line, in UI-x from the entity centre, then walked
// rightward one chunk at a time. Unrolled rather than looped over a
// [text, colour, width] list: this runs per tagged entity per FRAME, and the
// list would be three arrays built and thrown away every one of them.
private _scale  = 1 / _perMetre;                                   // UI-x → metres
private _cursor = -((_wMainSep + _wTacticSep + _wStatus) / 2);

if (_tacticSep != "") then {
    private _anchor = ASLToAGL (_posASL vectorAdd (_camRight vectorMultiply (_cursor * _scale)));
    drawIcon3D ["", _colTactic, _anchor, 0, 0, 0, _tacticSep, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
};
_cursor = _cursor + _wTacticSep;

if (_mainSep != "") then {
    private _anchor = ASLToAGL (_posASL vectorAdd (_camRight vectorMultiply (_cursor * _scale)));
    drawIcon3D ["", _colMain, _anchor, 0, 0, 0, _mainSep, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
};
_cursor = _cursor + _wMainSep;

if (_status != "") then {
    private _anchor = ASLToAGL (_posASL vectorAdd (_camRight vectorMultiply (_cursor * _scale)));
    drawIcon3D ["", _colStatus, _anchor, 0, 0, 0, _status, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
};
