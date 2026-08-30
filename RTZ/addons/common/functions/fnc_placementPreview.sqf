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
 * A Zeus-style marker + hint always draws at the spot. Left click confirms; Escape (or
 * the Zeus display closing) cancels. Exactly one instance runs at a time.
 *
 * Entirely client-local — no remoteExec, nothing networked — so the caller
 * dispatches its authoritative server work from the confirm callback. The one
 * piece of state that reaches outside this file is ZEN's own picker flag, held
 * for the session's lifetime so ZEN stands its pickers and its context menu
 * down; see the entry guard below.
 *
 * Arguments:
 * 0: CfgVehicles class to preview, or "" for an icon-only picker <STRING>
 * 1: Confirm callback, run once as [confirmed <BOOL>, position (AGL) <ARRAY>,
 *    direction <NUMBER> (0 when rotation is off), args <ANY>] <CODE>
 * 2: Arguments passed through to the callback <ANY> (default: [])
 * 3: Class glyph drawn inside the Zeus ring at the spot <STRING> (default: "",
 *    the bare ring, for pickers whose target has no glyph of its own)
 * 4: Marker color <ARRAY> (default: [1, 1, 1, 1])
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
    ["_icon", "", [""]],
    ["_color", [1, 1, 1, 1], [[]], 4],
    ["_allowRotate", false, [false]]
];

private _display = findDisplay IDD_RSCDISPLAYCURATOR;
if (!hasInterface || {isNull _display}) exitWith {
    [false, [0, 0, 0], 0, _args] call _onConfirm;
};

// One picker at a time — a second call fails cleanly rather than fighting the first.
// ZEN's own position picker counts as one: zen_common_fnc_selectPosition installs
// click handlers on this same display, and its re-entry guard reads the flag below
// but only ever sees ZEN's sessions. Nothing on ZEN's side stops a curator reaching
// an RTZ action while one is open either — zen_context_menu's keybind checks
// isPlacementActive but not this flag — so the test has to be made from this side.
// It is also what makes clearing the flag on teardown safe: no ZEN session can be
// running underneath this one.
if (GETGVAR(previewActive,false) || {GETMVAR(zen_common_selectPositionActive,false)}) exitWith {
    [false, [0, 0, 0], 0, _args] call _onConfirm;
};
// Drop ZEN's placement ghost if the curator left a class selected in the create
// tree. Both ghosts ride the same cursor, and they fight over
// lineIntersectsSurfaces: each ignores only its own helper and object, the call
// takes just two ignore slots, so each snaps onto whatever flat face the other
// presents and they climb each other. Cleared exactly the way ZEN's own
// context-menu keybind clears it (zen_context_menu/initKeybinds.inc.sqf) — the
// selection change routes through zen_placement_fnc_handleTreeSelect, which is
// what actually deletes the ghost. tvSetCurSel runs that chain synchronously, so
// the frame number latched below is still this frame.
//
// Deliberately ahead of every flag this function sets. isPlacementActive reads
// the vanilla RscDisplayCurator_sections global and would throw if Zeus ever had
// the display up without it; ZEN takes that risk too, but ZEN only loses a
// context menu, whereas a throw here past the flags would strand previewActive
// and ZEN's picker flag true and kill every picker for the rest of the mission.
// Ordered this way, the worst case is one picker that fails to open.
if (call zen_common_fnc_isPlacementActive) then {
    (call zen_common_fnc_getActiveTree) tvSetCurSel [-1];
};

// Drop the curator's ENTITY selection too — the sibling of the tree clear above,
// and the only thing that fixes the mouse pointer. Zeus picks its pointer from
// what is selected: with a squad held it shows CuratorSelect, the four-arc ring,
// which reads as "you are about to grab these" — the wrong thing to say while a
// curator is choosing where something goes. With nothing selected it falls back
// to CuratorPlace, the arrow with the plus, which is exactly right. Overriding
// the pointer directly is not an option: ctrlMapCursor is the only script lever
// on it and it works through a map control, while the curator display's 3D view
// is covered by its full-screen MouseArea (idc 53) instead.
//
// Costs the caller nothing: every picker resolves its targets BEFORE opening,
// and the selection is not put back on cancel — restoring it would restore the
// ring, and a curator who cancelled can select again.
setCuratorSelected [];

