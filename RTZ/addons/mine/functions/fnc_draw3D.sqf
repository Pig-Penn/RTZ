#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws an icon on each cached spotted mine. Called every frame, so it does as
 * little as it can get away with: the cache is already a flat list of validated
 * positions (FUNC(refreshMines)), the icon and the squared cull range are hoisted
 * out of the loop, and the range test is done on squared distances so a minefield
 * costs no square roots per frame.
 *
 * The handler is only registered while GVAR(mark3D) is on (FUNC(start)), so there
 * is no setting test here either.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_mine_fnc_draw3D
 *
 * Public: No
 */

private _mines = GVAR(mines);
if (_mines isEqualTo []) exitWith {};

(positionCameraToWorld [0, 0, 0]) params ["_camX", "_camY"];

private _icon = GVAR(icon);
private _maxDistance = GVAR(maxDistance) ^ 2;

{
    // 2D cull, written out rather than via distance2D/distanceSqr: both would
    // build a throwaway position array per mine per frame just to compare a
    // number this already has
    private _dx = (_x select 0) - _camX;
    private _dy = (_x select 1) - _camY;

    if (_dx * _dx + _dy * _dy <= _maxDistance) then {
        drawIcon3D [_icon, COLOR_MINE, _x, ICON_SIZE_3D, ICON_SIZE_3D, 0];
    };
} forEach _mines;
