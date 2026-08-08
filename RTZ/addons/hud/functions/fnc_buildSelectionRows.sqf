#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds the display model for the selection info dialog from the current curator
 * selection state. Reads EGVAR(core,selUnits) and GVAR(unitData), maintained by
 * EFUNC(core,selectionPoll) and the STREAM_UNIT feed.
 *
 * This function owns the STRUCTURE only — bucketing the selection into groups,
 * ordering them, and emitting the row/key lists. What each line SAYS lives with
 * the thing that says it: FUNC(selectionHeader) for the summary,
 * FUNC(groupDescriptor) for a group's line, FUNC(selectionRow) for a unit's, and
 * FUNC(selectionTooltip) for its hover dump. That split is not cosmetic — the
 * five helpers those became were inline closures, rebuilt on every call, and this
 * runs four times a second for as long as the dialog is open.
 *
 * Groups get a side-coloured separator row only when more than one is selected;
 * with a single group the header already describes it. The group leader is always
 * listed first within its group, marked » with a gold icon.
 *
 * Requirements: CBA_A3
 *
 * Arguments:
 * None
 *
 * Return Value:
 * 0: Summary line rendered above the list <STRING>
 * 1: Rows, each [text, color, tooltip, picture, pictureColor, pictureRight, pictureRightColor] <ARRAY>
 * 2: A stable structural key per row <ARRAY of STRING> — FUNC(selectionTick)
 *    compares it tick-to-tick to decide between an in-place refresh and a full rebuild
 *
 * Example:
 * call rtz_hud_fnc_buildSelectionRows
 *
 * Public: No
 */

// Row colours (COL_*), group separator tint (SIDE_TINTS), row icons (ICON_*), the
// flag tokens (FLAG_*) and the PKT_* field names all come from
// script_component.hpp — one palette/icon/token system shared with the head tags.

// Already capped by EFUNC(core,selectionPoll) before it reaches the global, and
// the cap is the engine's to apply — re-slicing it here only allocated a copy of
// the id list on every rebuild.
private _ids = EGVAR(core,selUnits);

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

private _showSep = (count _groupOrder) > 1;
private _header  = [_groupOrder, _groupMembers, count _ids, _pending] call FUNC(selectionHeader);

// ── Entry rows ────────────────────────────────────────────────────
private _dangerLabels = GVAR(dangerLabels);
private _rows = [];
private _keys = [];

{
    // ALIAS THE KEY: the inner loop rebinds _x to a packet
    // (docs/Knowledge Base/Gotchas.md §2).
    private _grpKey  = _x;
    private _members = _groupMembers get _grpKey;

    // Group separator — only when more than one group is selected; tinted by side.
    if (_showSep) then {
        private _sepCol = SIDE_TINTS select ((_members select 0) select PKT_SIDE);
        _rows pushBack [
            format ["──  %1  ──", [_members] call FUNC(groupDescriptor)],
            _sepCol, "", "", _sepCol, "", _sepCol
        ];
        _keys pushBack ("S:" + _grpKey);
    };

    {
        // ALIAS: FUNC(selectionRow) loops internally (joinRow's `select`, the
        // flag remaps), and the netId is read after it
        // (docs/Knowledge Base/Gotchas.md §2).
        private _pkt = _x;
        _rows pushBack ([_pkt, _dangerLabels] call FUNC(selectionRow));
        _keys pushBack ("U:" + (_pkt select 0));
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
