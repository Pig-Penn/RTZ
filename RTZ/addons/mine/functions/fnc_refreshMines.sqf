#include "script_component.hpp"
/*
 * Author: Maxim
 * Rebuilds the cache of active mines detected by the curator's side.
 *
 * The cache holds bare draw POSITIONS, not the mine objects. Mines do not move, so
 * their position is resolved once here rather than every frame, and because this
 * revalidates and prunes the whole list on every refresh the draw handlers need no
 * liveness test of their own — that check would otherwise repeat, per mine, per
 * frame, work this already did.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_mine_fnc_refreshMines
 *
 * Public: No
 */

GVAR(mines) = (detectedMines (side group player)) select {
    !isNull _x && {mineActive _x}
} apply {
    // NO VERTICAL LIFT. The obvious "raise it off the ground so it reads over the
    // mine model" is a world-METRE offset, and drawIcon3D draws the icon at a
    // FIXED SCREEN SIZE - so the gap it opens on screen is 0.5 / (distance *
    // tan(vFOV/2)) and belongs to the camera, not to the marker. First person is
    // locked to a wide FOV at infantry ranges, where half a metre lands on the
    // model; the Zeus camera zooms freely, and at a narrow FOV that same half
    // metre threw the icon hundreds of pixels up into the sky, still aligned over
    // a mine it had visibly detached from. Top-down it collapsed to nothing
    // instead. A constant screen gap would have to be measured per frame the way
    // rtz_hud measures its per-metre scale; centring the icon on the mine needs no
    // measurement and cannot come apart at any zoom or angle.
    ASLToAGL getPosASL _x
};
