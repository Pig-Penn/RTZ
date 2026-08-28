#include "script_component.hpp"
/*
 * Author: Maxim
 * Installs the curator-display handlers the drawing session listens on, and hands
 * back their ids so FUNC(endAiming) can remove precisely these and leave ZEN's own
 * handlers on the same display alone.
 *
 * Consuming a press is the exception. The gesture's own events are swallowed so the
 * Zeus display underneath does not also act on them; everything else passes through.
 *
 * Arguments:
 * 0: Curator display <DISPLAY>
 *
 * Return Value:
 * Installed handlers as [[eventType, id], ...] <ARRAY>
 *
 * Example:
 * private _handlers = [_display] call rtz_dig_fnc_handleAimInput
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

    // Frame guard, not a one-shot flag — see FUNC(beginAiming) for why. Only a press
    // on a LATER frame can be a genuine endpoint, so every press on the starting
    // frame is swallowed here without touching the stored frame number.
    if (diag_frameNo <= (GVAR(aiming) select AIM_FRAME)) exitWith {true};

    // Only a press in the world view draws. This handler is fed presses that land on
    // the curator's panels too, and getPosFromScreen defaults to getMousePosition,
    // which reports a point over the create tree as readily as one over terrain — so
    // without this, clicking a class in the tree would latch an endpoint from
    // whatever was projected under the panel. ZEN guards its own picker the same way
    // (zen_common_fnc_selectPosition).
    //
    // After the frame guard, never before: see EFUNC(common,placementPreview) for
    // why the opening context-menu press must stay decided by frame number alone.
    //
    // False, not true — the press belongs to the control under it. The release and
    // the Escape handler are deliberately NOT guarded this way: a gesture begun in
    // the world has to be able to finish with the cursor anywhere, or it strands.
    if (!call zen_common_fnc_isCursorOnMouseArea) exitWith {false};

    // Intersections OFF: a trench is cut into the terrain the cursor is over, never
    // onto the roof of whatever building happens to be under it.
    private _pos = [nil, 0] call zen_common_fnc_getPosFromScreen;

    GVAR(aiming) set [AIM_START, _pos];
    GVAR(aiming) set [AIM_END, _pos];
    GVAR(aiming) set [AIM_PLAN, []];
    GVAR(aiming) set [AIM_PLANAT, 0];

    true
}]];

_handlers pushBack ["MouseMoving", _display displayAddEventHandler ["MouseMoving", {
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    if ((GVAR(aiming) select AIM_START) isEqualTo []) exitWith {false};

    // Latch the cursor only. The plan is NOT rebuilt here: FUNC(planTrench) walks
    // every cell with nearestObjects and nearestTerrainObjects, which is far too
    // much work for a handler the engine fires on every pixel of mouse travel.
    // FUNC(drawAim) re-plans on PLAN_INTERVAL instead.
    GVAR(aiming) set [AIM_END, [nil, 0] call zen_common_fnc_getPosFromScreen];

    false
}]];

_handlers pushBack ["MouseButtonUp", _display displayAddEventHandler ["MouseButtonUp", {
    params ["", "_button", "", "", "_shift"];

    if (_button != 0) exitWith {false};
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    GVAR(aiming) params ["_objects", "_start", "_end"];

    // Released without ever having pressed in the world — nothing was drawn.
    if (_start isEqualTo []) exitWith {false};

    call FUNC(endAiming);

    // Shift is read HERE and nowhere else. It is the curator overriding a refusal he
    // has already been shown in red, which is what ACE's own Zeus trench module uses
    // it for. Deliberately not fed into the preview: "the line is blocked" is the
    // information he needs while dragging, and a preview that turned green whenever
    // he happened to be holding shift would hide it.
    [_start, _end, _objects, _shift] call FUNC(orderDig);

    true
}]];

_handlers pushBack ["KeyDown", _display displayAddEventHandler ["KeyDown", {
    params ["", "_key"];

    // A3's defineDIKCodes.inc scancode for Escape. Not a CBA macro and not included
    // here — RTZ vendors no A3 headers — so it is written as the literal DirectInput
    // scancode rather than a DIK_ESCAPE token that would resolve to nothing.
    if (_key != 1) exitWith {false};
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    call FUNC(endAiming);

    true
}]];

_handlers
