#include "script_component.hpp"
/*
 * Author: Maxim
 * Installs the curator-display handlers a placement session listens on, and
 * hands back their ids so FUNC(endPlacement) can remove precisely these and
 * leave ZEN's own handlers on the same display alone. Never
 * displayRemoveAllEventHandlers: ZEN has handlers here too and they must survive
 * this session.
 *
 * Every handler returns whether it consumed the press. Consuming is the
 * exception, not the rule: a left click that is not on a ghost has to reach the
 * Zeus display underneath or the curator loses the ability to select anything
 * while the mode is open. Only a grab, a release, Escape and the two Enter keys
 * are swallowed.
 *
 * There is deliberately no "ignore the frame we started on" guard of the kind
 * EFUNC(common,placementPreview) needs. That guard exists because a picker is
 * opened by clicking a context-menu entry, and the same click would otherwise
 * confirm it instantly; this mode is opened by a keybind, and CBA keybinds
 * cannot be bound to a mouse button. rtz_path makes the same point.
 *
 * No modifier state is tracked. Nothing in this session reads Shift, Ctrl or
 * Alt, so there is no KeyUp handler either — rtz_path carries one purely to keep
 * its modifier globals honest, and a no-op copy of it here would be a handler on
 * the curator display earning nothing.
 *
 * Arguments:
 * 0: Curator Display <DISPLAY>
 *
 * Return Value:
 * Installed handlers as [[eventType, id], ...] <ARRAY>
 *
 * Example:
 * GVAR(inputEHs) = [_display] call rtz_place_fnc_handleInput
 *
 * Public: No
 */

params ["_display"];

private _handlers = [];

// Take hold of the ghost under the cursor. GVAR(hovered) is resolved by the
// renderer, which already holds the camera basis and the mouse position from
// rtz_core's shared frame context — so the hit test is paid for once per frame
// there rather than recomputed here on every click.
_handlers pushBack ["MouseButtonDown", _display displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button"];

    if (_button != 0) exitWith {false};
    if (!GVAR(placing)) exitWith {false};

    // Nothing is grabbable while the Zeus map covers the 3D view: the renderer
    // that resolves GVAR(hovered) does not run there (rtz_core skips the world
    // pass on visibleMap), so the value under it is whatever the last 3D frame
    // left behind. Acting on it would drag a ghost the curator cannot see, to a
    // point picked by a cursor ray into a hidden scene.
    if (visibleMap) exitWith {false};

    // Only a press in the world view is a grab. A display-level handler is fed
    // presses that land on the curator's panels as well, and the renderer's
    // projection says nothing about whether a panel is drawn over the result, so
    // a ghost that happened to land under the create tree was grabbable straight
    // through it. Guarded here rather than in the renderer because the renderer's
    // answer is also what the hover highlight is drawn from, and that should keep
    // tracking. See EFUNC(common,placementPreview) and rtz_path.
    //
    // False, not true — the press belongs to the control under it.
    if (!call zen_common_fnc_isCursorOnMouseArea) exitWith {false};

    private _hovered = GVAR(hovered);
    if (_hovered < 0) exitWith {false};

    GVAR(grabbed) = _hovered;
    true
}]];

// Let go. Deliberately NOT mouse-area-guarded, unlike the press: a drag begun in
// the world has to be able to end with the cursor anywhere — including over a
// panel the curator swept across on the way — or the ghost stays stuck to it.
_handlers pushBack ["MouseButtonUp", _display displayAddEventHandler ["MouseButtonUp", {
    params ["", "_button"];

    if (_button != 0) exitWith {false};
    if (GVAR(grabbed) < 0) exitWith {false};

    GVAR(grabbed) = -1;
    true
}]];

_handlers pushBack ["KeyDown", _display displayAddEventHandler ["KeyDown", {
    params ["", "_key"];

    if (!GVAR(placing)) exitWith {false};

    // Escape closes the session without moving anything, and is swallowed so it
    // does not also open the pause menu on the way out.
    if (_key == DIK_ESCAPE) exitWith {
        [] call FUNC(endPlacement);
        true
    };

    // Either Enter commits. A curator reaching for "confirm" hits whichever one
    // their hand is nearest, and a mode that answers to only one of them reads as
    // broken. Shift + T commits too, through the keybind rather than here.
    if (_key in [DIK_RETURN, DIK_NUMPADENTER]) exitWith {
        [true] call FUNC(endPlacement);
        true
    };

    false
}]];

_handlers
