#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Draws one head tag's text line as up to three separately-coloured
 * chunks laid end to end, split at MEASURED text boundaries so the composed line
 * still reads as centred on the entity.
 *
 * Shared by FUNC(drawUnitTags) and FUNC(drawVehicleTags), which carried the same
 * boundary arithmetic, the same textAlign trick and the same degenerate-scale
 * fallback in two copies. They must produce identical geometry or the two tag
 * families stop reading as one system.
 *
 * THE CHUNKS ARE POSITIONAL, NOT NAMED. This function knows nothing about what a
 * chunk means — it takes a left, a middle and a right one, each with its own
 * colour and pre-measured width, and the CALLER decides which of the tactic, the
 * main field line and the status word goes in which slot. The two families order
 * them differently: unit tags run tactic · main · status, vehicle tags run
 * tactic · status · main, so a vehicle's status sits beside the tactic it belongs
 * with instead of trailing a variable-length field line. FUNC(tagEntryTail)
 * composes the separators to match (its _statusFirst argument).
 *
 * How the split works. drawIcon3D has no way to colour part of a string, so the
 * line is up to three draws laid end to end from its left edge: leftEdge =
 * centre - halfWidth(all three chunks), then each chunk is anchored at the
 * running cursor and the cursor advances by that chunk's measured width, walking
 * left to right. UI-x offsets convert to world metres through _perMetre.
 * textAlign names the SIDE of the anchor the text sits on — NOT typographic
 * alignment — so "right" STARTS at the anchor, which is what makes a
 * left-to-right walk possible at all. The " · " separators are already baked into
 * the chunks (FUNC(tagEntryTail)) and carry the spacing, so pushing the chunks
 * further apart double-spaces the line.
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
 * Falls back to a single centred draw when there is nothing to split — the left
 * chunk empty and at most one of the other two carrying text, which is the
 * ordinary tag in both families — or when the caller could not measure a usable
 * screen scale.
 *
 * Arguments:
 * 0: World position to centre on, ASL <ARRAY>
 * 1: UI-x per metre of camera-right at this depth; <= 0 forces the fallback <NUMBER>
 * 2: Camera-right unit vector, CTX_CAMRIGHT <ARRAY>
 * 3: Left chunk, separators already baked in, "" for none <STRING>
 * 4: Middle chunk, likewise <STRING>
 * 5: Right chunk, likewise <STRING>
 * 6: Left chunk colour, RGBA <ARRAY>
 * 7: Middle chunk colour, RGBA <ARRAY>
 * 8: Right chunk colour, RGBA <ARRAY>
 * 9: Text size <NUMBER>
 * 10: Measured width of the left chunk <NUMBER>
 * 11: Measured width of the middle chunk <NUMBER>
 * 12: Measured width of the right chunk <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_posASL, _perMetre, _camRight, _tacticSep, _mainSep, _status, _colTactic, _colMain, _colStatus, _size, _wTacticSep, _wMainSep, _wStatus] call rtz_hud_fnc_drawTagLine
 *
 * Public: No
 */

params [
    "_posASL", "_perMetre", "_camRight", "_textL", "_textM", "_textR",
    "_colL", "_colM", "_colR", "_size", "_wL", "_wM", "_wR"
];

// Nothing to split: one centred draw of whichever single chunk has text (the
// concatenation IS that chunk), in that chunk's own colour.
if ((_textL == "" && {_textM == "" || _textR == ""}) || {_perMetre <= 1e-6}) exitWith {
    drawIcon3D ["", [_colM, _colR] select (_textM == ""), ASLToAGL _posASL, 0, 0, 0, _textL + _textM + _textR, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
};

// Left edge of the composed line, in UI-x from the entity centre, then walked
// rightward one chunk at a time. Unrolled rather than looped over a
// [text, colour, width] list: this runs per tagged entity per FRAME, and the
// list would be three arrays built and thrown away every one of them.
private _scale  = 1 / _perMetre;                                   // UI-x → metres
private _cursor = -((_wL + _wM + _wR) / 2);

if (_textL != "") then {
    private _anchor = ASLToAGL (_posASL vectorAdd (_camRight vectorMultiply (_cursor * _scale)));
    drawIcon3D ["", _colL, _anchor, 0, 0, 0, _textL, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
};
_cursor = _cursor + _wL;

if (_textM != "") then {
    private _anchor = ASLToAGL (_posASL vectorAdd (_camRight vectorMultiply (_cursor * _scale)));
    drawIcon3D ["", _colM, _anchor, 0, 0, 0, _textM, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
};
_cursor = _cursor + _wM;

if (_textR != "") then {
    private _anchor = ASLToAGL (_posASL vectorAdd (_camRight vectorMultiply (_cursor * _scale)));
    drawIcon3D ["", _colR, _anchor, 0, 0, 0, _textR, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
};
