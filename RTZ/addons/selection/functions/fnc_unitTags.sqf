#include "script_component.hpp"
/*
 * rtz_fnc_unitTags
 *
 * Minimalist floating status tag above each selected infantry unit's head
 * while Zeus is open — one discrete text line (e.g. "Rifleman · HP 62 ·
 * FLEEING") fed by the same live server packets the selection info dialog
 * uses (GVAR(selCurrent) / GVAR(selData), maintained by rtz_fnc_selectionInfo).
 *
 * The line is assembled from the fields enabled in CBA settings (role, name,
 * health, morale, suppression, magazine rounds, status, LAMBS tactic, leader
 * intel) and drawn in a static colour — side-tinted when GVAR(tagSideColors)
 * is set, the normal tag colour otherwise — so urgency never recolours the
 * whole line. Only the trailing status word (DOWN / FLEEING) gets its own
 * colour (red), rendered as a second drawIcon3D split at a measured
 * text-width boundary from the rest of the line (same screen-space
 * trick as the flag icon below). DOWN / FLEEING always shows regardless of
 * the status field setting. Mounted units are skipped (the vehicle overlay
 * covers their vehicle); tags fade out approaching GVAR(tagMaxDistance) from
 * the camera.
 *
 * Three optional icons ride the same screen-space placement trick, each
 * hover-expandable to its full detail (GVAR(tagShow{Flag,State,Threat}Icon)):
 *   — a flag icon at the right end when the unit carries status flags
 *     (HIDDEN, BUSY, PATH OFF, …);
 *   — an AI-state icon at the left end mirroring the selection dialog's row
 *     icon (combat/stealth/fleeing/downed), hovering it reveals behaviour /
 *     state / current command;
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
 * entry (rtz_fnc_tagsContext), which drives this system's GVAR(fnc_toggleTags)
 * alongside the vehicle tags' toggle. The selection poll in
 * rtz_fnc_selectionInfo reports the selection to the server while
 * GVAR(tagsVisible) is true, so hidden tags cost zero gather/network traffic.
 *
 * Per-frame cost: tag text/colour is cached per unit (GVAR(tagCache)) and only
 * rebuilt after a fresh server push or a tag* setting change, so a frame does
 * two hashmap lookups + one drawIcon3D per selected unit.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it).
 *   Needs rtz_fnc_selectionInfo running (Selection Info setting ON) for the
 *   data stream — XEH_postInit only starts this system when both are enabled.
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableUnitTags). Client-only; registers a Draw3D MEH + CBA handlers,
 *   no scheduled ops — `call`ed, not `spawn`ed.
 */

if (!hasInterface) exitWith {};

// State/threat/flag icon textures (FLAG_ICON, ICON_*) come from
// script_component.hpp — the same BIS simpletask set the selection dialog's
// row icons use, so tag and dialog always agree.

// ICON_HOVER_RADIUS is the Zeus-cursor pick distance (UI coordinates) for an
// icon's hover-expand. The text widths that place the icons and split the
// coloured status word are now measured exactly (FUNC(textWidth)), so the
// old eyeballed per-character constants are gone.
#define ICON_HOVER_RADIUS 0.03

// Icon geometry, all as multiples of the tag's text size so icons scale WITH it
// (the old draw pass drew every icon at a fixed 0.7 regardless of Tag Size, so a
// larger tag kept postage-stamp icons). ICON_DRAW is the drawIcon3D render size;
// ICON_FOOT is the icon's on-screen footprint (UI-x) used to butt icons flush
// against the text and each other; ICON_TEXT_GAP is the (larger) gap between the
// text and its first icon so a status word like DOWN isn't cramped against the
// icon beside it, while ICON_GAP keeps two adjacent icons snug. Tuned so the
// default (size 0.03) reproduces the old ~0.7 icon — nudge ICON_FOOT /
// ICON_TEXT_GAP / ICON_GAP if icons overlap or drift at your UI scale.
#define ICON_DRAW      23
#define ICON_FOOT      1.1
#define ICON_TEXT_GAP  0.9
#define ICON_GAP       0.3

// Runtime visibility switch (context menu). The master CBA setting
// gates whether this system exists at all; this flips it mid-mission. Read
// defensively by the selection poll — while true, the poll reports the
// selection so the server streams packets.
GVAR(tagsVisible) = true;

// netId → [mainText, [r,g,b], statusText, [r,g,b], sep, flagsText, stateIcon,
// [r,g,b], stateHover, threatIcon, [r,g,b], threatHover] built lazily during
// the draw pass; wiped whenever the underlying data or a tag* setting changes.
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

