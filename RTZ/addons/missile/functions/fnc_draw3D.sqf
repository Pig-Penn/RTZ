#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer drawing a marker on each incoming projectile, with a line
 * back to the unit it is tracking.
 *
 * Registered with rtz_core's frame loop, and only while GVAR(markers) is on
 * (FUNC(start)), so there is no setting test per frame here. The one thing the loop
 * needs — the side colour — was baked by FUNC(receiveTrack) and is drawn with as-is;
 * this pass reads no config, builds no strings and allocates nothing per record.
 *
 * Positions are read as ASL and converted at the draw. getPosATLVisual would
 * measure from the seabed over water, which is exactly where an anti-ship missile
 * is.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in core's script_macros_core.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_missile_fnc_draw3D
 *
 * Public: No
 */

params ["_ctx"];

private _tracked = GVAR(tracked);
if (_tracked isEqualTo []) exitWith {};

[_ctx select CTX_NOW] call FUNC(pruneTracked);

(_ctx select CTX_CAMPOS) params ["_camX", "_camY"];

private _drawLine = GVAR(drawLine);
private _maxDistance = GVAR(maxDistance) ^ 2;

// REC_COLOR is EFUNC(common,sideColor)'s answer, which is ALREADY [r, g, b, 1], so
// it is handed to the draw commands as-is. The [_c#0, _c#1, _c#2, 1] this loop used
// to rebuild per record per frame reproduced it exactly.
//
// It is a SHARED read-only reference into rtz_common's palette, and passing it
// straight through is safe because none of drawIcon3D / drawLine3D writes back into
// a colour argument. Anything that ever wants a varying alpha must build a copy.
{
    _x params ["_missile", "_target", "_color", "", "", "_kind", "_fallback"];

    // The record survived the prune, so a null projectile here means the anchor is
    // something other than a flying object: the threatened unit, for a missile that
    // has not resolved on this machine, or for a grenade — whose marker is STATIC by
    // design and whose object slots are objNull for its whole life — the aim point.
    private _anchorASL = if (!isNull _missile) then {
        getPosASLVisual _missile
    } else {
        if (isNull _target) then {_fallback} else {getPosASLVisual _target}
    };

    // Position commands return [] for a model that has not resolved on this machine
    // yet. Guarding is not optional: one error aborts the whole forEach and drops
    // every record after this one.
    if (count _anchorASL < 3) then {continue};

    // 2D cull written out rather than through distance2D, which would build a
    // throwaway position array per record per frame
    private _dx = (_anchorASL select 0) - _camX;
    private _dy = (_anchorASL select 1) - _camY;

    if (_dx * _dx + _dy * _dy > _maxDistance) then {continue};

    private _anchor = ASLToAGL _anchorASL;

    // Branches rather than `[A, B] select _kind`, which would build two throwaway
    // arrays per record per frame.
    private _icon = ICON_MISSILE;
    private _size = ICON_SIZE_3D;

    if (_kind == KIND_GRENADE) then {
        _icon = ICON_GRENADE;
        _size = ICON_GRENADE_SIZE_3D;
    };

    drawIcon3D [_icon, _color, _anchor, _size, _size, 0];

    // The line is what makes the marker mean "aimed at THAT unit" rather than
    // "a missile is over there". Skipped when the icon is already sitting on the
    // target, which is the fallback case — and always for a grenade, which has no
    // target object to point at.
    if (_drawLine && {!isNull _missile} && {!isNull _target}) then {
        // getPosASLVisual rather than unitAimPositionVisual: the latter resolves
        // through the crew's aim point and returns [] for an empty hull, and this
        // line only needs to point at the right object, not at its turret ring.
        private _targetASL = getPosASLVisual _target;

        if (count _targetASL > 2) then {
            drawLine3D [_anchor, (ASLToAGL _targetASL) vectorAdd [0, 0, 0.5], _color, LINE_WIDTH_3D];
        };
    };
} forEach _tracked;
