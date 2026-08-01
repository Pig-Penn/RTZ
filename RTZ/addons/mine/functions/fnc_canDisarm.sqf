#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a clear mines order is possible: at least one selected group can clear
 * mines and there is a mine near the context menu position that the order would
 * ACTUALLY get cleared. Drives the visibility of the context menu action.
 *
 * The distinction matters. With GVAR(clearHidden) off, the vanilla demine
 * behaviour only defuses mines the group's own side has DETECTED — so testing
 * allMines, as this used to, offered the action for enemy mines the group would
 * then walk straight past and ignore. Each side's detected list is also far
 * shorter than the map-wide one, so the honest test is the cheap one too.
 *
 * Arguments:
 * 0: Context Position ASL <ARRAY>
 * 1: Selected Objects <ARRAY>
 *
 * Return Value:
 * Order Possible <BOOL>
 *
 * Example:
 * [_position, _objects] call rtz_mine_fnc_canDisarm
 *
 * Public: No
 */

params ["_position", "_objects"];

if (!GVAR(enabled)) exitWith {false};

private _groups = [_objects] call FUNC(getDeminers);
if (_groups isEqualTo []) exitWith {false};

private _pos = ASLToAGL _position;

// Sweeping for undetected mines looks at everything on the map; otherwise only
// what the ordered sides already know about. A mixed selection qualifies as soon
// as any one of its sides has spotted something here.
private _mines = if (GVAR(clearHidden)) then {
    allMines
} else {
    private _sides = [];
    {_sides pushBackUnique (side _x)} forEach _groups;

    private _detected = [];
    {_detected append (detectedMines _x)} forEach _sides;

    _detected
};

_mines findIf {mineActive _x && {_x distance2D _pos <= SEARCH_RADIUS}} != -1
