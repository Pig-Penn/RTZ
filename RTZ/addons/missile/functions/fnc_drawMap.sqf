#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the same incoming-projectile markers on the Zeus map. Attached only while
 * GVAR(markers) is on (FUNC(start)), so there is no setting test per frame.
 *
 * The map pass exists because rtz_core skips RENDER_WORLD renderers while the map
 * covers the 3D view — without it, opening the map mid-flight would lose the
 * warning entirely.
 *
 * Arguments:
 * 0: Zeus Map Control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrlMap] call rtz_missile_fnc_drawMap
 *
 * Public: No
 */

params ["_ctrlMap"];

private _tracked = GVAR(tracked);
if (_tracked isEqualTo []) exitWith {};

[CBA_missionTime] call FUNC(pruneTracked);

private _drawLine = GVAR(drawLine);

{
    _x params ["_missile", "_target", "_color"];

    private _anchor = if (isNull _missile) then {
        getPosASLVisual _target
    } else {
        getPosASLVisual _missile
    };

    if (count _anchor < 3) then {continue};

    private _col = [_color select 0, _color select 1, _color select 2, 1];

    if (_drawLine && {!isNull _missile}) then {
        private _targetPos = getPosASLVisual _target;

        if (count _targetPos > 2) then {
            _ctrlMap drawLine [_anchor, _targetPos, _col, LINE_WIDTH_MAP];
        };
    };

    _ctrlMap drawIcon [ICON_MISSILE, _col, _anchor, ICON_SIZE_MAP, ICON_SIZE_MAP, 0];
} forEach _tracked;
