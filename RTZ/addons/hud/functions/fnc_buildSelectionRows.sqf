#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds the display model for the selection info dialog from the current
 * curator selection state. Reads EGVAR(core,selUnits) and GVAR(unitData), maintained
 * by EFUNC(core,selectionPoll).
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
 * Requirements: CBA_A3
 *
 * Arguments:
 * None
 *
 * Return Value:
 * 0: Summary line rendered above the list <STRING>
 * 1: Rows, each [text, color, tooltip, picture, pictureColor, pictureRight, pictureRightColor] <ARRAY>
 * 2: A stable structural key per row <ARRAY of STRING> — FUNC(openSelectionInfo)
 *    compares it tick-to-tick to decide between an in-place refresh and a full rebuild
 *
 * Example:
 * call rtz_hud_fnc_buildSelectionRows
 *
 * Public: No
 */

// Row colours (COL_*), group separator tint (SIDE_TINTS), row icons (ICON_*) and
// the flag tokens (FLAG_*) all come from script_component.hpp — one
// palette/icon/token system shared with the unit head tags and vehicle cards.
// Danger-cause labels come from GVAR(dangerLabels), localized once at preInit.

// Spaced middot separator between the segments of a row / header line.
#define SEP "   ·   "

// ── Named packet fields ──────────────────────────────────────────────────────
// The per-row `params [...]` below reads the whole packet in order; these name the
// handful of fields this function ALSO reaches for out of order (grouping keys,
// tallies, side tint) so those stay readable and survive a layout change. Indices
// are the writer's — FUNC(gatherUnitInfo)'s array order.
#define PKT_ISLDR   1
#define PKT_GRPID   2
#define PKT_SIDE    4
#define PKT_MORALE  9
#define PKT_FLAGS   11
#define PKT_DOWNED  12
#define PKT_TACTIC  14
#define PKT_ISLOCAL 22
#define PKT_GRPNET  24


private _ids = EGVAR(core,selUnits) select [0, SEL_MAX_UNITS];

// ── Bucket the selection into groups, preserving selection order ───
private _groupOrder   = [];
private _groupMembers = createHashMap;
private _pending      = [];

{
    private _packet = GVAR(unitData) getOrDefault [_x, []];
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

// Leader first within each group — the » row anchors the listing.
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
        if (FLAG_FLEEING in (_x select PKT_FLAGS)) then { _fleeTotal = _fleeTotal + 1 };
    } forEach _y;
} forEach _groupMembers;

// Joins the non-empty segments of a row / header into one spaced line.
private _fnc_join = { (_this select { _x != "" }) joinString SEP };

// Localized "N unit" / "N units" — English pluralizes by suffix, others don't, so
// the two forms are separate stringtable entries rather than a spliced "s".
private _fnc_units = {
    params ["_n"];
    format [[LLSTRING(HeaderUnits), LLSTRING(HeaderUnit)] select (_n == 1), _n]
};

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
        [_n] call _fnc_units,
        [format [LLSTRING(LabelMorale), _mor], ""] select (_mor < 0),
        [format [LLSTRING(LabelTactic), _tac], ""] select (_tac == ""),
        [format [LLSTRING(LabelDownCount), _down], ""] select (_down == 0)
    ] call _fnc_join
};

// ── Overall header label (rendered above the list by ZEN Row_List) ─
private _header = "";
switch (true) do {
    case (_totalUnits == 0): {
        _header = LLSTRING(MsgNoUnitsSelected);
    };
    case (_numGroups == 0): {
        _header = [LLSTRING(HeaderAwaitingData), [_totalUnits] call _fnc_units] call _fnc_join;
    };
    // Pending units may still turn out to belong to a second group once their
    // packet arrives — until then, fall through to the multi-group summary
    // below (which counts _totalUnits, pending included) rather than a group
    // descriptor scoped to only the resolved members.
    case (_numGroups == 1 && { _pending isEqualTo [] }): {
        // Group descriptor only (name · N units · morale · tactic · down) —
        // raw AI state / combat mode is deliberately not surfaced.
        _header = [_groupMembers get (_groupOrder select 0)] call _fnc_groupDesc;
    };
    default {
        _header = [
            format [[LLSTRING(HeaderGroups), LLSTRING(HeaderGroup)] select (_numGroups == 1), _numGroups],
            format [LLSTRING(HeaderUnitsSelected), [_totalUnits] call _fnc_units],
            [format [LLSTRING(LabelDownCount), _downTotal], ""] select (_downTotal == 0),
            [format [LLSTRING(LabelFleeingCount), _fleeTotal], ""] select (_fleeTotal == 0)
        ] call _fnc_join;
    };
};

// Selections beyond SEL_MAX_UNITS are silently dropped by the client poll
// (EFUNC(core,selectionPoll)) before they ever reach EGVAR(core,selUnits) — note it here
// so the curator has some indication their selection was cut down, instead of
// extra units just never appearing anywhere.
if (GETEGVAR(core,selOverflow,0) > 0) then {
    _header = _header + " — " + format [LELSTRING(core,MsgSelectionTruncated), EGVAR(core,selOverflow), SEL_MAX_UNITS];
};

