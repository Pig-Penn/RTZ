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
    private _pos = ASLToAGL getPosASL _x;
    // Lift the icon off the ground so it stays readable over the mine model
    _pos set [2, (_pos select 2) + ICON_OFFSET_Z];
    _pos
};
