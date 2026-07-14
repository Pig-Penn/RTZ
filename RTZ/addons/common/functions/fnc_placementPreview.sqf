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
// that selected the context-menu entry can't instantly place at the menu spot
private _mouseEH = _display displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button"];
    if (_button != 0) exitWith {};
    if (diag_frameNo <= GVAR(previewStartFrame)) exitWith {};
    GVAR(previewPending) = [true];
}];

// Escape cancels (and swallows the key so it doesn't open the pause menu)
private _keyEH = _display displayAddEventHandler ["KeyDown", {
    params ["", "_key"];
    if (_key != 1) exitWith {false};      // DIK_ESCAPE
    GVAR(previewPending) = [false];
    true
}];

private _hint = [LLSTRING(PreviewHint), LLSTRING(PreviewHintRotate)] select _allowRotate;

// Per-frame: drive the helper to the cursor, draw feedback, finish on a result
[{
    params ["_args", "_pfhID"];
    _args params ["_display", "_helper", "_ghost", "_icon", "_color", "_hint", "_allowRotate", "_onConfirm", "_cbArgs", "_mouseEH", "_keyEH"];

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

        // Feedback marker + hint at the spot
        drawIcon3D [_icon, _color, ASLToAGL getPosASL _helper, 1.2, 1.2, getDir _helper, _hint, 1, 0.03, "RobotoCondensed"];
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
        if (!isNull _display) then {
            _display displayRemoveEventHandler ["MouseButtonDown", _mouseEH];
            _display displayRemoveEventHandler ["KeyDown", _keyEH];
        };
        deleteVehicle _ghost;
        deleteVehicle _helper;
        GVAR(previewActive) = false;
        GVAR(previewPending) = nil;

        [_confirmed, _posAGL, _dir, _cbArgs] call _onConfirm;
    };
}, 0, [_display, _helper, _ghost, _icon, _color, _hint, _allowRotate, _onConfirm, _args, _mouseEH, _keyEH]] call CBA_fnc_addPerFrameHandler;
