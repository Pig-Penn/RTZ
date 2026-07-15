#include "script_component.hpp"
/*
 * Author: Maxim
 * Rebuilds the cache of active mines detected by the configured side.
 * Mines are static, so their draw positions are cached with them.
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

if (!GVAR(mark3D) && {!GVAR(markMap)}) exitWith {GVAR(mines) = []};

private _sides = switch (GVAR(markSide)) do {
    case "west": {[west]};
    case "east": {[east]};
    case "independent": {[independent]};
    case "civilian": {[civilian]};
    case "all": {[west, east, independent, civilian]};
    default {[side group player]};
};

private _mines = [];

{
    _mines append detectedMines _x;
} forEach _sides;

// Mines spotted by several sides appear once per side
if (count _sides > 1) then {
    _mines = _mines arrayIntersect _mines;
};

GVAR(mines) = (_mines select {mineActive _x}) apply {
    private _pos = ASLToAGL getPosASL _x;
    _pos set [2, (_pos select 2) + ICON_OFFSET_Z];
    [_x, _pos]
};
