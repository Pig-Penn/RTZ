#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds one unit's cached tag entry for FUNC(drawUnitTags) from its server packet
 * (layout: FUNC(gatherUnitInfo)). Called lazily during the draw pass, once per
 * unit per cache generation — the cache is wiped on every fresh server push or
 * tag* setting change, so this never runs per frame in the steady state.
 *
 * Locality-bound fields (morale, suppression, ammo, task, tactic, command,
 * threat icon) are only rendered when the packet carries live data. tacticText
 * and statusText are kept out of the main line and coloured separately: the
 * tactic in COL_TACTIC, which is what identifies it now that it carries no
 * "TAC " prefix, and the status so DOWN / FLEEING can be red without recolouring
 * the whole tag. flagsText / threatHover are the hover-expand strings for their
 * respective icons ("" when the icon has nothing to show). The measured text
 * widths ride along so the per-frame draw only reads them back — see
 * FUNC(textWidth).
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
 *   0 mainSep (main line + its neighbouring separators)   1 mainRGB
 *   2 tacticSep (bare tactic word, no separator)          3 tacticRGB
 *   4 statusText                            5 statusRGB
 *   6 flagsText  7 threatIcon  8 threatRGB  9 threatHover
 *   10 mainSepWidth  11 tacticSepWidth  12 statusWidth
 *   13 threatCentreUI  14 flagCentreUI
 *   15 layoutHalfWidth  16 hasContent
 *   17 ammoFill (0..1; -1 for no bar)  18 ammoCentreUI
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

// Icon geometry (ICON_FOOT / FLAG_ICON_FOOT / ICON_TEXT_GAP / ICON_GAP) comes from
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
private _tacText = "";
private _ammoFill = -1;   // -1: no bar (see the ammo block below)
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
    // The same rounds as a gauge, which is what makes a screen full of tags
    // answerable at a glance. A capacity of -1 (no primary, or none loaded) has
    // no denominator, so there is no fraction to draw — the bar drops out rather
    // than showing an arbitrary one. Unlike the text field above it does NOT
    // vanish at full: a gauge that disappears reads as broken, not as full.
    // Clamped because a chambered round can put a magazine one over capacity.
    if (GVAR(tagShowAmmoBar) && { _ammoCap > 0 } && { _ammo >= 0 }) then {
        _ammoFill = (_ammo / _ammoCap) min 1;
    };
    if (GVAR(tagShowCommand) && { _cmd != "" }) then { _segs pushBack _cmd };
    // Group-wide fact — leader's tag only, so a squad doesn't repeat the same
    // line on every member. Kept OUT of _segs: it is drawn as its own chunk in
    // COL_TACTIC, and that colour is what marks it as the tactic — it spends no
    // line width on a "TAC " prefix.
    if (_isLdr && { GVAR(tagShowTactic) } && { _tactic != "" }) then {
        // A tactic mapped to "" (LAMBS' "None") drops the chunk entirely.
        _tacText = _labels getOrDefault [_tactic, _tactic];
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
// _status comes back OUT as well as in: the tail drops it when it merely repeats
// the tactic (FUNC(tagEntryTail)), and the entry has to ship the string the
// widths were measured against, not the one passed in.
([_segs, _tacText, _status, _tagSize] call FUNC(tagEntryTail))
    params ["_mainSep", "_tacticSep", "_status", "_wMainSep", "_wTacticSep", "_wStatus"];

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

private _halfFull = (_wMainSep + _wTacticSep + _wStatus) / 2;   // text half-width (UI-x)

// Only the flags the flag ICON will actually carry — an entry whose label maps
// to "" contributes nothing to the hover list, and neither does the flag the
// STATUS chunk is already drawing (FLEEING): it is on the tag either way, so
// listing it again under the icon just prints the same word twice. Filtered on
// the wire TOKEN rather than the resolved label, so a task label that happens to
// read like a flag's cannot swallow a flag that is genuinely extra information.
private _flagsText = (((_flags select { _x != _statusToken })
    apply { _labels getOrDefault [_x, _x] }) select { _x != "" }) joinString " · ";
private _hasFlag   = GVAR(tagShowFlagIcon) && { _flagsText != "" };

// Right-side layout (UI-x, from the unit's centre): threat icon, then flag icon,
// then the ammo bar, each butting flush against the text or its predecessor with
// one small ICON_GAP. Walked as a running cursor holding the LEFT EDGE of the
// next slot — the previous form placed each item with its own offset expression
// off a shared _flush, which only ever worked because there were exactly two of
// them; a third could not be expressed that way, and the vehicle tags need N.
// An absent item consumes nothing, so switching the flag icon off slides the bar
// left against the threat icon.
private _iconW   = _tagSize * ICON_FOOT;          // icon on-screen footprint
private _flagW   = _tagSize * FLAG_ICON_FOOT;     // flag icon's, narrower (its sheet is)
private _barW    = _tagSize * BAR_FOOT;           // ammo bar's, narrower still
private _gap     = _tagSize * ICON_GAP;           // gap between two adjacent items
private _textGap = _tagSize * ICON_TEXT_GAP;      // larger gap: text ↔ its first item
private _left    = _halfFull + _textGap;          // left edge of the first slot
private _cursor  = _left;

// Centres of the items that are absent are never read — every draw is gated on
// the same condition that placed it — so they stay 0 rather than costing a
// meaningless offset.
private _threatCenterUI = 0;
if (_threatIcon != "") then {
    _threatCenterUI = _cursor + (_iconW / 2);
    _cursor = _cursor + _iconW + _gap;
};
private _flagCenterUI = 0;
if (_hasFlag) then {
    _flagCenterUI = _cursor + (_flagW / 2);
    _cursor = _cursor + _flagW + _gap;
};
private _ammoCenterUI = 0;
if (_ammoFill >= 0) then {
    _ammoCenterUI = _cursor + (_barW / 2);
    _cursor = _cursor + _barW + _gap;
};

// De-confliction half-width: the text half plus whichever side carries items, so
// the stacking pass knows each tag's true footprint (icons and bar included).
// The cursor has already stepped past the last item's trailing gap, which is not
// part of the footprint.
private _hwLayout = [_halfFull, _cursor - _gap] select (_cursor > _left);

// Precomputed "anything to draw at all" flag — the per-frame resolve pass reads
// this single boolean instead of unpacking the entry to re-derive it every frame
// for every unit. Must test _hasFlag, NOT _flagsText: with the flag icon setting
// off, a flagged unit with every text field off has nothing to draw and used to
// cost an empty drawIcon3D every frame. _mainSep / _tacticSep are empty exactly
// when their own chunk is (FUNC(tagEntryTail)), so they stand in for them here.
private _hasContent = _mainSep != "" || { _tacticSep != "" } || { _status != "" }
    || { _hasFlag } || { _threatIcon != "" } || { _ammoFill >= 0 };

[
    _mainSep,
    _col select [0, 3],
    _tacticSep,
    (COL_TACTIC) select [0, 3],
    _status,
    _statusCol select [0, 3],
    _flagsText,
    _threatIcon,
    _threatIconCol select [0, 3],
    _threatHover,
    _wMainSep,
    _wTacticSep,
    _wStatus,
    _threatCenterUI,
    _flagCenterUI,
    _hwLayout,
    _hasContent,
    _ammoFill,
    _ammoCenterUI
]
