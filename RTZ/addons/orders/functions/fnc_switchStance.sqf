#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: raises or lowers the stance of the Zeus-selected AI infantry
 * one rung at a time — prone, crouched, standing — without opening ZEN's
 * "Stance" context-menu action first, or releases them back to AUTO. Men on
 * foot only — vehicles, crews and player units are skipped, matching
 * setUnitPos's scope.
 *
 * setUnitPos is a local-effect command, so each unit gets a
 * QGVAR(switchStance) event targeted at the unit itself — CBA delivers it to
 * whatever machine the unit is local to (server, headless client, or a
 * remote-controlling player), so no locality checks or server round-trip are
 * needed (handler registered on every machine in XEH_postInit).
 *
 * The rung a step starts from CANNOT come from unitPos: it is only
 * authoritative where the unit is local, so the curator's read is stale
 * whenever the unit lives on the server or a headless client — the usual case.
 * The ordered stance is therefore tracked in a public per-unit variable, the
 * same way FUNC(toggleCombatMode) tracks fire discipline. It is written HERE,
 * on the curator's own machine, rather than in the event handler: a curator
 * taps these keys, and a value that only came back after a round trip would
 * make every second press of a fast double-tap re-issue the first one's stance.
 * The broadcast then carries it to the other machines (and to JIP clients).
 *
 * A unit with no order yet reads AUTO, and the rung is taken from the stance he
 * is actually in — `stance` is animation-derived, so unlike unitPos it answers
 * the same everywhere. So the first press steps from what the curator can see.
 *
 * Arguments:
 * 0: Order: "RAISE", "LOWER" or "AUTO" <STRING> (default: "AUTO")
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * ["RAISE"] call rtz_orders_fnc_switchStance
 *
 * Public: No
 */

params [["_order", "AUTO", [""]]];

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

private _units = SELECTED_OBJECTS select {
    _x isKindOf "CAManBase"
    && { alive _x }
    && { !isPlayer _x }
    && { isNull objectParent _x }
};
if (_units isEqualTo []) exitWith {false};

private _dir = switch (_order) do {
    case "RAISE": {1};
    case "LOWER": {-1};
    default {0};
};

private _ladder = STANCE_LADDER;
private _top = (count _ladder) - 1;

{
    private _stance = "AUTO";

    if (_dir != 0) then {
        private _current = _x getVariable [QGVAR(stance), "AUTO"];

        if (_current isEqualTo "AUTO") then {
            _current = switch (stance _x) do {
                case "PRONE":  {"DOWN"};
                case "CROUCH": {"MIDDLE"};
                default        {"UP"};
            };
        };

        // Clamped, not wrapped: holding the key at either end of the ladder
        // must sit there, not flip the man from prone to standing.
        _stance = _ladder select (((_ladder find _current) + _dir) max 0 min _top);
    };

    _x setVariable [QGVAR(stance), _stance, true];

    [QGVAR(switchStance), [_x, _stance], _x] call CBA_fnc_targetEvent;

    // Feedback matches ZEN's switchStance: a stance icon over each unit
    private _iconProperties = switch (_stance) do {
        case "UP":     { [STANCE_ICON_UP, [1, 1, 1, 1], 1.5] };
        case "MIDDLE": { [STANCE_ICON_MIDDLE, [1, 1, 1, 1], 1.5] };
        case "DOWN":   { [STANCE_ICON_DOWN, [1, 1, 1, 1], 1.5] };
        default        { [STANCE_ICON_AUTO, [1, 1, 1, 1], 1] };
    };

    [[
        ["ICON", [_x] + _iconProperties]
    ], HINT_DURATION, _x, 1] call zen_common_fnc_drawHint;
} forEach _units;

true
