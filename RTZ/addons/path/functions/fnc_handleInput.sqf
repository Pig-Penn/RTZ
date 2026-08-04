#include "script_component.hpp"
/*
 * Author: Maxim
 * Installs the curator-display handlers path planning listens on, and hands
 * back their ids so FUNC(endPlanning) can remove precisely these and leave ZEN's
 * own handlers on the same display alone.
 *
 * Every handler returns whether it consumed the press. Consuming is the
 * exception, not the rule: a left click that is not on a drag handle has to
 * reach the Zeus display underneath or the curator loses the ability to select
 * anything while the mode is open. Only a grab, a release and Escape are
 * swallowed.
 *
 * Modifier state is republished from these events into GVAR(mods) instead of
 * being tracked in globals of its own. KeyDown/KeyUp fire for the modifier keys
 * themselves, so holding Shift with no other key still updates the state, and
 * the mouse events refresh it as well — which repairs the one stale case, a
 * modifier released while the display did not have focus.
 *
 * There is deliberately no "ignore the frame we started on" guard of the kind
 * EFUNC(common,placementPreview) needs. That guard exists because a picker is
 * opened by clicking a context-menu entry, and the same click would otherwise
 * confirm it instantly; this mode is opened by a keybind, and CBA keybinds
 * cannot be bound to a mouse button.
 *
 * Arguments:
 * 0: Curator Display <DISPLAY>
 *
 * Return Value:
 * Installed handlers as [[eventType, id], ...] <ARRAY>
 *
 * Example:
 * GVAR(inputEHs) = [_display] call rtz_path_fnc_handleInput
 *
 * Public: No
 */

params ["_display"];

private _handlers = [];

// Grab the handle under the cursor. GVAR(hovered) is resolved by the renderer,
// which already holds the camera basis and the mouse position from rtz_core's
// shared frame context — so the hit test is paid for once per frame there rather
// than recomputed here on every click.
_handlers pushBack ["MouseButtonDown", _display displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button", "", "", "_shift", "_ctrl", "_alt"];
    GVAR(mods) = [_shift, _ctrl, _alt];

    if (_button != 0) exitWith {false};

    // Ctrl-click on a path point cuts the path back to it. Tested before the
    // grab, because a point near a handle should cut rather than start a drag
    // that immediately re-draws what was just removed.
    private _point = GVAR(hoveredPoint);
    if (_ctrl && {_point isNotEqualTo []}) exitWith {
        [_point select 0, _point select 1] call FUNC(cutPath);
        true
    };

    private _hovered = GVAR(hovered);
    if (isNull _hovered) exitWith {false};

    GVAR(grabbed) = _hovered;

    // Taking hold of a handle ends any formation trailing it was doing. From
    // here the path is the curator's, and FUNC(formationTrail) will not touch
    // it again.
    private _index = GVAR(paths) findIf {(_x select PATH_UNIT) isEqualTo _hovered};
    if (_index != -1) then {
        (GVAR(paths) select _index) set [PATH_LEADER, objNull];
    };

    true
}]];

_handlers pushBack ["MouseButtonUp", _display displayAddEventHandler ["MouseButtonUp", {
    params ["", "_button", "", "", "_shift", "_ctrl", "_alt"];
    GVAR(mods) = [_shift, _ctrl, _alt];

    if (_button != 0) exitWith {false};
    if (isNull GVAR(grabbed)) exitWith {false};

    GVAR(grabbed) = objNull;
    true
}]];

_handlers pushBack ["KeyDown", _display displayAddEventHandler ["KeyDown", {
    params ["", "_key", "_shift", "_ctrl", "_alt"];
    GVAR(mods) = [_shift, _ctrl, _alt];

    // Escape closes the session without ordering anything, and is swallowed so
    // it does not also open the pause menu on the way out.
    if (_key == DIK_ESCAPE) exitWith {
        [] call FUNC(endPlanning);
        true
    };

    // Delete clears the path under the cursor — a cut at the beginning of it.
    // With nothing hovered the key is passed through rather than being read as
    // "clear everything", which is not a thing a curator can undo.
    if (_key == DIK_DELETE) exitWith {
        private _hovered = GVAR(hovered);
        if (isNull _hovered) exitWith {false};
        [_hovered, 0] call FUNC(cutPath);
        true
    };

    false
}]];

// Exists only to keep GVAR(mods) honest — a modifier is released far more often
// than it is pressed while the cursor is being dragged.
_handlers pushBack ["KeyUp", _display displayAddEventHandler ["KeyUp", {
    params ["", "", "_shift", "_ctrl", "_alt"];
    GVAR(mods) = [_shift, _ctrl, _alt];
    false
}]];

_handlers
