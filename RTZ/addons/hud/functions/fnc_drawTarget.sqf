#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Target-stream renderer: draws a side-coloured line from each watched
 * unit to where it BELIEVES its target is, capped with an impact icon and
 * labelled with the target's name and knowledge freshness while the cursor is
 * near it (modelled on the LAMBS debug renderer). Called once per frame per
 * active stream by FUNC(streamClient), which supplies the shared frame context.
 *
 * A fresh snapshot is baked once, on the first frame after it lands: the
 * target's side colour, its display name and the age of the sighting AT SEND
 * are resolved there. The age is then advanced every frame by however long the
 * snapshot has been sitting here, so the stale-dim fades continuously instead of
 * stepping once per poll — and, because the server sends an absolute sighting
 * time, an unchanging engagement diffs away on the wire while still ageing here.
 *
 * Baked entry: [unit, target, estimatedPos, ageAtSend, rgb, name, positionError].
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in script_component.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_hud_fnc_drawTarget
 *
 * Public: No
 */

params ["_ctx"];

private _record = GVAR(streamData) get STREAM_TGT;
if (isNil "_record") exitWith {};                       // no snapshot yet

_record params ["_entries", "_rxTime", "_dirty", "_refTime"];
if (_entries isEqualTo []) exitWith {};

private _camPos = _ctx select CTX_CAMPOS;
private _mouse  = _ctx select CTX_MOUSE;
private _now    = _ctx select CTX_NOW;

if (_dirty) then {
    _entries = _entries apply {
        _x params ["_unit", "_target", "_estPos", "_lastSeen", "_posError", "_tSide"];

        // Line and icon carry the TARGET's side colour — red line means
        // "shooting at OPFOR", matching the spotting palette semantics. The
        // palette array is shared and read-only, hence the copy.
        private _rgb  = ([_tSide, false] call EFUNC(common,sideColor)) select [0, 3];
        private _name = ([_target] call EFUNC(common,classInfo)) select 0;

        [_unit, _target, _estPos, (_refTime - _lastSeen) max 0, _rgb, _name, _posError]
    };
    _record set [0, _entries];
    _record set [2, false];
};

// How long this snapshot has been sitting on the client — added to each entry's
// age-at-send to age the intel between polls.
private _elapsed = _now - _rxTime;

{
    _x params ["_unit", "_target", "_estPos", "_ageAtSend", "_rgb", "_name", "_posError"];
    if (isNull _unit || {!alive _unit}) then { continue };
    // A kill between server ticks drops the line on the spot rather than
    // pointing at the corpse until the next snapshot.
    if (isNull _target || {!alive _target}) then { continue };

    // Anchor on the vehicle so mounted crews draw from the hull, and read the
    // position live each frame — only the target end is snapshotted.
    private _from    = (getPosATLVisual (vehicle _unit)) vectorAdd [0, 0, 0.5];
    private _camDist = _camPos distance _from;
    if (_camDist > MAX_DRAW_DIST && {_camPos distance _estPos > MAX_DRAW_DIST}) then { continue };

    // Distant overlays recede instead of stacking into clutter; stale sightings
    // dim on top of that.
    private _age        = _ageAtSend + _elapsed;
    private _freshAlpha = linearConversion [0, STALE_DIM_TIME, _age, 1, 0.45, true];
    private _alpha      = (linearConversion [FADE_NEAR, MAX_DRAW_DIST, _camDist, 1, 0.3, true]) * _freshAlpha;
    private _color      = _rgb + [_alpha];

    drawLine3D [_from, _estPos, _color];

    // Label only near the cursor — a screenful of contact reports is noise, and
    // composing the freshness text for one hovered icon beats baking it for all
    // of them every poll.
    private _text = "";
    private _scr  = worldToScreen _estPos;
    if (_scr isNotEqualTo [] && {_mouse distance2D _scr < LABEL_CURSOR_RADIUS}) then {
        private _seenTxt = if (_age < 1) then { LLSTRING(LabelInSight) } else {
            format [LLSTRING(LabelSeenAgo), round _age]
        };
        _text = format ["%1 — %2", _name, _seenTxt];
        if (_posError > 5) then {
            _text = format ["%1 (±%2m)", _text, round _posError];
        };
    };

    drawIcon3D [
        ICON_TGT_MARK,
        _color,
        _estPos,
        TGT_SIZE, TGT_SIZE, 0,
        _text,
        1, LABEL_TEXT_SIZE, LABEL_FONT
    ];
} forEach _entries;
