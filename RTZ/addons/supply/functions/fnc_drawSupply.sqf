#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Supply-lines renderer: draws a line from each watched supply vehicle to
 * every vehicle it is currently servicing. The line doubles as the progress bar —
 * it is drawn bright from the supply vehicle up to the progress point and dim for
 * the remainder. Registered as a RENDER_WORLD renderer on EFUNC(core,frameLoop),
 * which resolves the Zeus test, the camera position and the mouse position once
 * for every display — so this pays for none of it, and is skipped entirely while
 * the Zeus map covers the 3D view.
 *
 * LINES ONLY, no icon and no label. There used to be a resupply glyph riding the
 * midpoint of each line, captioned with the exact percentage while the cursor was
 * near it. It was removed as clutter: the fill already reads the job at a glance,
 * and a column being serviced hung a row of glyphs across the middle of the Zeus
 * view. Nothing here is anchored to a hull either — Zeus draws its own icon over
 * every unit it can edit, the engine puts it on top of anything a script draws,
 * and it cannot be moved, so an icon on the target is hidden behind exactly the
 * thing it annotates.
 *
 * A fresh snapshot is baked once, on the first frame after it lands: the server's
 * absolute start time becomes an elapsed-at-send figure, which is then advanced
 * every frame by however long the snapshot has been sitting here. That is what
 * makes the fill climb smoothly between polls while an unchanging order still
 * costs nothing on the wire — see FUNC(gatherSupply).
 *
 * Baked entry: [unit, targets, elapsedAtSend, duration].
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in core's script_macros_core.hpp <ARRAY>
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
// elapsed-at-send to advance the fill between polls.
private _sinceRx = _now - _rxTime;

{
    _x params ["_unit", "_targets", "_elapsedAtSend", "_duration"];
    if (isNull _unit || {!alive _unit}) then { continue };

    // Anchor on the vehicle so a selected crewman draws from the hull, and read
    // the position live each frame — only the target list is snapshotted.
    //
    // ASLToAGL, NOT getPosATLVisual: drawLine3D takes AGL, whose Z is measured
    // from the WATER SURFACE over sea, while ATL measures from the terrain —
    // which under water is the seabed. A supply boat, an amphibious hull or
    // anything servicing over water drew its whole fan lifted by the water
    // depth. Same idiom rtz_mine, rtz_path and rtz_common already use.
    private _veh     = vehicle _unit;
    private _from    = (ASLToAGL getPosASLVisual _veh) vectorAdd [0, 0, 0.5];
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

        // AGL, for the same reason as _from above — and both ends of one line
        // must be in the same space or it skews as well as lifts.
        private _to = (ASLToAGL getPosASLVisual _x) vectorAdd [0, 0, 0.5];

        // The line IS the progress bar: bright from the supply vehicle out to the
        // progress point, dim the rest of the way. One order services every target
        // on the same clock, so the whole fan fills in step and a glance at any
        // single line reads the job.
        private _split = _from vectorAdd ((_to vectorDiff _from) vectorMultiply _progress);
        drawLine3D [_from, _split, _color];
        drawLine3D [_split, _to, _pending];
    } forEach _targets;
} forEach _entries;
