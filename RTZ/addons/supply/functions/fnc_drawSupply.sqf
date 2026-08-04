#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Supply-lines renderer: draws a line from each watched supply vehicle to
 * every vehicle it is currently servicing. The line doubles as the progress bar —
 * it is drawn bright from the supply vehicle up to the progress point and dim for
 * the remainder — and the resupply icon rides the MIDPOINT of that line, showing
 * the exact percentage while the cursor is near it. Registered as a RENDER_WORLD
 * renderer on EFUNC(core,frameLoop), which resolves the Zeus test, the camera
 * position and the mouse position once for every display — so this pays for none
 * of it, and is skipped entirely while the Zeus map covers the 3D view.
 *
 * Nothing is drawn ON the serviced vehicle, and that is deliberate: Zeus draws its
 * own icon over every unit it can edit, the engine puts it on top of anything a
 * script draws, and it cannot be moved — so an icon anchored to the target hull is
 * hidden behind exactly the thing it is annotating. See SERVICE_ICON_LIFT in
 * script_component.hpp.
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
 * 0: Frame context, see the CTX_* indices in main's script_macros.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_supply_fnc_drawSupply
 *
 * Public: No
 */

params ["_ctx"];

private _record = EGVAR(core,streamData) get STREAM_SUPPLY;
if (isNil "_record") exitWith {};                       // no snapshot yet

_record params ["_entries", "_rxTime", "_dirty", "_refTime"];
if (_entries isEqualTo []) exitWith {};

private _camPos = _ctx select CTX_CAMPOS;
private _mouse  = _ctx select CTX_MOUSE;
private _now    = _ctx select CTX_NOW;

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
    private _alpha    = linearConversion [FADE_NEAR, MAX_DRAW_DIST, _camDist, 1, 0.3, true];
    private _color    = COLOR_SUPPLY_RGB + [_alpha];
    private _pending  = COLOR_SUPPLY_RGB + [_alpha * LINE_PENDING_ALPHA];
    private _progress = ((_elapsedAtSend + _sinceRx) / _duration) min 1;

    {
        // A kill between server ticks drops the line on the spot rather than
        // leaving it pointing at the wreck until the next snapshot
        if (isNull _x || {!alive _x}) then { continue };

        private _to = (getPosATLVisual _x) vectorAdd [0, 0, 0.5];

        // The line IS the progress bar: bright from the supply vehicle out to the
        // progress point, dim the rest of the way. One order services every target
        // on the same clock, so the whole fan fills in step and a glance at any
        // single line reads the job.
        private _split = _from vectorAdd ((_to vectorDiff _from) vectorMultiply _progress);
        drawLine3D [_from, _split, _color];
        drawLine3D [_split, _to, _pending];

        // Midpoint, lifted — clear of the Zeus icons sitting on both hulls.
        private _iconPos = ((_from vectorAdd _to) vectorMultiply 0.5) vectorAdd [0, 0, SERVICE_ICON_LIFT];

        // Exact percentage only near the cursor — a readout on every line of a
        // serviced column is noise, and the fill above already carries the gist
        private _text = "";
        private _scr  = worldToScreen _iconPos;
        if (_scr isNotEqualTo [] && {_mouse distance2D _scr < LABEL_CURSOR_RADIUS}) then {
            _text = format ["%1 %2%3", LLSTRING(LabelServicing), round (_progress * 100), "%"];
        };

        drawIcon3D [
            ICON_RESUPPLY,
            _color,
            _iconPos,
            ICON_SIZE_SERVICE, ICON_SIZE_SERVICE, 0,
            _text,
            1, LABEL_TEXT_SIZE, LABEL_FONT
        ];
    } forEach _targets;
} forEach _entries;
