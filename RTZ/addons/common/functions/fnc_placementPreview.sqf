#include "script_component.hpp"
/*
 * Author: Maxim
 * Shared interactive placement picker for Zeus. Ports ZEN's placement-preview
 * technique (zen_placement_fnc_setupPreview / updatePreview) into RTZ's own
 * namespace so it can drive RTZ context-menu placement flows. ZEN's own
 * functions are Public: No and share module-scoped state tied to the curator
 * tree and the native CuratorObjectPlaced event, so they cannot be called
 * directly without clobbering ZEN's own preview — this is the ported recipe.
 *
 * With a preview class, a simulation-disabled local copy of the object is
 * attached to a hidden Logic helper and follows the cursor every frame (flush
 * to slopes and rooftops via lineIntersectsSurfaces + surfaceNormal),
 * rotatable while the curator's rotate modifier is held. With "" it is an
 * icon-only picker (for things without a meaningful silhouette, e.g. mines).
 * A 3D icon + hint always draws at the spot. Left click confirms; Escape (or
 * the Zeus display closing) cancels. Exactly one instance runs at a time.
 *
 * Entirely client-local — no remoteExec, no global state — so the caller
 * dispatches its authoritative server work from the confirm callback.
 *
 * Arguments:
 * 0: CfgVehicles class to preview, or "" for an icon-only picker <STRING>
 * 1: Confirm callback, run once as [confirmed <BOOL>, position (AGL) <ARRAY>,
 *    direction <NUMBER> (0 when rotation is off), args <ANY>] <CODE>
 * 2: Arguments passed through to the callback <ANY> (default: [])
 * 3: 3D icon texture drawn at the spot <STRING> (default: select target cursor)
 * 4: Icon color <ARRAY> (default: [1, 1, 1, 1])
 * 5: Allow rotation and report facing <BOOL> (default: false)
 * 6: Hint text drawn under the icon <STRING> (default: the standard place/cancel
 *    hint, picking up the rotate wording when rotation is on; "" draws no text,
 *    for callers that want vanilla Zeus' silent ghost placement)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["Land_BagFence_Round_F", {params ["_confirmed", "_pos", "_dir"]}] call rtz_common_fnc_placementPreview
 *
 * Public: No
 */

params [
    ["_previewClass", "", [""]],
    ["_onConfirm", {}, [{}]],
    ["_args", []],
    ["_icon", ICON_PREVIEW, [""]],
    ["_color", [1, 1, 1, 1], [[]], 4],
    ["_allowRotate", false, [false]]
];

private _display = findDisplay IDD_RSCDISPLAYCURATOR;
if (!hasInterface || {isNull _display}) exitWith {
    [false, [0, 0, 0], 0, _args] call _onConfirm;
};

// One picker at a time — a second call fails cleanly rather than fighting the first
if (GETGVAR(previewActive,false)) exitWith {
    [false, [0, 0, 0], 0, _args] call _onConfirm;
};
GVAR(previewActive) = true;
GVAR(previewPending) = nil;               // set to [_confirmed] by the input EHs below
GVAR(previewStartFrame) = diag_frameNo;   // guard: ignore the click that closed the menu

// Hidden helper the ghost rides on so it can be positioned/oriented cleanly
private _helper = "Logic" createVehicleLocal [0, 0, 0];
_helper hideObject true;

// Optional local ghost model, attached to the helper (ZEN's setupPreview recipe)
private _ghost = objNull;
if (_previewClass != "" && {isClass (configFile >> "CfgVehicles" >> _previewClass)}) then {
    _ghost = _previewClass createVehicleLocal [0, 0, 0];
    _ghost disableCollisionWith player;
    _ghost enableSimulation false;
    _ghost allowDamage false;

    // Keep ZEN from auto-registering this local object as curator-editable.
    // ZEN's auto-add class EH only runs on the server, so this only matters
    // when the curator is the host (matches ZEN's own setupPreview).
    if (isServer) then {
        _ghost setVariable ["zen_common_autoAddObject", false];
    };

    // Align the model centre to land contact so it sits on the ground
    private _offset = (getPosWorld _ghost select 2) - (getPosASL _ghost select 2);
    _ghost attachTo [_helper, [0, 0, _offset]];
};

// Left click confirms — but skip the very frame we start on, so the click
// that selected the context-menu entry can't instantly place at the menu spot.
// Returns true either way so the press is consumed by the picker: letting it
// fall through reached the Zeus display underneath, which would clear the
// curator's selection or drop whatever was highlighted in the Zeus tree at the
// same spot. Other buttons return false so right-click still behaves normally.
private _mouseEH = _display displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button"];
    if (_button != 0) exitWith {false};
    if (diag_frameNo > GVAR(previewStartFrame)) then {
        GVAR(previewPending) = [true];
    };
    true
}];

// Escape cancels (and swallows the key so it doesn't open the pause menu)
private _keyEH = _display displayAddEventHandler ["KeyDown", {
    params ["", "_key"];
    if (_key != 1) exitWith {false};      // DIK_ESCAPE
    GVAR(previewPending) = [false];
    true
}];

