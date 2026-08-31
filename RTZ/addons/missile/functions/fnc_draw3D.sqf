#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer drawing a marker on each incoming projectile, with a line
 * back to the unit it is tracking.
 *
 * Registered with rtz_core's frame loop, and only while GVAR(markers) is on
 * (FUNC(start)), so there is no setting test per frame here. The one thing the
 * loop needs — the side colour — was baked by FUNC(receiveIncoming); this pass
 * reads config and builds no strings.
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

{
    _x params ["_missile", "_target", "_color"];

    // The record survived the prune, so a null projectile here means the fallback
    // case: mark the threatened unit instead of the missile that never arrived.
    private _anchorASL = if (isNull _missile) then {
        getPosASLVisual _target
    } else {
        getPosASLVisual _missile
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
    private _col = [_color select 0, _color select 1, _color select 2, 1];

    drawIcon3D [ICON_MISSILE, _col, _anchor, ICON_SIZE_3D, ICON_SIZE_3D, 0];

    // The line is what makes the marker mean "aimed at THAT unit" rather than
    // "a missile is over there". Skipped when the icon is already sitting on the
    // target, which is the fallback case.
    if (_drawLine && {!isNull _missile}) then {
        // getPosASLVisual rather than unitAimPositionVisual: the latter resolves
        // through the crew's aim point and returns [] for an empty hull, and this
        // line only needs to point at the right object, not at its turret ring.
        private _targetASL = getPosASLVisual _target;

        if (count _targetASL > 2) then {
            drawLine3D [_anchor, (ASLToAGL _targetASL) vectorAdd [0, 0, 0.5], _col, LINE_WIDTH_3D];
        };
    };
} forEach _tracked;
