#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Destination-stream renderer: draws a line + move icon from each
 * watched unit to its AI pathing destination, labelled with distance and
 * pathing mode while the cursor is near the icon (modelled on the LAMBS debug
 * renderer). Called once per frame per active stream by FUNC(streamClient),
 * which supplies the shared frame context.
 *
 * A fresh snapshot is baked once, on the first frame after it lands: the
 * pathing-mode label is localised and, if the engine flagged a forced replan,
 * annotated. Distance changes every frame, so it stays in the draw loop.
 *
 * Baked entry: [unit, destination, label].
 *
 * Arguments:
 * 0: Stream record [entries, rxTime, dirty, refTime] (mutated in place) <ARRAY>
 * 1: Camera world position <ARRAY>
 * 2: Mouse position, UI coordinates <ARRAY>
 * 3: CBA_missionTime this frame <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record, _camPos, _mouse, CBA_missionTime] call rtz_overlays_fnc_drawDestination
 *
 * Public: No
 */

params ["_record", "_camPos", "_mouse"];

_record params ["_entries", "", "_dirty"];

if (_dirty) then {
    _entries = _entries apply {
        _x params ["_unit", "_dest", "_mode", "_forceReplan"];

        private _key   = toUpper (_mode splitString " " joinString "");
        private _label = GVAR(destModeLabels) getOrDefault [_key, _mode];
        if (_forceReplan) then {
            _label = format ["%1 (%2)", _label, LLSTRING(ModeReplanning)];
        };

        [_unit, _dest, _label]
    };
    _record set [0, _entries];
    _record set [2, false];
};

private _growWithSpeed = GVAR(destGrowWithSpeed);

{
    _x params ["_unit", "_dest", "_label"];
    if (isNull _unit || {!alive _unit}) then { continue };

    // Anchor on the vehicle so mounted crews draw from the hull, and read the
    // position live each frame — only the destination is snapshotted.
    private _veh     = vehicle _unit;
    private _from    = (getPosATLVisual _veh) vectorAdd [0, 0, 0.5];
    private _camDist = _camPos distance _from;
    if (_camDist > MAX_DRAW_DIST && {_camPos distance _dest > MAX_DRAW_DIST}) then { continue };

    // The unit keeps walking between server ticks — drop the line once it has
    // effectively arrived rather than drawing a stub to its feet.
    private _distLeft = _veh distance _dest;
    if (_distLeft < ARRIVE_RADIUS) then { continue };
    private _destLift = _dest vectorAdd [0, 0, 0.1];

    // Distant overlays recede instead of stacking into clutter.
    private _color = [1, 1, 1, linearConversion [FADE_NEAR, MAX_DRAW_DIST, _camDist, 1, 0.3, true]];
    drawLine3D [_from, _destLift, _color];

    // Label only near the cursor — a screenful of distance readouts is noise.
    private _text = "";
    private _scr  = worldToScreen _destLift;
    if (_scr isNotEqualTo [] && {_mouse distance2D _scr < LABEL_CURSOR_RADIUS}) then {
        _text = format ["%1m — %2", floor _distLeft, _label];
    };

    private _iconSize = if (_growWithSpeed) then {
        linearConversion [0, ICON_SPEED_MAX, speed _veh, ICON_SIZE_MIN, ICON_SIZE_MAX, true]
    } else {
        ICON_SIZE_FIXED
    };

    drawIcon3D [
        [ICON_VEHICLE, ICON_FOOT] select (_veh isKindOf "CAManBase"),
        _color,
        _destLift,
        _iconSize, _iconSize, 0,
        _text,
        1, LABEL_TEXT_SIZE, LABEL_FONT
    ];
} forEach _entries;
