#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the infantry head tags. Called once per frame by
 * EFUNC(core,frameLoop) with the shared frame context — the Zeus test, the camera
 * basis and the mouse position are already resolved, so this pass does no camera
 * query of its own.
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

if (GVAR(unitTagsDirty)) then {
    GVAR(unitTagsCache) = createHashMap;
    GVAR(unitTagsDirty) = false;
};

private _camPos   = _ctx select CTX_CAMPOS;
private _camRight = _ctx select CTX_CAMRIGHT;
private _camUp    = _ctx select CTX_CAMUP;
private _mouse    = _ctx select CTX_MOUSE;

private _cache    = GVAR(unitTagsCache);
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
    if !(_entry select 14) then { continue };                       // every field/icon toggled off

    private _unit = objectFromNetId _x;
    // objectParent re-check: the unit can mount between server pushes.
    if (isNull _unit || {!alive _unit} || {!isNull objectParent _unit}) then { continue };

    private _head = _unit modelToWorldVisual ([_unit] call EFUNC(common,headOffset));
    // modelToWorldVisual yields [] while the model has not resolved on this machine
    // (the frames right after Zeus creates the unit), and `distance` throws a
    // Generic error on []. That error ABORTS THE WHOLE forEach, so one unresolved
    // unit dropped every tag after it in the store — not just its own.
    if (count _head < 3) then { continue };
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
private _lineH = _size * 1.5;   // clears the text + icon band between stacked tags
private _order = [];
{ _order pushBack [(_x select 0) select 1, _forEachIndex] } forEach _records;
_order sort true;                                                  // top of screen first

private _placed = [];                                              // [xCentre, halfWidth, finalY]
{
    private _rec = _records select (_x select 1);
    private _scr = _rec select 0;
    private _xC  = _scr select 0;
    private _hw  = (_rec select 4) select 13;   // composed half-width (text + present icons)
    private _finalY = _scr select 1;
    private _pass = 0;
    private _bumped = true;
    while {_bumped && {_pass <= count _placed}} do {
        _bumped = false;
        {
            _x params ["_pXc", "_pHw", "_pY"];
            if ((abs (_xC - _pXc) < (_hw + _pHw)) && {abs (_finalY - _pY) < _lineH}) then {
                _finalY = _pY + _lineH;
                _bumped = true;
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
        "_mainText", "_rgbMain", "_statusText", "_rgbStatus", "_sep", "_flagsText",
        "_threatIcon", "_rgbThreat", "_threatHover",
        "_wMainSep", "_wStatus", "_threatCenterUI", "_flagCenterUI",
        "", "", "_mainSep"
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

    // Main line — split so the status word carries its own colour while the
    // combined line stays centred on the unit. Boundary = centre + halfFull -
    // statusWidth (measured), converted from UI-x to world via _perMetre.
    // drawIcon3D textAlign names the SIDE of the anchor the text sits on (not
    // typographic alignment): "left" ends at the anchor, "right" starts there.
    if (_statusText == "") then {
        drawIcon3D ["", _colMain, _dpos, 0, 0, 0, _mainSep, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
    } else {
        private _boundaryUI  = ((_wMainSep + _wStatus) / 2) - _wStatus;
        private _boundaryPos = _dpos vectorAdd (_camRight vectorMultiply (_boundaryUI / _perMetre));
        drawIcon3D ["", _colMain,              _boundaryPos, 0, 0, 0, _mainSep,    2, _size, "RobotoCondensedBold", "left",  false, 0, 0];
        drawIcon3D ["", _rgbStatus + [_alpha], _boundaryPos, 0, 0, 0, _statusText, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
    };

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
