#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the infantry head tags. Called once per frame by
 * EFUNC(core,frameLoop) with the shared frame context — the Zeus test, the camera
 * basis and the mouse position are already resolved, so this pass does no camera
 * query of its own.
 *
 * The tag is one discrete text line (e.g. "Rifleman · HP 62 · FLEEING") fed by
 * the same live server packets the selection info dialog uses
 * (EGVAR(core,selUnits) / GVAR(unitData), maintained by EFUNC(core,selectionPoll)
 * and the STREAM_UNIT feed). It is assembled by FUNC(buildTagEntry) from the
 * fields enabled in CBA settings (role, health, morale, suppression, magazine
 * rounds, status, LAMBS tactic, current AI command) and drawn in a static colour
 * so urgency never recolours the whole line — only the trailing status word (DOWN
 * / FLEEING) carries its own, split off at a measured text boundary by
 * FUNC(drawTagLine). DOWN / FLEEING shows regardless of the status field setting.
 * Mounted units are skipped: the vehicle tag covers their vehicle.
 *
 * Two optional icons ride the same screen-space placement trick, each
 * hover-expandable to its full detail (GVAR(tagShow{Flag,Threat}Icon)):
 *   — a flag icon at the right end when the unit carries status flags
 *     (HIDDEN, BUSY, PATH OFF, …);
 *   — a threat icon between the text and the flag icon — the unit's LAMBS danger
 *     cause if any, else its current attack target (danger always wins, the same
 *     rule the dialog uses) — hovering reveals the full detail.
 *
 * Per-frame cost: the text, colours, widths and icon offsets are all cached per
 * unit (TAG_CACHE) and rebuilt only after a fresh server push or a tag* setting
 * change, so the steady state is two hashmap lookups and the draws below.
 *
 * Three passes per frame: (1) resolve each selected unit to a render record
 * (screen pos, per-metre scales, cache entry); (2) de-conflict vertically so
 * bunched tags stack instead of piling; (3) draw. The layout pass needs every
 * survivor's screen extent up front, hence the split from a single loop.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in script_component.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_hud_fnc_drawUnitTags
 *
 * Public: No
 */

params ["_ctx"];

private _ids = EGVAR(core,selUnits);
if (_ids isEqualTo []) exitWith {};

// This renderer is only registered while its system is in the registry
// (FUNC(applyTagVisibility)), so the record is always there — but a nil read
// would abort the whole pass, so it is not worth assuming.
private _sys = GVAR(tagSystems) get QGVAR(unitTags);
if (isNil "_sys") exitWith {};

if (_sys select TAG_DIRTY) then {
    _sys set [TAG_CACHE, createHashMap];
    _sys set [TAG_DIRTY, false];
};

private _camPos   = _ctx select CTX_CAMPOS;
private _camRight = _ctx select CTX_CAMRIGHT;
private _camUp    = _ctx select CTX_CAMUP;
private _mouse    = _ctx select CTX_MOUSE;

private _cache    = _sys select TAG_CACHE;
private _data     = GVAR(unitData);
private _maxDist  = GVAR(tagMaxDistance);
private _fadeIn   = _maxDist * 0.85;
private _size     = GVAR(tagSize);
private _iconDraw = _size * ICON_DRAW;   // icons scale with the tag size
private _zOff     = GVAR(tagHeight);

