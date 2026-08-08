#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds one unit's cached tag entry for FUNC(drawUnitTags) from its server packet
 * (layout: FUNC(gatherUnitInfo)). Called lazily during the draw pass, once per
 * unit per cache generation — the cache is wiped on every fresh server push or
 * tag* setting change, so this never runs per frame in the steady state.
 *
 * Locality-bound fields (morale, suppression, ammo, task, tactic, command,
 * threat icon) are only rendered when the packet carries live data. statusText is
 * kept out of the main line and coloured separately so DOWN / FLEEING can be red
 * without recolouring the whole tag. flagsText / threatHover are the
 * hover-expand strings for their respective icons ("" when the icon has nothing
 * to show). The measured text widths ride along so the per-frame draw only reads
 * them back — see FUNC(textWidth).
 *
 * All display text resolves here: LAMBS task/tactic strings and the RTZ FLAG_* /
 * STATUS_* wire tokens go through GVAR(tagLabels) (FUNC(loadTagLabels)), and a
 * token whose label is deliberately blank drops its whole segment.
 *
 * Arguments:
 * 0: Unit packet <ARRAY>
 *
 * Return Value:
 * Cache entry <ARRAY>
 *   0 mainSep (main line + its separator)  1 mainRGB  2 statusText  3 statusRGB
 *   4 flagsText  5 threatIcon  6 threatRGB  7 threatHover
 *   8 mainSepWidth  9 statusWidth  10 threatCentreUI  11 flagCentreUI
 *   12 layoutHalfWidth  13 hasContent
 *
 * The bare main line and the separator used to ride along as their own slots.
 * Nothing read them — FUNC(drawUnitTags) is the only consumer and draws the
 * composed mainSep — so they were two fields built and shipped per unit per cache
 * generation for nobody.
 *
 * Example:
 * [_packet] call rtz_hud_fnc_buildTagEntry
 *
 * Public: No
 */

// Icon geometry (ICON_FOOT / ICON_TEXT_GAP / ICON_GAP) comes from
// script_component.hpp — the same tuned set FUNC(drawUnitTags) draws with, so the
// offsets measured here and the icons drawn there cannot drift apart.

params ["_pkt"];

_pkt params [
    "", "_isLdr", "", "_role", "", "",
    "", "", "_cmd", "_morale", "_supp", "_flags", "_downed",
    "_task", "_tactic", ["_dangerType", -1], ["_dangerDist", -1], ["_dangerTimeout", -1],
    "_tgtType", ["_tgtVis", -1], "", "", "_isLocal", ["_hp", 100],
    "", ["_ammo", -1], ["_ammoCap", -1]
];

// Display-label remap (FUNC(loadTagLabels)) — LAMBS strings and RTZ tokens to
// localized text, resolved at build time (cached).
private _labels = GVAR(tagLabels);

private _segs = [];
if (GVAR(tagShowRole)) then { _segs pushBack _role };
if (GVAR(tagShowHealth) && { _hp < 100 }) then {
    _segs pushBack format [LLSTRING(TagFieldHealth), _hp];
};
private _suppPct = round (_supp * 100);
if (_isLocal) then {
    if (GVAR(tagShowMorale)) then {
        _segs pushBack format [LLSTRING(TagFieldMorale),
            round (linearConversion [-1, 1, _morale, 0, 100, true])];
    };
    if (GVAR(tagShowSuppression) && { _suppPct > 0 }) then {
        _segs pushBack format [LLSTRING(TagFieldSuppression), _suppPct];
    };
    if (GVAR(tagShowAmmo) && { _ammo >= 0 } && { _ammo != _ammoCap }) then {
        // "<current>/<capacity>"; capacity can be unknown (-1: no mag loaded, or
        // a pre-capacity server build) — degrade to the bare count, which needs
        // no localizing. A full magazine (_ammo == _ammoCap) is dropped
        // entirely — only partial/depleted mags are worth flagging.
        _segs pushBack ([str _ammo, format [LLSTRING(TagFieldAmmo), _ammo, _ammoCap]] select (_ammoCap > 0));
    };
    if (GVAR(tagShowCommand) && { _cmd != "" }) then { _segs pushBack _cmd };
    // Group-wide fact — leader's tag only, so a squad doesn't repeat the same
    // line on every member.
    if (_isLdr && { GVAR(tagShowTactic) } && { _tactic != "" }) then {
        // Remap FIRST: a tactic mapped to "" (LAMBS' "None") must drop the whole
        // segment, not render a bare "TAC ".
        private _tacLabel = _labels getOrDefault [_tactic, _tactic];
        if (_tacLabel != "") then {
            _segs pushBack format [LLSTRING(TagFieldTactic), _tacLabel];
        };
    };
};

