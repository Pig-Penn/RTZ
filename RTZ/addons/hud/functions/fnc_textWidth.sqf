#include "script_component.hpp"
/*
 * Author: Maxim
 * Measures a tag string's on-screen width in UI-x coordinates (the same space
 * worldToScreen / getMousePosition return) with the font and size the tags'
 * drawIcon3D calls use, so icon placement and the coloured chunk splits land
 * exactly at the real text edges at any resolution or UI scale. Shared by both
 * head-tag entry builders through FUNC(tagEntryTail).
 *
 * getTextWidth, NOT ctrlTextWidth — and never a control measurement again.
 * ctrlTextWidth answers "how wide must a CONTROL be to hold this", which
 * includes the engine's hardcoded 0.008 UI-x margin on EACH side; drawIcon3D
 * draws bare glyphs and has no margins. So every chunk measured that way came
 * back 0.016 too wide, and since FUNC(drawTagLine) walks its cursor by these
 * widths, each chunk after the first was pushed 0.016 past the " · " baked into
 * the one before it — a visibly wider gap after every separator than before it —
 * while the line, centred on the inflated total, sat 0.008 left of its entity.
 * FUNC(buildTagEntry) sizes its icon slots and its de-confliction footprint off
 * the same sum, so its icons drifted right by one margin per non-empty chunk:
 * an error that CHANGED with how many chunks a tag happened to carry, which is
 * why no fixed ICON_TEXT_GAP could ever look right for every tag.
 *
 * If a control measurement is ever unavoidable, subtract 0.016 per measured
 * string. getTextWidth also needs no display, so this no longer degrades to a
 * per-character estimate for entries built before display 46 exists.
 *
 * Arguments:
 * 0: Text to measure <STRING>
 * 1: Font height (drawIcon3D text size) <NUMBER>
 *
 * Return Value:
 * Width in UI-x units <NUMBER>
 *
 * Example:
 * ["Rifleman · HP 62", 0.03] call rtz_hud_fnc_textWidth
 *
 * Public: No
 */

params ["_text", "_size"];

// An absent chunk has no width — and no separator either (FUNC(tagEntryTail)),
// so it costs the line nothing.
if (_text == "") exitWith { 0 };

// The font MUST stay the one FUNC(drawTagLine) draws with: a width measured in
// another face is not a width, it is a number.
_text getTextWidth ["RobotoCondensedBold", _size]