GVAR(previewActive) = true;
GVAR(previewPending) = nil;               // set to [_confirmed] by the input EHs below
GVAR(previewStartFrame) = diag_frameNo;   // guard: ignore the click that closed the menu

// Stand ZEN's pickers down for the duration, the way ZEN stands its own down. Read
// by zen_common_fnc_selectPosition for re-entry and by zen_context_menu's
// right-click handler, which will not open a menu over an active picker.
zen_common_selectPositionActive = true;

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
// That opening frame is swallowed either way: letting it fall through reached the
// Zeus display underneath, which would clear the curator's selection or drop
// whatever was highlighted in the Zeus tree at the same spot. Other buttons
// return false so right-click still behaves normally.
private _mouseEH = _display displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button"];
    if (_button != 0) exitWith {false};
    if (diag_frameNo <= GVAR(previewStartFrame)) exitWith {true};

    // Only a press in the world view is a placement. A display-level handler is
    // fed presses that land on the curator's panels as well, and getMousePosition
    // reports a point over a panel just as happily as one over terrain — so
    // without this, clicking the create tree confirmed the placement at whatever
    // screenToWorld made of the point underneath the panel, and did it on the very
    // click that was selecting a class for ZEN's own preview. ZEN guards its picker
    // the same way (zen_common_fnc_selectPosition), which is what establishes that
    // the press really does arrive here.
    //
    // Tested AFTER the frame guard, never before. The press that opened this picker
    // is a context-menu press, and whether the menu control is still there to be
    // found under the cursor by the time this runs is engine-ordering dependent
    // (addons/airstrike/functions/fnc_beginAiming.sqf works the same problem at
    // length). A frame-number comparison has no such ambiguity, so it stays what
    // decides the opening frame.
    //
    // False, not true — the press belongs to the control under it.
    if (!call zen_common_fnc_isCursorOnMouseArea) exitWith {false};

    GVAR(previewPending) = [true];
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

// Feedback marker + hint at the spot, drawn from a Draw3D mission EH of its own.
// Deliberately NOT on rtz_core's shared frame loop, which every persistent RTZ
// overlay rides: that loop exists to stop long-lived displays each rebuilding the
// camera basis every frame, and this draw needs no camera at all — three
// drawIcon3D layers off the helper's live position, at a fixed size — while
// living only for the seconds a picker is open, inside Zeus by construction.
// Registering it would add indirection, and would also mean rtz_common taking a
// dependency on rtz_core that every component in the mod would then carry. It
// reads the helper's live position, so the PFH below never has to feed it. Drawn
// upright (angle 0) rather than spun to the ghost's facing: the ghost model
// already shows the direction, and a fixed marker reads like vanilla Zeus instead
// of a tumbling reticle. Single-instance state is safe here —
// GVAR(previewActive) above guarantees exactly one picker at a time.
GVAR(previewDraw) = [_helper, _icon, _color, _hint];
GVAR(previewDrawEH) = addMissionEventHandler ["Draw3D", {
    GVAR(previewDraw) params ["_helper", "_icon", "_color", "_hint"];
    if (isNull _helper) exitWith {};

    [
        ASLToAGL getPosASL _helper,
        _color, _icon, _hint, PREVIEW_TEXT_SIZE
    ] call FUNC(drawZeusIcon);
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
            // surface hit on the way (rooftops, bridges). Both ignore slots go to
            // this picker's own helper and ghost — see FUNC(cursorSurface), which
            // is where this trace and its break-not-exitWith hazard now live, and
            // which rtz_place's dragged handles call for the same answer.
            ([_helper, _ghost] call FUNC(cursorSurface)) params ["_position", "_vectorUp"];
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
        // Cleared outright rather than restored to a remembered value: the entry
        // guard refuses to start while ZEN's picker is active, so this was false
        // before this picker set it.
        zen_common_selectPositionActive = false;
        // GVAR(previewDraw) is deliberately left in place rather than nil'd:
        // its handler is gone, the next picker overwrites it, and the isNull
        // helper guard makes a stale entry inert either way.

        [_confirmed, _posAGL, _dir, _cbArgs] call _onConfirm;
    };
}, 0, [_display, _helper, _ghost, _allowRotate, _onConfirm, _args, _mouseEH, _keyEH]] call CBA_fnc_addPerFrameHandler;