// ── Tag line assembly ────────────────────────────────────────────────────────
// Builds one unit's cache entry (see GVAR(tagCache) layout above) from its
// server packet (layout: rtz_fnc_gatherUnitInfo). Locality-bound fields
// (morale, suppression, ammo, task, tactic, intel, state/threat icons) are
// only rendered when the packet carries live data. statusText is coloured
// separately from mainText so DOWN / FLEEING can be red without recolouring
// the whole line. flagsText/stateHover/threatHover are the hover-expand
// strings for their respective icons ("" when the icon has nothing to show).
GVAR(fnc_buildTagEntry) = {
    params ["_pkt"];
    _pkt params [
        "", "_isLdr", "", "_role", "_sideNum", "_name",
        "_behaviour", "_state", "_cmd", "_morale", "_supp", "_flags", "_downed",
        "_task", "_tactic", ["_dangerType", -1], ["_dangerDist", -1], ["_dangerTimeout", -1],
        "_tgtType", ["_tgtVis", -1], ["_known", -1], ["_groupMem", -1], "_isLocal", ["_hp", 100], "",
        "", ["_ammo", -1], ["_ammoCap", -1]
    ];

    // Display-label remap (rtz_fnc_loadTagLabels) — re-words LAMBS task/tactic
    // strings, RTZ status words, and flags at build time (cached).
    private _labels = GVAR(tagLabels);

    private _segs = [];
    if (GVAR(tagShowName)) then { _segs pushBack _name };
    if (GVAR(tagShowRole)) then { _segs pushBack _role };
    if (GVAR(tagShowHealth) && { _hp < 100 }) then { _segs pushBack format ["HP %1", _hp] };
    private _suppPct = round (_supp * 100);
    if (_isLocal) then {
        if (GVAR(tagShowMorale)) then {
            _segs pushBack format ["MOR %1", round (linearConversion [-1, 1, _morale, 0, 100, true])];
        };
        if (GVAR(tagShowSuppression) && { _suppPct > 0 }) then {
            _segs pushBack format ["SUP %1", _suppPct];
        };
        if (GVAR(tagShowAmmo) && { _ammo >= 0 } && { _ammo != _ammoCap }) then {
            // "<current>/<capacity>"; capacity can be unknown (-1: no mag
            // loaded, or a pre-capacity server build) — degrade to bare count.
            // A full magazine (_ammo == _ammoCap) is dropped entirely — only
            // partial/depleted mags are worth flagging.
            _segs pushBack ([str _ammo, format ["%1/%2", _ammo, _ammoCap]] select (_ammoCap > 0));
        };
        // Group-wide facts — leader's tag only, so a squad doesn't repeat the
        // same line on every member.
        if (_isLdr) then {
            if (GVAR(tagShowTactic) && { _tactic != "" }) then {
                _segs pushBack format ["TAC %1", _labels getOrDefault [_tactic, _tactic]];
            };
            if (GVAR(tagShowIntel)) then {
                _segs pushBack format ["ENEMY %1 · MEM %2", _known max 0, _groupMem max 0];
            };
        };
    };

    // Status: urgent states always surface; the LAMBS task only when enabled.
    // Kept out of _segs — it's rendered as its own coloured drawIcon3D so DOWN
    // / FLEEING can be red without recolouring the rest of the line.
    private _status = switch (true) do {
        case (_downed):             { "DOWN" };
        case ("FLEEING" in _flags): { "FLEEING" };
        case (GVAR(tagShowStatus)): { _task };   // "" without LAMBS
        default                     { "" };
    };
    _status = _labels getOrDefault [_status, _status];   // re-word DOWN/FLEEING/task

    // Static colour — side tint when enabled, otherwise the normal tag colour.
    private _urgent = _downed || { "FLEEING" in _flags };
    private _col = [COL_NORMAL, SIDE_TINTS select _sideNum] select GVAR(tagSideColors);
    // Urgency wins over the side tint: when the unit is downed/fleeing the red
    // status word carries the alarm, so the rest of the line drops back to the
    // neutral colour instead of clashing red-on-red against a red side tint.
    if (_urgent) then { _col = COL_NORMAL };
    private _statusCol = [_col, COL_BAD] select _urgent;

    private _mainText = _segs joinString " · ";
    private _sep = ["", " · "] select (_mainText != "" && { _status != "" });

    // AI-state icon (left of the tag) — same switch the dialog's row icon
    // uses, minus the MOUNTED case (mounted units never reach this function).
    // Leader gets it gold, same override rule as the dialog.
    private _stateIcon = "";
    private _stateIconColFull = [];
    private _stateHover = "";
    if (GVAR(tagShowStateIcon) && _isLocal) then {
        // Downed/fleeing already shout via the red status word, so their state
        // icon is dropped to keep the left side of a crowded tag clean.
        _stateIcon = switch (true) do {
            case (_urgent):                 { "" };
            case (_behaviour == "COMBAT"):  { ICON_ATTACK };
            case (_behaviour == "STEALTH"): { ICON_SEARCH };
            default                         { ICON_MOVE };
        };
        _stateIconColFull = if (_isLdr && { _col isEqualTo COL_NORMAL }) then { COL_GOLD } else { _col };
        _stateHover = ([_behaviour, _state, _cmd] select { _x != "" }) joinString " · ";
    };

    // Threat icon (between the text and the flag icon) — LAMBS danger cause
    // beats a live attack target, same rule the dialog uses for its one
    // right-side indicator.
    private _threatIcon = "";
    private _threatIconCol = [];
    private _threatHover = "";
    if (GVAR(tagShowThreatIcon) && _isLocal) then {
        private _dStr = DANGER_LABELS param [(_dangerType + 2) max 0, ""];
        if (_dStr != "") then {
            _threatIcon = ICON_DANGER;
            _threatIconCol = COL_WARN;
            _threatHover = _dStr
                + ([" ", format [" %1m", _dangerDist]] select (_dangerDist >= 0))
                + ([" ", format [" %1s", _dangerTimeout]] select (_dangerTimeout >= 0));
        } else {
            if (_tgtType != "") then {
                _threatIcon = ICON_TARGET;
                _threatIconCol = COL_BAD;
                _threatHover = format ["Target %1 (%2 vis)", _tgtType, (_tgtVis max 0) toFixed 1];
            };
        };
    };

    // Exact on-screen widths for the icon placement / status split in the draw
    // pass. Measured here (once per cache build) so the per-frame draw only
    // reads them back — size changes dirty the cache, so these stay in step.
    private _tagSize  = GVAR(tagSize);
    private _wMainSep = [_mainText + _sep, _tagSize] call FUNC(textWidth);
    private _wStatus  = [_status, _tagSize] call FUNC(textWidth);
    private _halfFull = (_wMainSep + _wStatus) / 2;   // text half-width (UI-x)

    // Icon layout (UI-x, from the unit's centre). Each icon butts flush against
    // the text or the previous icon with one small ICON_GAP — no more eyeballed
    // per-icon advances. Right side: threat then flag; left side: the state icon.
    private _iconW    = _tagSize * ICON_FOOT;          // icon on-screen footprint
    private _gap      = _tagSize * ICON_GAP;           // gap between two adjacent icons
    private _textGap  = _tagSize * ICON_TEXT_GAP;      // larger gap: text ↔ its first icon
    private _step     = _iconW + _gap;                 // centre-to-centre, adjacent icons
    private _flush    = _halfFull + _textGap + (_iconW / 2); // first icon offset from a text edge

    private _stateCenterUI  = -_flush;                 // left of the text
    private _threatCenterUI =  _flush;                 // right of the text
    // Flag follows the threat icon when both show, otherwise sits flush itself.
    private _flagCenterUI    = if (_threatIcon != "") then { _flush + _step } else { _flush };

    // De-confliction half-width: the text half plus whichever side carries icons,
    // so the stacking pass knows each tag's true footprint (icons included).
    private _hasFlag     = GVAR(tagShowFlagIcon) && { _flags isNotEqualTo [] };
    private _nRight      = parseNumber (_threatIcon != "") + parseNumber _hasFlag;
    private _rightExtent = [_halfFull, _flush + (_iconW / 2) + ([0, _step] select (_nRight > 1))] select (_nRight > 0);
    private _leftExtent  = [_halfFull, _flush + (_iconW / 2)] select (_stateIcon != "");
    private _hwLayout    = _rightExtent max _leftExtent;

    private _flagsText = (_flags apply { _labels getOrDefault [_x, _x] }) joinString " · ";
    // Precomputed "anything to draw at all" flag (index 18) — the per-frame
    // resolve pass reads this single boolean instead of unpacking the entry to
    // re-derive it every frame for every unit.
    private _hasContent = _mainText != "" || { _status != "" } || { _flagsText != "" }
        || { _stateIcon != "" } || { _threatIcon != "" };

    [
        _mainText,
        _col select [0, 3],
        _status,
        _statusCol select [0, 3],
        _sep,
        _flagsText,
        _stateIcon,
        _stateIconColFull select [0, 3],
        _stateHover,
        _threatIcon,
        _threatIconCol select [0, 3],
        _threatHover,
        _wMainSep,
        _wStatus,
        _stateCenterUI,
        _threatCenterUI,
        _flagCenterUI,
        _hwLayout,
        _hasContent
    ]
};

