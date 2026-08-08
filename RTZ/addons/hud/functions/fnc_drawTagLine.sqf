#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Draws one head tag's text line: the main line in its own colour with
 * the trailing status word in another, split at a MEASURED text boundary so the
 * combined line still reads as centred on the entity.
 *
 * Shared by FUNC(drawUnitTags) and FUNC(drawVehicleTags), which carried the same
 * boundary arithmetic, the same textAlign trick and the same degenerate-scale
 * fallback in two copies. They must produce identical geometry or the two tag
 * families stop reading as one system.
 *
 * How the split works. drawIcon3D has no way to colour part of a string, so the
 * line is two draws meeting at one anchor: boundary = centre + halfWidth(full) -
 * width(status), converted from UI-x to world metres through _perMetre. textAlign
 * names the SIDE of the anchor the text sits on — NOT typographic alignment — so
 * "left" ends at the anchor and "right" starts there, and the two halves meet
 * exactly. The " · " separator is already baked into _mainSep and carries the
 * spacing, so pushing the halves further apart double-spaces the line.
 *
 * Falls back to a single centred draw when there is no status word to colour, or
 * when the caller could not measure a usable screen scale.
 *
 * Arguments:
 * 0: World position to centre on <ARRAY>
 * 1: UI-x per metre of camera-right at this depth; <= 0 forces the fallback <NUMBER>
 * 2: Camera-right unit vector, CTX_CAMRIGHT <ARRAY>
 * 3: Main line INCLUDING its trailing separator, baked by FUNC(tagEntryTail) <STRING>
 * 4: Status word, "" for none <STRING>
 * 5: Main line colour, RGBA <ARRAY>
 * 6: Status word colour, RGBA <ARRAY>
 * 7: Text size <NUMBER>
 * 8: Measured width of the main line + separator <NUMBER>
 * 9: Measured width of the status word <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_pos, _perMetre, _camRight, _mainSep, _status, _colMain, _colStatus, _size, _wMainSep, _wStatus] call rtz_hud_fnc_drawTagLine
 *
 * Public: No
 */

params [
    "_pos", "_perMetre", "_camRight", "_mainSep", "_status",
    "_colMain", "_colStatus", "_size", "_wMainSep", "_wStatus"
];

if (_status == "" || {_perMetre <= 1e-6}) exitWith {
    drawIcon3D ["", _colMain, _pos, 0, 0, 0, _mainSep + _status, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
};

private _boundaryUI  = ((_wMainSep + _wStatus) / 2) - _wStatus;
private _boundaryPos = _pos vectorAdd (_camRight vectorMultiply (_boundaryUI / _perMetre));

drawIcon3D ["", _colMain,   _boundaryPos, 0, 0, 0, _mainSep, 2, _size, "RobotoCondensedBold", "left",  false, 0, 0];
drawIcon3D ["", _colStatus, _boundaryPos, 0, 0, 0, _status,  2, _size, "RobotoCondensedBold", "right", false, 0, 0];
