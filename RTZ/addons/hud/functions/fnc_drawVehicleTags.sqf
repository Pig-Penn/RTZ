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
 * settings (name, speed, crew/seats, fuel, hull, fly height, ammo,
 * LAMBS task, tactic) and drawn in a static colour. Two pieces carry their own:
 * the LAMBS tactic (amber, the Draw Destinations tint, which is what names it as
 * the tactic without a "TAC " prefix), and the trailing status word — the warning
 * flags (LOW FUEL amber, DAMAGED red) always show regardless of the status field
 * setting. Both are split off at measured text boundaries by FUNC(drawTagLine).
 * Tags fade out approaching GVAR(vtagMaxDistance) from the camera.
 *
 * Right of the text sit the optional ammunition gauges (GVAR(vtagShowAmmoBar)),
 * one per armed turret — so an IFV reads its main gun and its commander MG side
 * by side instead of collapsing both into the one selected-weapon count the text
 * field carries. Same bar the infantry tags draw (FUNC(drawTagBar)).
 *
 * Per-frame cost: the text, colours and widths are cached per vehicle (TAG_CACHE)
 * and rebuilt only after a fresh server push or a vtag* setting change, so the
 * steady state is two hashmap lookups and one to three drawIcon3D per vehicle.
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
private _aspect   = _ctx select CTX_ASPECT;

private _cache   = _sys select TAG_CACHE;
private _data    = GVAR(vehicleData);
private _maxDist = GVAR(vtagMaxDistance);
private _fadeIn  = _maxDist * 0.85;
private _size    = GVAR(vtagSize);
private _liftUI  = GVAR(vtagHeight);   // UI-y, NOT metres — see the lift below
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
    if !(_entry select 9) then { continue };

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

    _entry params [
        "_mainSep", "_rgbMain", "_tacticSep", "_rgbTactic", "_statusText", "_rgbStatus",
        "_wMainSep", "_wTacticSep", "_wStatus", "", "_bars"
    ];

    // Screen-space scales (UI units per metre of camera-right / camera-up at this
    // vehicle's depth) — used to split the tactic and the status word into their
    // own coloured draws, to place, size and fill the ammo gauges, and now to lift
    // the tag. Exact for any FOV, no fov-formula guesswork.
    //
    // Measured at the UNLIFTED anchor and no longer conditional. It used to be
    // skipped for a plain centred line with no bars, which needs no scale — but
    // the lift needs one for EVERY vehicle now, so there is nothing left to skip.
    // The vertical scale is the horizontal one times the frame's screen aspect
    // (CTX_ASPECT), so the bar-only `worldToScreen` this renderer used to spend on
    // it is gone: the worst case drops from three probes a vehicle to two.
    // Measuring before the lift is exact — the lift rides camera-up, which is
    // perpendicular to the view axis and so leaves the point's DEPTH alone.
    private _baseASL = AGLToASL _base;
    private _scr = worldToScreen _base;
    if (_scr isEqualTo []) then { continue };                  // off-screen
    private _oneRight = worldToScreen (ASLToAGL (_baseASL vectorAdd _camRight));
    if (_oneRight isEqualTo []) then { continue };
    private _perMetre = (_oneRight select 0) - (_scr select 0);
    if (_perMetre <= 1e-6) then { continue };
    private _perMetreUp = _perMetre * _aspect;

    // Vertical lift — a SCREEN distance along camera-up, not world +Z (which
    // projects to nothing from a top-down camera) and not world metres either.
    // See FUNC(drawUnitTags) for why the old `_zOff * (1 max (_dist / 30))` metres
    // gave a gap that tracked the Zeus camera's zoom instead of holding still.
    // ASL, not the AGL FUNC(tagAnchor) returns: a camera-basis offset added to an
    // AGL position holds HEIGHT ABOVE GROUND rather than altitude, so it rides the
    // terrain instead of the screen axis. See FUNC(drawTagLine), which takes the
    // centre in ASL for the same reason and converts per chunk at the draw.
    private _posASL = _baseASL;
    if (_liftUI > 0 && {abs _perMetreUp > 1e-6}) then {
        // `abs`: _perMetreUp is negative (UI-y grows downward), and a positive
        // setting must always move the tag UP the screen.
        _posASL = _baseASL vectorAdd (_camUp vectorMultiply (_liftUI / (abs _perMetreUp)));
    };

    private _alpha = linearConversion [_fadeIn, _maxDist, _dist, 0.85, 0, true];

    // Shared with the unit tags so both families measure and place the coloured
    // splits identically; a degenerate _perMetre falls back to one centred draw
    // of the whole line.
    [
        _posASL, _perMetre, _camRight, _mainSep, _tacticSep, _statusText,
        _rgbMain + [_alpha], _rgbTactic + [_alpha], _rgbStatus + [_alpha], _size,
        _wMainSep, _wTacticSep, _wStatus
    ] call FUNC(drawTagLine);

    // Ammunition gauges, right of the text — one per armed turret, already placed
    // and filled at cache-build time. Shared with the unit tags so both families
    // draw an identical bar.
    {
        _x params ["_centreUI", "_fill"];
        [
            _posASL, _perMetre, _perMetreUp, _camRight, _camUp,
            _centreUI, _fill, _size, _alpha
        ] call FUNC(drawTagBar);
    } forEach _bars;
} forEach _ids;
