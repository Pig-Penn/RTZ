#include "script_component.hpp"
/*
 * Author: Maxim
 * Minimalist floating status tag above each selected infantry unit's head
 * while Zeus is open — one discrete text line (e.g. "Rifleman · HP 62 ·
 * FLEEING") fed by the same live server packets the selection info dialog
 * uses (GVAR(selCurrent) / GVAR(selData), maintained by FUNC(selectionInfo)).
 *
 * The line is assembled by FUNC(buildTagEntry) from the fields enabled in CBA
 * settings (role, health, morale, suppression, magazine rounds, status, LAMBS
 * tactic, current AI command) and drawn in a static colour so urgency never
 * recolours the whole line. Only the trailing status word (DOWN / FLEEING)
 * gets its own colour (red), rendered as a second drawIcon3D split at a
 * measured text-width boundary from the rest of the line (same screen-space
 * trick as the flag icon below). DOWN / FLEEING always shows regardless of
 * the status field setting. Mounted units are skipped (the vehicle overlay
 * covers their vehicle); tags fade out approaching GVAR(tagMaxDistance) from
 * the camera.
 *
 * Two optional icons ride the same screen-space placement trick, each
 * hover-expandable to its full detail (GVAR(tagShow{Flag,Threat}Icon)):
 *   — a flag icon at the right end when the unit carries status flags
 *     (HIDDEN, BUSY, PATH OFF, …);
 *   — a threat icon between the text and the flag icon — the unit's LAMBS
 *     danger cause if any, else its current attack target (danger always
 *     wins, same rule the dialog uses) — hovering reveals the full detail.
 * Each icon's world position is derived in screen space — measured text-width
 * offset plus a gap, converted to metres by measuring how far one metre of
 * camera-right moves on screen at the unit's depth — and hover is a
 * worldToScreen vs getMousePosition proximity test (same UI-coordinate space).
 *
 * Tags of units bunched together are de-conflicted each frame: a top-down
 * layout pass pushes overlapping tags one line-height apart (screen-space
 * measured extents), applied as a vertical world nudge so text and icons move
 * as one — a tight squad reads as a stack instead of an unreadable pile.
 *
 * Visibility toggles at runtime via the shared "Draw Tags" ZEN context menu
 * entry (FUNC(tagsContext)) — one entry drives this system and the vehicle
 * tags together, through FUNC(toggleTags). The selection poll in
 * FUNC(selectionInfo) reports the selection to the server while
 * GVAR(tagsVisible) is true, so hidden tags cost zero gather/network traffic.
 *
 * Per-frame cost: tag text/colour is cached per unit (GVAR(tagCache)) and only
 * rebuilt after a fresh server push or a tag* setting change, so a frame does
 * two hashmap lookups + one drawIcon3D per selected unit.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it).
 *   Needs FUNC(selectionInfo) running (Selection Info setting ON) for the
 *   data stream — XEH_postInit only starts this system when both are enabled.
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableUnitTags). Client-only; registers a Draw3D MEH + CBA handlers,
 *   no scheduled ops — `call`ed, not `spawn`ed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_selection_fnc_unitTags
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Icon render size and hover pick distance (ICON_DRAW / ICON_HOVER_RADIUS) come
// from script_component.hpp, alongside the placement constants
// FUNC(buildTagEntry) measures with. The UI-x offsets that position the icons and
// split the coloured status word are measured exactly at cache-build time — this
// pass only reads them back.

// Runtime visibility switch (context menu). The master CBA setting gates whether
// this system exists at all; this flips it mid-mission. Read defensively by the
// selection poll — while true, the poll reports the selection so the server
// streams packets.
GVAR(tagsVisible) = true;

// netId → FUNC(buildTagEntry) result, built lazily during the draw pass; wiped
// whenever the underlying data or a tag* setting changes.
GVAR(tagCache)      = createHashMap;
GVAR(tagCacheDirty) = true;

// Invalidate on every fresh server push (second handler on the same CBA event
// the dialog consumes — both run inside one dispatch, before the next draw)…
[QGVAR(selData), { GVAR(tagCacheDirty) = true }] call CBA_fnc_addEventHandler;

// …and when a tag setting changes mid-mission, so field toggles apply live.
// Flipping the master setting also syncs the runtime switch: OFF hides tags
// (and stops the data stream) immediately instead of waiting for a restart.
["CBA_SettingChanged", {
    params ["_name", "_value"];
    private _lname = toLower _name;
    if ((_lname find toLower QGVAR(tag)) == 0) then { GVAR(tagCacheDirty) = true };
    if (_lname == toLower QGVAR(enableUnitTags)) then { GVAR(tagsVisible) = _value };
}] call CBA_fnc_addEventHandler;

// ── Draw pass ────────────────────────────────────────────────────────────────
// Three passes per frame: (1) resolve each selected unit to a render record
// (screen pos, per-metre scales, cache entry); (2) de-conflict vertically so
// bunched tags stack instead of piling; (3) draw. The layout pass needs every
// survivor's screen extent up front, hence the split from the old single loop.
[missionNamespace, "Draw3D", {
    if (!GVAR(tagsVisible)) exitWith {};
    if (isNull (findDisplay IDD_RSCDISPLAYCURATOR) || { isNull (getAssignedCuratorLogic player) }) exitWith {};
    if (isNil QGVAR(selCurrent)) exitWith {};
    private _ids = GVAR(selCurrent);
    if (_ids isEqualTo []) exitWith {};

    if (GVAR(tagCacheDirty)) then {
        GVAR(tagCache)      = createHashMap;
        GVAR(tagCacheDirty) = false;
    };

    private _cache    = GVAR(tagCache);
    private _data     = GVAR(selData);
    private _camPos   = positionCameraToWorld [0, 0, 0];
    private _maxDist  = GVAR(tagMaxDistance);
    private _fadeIn   = _maxDist * 0.85;
    private _size     = GVAR(tagSize);
    private _iconDraw = _size * ICON_DRAW;   // icons scale with the tag size now
    private _zOff     = GVAR(tagHeight);
    private _mouse    = getMousePosition;
    // Camera-right / camera-up unit vectors in world space — the axes tags are
    // shifted along so "right of the text" and "one line down" hold for any
    // camera orientation.
    private _camRight = (positionCameraToWorld [1, 0, 0]) vectorDiff _camPos;
    private _camUp    = (positionCameraToWorld [0, 1, 0]) vectorDiff _camPos;

    // ── Pass 1: resolve each selected unit to a render record ────────────────
    // [_scr, _perMetreRight, _pos, _alpha, _entry, _yShift]. Every skip
    // condition from the old single loop lives here; only survivors reach the
    // layout and draw passes. _perMetreRight is UI-x per metre of camera-right
    // at this unit's depth — exact for any FOV, no formula guesswork — used to
    // convert measured UI offsets back to world metres. (The camera-up
    // equivalent is only needed for the rare de-conflicted tag, so the draw
    // pass measures it on demand instead of here for every unit.)
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
        if (isNull _unit || { !alive _unit } || { !isNull objectParent _unit }) then { continue };

        private _head = _unit modelToWorldVisual (_unit selectionPosition "Head");
        private _dist = _camPos distance _head;
        if (_dist > _maxDist) then { continue };
        // Screen-space vertical lift: offset along camera-up, NOT world +Z
        // (which projects to nothing from a top-down camera, collapsing the tag
        // onto its icon). Scaled by camera distance so the on-screen gap above
        // the icon stays constant at any pitch/zoom; below ~30 m it holds the
        // literal "metres above head" the Tag Height setting promises.
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

    // ── Pass 2: vertical de-confliction ──────────────────────────────────────
    // Working top-of-screen downward, push each tag below any already-placed
    // tag it overlaps — horizontal extent from the measured widths, one
    // line-height of vertical clearance. Records only their final screen Y; the
    // resulting shift is stored per record and applied in the draw pass.
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
        while { _bumped && { _pass <= count _placed } } do {
            _bumped = false;
            {
                _x params ["_pXc", "_pHw", "_pY"];
                if ((abs (_xC - _pXc) < (_hw + _pHw)) && { abs (_finalY - _pY) < _lineH }) then {
                    _finalY = _pY + _lineH;
                    _bumped = true;
                };
            } forEach _placed;
            _pass = _pass + 1;
        };
        _placed pushBack [_xC, _hw, _finalY];
        _rec set [5, _finalY - (_scr select 1)];
    } forEach _order;

    // ── Pass 3: draw ─────────────────────────────────────────────────────────
    // The de-confliction shift is a screen-space UI-y offset converted to a
    // world nudge along camera-up, applied to the base position so text and
    // icons of one tag move together. The UI-y-per-metre-of-camera-up scale is
    // measured here, only for the (rare) shifted tags — unshifted tags never
    // pay for the extra worldToScreen.
    private _showFlags = GVAR(tagShowFlagIcon);
    {
        _x params ["_scr", "_perMetre", "_pos", "_alpha", "_entry", "_yShift"];
        _entry params [
            "_mainText", "_rgbMain", "_statusText", "_rgbStatus", "_sep", "_flagsText",
            "_threatIcon", "_rgbThreat", "_threatHover",
            "_wMainSep", "_wStatus", "_threatCenterUI", "_flagCenterUI"
        ];

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
        // combined line stays centred on the unit. Boundary = centre + halfFull
        // - statusWidth (measured), converted from UI-x to world via _perMetre.
        // drawIcon3D textAlign names the SIDE of the anchor the text sits on
        // (not typographic alignment): "left" ends at the anchor, "right"
        // starts there.
        if (_statusText == "") then {
            drawIcon3D ["", _rgbMain + [_alpha], _dpos, 0, 0, 0, _mainText + _sep, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
        } else {
            private _boundaryUI  = ((_wMainSep + _wStatus) / 2) - _wStatus;
            private _boundaryPos = _dpos vectorAdd (_camRight vectorMultiply (_boundaryUI / _perMetre));
            drawIcon3D ["", _rgbMain   + [_alpha], _boundaryPos, 0, 0, 0, _mainText + _sep, 2, _size, "RobotoCondensedBold", "left",  false, 0, 0];
            drawIcon3D ["", _rgbStatus + [_alpha], _boundaryPos, 0, 0, 0, _statusText,      2, _size, "RobotoCondensedBold", "right", false, 0, 0];
        };

        // Icons ride the flush centre offsets measured at cache-build time (UI-x
        // from the unit centre), converted to world via _perMetre so each sits
        // snug against the text / its neighbour. Non-hover draws centre the icon
        // on that point; hover expands the detail away from the text.

        // Threat icon (danger/target) — flush to the right edge of the line.
        if (_threatIcon != "") then {
            private _iconPos = _dpos vectorAdd (_camRight vectorMultiply (_threatCenterUI / _perMetre));
            if ([_scrX + _threatCenterUI, _scrY] distance2D _mouse < ICON_HOVER_RADIUS) then {
                drawIcon3D [_threatIcon, _rgbThreat + [_alpha], _iconPos, _iconDraw, _iconDraw, 0, _threatHover, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
            } else {
                drawIcon3D [_threatIcon, _rgbThreat + [_alpha], _iconPos, _iconDraw, _iconDraw, 0, "", 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
            };
        };

        // Flag-inventory icon — flush past the threat icon when both show, else
        // flush to the text. Hovering expands the full flag list.
        if (_showFlags && { _flagsText != "" }) then {
            private _iconPos = _dpos vectorAdd (_camRight vectorMultiply (_flagCenterUI / _perMetre));
            if ([_scrX + _flagCenterUI, _scrY] distance2D _mouse < ICON_HOVER_RADIUS) then {
                drawIcon3D [FLAG_ICON, COL_GOLD, _iconPos, _iconDraw, _iconDraw, 0, _flagsText, 2, _size, "RobotoCondensedBold", "right", false, 0, 0];
            } else {
                drawIcon3D [FLAG_ICON, _rgbMain + [_alpha], _iconPos, _iconDraw, _iconDraw, 0, "", 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
            };
        };
    } forEach _records;
}] call CBA_fnc_addBISEventHandler;
