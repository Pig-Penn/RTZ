#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Draws one head tag's vertical ammunition gauge: a dim full-height
 * track with the loaded magazine's fill drawn over it, coloured by how little is
 * left.
 *
 * Shared by FUNC(drawUnitTags) and FUNC(drawVehicleTags) for the same reason
 * FUNC(drawTagLine) is: a bar that reads one way on an infantry tag and another
 * on the vehicle tag beside it is two features, not one. Infantry draws a single
 * bar for the primary weapon; a vehicle draws one per armed turret.
 *
 * WHY A CENTRE NUDGE. drawIcon3D centres its icon on the position given — there
 * is no bottom-anchored draw — so a partial fill cannot simply be a shorter icon
 * at the same point, or it would drain from both ends at once. The fill is drawn
 * short AND pushed down by half the height it is missing, which puts its bottom
 * edge back on the track's bottom edge.
 *
 * THE TWO SCREEN AXES ARE NOT THE SAME SCALE. That nudge is a UI-y offset, while
 * every other offset in the tag layout is UI-x, and one UI unit of each covers a
 * different fraction of the screen. The ratio is not assumed: one metre of
 * camera-right and one metre of camera-up at the same depth subtend the same
 * angle and therefore cover the same PHYSICAL screen size, so the caller's two
 * measured per-metre scales divide out to exactly the axis aspect, at any
 * resolution and any FOV. BAR_HEIGHT is stated in UI-x-equivalent units (so the
 * layout cursor can treat a bar and an icon as the same kind of object) and
 * converted here.
 *
 * The drawIcon3D size arguments need none of that — equal sizeX/sizeY renders
 * physically square — so only the fill nudge is aspect-corrected. The ROW
 * baseline below is not: it is a multiple of the text size, which is already a
 * UI-y measure.
 *
 * _perMetreUp is NEGATIVE: screen Y grows downward and camera-up does not. The
 * downward nudge divides by it as-is and comes out with the right sign, the same
 * way FUNC(drawUnitTags) converts its de-confliction shift.
 *
 * Position arrives ASL and converts back at the draw, for the reason spelled out
 * in FUNC(drawTagLine): a camera-basis offset added to an AGL position holds
 * height above ground rather than altitude, so it rides the terrain instead of
 * the screen axis.
 *
 * Arguments:
 * 0: World position of the TAG CENTRE, ASL <ARRAY>
 * 1: UI-x per metre of camera-right at this depth <NUMBER>
 * 2: UI-y per metre of camera-up at this depth (negative) <NUMBER>
 * 3: Camera-right unit vector, CTX_CAMRIGHT <ARRAY>
 * 4: Camera-up unit vector, CTX_CAMUP <ARRAY>
 * 5: Bar centre offset from the tag centre, UI-x <NUMBER>
 * 6: Fill fraction, already clamped to 0..1 by the caller <NUMBER>
 * 7: Tag size <NUMBER>
 * 8: Distance-fade alpha <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_posASL, _perMetre, _perMetreUp, _camRight, _camUp, _centreUI, _fill, _size, _alpha] call rtz_hud_fnc_drawTagBar
 *
 * Public: No
 */

params [
    "_posASL", "_perMetre", "_perMetreUp", "_camRight", "_camUp",
    "_centreUI", "_fill", "_size", "_alpha"
];

// Either scale degenerate (the tag centre or its offset probe failed to project)
// leaves nothing meaningful to draw — the bar would land at an arbitrary point
// rather than beside its tag.
if (_perMetre <= 1e-6 || {abs _perMetreUp < 1e-6}) exitWith {};

// Across, then DOWN onto the text's centre line: the tag's anchor is where
// FUNC(drawTagLine) hangs its text FROM, not where the text sits, so an item
// centred on it rides half a line high (ICON_BASELINE, script_component.hpp).
// The same nudge the icons take, applied here so both tag families get it from
// the one place that already holds the vertical scale.
private _centre = _posASL
    vectorAdd (_camRight vectorMultiply (_centreUI / _perMetre))
    vectorAdd (_camUp vectorMultiply ((_size * ICON_BASELINE) / _perMetreUp));
private _drawW  = _size * BAR_FOOT * BAR_PER_UI;
private _drawH  = _size * BAR_HEIGHT * BAR_PER_UI;

// The COL_* macros expand to array literals, so each is a fresh array this call
// owns — the alpha goes in by `set` rather than by slicing off the RGB and
// concatenating a new one, which would allocate a second array per bar per frame.
private _colTrack = COL_DIM;
_colTrack set [3, _alpha];
drawIcon3D [BAR_TEXTURE, _colTrack, ASLToAGL _centre, _drawW, _drawH, 0, "", 2, 0, "RobotoCondensedBold", "center", false, 0, 0];

if (_fill <= 0) exitWith {};   // dry: the empty track IS the reading

private _colFill = switch (true) do {
    case (_fill < BAR_BAD_AT):  { COL_BAD };
    case (_fill < BAR_WARN_AT): { COL_WARN };
    default                     { COL_NORMAL };
};
_colFill set [3, _alpha];

// Half the missing height, in UI-y, converted to a world nudge along camera-up.
private _down    = (_size * BAR_HEIGHT * ((abs _perMetreUp) / _perMetre) * (1 - _fill)) / 2;
private _fillPos = _centre vectorAdd (_camUp vectorMultiply (_down / _perMetreUp));

drawIcon3D [BAR_TEXTURE, _colFill, ASLToAGL _fillPos, _drawW, _drawH * _fill, 0, "", 2, 0, "RobotoCondensedBold", "center", false, 0, 0];