// ── Pass 1: resolve each selected unit to a render record ────────────────────
// [_scr, _perMetreRight, _pos, _alpha, _entry, _yShift]. Only survivors reach
// the layout and draw passes. _perMetreRight is UI-x per metre of camera-right
// at this unit's depth — exact for any FOV, no formula guesswork — used to
// convert measured UI offsets back to world metres. (The camera-up equivalent is
// only needed for the rare de-conflicted tag, so the draw pass measures it on
// demand instead of here for every unit.)
private _records = [];
{
    private _entry = _cache get _x;
    if (isNil "_entry") then {
        private _pkt = _data get _x;
        if (isNil "_pkt") then { continue };                        // packet not arrived yet
        if (FLAG_MOUNTED in (_pkt select 11)) then { continue };    // vehicle card covers it
        _entry = [_pkt] call FUNC(buildTagEntry);
        _cache set [_x, _entry];
    };
    if !(_entry select 13) then { continue };                       // every field/icon toggled off

    private _unit = objectFromNetId _x;
    // objectParent re-check: the unit can mount between server pushes.
    if (isNull _unit || {!alive _unit} || {!isNull objectParent _unit}) then { continue };

    // [] while the model has not resolved on this machine — see FUNC(tagAnchor)
    // for why that has to be tested rather than fed to `distance`.
    private _head = [_unit] call FUNC(tagAnchor);
    if (_head isEqualTo []) then { continue };
    private _dist = _camPos distance _head;
    if (_dist > _maxDist) then { continue };
    // Screen-space vertical lift: offset along camera-up, NOT world +Z (which
    // projects to nothing from a top-down camera, collapsing the tag onto its
    // icon). Scaled by camera distance so the on-screen gap above the icon stays
    // constant at any pitch/zoom; below ~30 m it holds the literal "metres above
    // head" the Tag Height setting promises.
    private _pos = _head vectorAdd (_camUp vectorMultiply (_zOff * (1 max (_dist / 30))));

    private _scr = worldToScreen _pos;
    if (_scr isEqualTo []) then { continue };                       // unit off-screen
    private _oneRight = worldToScreen (_pos vectorAdd _camRight);
    if (_oneRight isEqualTo []) then { continue };
    private _perMetreRight = (_oneRight select 0) - (_scr select 0);
    if (_perMetreRight <= 1e-6) then { continue };

    private _alpha = linearConversion [_fadeIn, _maxDist, _dist, 0.85, 0, true];
    _records pushBack [_scr, _perMetreRight, _pos, _alpha, _entry, 0];
} forEach _ids;

if (_records isEqualTo []) exitWith {};

// ── Pass 2: vertical de-confliction ─────────────────────────────────────────
// Working top-of-screen downward, push each tag below any already-placed tag it
// overlaps — horizontal extent from the measured widths, one line-height of
// vertical clearance. Records only their final screen Y; the resulting shift is
// stored per record and applied in the draw pass.
//
// MAX semantics, not stepping. This used to move a tag down one line-height per
// collision and then re-scan every placed tag, needing a pass per line of
// displacement — so a bunched squad (which is the normal case, and the only case
// this pass exists for) ran up to O(n) passes over an O(n) list for each of n
// tags, EVERY FRAME. Taking the maximum clears the tag past every tag it overlaps
// in one sweep instead. A move can still expose an overlap with a tag placed
// lower again, hence the repeat — but it converges in one or two, so the loop is
// bounded outright rather than trusted to settle.
private _lineH = _size * 1.5;   // clears the text + icon band between stacked tags
private _order = [];
{ _order pushBack [(_x select 0) select 1, _forEachIndex] } forEach _records;
_order sort true;                                                  // top of screen first

private _placed = [];                                              // [xCentre, halfWidth, finalY]
{
    private _rec = _records select (_x select 1);
    private _scr = _rec select 0;
    private _xC  = _scr select 0;
    private _hw  = (_rec select 4) select 12;   // composed half-width (text + present icons)
    private _finalY = _scr select 1;
    private _pass = 0;
    private _bumped = true;
    while {_bumped && {_pass < DECONFLICT_MAX_PASSES}} do {
        _bumped = false;
        {
            // ALIAS-FREE: the outer forEach's _x is already read into _rec above,
            // so rebinding it here is safe (docs/Knowledge Base/Gotchas.md §2).
            _x params ["_pXc", "_pHw", "_pY"];
            if ((abs (_xC - _pXc) < (_hw + _pHw)) && {abs (_finalY - _pY) < _lineH}) then {
                private _clear = _pY + _lineH;
                if (_clear > _finalY) then {
                    _finalY = _clear;
                    _bumped = true;
                };
            };
        } forEach _placed;
        _pass = _pass + 1;
    };
    _placed pushBack [_xC, _hw, _finalY];
    _rec set [5, _finalY - (_scr select 1)];
} forEach _order;

