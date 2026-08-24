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
 * One modifier is read differently: the Shift that turns a drag into a ROTATION
 * is latched at mouse-down rather than read live, because it decides which
 * gesture is under way rather than modifying one already in progress. See the
 * handler for what reading it live would do.
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

    // Only a press in the world view — or on the map, which this mode also draws to
    // and which zen_common_fnc_isCursorOnMouseArea admits — can be a grab or a cut.
    // GVAR(hovered) and GVAR(hoveredPoint) are resolved by projecting handles into
    // screen space, which says nothing about whether a panel is drawn over the
    // result, so a handle that happened to land under the create tree was grabbable
    // straight through it. Guarded here rather than in the renderer because the
    // renderer's answer is also what the hover highlight is drawn from, and that
    // should keep tracking. See EFUNC(common,placementPreview).
    //
    // The release below is deliberately NOT guarded the same way: a drag begun in
    // the world has to be able to end with the cursor anywhere, or the handle
    // stays stuck to it.
    if (!call zen_common_fnc_isCursorOnMouseArea) exitWith {false};

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

    // A new drag starts from the altitude the handle already has, never from
    // whatever the previous one had banked and not spent (FUNC(airTarget))
    GVAR(altDrag) = 0;

    // Taking hold of a handle ends any formation trailing it was doing. From
    // here the path is the curator's, and FUNC(formationTrail) will not touch
    // it again.
    private _index = GVAR(paths) findIf {(_x select PATH_UNIT) isEqualTo _hovered};
    if (_index != -1) then {
        private _path = GVAR(paths) select _index;
        _path set [PATH_LEADER, objNull];

        // Shift on the way IN turns the drag into a rotation: the cursor sets
        // which way the subject faces rather than where it goes, which is the
        // direction a tactical stretch of path is then walked facing.
        //
        // Armed here and only here, so the gesture is decided by what was held
        // when the handle was taken. A modifier read live would let a Shift
        // pressed mid-trace silently stop the path growing, and a Shift released
        // mid-rotation turn the rotation into a trace from wherever the cursor
        // had wandered to.
        //
        // Infantry only, exactly as Wargame gates it — and that gate is also
        // what keeps Shift free to mean road magnetisation on a land path and
        // coarse altitude on an air one.
        GVAR(rotating) = _shift && {(_path select PATH_KIND) == KIND_INFANTRY};
    };

    true
}]];

_handlers pushBack ["MouseButtonUp", _display displayAddEventHandler ["MouseButtonUp", {
    params ["", "_button", "", "", "_shift", "_ctrl", "_alt"];
    GVAR(mods) = [_shift, _ctrl, _alt];

    if (_button != 0) exitWith {false};
    if (isNull GVAR(grabbed)) exitWith {false};

    GVAR(grabbed) = objNull;
    GVAR(rotating) = false;
    GVAR(altDrag) = 0;
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
