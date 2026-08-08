#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the vehicle head tags. Called once per frame by
 * EFUNC(core,frameLoop) with the shared frame context — the Zeus test, the camera
 * basis and the mouse position are already resolved, so this pass does no camera
 * query of its own.
 *
 * The tag is one discrete text line (e.g. "Hunter HMG · 45 km/h · CREW 3/4 ·
 * FUEL 62 · LOW FUEL") — the vehicle counterpart of the infantry head tags
 * (FUNC(drawUnitTags)). Fed by EGVAR(core,selVehicles) from
 * EFUNC(core,selectionPoll) and GVAR(vehicleData) from the STREAM_VEH feed.
 *
 * The line is assembled by FUNC(buildVtagEntry) from the fields enabled in CBA
 * settings (name, speed, crew/seats, fuel, hull, fly height, ammo, commander,
 * LAMBS task, tactic) and drawn in a static colour. Only the trailing status word
 * carries its own: the warning flags (LOW FUEL amber, DAMAGED red) always show
 * regardless of the status field setting, split off at a measured text boundary
 * by FUNC(drawTagLine). Tags fade out approaching GVAR(vtagMaxDistance) from the
 * camera.
 *
 * Per-frame cost: the text, colours and widths are cached per vehicle (TAG_CACHE)
 * and rebuilt only after a fresh server push or a vtag* setting change, so the
 * steady state is two hashmap lookups and one or two drawIcon3D per vehicle.
 * Unlike the unit tags there is no de-confliction pass — vehicles are far enough
 * apart on screen for their tags not to pile up, and the pass is not free.
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

// This renderer is only registered while its system is in the registry
// (FUNC(applyTagVisibility)), so the record is always there — but a nil read
// would abort the whole pass, so it is not worth assuming.
private _sys = GVAR(tagSystems) get QGVAR(vehicleTags);
if (isNil "_sys") exitWith {};

if (_sys select TAG_DIRTY) then {
    _sys set [TAG_CACHE, createHashMap];
    _sys set [TAG_DIRTY, false];
};

private _camPos   = _ctx select CTX_CAMPOS;
private _camRight = _ctx select CTX_CAMRIGHT;
private _camUp    = _ctx select CTX_CAMUP;

private _cache   = _sys select TAG_CACHE;
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
    // Single precomputed boolean, tested BEFORE unpacking the entry — every field
    // toggled off used to cost a full `params` over the whole entry per vehicle
    // per frame just to discover there was nothing to draw.
    if !(_entry select 6) then { continue };

    private _veh = objectFromNetId _x;
    if (isNull _veh || {!alive _veh}) then { continue };
    // Side re-check between server pushes (crew change can flip a vehicle's
    // effective side) — same filter the selection poll applies.
    if (!_anySide && {!(VEH_SIDE_OK(_veh,_curSide))}) then { continue };

    // [] while the model has not resolved on this machine — see FUNC(tagAnchor),
    // which also owns the empty-hull aim-position fallback.
    private _base = [_veh] call FUNC(tagAnchor);
    if (_base isEqualTo []) then { continue };

    private _dist = _camPos distance _base;
    if (_dist > _maxDist) then { continue };
    // Screen-space vertical lift (see FUNC(drawUnitTags)): along camera-up and
    // distance-scaled, so the tag clears the icon from a top-down camera too.
    private _pos = _base vectorAdd (_camUp vectorMultiply (_zOff * (1 max (_dist / 30))));
    private _alpha = linearConversion [_fadeIn, _maxDist, _dist, 0.85, 0, true];

    _entry params ["_mainSep", "_rgbMain", "_statusText", "_rgbStatus", "_wMainSep", "_wStatus"];

    // Screen-space scale (UI units per metre of camera-right at this vehicle's
    // depth) — needed to split the status word into its own coloured draw. Exact
    // for any FOV, no fov-formula guesswork. Only measured when there IS a status
    // word: without one, FUNC(drawTagLine) draws a single centred line and never
    // looks at the scale, so the two worldToScreen calls would be wasted.
    private _perMetre = 0;
    if (_statusText != "") then {
        private _scr = worldToScreen _pos;
        private _oneRight = worldToScreen (_pos vectorAdd _camRight);
        if (_scr isNotEqualTo [] && {_oneRight isNotEqualTo []}) then {
            _perMetre = (_oneRight select 0) - (_scr select 0);
        };
    };

    // Shared with the unit tags so both families measure and place the coloured
    // status split identically; a degenerate _perMetre falls back to one centred
    // draw of the whole line.
    [
        _pos, _perMetre, _camRight, _mainSep, _statusText,
        _rgbMain + [_alpha], _rgbStatus + [_alpha], _size, _wMainSep, _wStatus
    ] call FUNC(drawTagLine);
} forEach _ids;