// ── Pass 3: draw ────────────────────────────────────────────────────────────
// The de-confliction shift is a screen-space UI-y offset converted to a world
// nudge along camera-up, applied to the base position so text and icons of one
// tag move together. The UI-y-per-metre-of-camera-up scale is measured here, only
// for the (rare) shifted tags — unshifted tags never pay for the extra
// worldToScreen.
private _showFlags = GVAR(tagShowFlagIcon);
{
    _x params ["_scr", "_perMetre", "_pos", "_alpha", "_entry", "_yShift"];
    _entry params [
        "_mainSep", "_rgbMain", "_statusText", "_rgbStatus", "_flagsText",
        "_threatIcon", "_rgbThreat", "_threatHover",
        "_wMainSep", "_wStatus", "_threatCenterUI", "_flagCenterUI"
    ];

    // The distance fade is the only per-frame part of the colour, so build each
    // RGBA once here instead of re-concatenating inside every drawIcon3D below.
    private _colMain   = _rgbMain + [_alpha];
    private _colThreat = _rgbThreat + [_alpha];

    private _dpos = _pos;
    if (_yShift != 0) then {
        private _oneUp = worldToScreen (_pos vectorAdd _camUp);
        if (_oneUp isNotEqualTo []) then {
            private _perMetreUp = (_oneUp select 1) - (_scr select 1);
            if (abs _perMetreUp > 1e-6) then {
                _dpos = _pos vectorAdd (_camUp vectorMultiply (_yShift / _perMetreUp));
            };
        };
    };
    private _scrX = _scr select 0;
    private _scrY = (_scr select 1) + _yShift;

    // Main line, with the status word split off into its own colour — shared with
    // the vehicle tags so both families measure and place it identically.
    [
        _dpos, _perMetre, _camRight, _mainSep, _statusText,
        _colMain, _rgbStatus + [_alpha], _size, _wMainSep, _wStatus
    ] call FUNC(drawTagLine);

    // Icons ride the flush centre offsets measured at cache-build time (UI-x from
    // the unit centre), converted to world via _perMetre so each sits snug against
    // the text / its neighbour. Non-hover draws centre the icon on that point;
    // hover expands the detail away from the text.

    // Threat icon (danger/target) — flush to the right edge of the line.
    if (_threatIcon != "") then {
        private _iconPos = _dpos vectorAdd (_camRight vectorMultiply (_threatCenterUI / _perMetre));
        if ([_scrX + _threatCenterUI, _scrY] distance2D _mouse < ICON_HOVER_RADIUS) then {
            drawIcon3D [_threatIcon, _colThreat, _iconPos, _iconDraw, _iconDraw, 0, _threatHover, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
        } else {
            drawIcon3D [_threatIcon, _colThreat, _iconPos, _iconDraw, _iconDraw, 0, "", 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
        };
    };

    // Flag-inventory icon — flush past the threat icon when both show, else flush
    // to the text. Hovering expands the full flag list.
    if (_showFlags && {_flagsText != ""}) then {
        private _iconPos = _dpos vectorAdd (_camRight vectorMultiply (_flagCenterUI / _perMetre));
        if ([_scrX + _flagCenterUI, _scrY] distance2D _mouse < ICON_HOVER_RADIUS) then {
            drawIcon3D [FLAG_ICON, COL_GOLD, _iconPos, _iconDraw, _iconDraw, 0, _flagsText, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
        } else {
            drawIcon3D [FLAG_ICON, _colMain, _iconPos, _iconDraw, _iconDraw, 0, "", 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
        };
    };
} forEach _records;
