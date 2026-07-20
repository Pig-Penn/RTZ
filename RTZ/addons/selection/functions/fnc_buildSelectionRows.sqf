#include "script_component.hpp"
/*
 * rtz_fnc_buildSelectionRows
 *
 * Builds the display model for the selection info dialog from the current
 * curator selection state. Reads GVAR(selCurrent) and GVAR(selData), maintained
 * by rtz_fnc_selectionInfo.
 *
 * Each unit becomes one spaced listbox line — "» Role · STATUS · Morale x% ·
 * Supp y% · HP z%" plus the current danger OR target when present — carrying a
 * status icon on the left, a danger/target indicator icon on the right, and a
 * status-driven colour. STATUS is only urgent/interesting information (DOWNED,
 * FLEEING, or the LAMBS task) — plain AI state and combat mode live in the
 * hover tooltip's full LAMBS-style field dump, not in the row. The group
 * leader is always listed first, marked » with a gold icon. Groups get a
 * side-coloured header row (name · units · morale · tactic · down) only when
 * more than one group is selected.
 *
 * Returns: [_header, _rows, _keys]
 *   _header  STRING            — summary line rendered above the list.
 *   _rows    [[text, color, tooltip, picture, pictureColor, pictureRight, pictureRightColor], ...]
 *   _keys    [STRING, ...]     — a stable structural key per row. rtz_fnc_open-
 *                                SelectionInfo compares it tick-to-tick to decide
 *                                between an in-place refresh and a full rebuild.
 *
 * No parameters.
 * Requirements: CBA_A3
 */

// Row colours (COL_*), group separator tint (SIDE_TINTS), row icons (ICON_*),
// and the LAMBS danger-cause labels (DANGER_LABELS) all come from
// script_component.hpp — one palette/icon/label system shared with the unit
// head tags and vehicle cards.

// Spaced middot separator between the segments of a row / header line.
#define SEP "   ·   "

// ── Named packet fields ──────────────────────────────────────────────────────
// The per-row `params [...]` below reads the whole packet in order; these name the
// handful of fields this function ALSO reaches for out of order (grouping keys,
// tallies, side tint) so those stay readable and survive a layout change. Indices
// are the writer's — rtz_fnc_gatherUnitInfo's array order.
#define PKT_ISLDR   1
#define PKT_GRPID   2
#define PKT_SIDE    4
#define PKT_MORALE  9
#define PKT_FLAGS   11
#define PKT_DOWNED  12
#define PKT_TACTIC  14
#define PKT_ISLOCAL 22
#define PKT_GRPNET  25

if (isNil QGVAR(selCurrent)) exitWith { ["", [], []] };

private _ids = GVAR(selCurrent) select [0, SEL_MAX_UNITS];

// ── Bucket the selection into groups, preserving selection order ───
private _groupOrder   = [];
private _groupMembers = createHashMap;
private _pending      = [];

{
    private _packet = GVAR(selData) getOrDefault [_x, []];
    if (_packet isEqualTo []) then {
        _pending pushBack _x;
    } else {
        // Bucket by group netId, NOT the groupId string: copy-pasted compositions
        // duplicate callsigns, and distinct groups must not merge under one header.
        private _grpKey = _packet select PKT_GRPNET;
        if !(_grpKey in _groupOrder) then {
            _groupOrder   pushBack _grpKey;
            _groupMembers set [_grpKey, []];
        };
        (_groupMembers get _grpKey) pushBack _packet;
    };
} forEach _ids;

// Leader first within each group — the ★ row anchors the listing.
{
    private _members = _groupMembers get _x;
    private _ldrIdx  = _members findIf { _x select PKT_ISLDR };
    if (_ldrIdx > 0) then {
        _groupMembers set [_x, [_members deleteAt _ldrIdx] + _members];
    };
} forEach _groupOrder;

private _totalUnits = count _ids;
private _numGroups  = count _groupOrder;
private _showSep    = _numGroups > 1;

// Selection-wide casualty tallies for the header (HashMap forEach: _y = members).
private _downTotal = 0;
private _fleeTotal = 0;
{
    {
        if (_x select PKT_DOWNED) then { _downTotal = _downTotal + 1 };
        if ("FLEEING" in (_x select PKT_FLAGS)) then { _fleeTotal = _fleeTotal + 1 };
    } forEach _y;
} forEach _groupMembers;

// Joins the non-empty segments of a row / header into one spaced line.
private _fnc_join = { (_this select { _x != "" }) joinString SEP };

// Average clamped 0-100% morale across a group's local members (-1 if none).
private _fnc_avgMorale = {
    params ["_members"];
    private _sum = 0;
    private _n   = 0;
    {
        if (_x select PKT_ISLOCAL) then {
            _sum = _sum + linearConversion [-1, 1, _x select PKT_MORALE, 0, 100, true];
            _n = _n + 1;
        };
    } forEach _members;
    if (_n == 0) exitWith { -1 };
    round (_sum / _n)
};