// ── Runtime toggle (driven by the shared context menu entry) ────────────────
GVAR(fnc_toggleTags) = {
    GVAR(tagsVisible) = !GVAR(tagsVisible);
    [format ["Unit tags %1", ["hidden", "shown"] select GVAR(tagsVisible)]] call zen_common_fnc_showMessage;
};

// ── Draw pass ────────────────────────────────────────────────────────────────
// Three passes per frame: (1) resolve each selected unit to a render record
// (screen pos, per-metre scales, measured widths, cache entry); (2) de-conflict
// vertically so bunched tags stack instead of piling; (3) draw. The layout pass
// needs every survivor's screen extent up front, hence the split from the old
// single loop.
[missionNamespace, "Draw3D", {
    if (!GVAR(tagsVisible)) exitWith {};
    if (isNull (findDisplay 312) || { isNull (getAssignedCuratorLogic player) }) exitWith {};
    if (isNil QGVAR(selCurrent)) exitWith {};
    private _ids = GVAR(selCurrent);
    if (_ids isEqualTo []) exitWith {};

    if (GVAR(tagCacheDirty)) then {
        GVAR(tagCache)      = createHashMap;
        GVAR(tagCacheDirty) = false;
    };

    private _cache   = GVAR(tagCache);
    private _data    = GVAR(selData);
    private _camPos  = positionCameraToWorld [0, 0, 0];
    private _maxDist = GVAR(tagMaxDistance);
    private _fadeIn  = _maxDist * 0.85;
    private _size    = GVAR(tagSize);
    private _iconDraw = _size * ICON_DRAW;   // icons scale with the tag size now
    private _zOff    = GVAR(tagHeight);
    private _showFlags = GVAR(tagShowFlagIcon);
    private _mouse     = getMousePosition;
    // Camera-right / camera-up unit vectors in world space — the axes tags are
    // shifted along so "right of the text" and "one line down" hold for any
    // camera orientation.
    private _camRight  = (positionCameraToWorld [1, 0, 0]) vectorDiff _camPos;
    private _camUp     = (positionCameraToWorld [0, 1, 0]) vectorDiff _camPos;

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
            if (isNil "_pkt") then { continue };                   // packet not arrived yet
            if ("MOUNTED" in (_pkt select 11)) then { continue };  // vehicle card covers it
            _entry = [_pkt] call GVAR(fnc_buildTagEntry);
            _cache set [_x, _entry];
        };
        if !(_entry select 18) then { continue };                  // every field/icon toggled off

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
        if (_scr isEqualTo []) then { continue };                  // unit off-screen
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
    _order sort true;                                              // top of screen first

    private _placed = [];                                          // [xCentre, halfWidth, finalY]
    {
        private _rec = _records select (_x select 1);
        private _e   = _rec select 4;
        private _scr = _rec select 0;
        private _xC  = _scr select 0;
        private _hw  = _e select 17;   // true composed half-width (text + present icons)
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
    {
        _x params ["_scr", "_perMetre", "_pos", "_alpha", "_entry", "_yShift"];
        _entry params [
            "_mainText", "_rgbMain", "_statusText", "_rgbStatus", "_sep", "_flagsText",
            "_stateIcon", "_rgbState", "_stateHover", "_threatIcon", "_rgbThreat", "_threatHover",
            "_wMainSep", "_wStatus", "_stateCenterUI", "_threatCenterUI", "_flagCenterUI"
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
        private _halfFull = (_wMainSep + _wStatus) / 2;

        // Main line — split so the status word carries its own colour while the
        // combined line stays centred on the unit. Boundary = centre + halfFull
        // - statusWidth (measured), converted from UI-x to world via _perMetre.
        // drawIcon3D textAlign names the SIDE of the anchor the text sits on
        // (not typographic alignment): "left" ends at the anchor, "right"
        // starts there.
        if (_statusText == "") then {
            drawIcon3D ["", _rgbMain + [_alpha], _dpos, 0, 0, 0, _mainText + _sep, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
        } else {
            private _boundaryUI  = _halfFull - _wStatus;
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

        // AI-state icon — flush to the left edge, mirroring the selection
        // dialog's row icon. Hovering expands the detail leftward.
        if (_stateIcon != "") then {
            private _iconPos = _dpos vectorAdd (_camRight vectorMultiply (_stateCenterUI / _perMetre));
            if ([_scrX + _stateCenterUI, _scrY] distance2D _mouse < ICON_HOVER_RADIUS) then {
                drawIcon3D [_stateIcon, _rgbState + [_alpha], _iconPos, _iconDraw, _iconDraw, 0, _stateHover, 2, _size, "RobotoCondensedBold", "left", false, 0, 0];
            } else {
                drawIcon3D [_stateIcon, _rgbState + [_alpha], _iconPos, _iconDraw, _iconDraw, 0, "", 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
            };
        };
    } forEach _records;
}] call CBA_fnc_addBISEventHandler;
