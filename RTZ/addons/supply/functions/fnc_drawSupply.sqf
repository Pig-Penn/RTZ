#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Supply-lines renderer: draws a line from each watched supply vehicle to
 * every vehicle it is currently servicing, capped with a resupply icon and
 * labelled with the order's progress while the cursor is near it. Called once per
 * frame per active stream by EFUNC(overlays,streamClient), which supplies the
 * shared frame context (camera, mouse, clock) so this pays for none of it.
 *
 * A fresh snapshot is baked once, on the first frame after it lands: the server's
 * absolute start time becomes an elapsed-at-send figure, which is then advanced
 * every frame by however long the snapshot has been sitting here. That is what
 * makes the progress readout climb smoothly between polls while an unchanging
 * order still costs nothing on the wire — see FUNC(gatherSupply).
 *
 * Baked entry: [unit, targets, elapsedAtSend, duration].
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
 * [_record, _camPos, _mouse, CBA_missionTime] call rtz_supply_fnc_drawSupply
 *
 * Public: No
 */

params ["_record", "_camPos", "_mouse", "_now"];

_record params ["_entries", "_rxTime", "_dirty", "_refTime"];

if (_dirty) then {
    _entries = _entries apply {
        _x params ["_unit", "_targets", "_startTime", "_duration"];

        [_unit, _targets, (_refTime - _startTime) max 0, _duration max 1]
    };
    _record set [0, _entries];
    _record set [2, false];
};

// How long this snapshot has been sitting on the client — added to each entry's
// elapsed-at-send to advance the progress readout between polls.
private _sinceRx = _now - _rxTime;

{
    _x params ["_unit", "_targets", "_elapsedAtSend", "_duration"];
    if (isNull _unit || {!alive _unit}) then { continue };

    // Anchor on the vehicle so a selected crewman draws from the hull, and read
    // the position live each frame — only the target list is snapshotted.
    private _veh     = vehicle _unit;
    private _from    = (getPosATLVisual _veh) vectorAdd [0, 0, 0.5];
    private _camDist = _camPos distance _from;
    if (_camDist > MAX_DRAW_DIST) then { continue };

    // Distant overlays recede instead of stacking into clutter
    private _color    = COLOR_SUPPLY_RGB + [linearConversion [FADE_NEAR, MAX_DRAW_DIST, _camDist, 1, 0.3, true]];
    private _progress = ((_elapsedAtSend + _sinceRx) / _duration) min 1;

    {
        // A kill between server ticks drops the line on the spot rather than
        // leaving it pointing at the wreck until the next snapshot
        if (isNull _x || {!alive _x}) then { continue };

        private _to = (getPosATLVisual _x) vectorAdd [0, 0, 0.5];
        drawLine3D [_from, _to, _color];

        // Label only near the cursor — a percentage over every vehicle in a
        // serviced column is noise
        private _text = "";
        private _scr  = worldToScreen _to;
        if (_scr isNotEqualTo [] && {_mouse distance2D _scr < LABEL_CURSOR_RADIUS}) then {
            _text = format ["%1 %2%3", LLSTRING(LabelServicing), round (_progress * 100), "%"];
        };

        drawIcon3D [
            ICON_RESUPPLY,
            _color,
            _to,
            ICON_SIZE_SERVICE, ICON_SIZE_SERVICE, 0,
            _text,
            1, LABEL_TEXT_SIZE, LABEL_FONT
        ];
    } forEach _targets;
} forEach _entries;