// Status: urgent states always surface; the LAMBS task only when enabled.
// Kept out of _segs — it's rendered as its own coloured drawIcon3D so DOWN /
// FLEEING can be red without recolouring the rest of the line.
private _statusToken = switch (true) do {
    case (_downed):                  { STATUS_DOWN };
    case (FLAG_FLEEING in _flags):   { FLAG_FLEEING };
    case (GVAR(tagShowStatus)):      { _task };   // "" without LAMBS
    default                          { "" };
};
private _status = _labels getOrDefault [_statusToken, _statusToken];

private _urgent = _downed || { FLAG_FLEEING in _flags };
private _col = COL_NORMAL;
private _statusCol = [_col, COL_BAD] select _urgent;

// Composed line and its exact on-screen widths, measured once per cache build so
// the per-frame draw only reads them back. Shared with the vehicle tags —
// everything from here to the end of the line is the same job in both builders
// (FUNC(tagEntryTail)).
private _tagSize = GVAR(tagSize);
([_segs, _status, _tagSize] call FUNC(tagEntryTail)) params ["_mainSep", "_wMainSep", "_wStatus"];

// Threat icon (between the text and the flag icon) — LAMBS danger cause beats a
// live attack target, same rule the dialog uses for its right-side indicator.
private _threatIcon = "";
private _threatIconCol = [];
private _threatHover = "";
if (GVAR(tagShowThreatIcon) && _isLocal) then {
    private _dStr = GVAR(dangerLabels) param [(_dangerType + 2) max 0, ""];
    if (_dStr != "") then {
        _threatIcon = ICON_DANGER;
        _threatIconCol = COL_WARN;
        _threatHover = _dStr
            + ([" ", format [" " + LLSTRING(LabelRange), _dangerDist]] select (_dangerDist >= 0))
            + ([" ", format [" " + LLSTRING(LabelTimeout), _dangerTimeout]] select (_dangerTimeout >= 0));
    } else {
        if (_tgtType != "") then {
            _threatIcon = ICON_TARGET;
            _threatIconCol = COL_BAD;
            // Visibility is dialog-only intel (-1 when not gathered) — drop the
            // parenthetical rather than showing a bogus 0.0.
            _threatHover = if (_tgtVis >= 0) then {
                format [LLSTRING(TipTargetVis), _tgtType, _tgtVis toFixed 1]
            } else {
                format [LLSTRING(TipTarget), _tgtType]
            };
        };
    };
};

private _halfFull = (_wMainSep + _wStatus) / 2;   // text half-width (UI-x)

// Icon layout (UI-x, from the unit's centre). Each icon butts flush against the
// text or the previous icon with one small ICON_GAP. Right side only: threat
// then flag.
private _iconW   = _tagSize * ICON_FOOT;          // icon on-screen footprint
private _gap     = _tagSize * ICON_GAP;           // gap between two adjacent icons
private _textGap = _tagSize * ICON_TEXT_GAP;      // larger gap: text ↔ its first icon
private _step    = _iconW + _gap;                 // centre-to-centre, adjacent icons
private _flush   = _halfFull + _textGap + (_iconW / 2); // first icon offset from a text edge

private _threatCenterUI = _flush;                 // right of the text
// Flag follows the threat icon when both show, otherwise sits flush itself.
private _flagCenterUI = _flush + ([0, _step] select (_threatIcon != ""));

// Only the flags the flag ICON will actually carry — an entry whose label maps
// to "" contributes nothing to the hover list.
private _flagsText = ((_flags apply { _labels getOrDefault [_x, _x] }) select { _x != "" }) joinString " · ";
private _hasFlag   = GVAR(tagShowFlagIcon) && { _flagsText != "" };

// De-confliction half-width: the text half plus whichever side carries icons, so
// the stacking pass knows each tag's true footprint (icons included).
private _nRight   = parseNumber (_threatIcon != "") + parseNumber _hasFlag;
private _hwLayout = [_halfFull, _flush + (_iconW / 2) + ([0, _step] select (_nRight > 1))] select (_nRight > 0);

// Precomputed "anything to draw at all" flag — the per-frame resolve pass reads
// this single boolean instead of unpacking the entry to re-derive it every frame
// for every unit. Must test _hasFlag, NOT _flagsText: with the flag icon setting
// off, a flagged unit with every text field off has nothing to draw and used to
// cost an empty drawIcon3D every frame. _mainSep is empty exactly when the main
// line is (FUNC(tagEntryTail)), so it stands in for it here.
private _hasContent = _mainSep != "" || { _status != "" } || { _hasFlag }
    || { _threatIcon != "" };

[
    _mainSep,
    _col select [0, 3],
    _status,
    _statusCol select [0, 3],
    _flagsText,
    _threatIcon,
    _threatIconCol select [0, 3],
    _threatHover,
    _wMainSep,
    _wStatus,
    _threatCenterUI,
    _flagCenterUI,
    _hwLayout,
    _hasContent
]
