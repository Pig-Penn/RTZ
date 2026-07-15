#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws an icon on each cached spotted mine. Called every frame.
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

if (!GVAR(mark3D) || {GVAR(mines) isEqualTo []}) exitWith {};

private _camPos = positionCameraToWorld [0, 0, 0];
private _maxDistance = GVAR(maxDistance);

{
    _x params ["_mine", "_pos"];

    if (!isNull _mine && {_pos distance2D _camPos <= _maxDistance}) then {
        drawIcon3D [GVAR(icon), COLOR_MINE, _pos, ICON_SIZE_3D, ICON_SIZE_3D, 0];
    };
} forEach GVAR(mines);