// First non-empty LAMBS tactic among a group's members ("" if none / no LAMBS).
private _fnc_groupTactic = {
    params ["_members"];
    private _i = _members findIf { (_x select PKT_TACTIC) != "" };
    if (_i < 0) then { "" } else { (_members select _i) select PKT_TACTIC }
};

// Builds the shared "GRP · N units · Morale x% · Tactic: y · z down" descriptor.
// The display name comes from the members' groupId field (packet 2) — the
// bucket key is a group netId and must never be rendered.
private _fnc_groupDesc = {
    params ["_members"];
    private _grpId = (_members select 0) select PKT_GRPID;
    private _n    = count _members;
    private _mor  = [_members] call _fnc_avgMorale;
    private _tac  = [_members] call _fnc_groupTactic;
    private _down = { _x select PKT_DOWNED } count _members;
    [
        toUpper _grpId,
        format ["%1 unit%2", _n, ["s", ""] select (_n == 1)],
        [format ["Morale %1%%", _mor], ""] select (_mor < 0),
        [format ["Tactic: %1", _tac], ""] select (_tac == ""),
        [format ["%1 down", _down], ""] select (_down == 0)
    ] call _fnc_join
};

// ── Overall header label (rendered above the list by ZEN Row_List) ─
private _header = "";
switch (true) do {
    case (_totalUnits == 0): {
        _header = LLSTRING(MsgNoUnitsSelected);
    };
    case (_numGroups == 0): {
        _header = format ["Awaiting data%1%2 unit%3",
            SEP, _totalUnits, ["s", ""] select (_totalUnits == 1)];
    };
    case (_numGroups == 1): {
        // Group descriptor only (name · N units · morale · tactic · down) —
        // raw AI state / combat mode is deliberately not surfaced.
        private _members = _groupMembers get (_groupOrder select 0);
        _header = [_members] call _fnc_groupDesc;
    };
    default {
        _header = [
            format ["%1 groups", _numGroups],
            format ["%1 units selected", _totalUnits],
            [format ["%1 down", _downTotal], ""] select (_downTotal == 0),
            [format ["%1 fleeing", _fleeTotal], ""] select (_fleeTotal == 0)
        ] call _fnc_join;
    };
};

// ── Entry rows ────────────────────────────────────────────────────
private _rows = [];
private _keys = [];

