#include "script_component.hpp"
/*
 * Author: Maxim
 * Installs the curator-display handlers the aim session listens on, and hands back
 * their ids so FUNC(endAiming) can remove precisely these and leave ZEN's own
 * handlers on the same display alone.
 *
 * Consuming a press is the exception. The gesture's own three events are swallowed so
 * the Zeus display underneath does not also act on them; everything else passes
 * through.
 *
 * Arguments:
 * 0: Curator display <DISPLAY>
 *
 * Return Value:
 * Installed handlers as [[eventType, id], ...] <ARRAY>
 *
 * Example:
 * private _handlers = [_display] call rtz_airstrike_fnc_handleAimInput
 *
 * Public: No
 */

params ["_display"];

private _handlers = [];

_handlers pushBack ["MouseButtonDown", _display displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button"];

    if (GVAR(aiming) isEqualTo []) exitWith {false};

    // Right button cancels.
    if (_button == 1) exitWith {
        call FUNC(endAiming);
        true
    };

    if (_button != 0) exitWith {false};

    // Frame guard, not a one-shot flag — see FUNC(beginAiming) for why. Index 5
    // holds the frame the session opened on; only a press on a LATER frame can be
    // a genuine target press, so every press on that starting frame is swallowed
    // here without touching the stored frame number.
    if (diag_frameNo <= (GVAR(aiming) select 5)) exitWith {true};

    // Only a press in the world view aims. This handler is fed presses that land on
    // the curator's panels too, and getPosFromScreen defaults to getMousePosition,
    // which reports a point over the create tree as readily as one over terrain — so
    // without this, clicking a class in the tree latched an aim point from whatever
    // was projected under the panel and opened the gesture on it. ZEN guards its own
    // picker the same way (zen_common_fnc_selectPosition).
    //
    // After the frame guard, never before: see EFUNC(common,placementPreview) for
    // why the opening context-menu press must stay decided by frame number alone.
    //
    // False, not true — the press belongs to the control under it. The release and
    // the Escape handler are deliberately NOT guarded this way: a gesture begun in
    // the world has to be able to finish with the cursor anywhere, or it strands.
    if (!call zen_common_fnc_isCursorOnMouseArea) exitWith {false};

    // Intersections OFF: the strike should land on the terrain the cursor is over,
    // not on the roof of whatever building happens to be under it.
    GVAR(aiming) set [2, [nil, 0] call zen_common_fnc_getPosFromScreen];
    GVAR(aiming) set [3, -1];

    true
}]];

_handlers pushBack ["MouseMoving", _display displayAddEventHandler ["MouseMoving", {
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    private _aim = GVAR(aiming) select 2;
    if (_aim isEqualTo []) exitWith {false};

    private _cursor = [nil, 0] call zen_common_fnc_getPosFromScreen;

    // Below MIN_AIM_DRAG the gesture has not said anything yet, so the bearing stays
    // unset and the order falls back to the aircraft's current heading. That is what
    // makes a plain click a valid order rather than an accident.
    if (_aim distance2D _cursor < MIN_AIM_DRAG) exitWith {
        GVAR(aiming) set [3, -1];
        false
    };

    GVAR(aiming) set [3, _aim getDir _cursor];

    false
}]];

_handlers pushBack ["MouseButtonUp", _display displayAddEventHandler ["MouseButtonUp", {
    params ["", "_button"];

    if (_button != 0) exitWith {false};
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    GVAR(aiming) params ["_objects", "_args", "_aim", "_bearing"];

    // Released without ever having pressed on a target — nothing was aimed.
    if (_aim isEqualTo []) exitWith {false};

    call FUNC(endAiming);

    [_aim, _objects, _args, _bearing] call FUNC(orderStrike);

    true
}]];

_handlers pushBack ["KeyDown", _display displayAddEventHandler ["KeyDown", {
    params ["", "_key"];

    // A3's defineDIKCodes.inc scancode for Escape. Not a CBA macro and not
    // included here — RTZ vendors no A3 headers (see addons/restrict and
    // addons/path, which each declare their own local copy for the same
    // reason) — so it is written as the literal DirectInput scancode rather
    // than a DIK_ESCAPE token that would resolve to nothing in this component.
    if (_key != 1) exitWith {false};
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    call FUNC(endAiming);

    true
}]];

_handlers