// Read separately from params so an explicitly passed "" survives as "no text" —
// the default has to be computed from _allowRotate, which params can't express
private _hint = param [6, [LLSTRING(PreviewHint), LLSTRING(PreviewHintRotate)] select _allowRotate, [""]];

// Feedback marker + hint at the spot, drawn from a Draw3D mission EH — the
// render pass drawIcon3D belongs in, and the one every other RTZ overlay
// (rtz_mine, rtz_overlays, rtz_selection) draws from. It reads the helper's
// live position, so the PFH below never has to feed it. Drawn upright (angle
// 0) rather than spun to the ghost's facing: the ghost model already shows the
// direction, and a fixed icon reads like vanilla Zeus instead of a tumbling
// reticle. Single-instance state is safe here — GVAR(previewActive) above
// guarantees exactly one picker at a time.
GVAR(previewDraw) = [_helper, _icon, _color, _hint];
GVAR(previewDrawEH) = addMissionEventHandler ["Draw3D", {
    GVAR(previewDraw) params ["_helper", "_icon", "_color", "_hint"];
    if (isNull _helper) exitWith {};

    drawIcon3D [
        _icon, _color, ASLToAGL getPosASL _helper,
        PREVIEW_ICON_SIZE, PREVIEW_ICON_SIZE, 0,
        _hint, 1, PREVIEW_TEXT_SIZE, "RobotoCondensed"
    ];
}];

// Per-frame: drive the helper to the cursor, finish on a result
[{
    params ["_args", "_pfhID"];
    _args params ["_display", "_helper", "_ghost", "_allowRotate", "_onConfirm", "_cbArgs", "_mouseEH", "_keyEH"];

    private _pending = GVAR(previewPending);

    // Update the helper from the cursor unless we're finishing this frame
    if (!isNull _display && {isNil "_pending"}) then {
        if (_allowRotate && {inputAction "curatorRotateMod" > 0}) then {
            // Rotate in place: aim the helper from its screen position toward
            // the cursor (ZEN's updatePreview formula — north = 0, corrected
            // for camera heading); off-screen fallback via the world position
            private _mousePos = getMousePosition;
            private _screenPos = worldToScreen ASLToAGL getPosASL _helper;
            private _direction = if (_screenPos isNotEqualTo []) then {
                (_screenPos vectorDiff _mousePos) params ["_vectorX", "_vectorY"];
                _vectorY atan2 _vectorX - 90 + getDir curatorCamera
            } else {
                _helper getDir screenToWorld _mousePos
            };
            _helper setDir _direction;
        } else {
            // Snap to the cursor's terrain point; sit flush on any mostly-flat
            // surface hit on the way (rooftops, bridges)
            private _position = AGLToASL screenToWorld getMousePosition;
            private _vectorUp = surfaceNormal _position;
            {
                _x params ["_intersectPos", "_surfaceNormal"];
                if (_surfaceNormal vectorDotProduct [0, 0, 1] > 0.5) exitWith {
                    _position = _intersectPos;
                    _vectorUp = _surfaceNormal;
                };
            } forEach lineIntersectsSurfaces [getPosASL curatorCamera, _position, _helper, _ghost, true, 5];
            _helper setPosASL _position;
            _helper setVectorUp _vectorUp;
        };
    };

    // Finish: click confirmed, Escape cancelled, or the Zeus display went away
    if (!isNil "_pending" || {isNull _display}) then {
        // _pending is still nil when the display vanished without a click or
        // Escape (Zeus closed via its own keybind, player death, remote
        // control...) — reading it with params would throw "undefined
        // variable" and abort this block before the teardown, leaking the PFH
        // and wedging GVAR(previewActive) true, which kills every later
        // picker. Treat that path as cancelled.
        private _confirmed = if (isNil "_pending") then {false} else {_pending param [0, false]};
        private _posAGL = ASLToAGL getPosASL _helper;
        private _dir = getDir _helper;

        // Tear everything down before the callback so a re-entrant picker is allowed
        [_pfhID] call CBA_fnc_removePerFrameHandler;
        removeMissionEventHandler ["Draw3D", GVAR(previewDrawEH)];
        if (!isNull _display) then {
            _display displayRemoveEventHandler ["MouseButtonDown", _mouseEH];
            _display displayRemoveEventHandler ["KeyDown", _keyEH];
        };
        deleteVehicle _ghost;
        deleteVehicle _helper;
        GVAR(previewActive) = false;
        GVAR(previewPending) = nil;
        // GVAR(previewDraw) is deliberately left in place rather than nil'd:
        // its handler is gone, the next picker overwrites it, and the isNull
        // helper guard makes a stale entry inert either way.

        [_confirmed, _posAGL, _dir, _cbArgs] call _onConfirm;
    };
}, 0, [_display, _helper, _ghost, _allowRotate, _onConfirm, _args, _mouseEH, _keyEH]] call CBA_fnc_addPerFrameHandler;
