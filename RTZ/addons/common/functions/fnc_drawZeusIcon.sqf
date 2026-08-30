#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws one marker in vanilla Zeus' own style: a translucent disc, a crisp ring
 * over it, and an optional class glyph inside. The composite, the textures and
 * the colours are the engine's, taken from CfgCurator >> DrawObject >> 3D — see
 * the ICON_ZEUS_* block in script_component.hpp for the mapping.
 *
 * Exists because the engine draws that marker for ITS placement ghost only. Every
 * RTZ ghost is a plain createVehicleLocal object, so a curator picking a spot
 * through RTZ got a single flat cursor glyph where Zeus gives a ring. Both RTZ
 * draw sites now come through here.
 *
 * The MOUSE POINTER that belongs with this marker is not drawn here and is not
 * set here either — the engine picks it from what the curator has selected, so
 * both draw sites clear the selection on the way in. FUNC(placementPreview) has
 * the reasoning.
 *
 * SIZE IS FIXED, NOT SCALED BY CAMERA RANGE. drawIcon3D holds an icon at a
 * constant apparent size on its own — which is what lets rtz_hud size tag icons
 * off the tag text size and expect them to stay glued to it at any range. The
 * vanilla config carries distance coefficients, but those are the engine
 * compensating inside its own drawing path; reproducing them here made the marker
 * grow as the curator pulled the camera back. It needs no camera at all.
 *
 * Arguments:
 * 0: Position (AGL) <ARRAY>
 * 1: Colour, RGBA — the ring and glyph take it as given, the disc takes its RGB
 *    at a fraction of its alpha <ARRAY> (default: [1, 1, 1, 1])
 * 2: Glyph texture drawn inside the ring <STRING> (default: "", no glyph)
 * 3: Text drawn under the marker <STRING> (default: "")
 * 4: Text size <NUMBER> (default: 0)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_posAGL, [1, 1, 1, 1], _glyph] call rtz_common_fnc_drawZeusIcon
 *
 * Public: No
 */

params [
    ["_position", [0, 0, 0], [[]], 3],
    ["_color", [1, 1, 1, 1], [[]], 4],
    ["_glyph", "", [""]],
    ["_text", "", [""]],
    ["_textSize", 0, [0]]
];

// Painted in this order: the disc goes down first so the ring reads as its
// border rather than a line under it.
drawIcon3D [
    ICON_ZEUS_DISC,
    [_color select 0, _color select 1, _color select 2, (_color select 3) * ZEUS_ICON_FILL_ALPHA],
    _position,
    ZEUS_ICON_SIZE, ZEUS_ICON_SIZE, 0,
    "", 0, 0, "RobotoCondensed", "center", false, 0, 0
];

// The ring carries the text. drawIcon3D hangs a label off the BOTTOM of the icon
// it is given, so putting it on the full-size layer is what keeps the hint clear
// of the circle instead of overlapping the glyph.
drawIcon3D [
    ICON_ZEUS_RING, _color, _position,
    ZEUS_ICON_SIZE, ZEUS_ICON_SIZE, 0,
    _text, 0, _textSize, "RobotoCondensed"
];

if (_glyph == "") exitWith {};

private _glyphSize = ZEUS_ICON_SIZE * ZEUS_ICON_GLYPH_COEF;
drawIcon3D [
    _glyph, _color, _position,
    _glyphSize, _glyphSize, 0,
    "", 0, 0, "RobotoCondensed", "center", false, 0, 0
];
