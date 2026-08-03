#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the vehicle head tags. Called once per frame by
 * EFUNC(core,frameLoop) with the shared frame context — the Zeus test, the camera basis
 * and the mouse position are already resolved, so this pass does no camera query
 * of its own.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in script_component.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_hud_fnc_drawVehicleTags
 *
 * Public: No
 */

params ["_ctx"];

private _ids = EGVAR(core,selVehicles);
if (_ids isEqualTo []) exitWith {};

if (GVAR(vehicleTagsDirty)) then {
    GVAR(vehicleTagsCache) = createHashMap;
    GVAR(vehicleTagsDirty) = false;
};

private _camPos   = _ctx select CTX_CAMPOS;
private _camRight = _ctx select CTX_CAMRIGHT;
private _camUp    = _ctx select CTX_CAMUP;

private _cache   = GVAR(vehicleTagsCache);
private _data    = GVAR(vehicleData);
private _maxDist = GVAR(vtagMaxDistance);
private _fadeIn  = _maxDist * 0.85;
private _size    = GVAR(vtagSize);
private _zOff    = GVAR(vtagHeight);
// A virtual Zeus (VirtualMan_F) is the game master, not a PvP officer — exempt
// from the own-side render filter (mirrors the selection poll and the gather).
private _anySide = player isKindOf "VirtualMan_F";
private _curSide = side player;

{
    private _entry = _cache get _x;
    if (isNil "_entry") then {
        private _pkt = _data get _x;
        if (isNil "_pkt") then { continue };                   // packet not arrived yet
        _entry = [_pkt] call FUNC(buildVtagEntry);
        _cache set [_x, _entry];
    };
    _entry params ["_mainText", "_rgbMain", "_statusText", "_rgbStatus", "_sep", ["_wMainSep", 0], ["_wStatus", 0]];
    if (_mainText == "" && {_statusText == ""}) then { continue };  // every field toggled off

    private _veh = objectFromNetId _x;
    if (isNull _veh || {!alive _veh}) then { continue };
    // Side re-check between server pushes (crew change can flip a vehicle's
    // effective side) — same filter the selection poll applies.
    if (!_anySide && {!(VEH_SIDE_OK(_veh,_curSide))}) then { continue };

    private _base = unitAimPositionVisual _veh;
    private _dist = _camPos distance _base;
    if (_dist > _maxDist) then { continue };
    // Screen-space vertical lift (see FUNC(drawUnitTags)): along camera-up and
    // distance-scaled, so the tag clears the icon from a top-down camera too.
    private _pos = _base vectorAdd (_camUp vectorMultiply (_zOff * (1 max (_dist / 30))));
    private _alpha = linearConversion [_fadeIn, _maxDist, _dist, 0.85, 0, true];

    if (_statusText == "") then {
        drawIcon3D ["", _rgbMain + [_alpha], _pos, 0, 0, 0, _mainText, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
        continue;
    };

    // Screen-space scale (UI units per metre of camera-right at this vehicle's
    // depth) — needed to split the status word into its own coloured draw. Exact
    // for any FOV, no fov-formula guesswork.
    private _perMetre = 0;
    private _scr = worldToScreen _pos;
    private _oneRight = worldToScreen (_pos vectorAdd _camRight);
    if (_scr isNotEqualTo [] && {_oneRight isNotEqualTo []}) then {
        _perMetre = (_oneRight select 0) - (_scr select 0);
    };

    if (_perMetre <= 1e-6) then {
        drawIcon3D ["", _rgbMain + [_alpha], _pos, 0, 0, 0, _mainText + _sep + _statusText, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
    } else {
        // Split point = centre + halfWidth(fullText) - width(statusText), from the
        // widths measured at cache-build time (FUNC(textWidth)) — keeps the
        // combined line centred on the vehicle while letting the status word carry
        // its own colour. Both halves meet exactly at that point (same as the unit
        // tags): the " · " separator already carries the spacing, so pushing them
        // further apart double-spaces the line.
        private _boundaryUI  = ((_wMainSep + _wStatus) / 2) - _wStatus;
        private _boundaryPos = _pos vectorAdd (_camRight vectorMultiply (_boundaryUI / _perMetre));
        // textAlign names the SIDE of the anchor the text sits on (not typographic
        // alignment): "left" ends at the anchor, "right" starts there.
        drawIcon3D ["", _rgbMain   + [_alpha], _boundaryPos, 0, 0, 0, _mainText + _sep, 2, _size, "RobotoCondensedBold", "left",  false, 0, 0];
        drawIcon3D ["", _rgbStatus + [_alpha], _boundaryPos, 0, 0, 0, _statusText,      2, _size, "RobotoCondensedBold", "right", false, 0, 0];
    };
} forEach _ids;