// ── Entry rows ────────────────────────────────────────────────────
private _dangerLabels = GVAR(dangerLabels);
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
            _text  = [format ["%1%2", _star, _role], LLSTRING(RowNoLiveData)] call _fnc_join;
            _color = COL_DIM;
            _iconC = COL_DIM;
            _icon  = "";
            _tip   = _tip + "\n" + LLSTRING(TipNotLocal);
        } else {
            // Single headline status — only urgent/interesting info makes the row;
            // plain AI state and combat mode are tooltip-only by design.
            private _status = switch (true) do {
                case (_downed):                { LLSTRING(StatusDowned) };
                case (FLAG_FLEEING in _flags): { LLSTRING(StatusFleeing) };
                default                        { _task };   // "" without LAMBS
            };

            // One optional inline extra so rows fit the standard dialog width:
            // the danger cause (+range) wins over the current target; the
            // right-side indicator icon and the tooltip carry whichever lost.
            private _dStr      = _dangerLabels param [(_dangerType + 2) max 0, ""];
            private _dangerSeg = _dStr;
            if (_dangerSeg != "" && { _dangerDist >= 0 }) then {
                _dangerSeg = _dangerSeg + " " + format [LLSTRING(LabelRange), _dangerDist];
            };
            private _extraSeg = _dangerSeg;
            if (_extraSeg == "" && { _tgtType != "" }) then {
                _extraSeg = format [LLSTRING(LabelTarget), _tgtType];
            };

            _text = [
                format ["%1%2", _star, _role],
                _status,
                format [LLSTRING(LabelMorale), _moralePct],
                ["", format [LLSTRING(LabelSuppression), _suppPct]] select (_suppPct > 0),
                ["", format [LLSTRING(LabelHealth), _hp]] select (_hp < 100),
                _extraSeg
            ] call _fnc_join;

            // Colour driven by the most urgent condition; shaken/wounded units
            // go amber even without an explicit flag.
            _color = switch (true) do {
                case (_downed):                    { COL_BAD };
                case (FLAG_FLEEING in _flags):     { COL_BAD };
                case (FLAG_PATH_OFF in _flags
                    || { FLAG_MOVE_OFF in _flags }
                    || { FLAG_FORCED in _flags }): { COL_WARN };
                case (_moralePct <= 25
                    || { _suppPct >= 60 }
                    || { FLAG_WOUNDED in _flags }): { COL_WARN };
                default                            { COL_NORMAL };
            };

            // Left icon mirrors what the unit is DOING; leaders get it in gold
            // unless an urgent colour has taken the row over.
            _icon = switch (true) do {
                case (_downed):                 { ICON_HEAL };
                case (FLAG_FLEEING in _flags):  { ICON_RUN };
                case (FLAG_MOUNTED in _flags):  { ICON_GETIN };
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
            // "—" is a placeholder glyph for an empty field, not translatable text.
            _tip = _tip + "\n" + format [LLSTRING(TipState), [_state, "—"] select (_state == "")];
            _tip = _tip + "\n" + format [LLSTRING(TipTask),  [_task,  "—"] select (_task  == "")];
            if (_isLdr && { _tactic != "" }) then {
                _tip = _tip + "   " + format [LLSTRING(TipTactic), _tactic];
            };
            if (_dStr != "") then {
                private _dExtra = "";
                if (_dangerDist    >= 0) then { _dExtra = _dExtra + "  " + format [LLSTRING(LabelRange), _dangerDist] };
                if (_dangerTimeout >= 0) then { _dExtra = _dExtra + "  " + format [LLSTRING(LabelTimeout), _dangerTimeout] };
                _tip = _tip + "\n" + format [LLSTRING(TipDanger), _dStr] + _dExtra;
            };
            if (_tgtType != "") then {
                // Visibility is gathered only while this dialog is open, so it is
                // present here; -1 would mean a packet from before the open.
                _tip = _tip + "\n" + (if (_tgtVis >= 0) then {
                    format [LLSTRING(TipTargetVis), _tgtType, _tgtVis toFixed 1]
                } else {
                    format [LLSTRING(TipTarget), _tgtType]
                });
            };
            if (_isLdr) then {
                _tip = _tip + "\n" + format [LLSTRING(TipIntel), _known max 0, _groupMem max 0];
            };
            _tip = _tip + "\n" + format [LLSTRING(TipCommand), [_cmd, "—"] select (_cmd == "")];
            _tip = _tip + "\n" + format [LLSTRING(TipMoraleSupp), _moralePct, _suppPct];
            if (_flags isNotEqualTo []) then {
                // Same localized remap the tags use — the packet carries tokens.
                private _flagLabels = ((_flags apply { GVAR(tagLabels) getOrDefault [_x, _x] }) select { _x != "" });
                if (_flagLabels isNotEqualTo []) then {
                    _tip = _tip + "\n" + format [LLSTRING(TipFlags), _flagLabels joinString ", "];
                };
            };
        };

        _rows pushBack [_text, _color, _tip, _icon, _iconC, _iconR, _iconRC];
        _keys pushBack ("U:" + _netId);
    } forEach _members;
} forEach _groupOrder;

// ── Units whose server packet has not arrived yet ─────────────────
if (_pending isNotEqualTo []) then {
    if (_showSep || _groupOrder isEqualTo []) then {
        _rows pushBack [
            format ["── %1 ──", toUpper LLSTRING(HeaderAwaitingData)],
            COL_DIM, "", "", COL_DIM, "", COL_DIM
        ];
        _keys pushBack "S:PENDING";
    };
    {
        _rows pushBack [
            LLSTRING(RowAwaitingData), COL_DIM,
            LLSTRING(TipAwaitingData),
            ICON_UNKNOWN, COL_DIM, "", COL_DIM
        ];
        _keys pushBack ("P:" + _x);
    } forEach _pending;
};

[_header, _rows, _keys]
