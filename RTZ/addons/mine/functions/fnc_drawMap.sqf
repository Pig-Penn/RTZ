#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws an icon on each cached spotted mine on the Zeus map.
 *
 * Arguments:
 * 0: Zeus Map Control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrlMap] call rtz_mine_fnc_drawMap
 *
 * Public: No
 */

params ["_ctrlMap"];

if (!GVAR(markMap) || {GVAR(mines) isEqualTo []}) exitWith {};

{
    _x params ["_mine", "_pos"];

    if (!isNull _mine) then {
        _ctrlMap drawIcon [GVAR(icon), COLOR_MINE, _pos, ICON_SIZE_MAP, ICON_SIZE_MAP, 0];
    };
} forEach GVAR(mines);
