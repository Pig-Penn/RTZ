#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer drawing an icon on each cached spotted mine. Called every
 * frame, so it does as little as it can get away with: the cache is already a
 * flat list of validated positions (FUNC(refreshMines)), the icon and the squared
 * cull range are hoisted out of the loop, and the range test is done on squared
 * distances so a minefield costs no square roots per frame.
 *
 * Registered with EFUNC(core,frameLoop) — and only while GVAR(mark3D) is on
 * (FUNC(start)) — so there is no setting test here either. Riding the shared
 * frame loop rather than a Draw3D handler of its own gets three things this pass
 * used to lack: the camera position arrives already resolved (it used to make its
 * own positionCameraToWorld call alongside every other display making theirs),
 * the icons are confined to the Zeus view instead of also drawing in first person
 * for a curator who is playing, and the pass is skipped entirely while the Zeus
 * map covers the 3D view — where these have their own map markers anyway
 * (FUNC(drawMap)).
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in main's script_macros.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_mine_fnc_draw3D
 *
 * Public: No
 */

params ["_ctx"];

private _mines = GVAR(mines);
if (_mines isEqualTo []) exitWith {};

(_ctx select CTX_CAMPOS) params ["_camX", "_camY"];

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