{
    private _grpKey  = _x;
    private _members = _groupMembers get _grpKey;

    // Group separator — only when more than one group is selected; tinted by side.
    if (_showSep) then {
        private _sepCol = SIDE_TINTS select ((_members select 0) select PKT_SIDE);
        _rows pushBack [
            format ["──  %1  ──", [_members] call _fnc_groupDesc],
            _sepCol, "", "", _sepCol, "", _sepCol
        ];
        _keys pushBack ("S:" + _grpKey);
    };

    {
        _x params [
            "_netId", "_isLdr", "", "_role", "", "_name",
            "_behaviour", "_state", "_cmd", "_morale", "_supp", "_flags", "_downed",
            "_task", "_tactic", "_dangerType", "_dangerDist", "_dangerTimeout",
            "_tgtType", "_tgtVis", "_known", "_groupMem", "_isLocal",
            ["_hp", 100], "", "", ""
        ];

        // "»" leader marker — NOT "★": the star glyph is outside the Windows-1252
        // range Arma's fonts cover and renders as a blank gap.
        private _star      = ["", "» "] select _isLdr;
        private _moralePct = round (linearConversion [-1, 1, _morale, 0, 100, true]);
        private _suppPct   = round (_supp * 100);

        private _text    = "";
        private _color   = COL_NORMAL;
        private _icon    = ICON_MOVE;
        private _iconC   = COL_NORMAL;
        private _iconR   = "";
        private _iconRC  = COL_NORMAL;
        private _tip     = format ["%1 — %2", _name, _role];

        if (!_isLocal) then {
            _text  = [format ["%1%2", _star, _role], "no live data"] call _fnc_join;
            _color = COL_DIM;
            _iconC = COL_DIM;
            _icon  = "";
            _tip   = _tip + "\nNot local — no live data (HC-owned or remote-controlled)";
        } else {
            // Single headline status — only urgent/interesting info makes the row;
            // plain AI state and combat mode are tooltip-only by design.
            private _status = switch (true) do {
                case (_downed):             { "DOWNED" };
                case ("FLEEING" in _flags): { "FLEEING" };
                default                     { _task };   // "" without LAMBS
            };

            // One optional inline extra so rows fit the standard dialog width:
            // the danger cause (+range) wins over the current target; the
            // right-side indicator icon and the tooltip carry whichever lost.
            private _dStr      = DANGER_LABELS param [(_dangerType + 2) max 0, ""];
            private _dangerSeg = _dStr;
            if (_dangerSeg != "" && { _dangerDist >= 0 }) then {
                _dangerSeg = format ["%1 %2m", _dangerSeg, _dangerDist];
            };
            private _extraSeg = _dangerSeg;
            if (_extraSeg == "" && { _tgtType != "" }) then {
                _extraSeg = format ["Target: %1", _tgtType];
            };

            _text = [
                format ["%1%2", _star, _role],
                _status,
                format ["Morale %1%%", _moralePct],
                ["", format ["Supp %1%%", _suppPct]] select (_suppPct > 0),
                ["", format ["HP %1%%", _hp]] select (_hp < 100),
                _extraSeg
            ] call _fnc_join;

            // Colour driven by the most urgent condition; shaken/wounded units
            // go amber even without an explicit flag.
            _color = switch (true) do {
                case (_downed):                    { COL_BAD };
                case ("FLEEING" in _flags):        { COL_BAD };
                case ("PATH OFF" in _flags
                    || { "MOVE OFF" in _flags }
                    || { "FORCED" in _flags }):    { COL_WARN };
                case (_moralePct <= 25
                    || { _suppPct >= 60 }
                    || { "WOUNDED" in _flags }):   { COL_WARN };
                default                            { COL_NORMAL };
            };

            // Left icon mirrors what the unit is DOING; leaders get it in gold
            // unless an urgent colour has taken the row over.
            _icon = switch (true) do {
                case (_downed):                 { ICON_HEAL };
                case ("FLEEING" in _flags):     { ICON_RUN };
                case ("MOUNTED" in _flags):     { ICON_GETIN };
                case (_behaviour == "COMBAT"):  { ICON_ATTACK };
                case (_behaviour == "STEALTH"): { ICON_SEARCH };
                default                         { ICON_MOVE };
            };
            _iconC = _color;
            if (_isLdr && { _color isEqualTo COL_NORMAL }) then { _iconC = COL_GOLD };

            // Right icon is the threat indicator: danger cause beats target lock.
            switch (true) do {
                case (_dStr != ""):     { _iconR = ICON_DANGER; _iconRC = COL_WARN };
                case (_tgtType != ""):  { _iconR = ICON_TARGET; _iconRC = COL_BAD };
            };

            // ── Full LAMBS-style detail, packed into the hover tooltip ──
            _tip = _tip + format ["\nState %1", [_state, "—"] select (_state == "")];
            _tip = _tip + format ["\nTask %1", [_task, "—"] select (_task == "")];
            if (_isLdr && { _tactic != "" }) then {
                _tip = _tip + format ["   Tactic %1", _tactic];
            };
            if (_dStr != "") then {
                private _dExtra = "";
                if (_dangerDist    >= 0) then { _dExtra = _dExtra + format ["  %1m", _dangerDist] };
                if (_dangerTimeout >= 0) then { _dExtra = _dExtra + format ["  %1s", _dangerTimeout] };
                _tip = _tip + format ["\nDanger %1%2", _dStr, _dExtra];
            };
            if (_tgtType != "") then {
                _tip = _tip + format ["\nTarget %1  (%2 vis)", _tgtType, (_tgtVis max 0) toFixed 1];
            };
            if (_isLdr) then {
                _tip = _tip + format ["\nKnown enemies %1   Group memory %2",
                    _known max 0, _groupMem max 0];
            };
            _tip = _tip + format ["\nCommand %1", [_cmd, "—"] select (_cmd == "")];
            _tip = _tip + format ["\nMorale %1%%   Suppression %2%%", _moralePct, _suppPct];
            if (_flags isNotEqualTo []) then {
                _tip = _tip + "\nFlags " + (_flags joinString ", ");
            };
        };

        _rows pushBack [_text, _color, _tip, _icon, _iconC, _iconR, _iconRC];
        _keys pushBack ("U:" + _netId);
    } forEach _members;
} forEach _groupOrder;

// ── Units whose server packet has not arrived yet ─────────────────
if (_pending isNotEqualTo []) then {
    if (_showSep || _groupOrder isEqualTo []) then {
        _rows pushBack ["── AWAITING DATA ──", COL_DIM, "", "", COL_DIM, "", COL_DIM];
        _keys pushBack "S:PENDING";
    };
    {
        _rows pushBack [
            "awaiting server data", COL_DIM,
            "Waiting for the server to report this unit's state.",
            ICON_UNKNOWN, COL_DIM, "", COL_DIM
        ];
        _keys pushBack ("P:" + _x);
    } forEach _pending;
};

[_header, _rows, _keys]
