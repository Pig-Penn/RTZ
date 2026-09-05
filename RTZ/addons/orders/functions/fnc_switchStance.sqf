#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: sets the stance of the Zeus-selected AI infantry without
 * opening ZEN's "Stance" context-menu action first. Men on foot only —
 * vehicles, crews and player units are skipped, matching setUnitPos's scope.
 *
 * setUnitPos is a local-effect command, so each unit gets a
 * QGVAR(switchStance) event targeted at the unit itself — CBA delivers it to
 * whatever machine the unit is local to (server, headless client, or a
 * remote-controlling player), so no locality checks or server round-trip are
 * needed (handler registered on every machine in XEH_postInit). No
 * `unitPos _x == _stance` pre-filter: unitPos is only authoritative where the
 * unit is local, so the curator's read may be stale — a redundant setUnitPos
 * is a harmless no-op, a wrongly skipped one is a dead keybind.
 *
 * Arguments:
 * 0: Stance mode: "UP", "MIDDLE", "DOWN" or "AUTO" <STRING> (default: "AUTO")
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * ["DOWN"] call rtz_orders_fnc_switchStance
 *
 * Public: No
 */

params [["_stance", "AUTO", [""]]];

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

private _units = SELECTED_OBJECTS select {
    _x isKindOf "CAManBase"
    && { alive _x }
    && { !isPlayer _x }
    && { isNull objectParent _x }
};
if (_units isEqualTo []) exitWith {false};

// Feedback matches ZEN's switchStance: a stance icon over each unit
private _iconProperties = switch (_stance) do {
    case "UP":     { [STANCE_ICON_UP, [1, 1, 1, 1], 1.5] };
    case "MIDDLE": { [STANCE_ICON_MIDDLE, [1, 1, 1, 1], 1.5] };
    case "DOWN":   { [STANCE_ICON_DOWN, [1, 1, 1, 1], 1.5] };
    default        { [STANCE_ICON_AUTO, [1, 1, 1, 1], 1] };
};

{
    [QGVAR(switchStance), [_x, _stance], _x] call CBA_fnc_targetEvent;

    [[
        ["ICON", [_x] + _iconProperties]
    ], HINT_DURATION, _x, 1] call zen_common_fnc_drawHint;
} forEach _units;

true
