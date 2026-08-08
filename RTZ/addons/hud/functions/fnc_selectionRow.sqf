#include "script_component.hpp"
/*
 * Author: Maxim
 * Turns one unit's packet into one selection-dialog listbox row: the line, its
 * colour, its hover tooltip, and the two indicator icons.
 *
 * The line is "» Role · STATUS · Morale x% · Supp y% · HP z%" plus ONE optional
 * inline extra, because rows have to fit ZEN's standard 26-column width. STATUS
 * is only urgent or interesting information — DOWNED, FLEEING, or the LAMBS task;
 * plain AI state and combat mode are tooltip-only by design
 * (FUNC(selectionTooltip)). The group leader is marked ».
 *
 * The one inline extra is the danger cause (+range) if there is one, else the
 * current target. Whichever loses still surfaces: the right-side indicator icon
 * shows which of the two is driving, and the tooltip carries both. Danger beating
 * target is the same rule the unit head tags use for their threat icon.
 *
 * Arguments:
 * 0: Unit packet, layout FUNC(gatherUnitInfo) <ARRAY>
 * 1: Localized danger-cause table, GVAR(dangerLabels) <ARRAY>
 *
 * Return Value:
 * Row, [text, color, tooltip, picture, pictureColor, pictureRight, pictureRightColor] <ARRAY>
 *
 * Example:
 * [_pkt, GVAR(dangerLabels)] call rtz_hud_fnc_selectionRow
 *
 * Public: No
 */

params ["_pkt", "_dangerLabels"];

_pkt params [
    "", "_isLdr", "", "_role", "", "_name",
    "_behaviour", "", "", "_morale", "_supp", "_flags", "_downed",
    "_task", "", ["_dangerType", -1], ["_dangerDist", -1], "",
    "_tgtType", "", "", "", "_isLocal", ["_hp", 100]
];

// "»" leader marker — NOT "★": the star glyph is outside the Windows-1252 range
// Arma's fonts cover and renders as a blank gap.
private _star = ["", "» "] select _isLdr;
private _head = format ["%1%2", _star, _role];

private _moralePct = round (linearConversion [-1, 1, _morale, 0, 100, true]);
private _suppPct   = round (_supp * 100);

// A unit owned elsewhere (headless client, or remote-controlled by another
// curator) carries no live AI state — say so rather than rendering its defaults
// as if they were readings.
if (!_isLocal) exitWith {
    [
        [_head, LLSTRING(RowNoLiveData)] call FUNC(joinRow),
        COL_DIM,
        format ["%1 — %2", _name, _role] + "\n" + LLSTRING(TipNotLocal),
        "", COL_DIM, "", COL_NORMAL
    ]
};

// Single headline status.
private _status = switch (true) do {
    case (_downed):                { LLSTRING(StatusDowned) };
    case (FLAG_FLEEING in _flags): { LLSTRING(StatusFleeing) };
    default                        { _task };   // "" without LAMBS
};

private _dStr      = _dangerLabels param [(_dangerType + 2) max 0, ""];
private _dangerSeg = _dStr;
if (_dangerSeg != "" && { _dangerDist >= 0 }) then {
    _dangerSeg = _dangerSeg + " " + format [LLSTRING(LabelRange), _dangerDist];
};
private _extraSeg = _dangerSeg;
if (_extraSeg == "" && { _tgtType != "" }) then {
    _extraSeg = format [LLSTRING(LabelTarget), _tgtType];
};

private _text = [
    _head,
    _status,
    format [LLSTRING(LabelMorale), _moralePct],
    ["", format [LLSTRING(LabelSuppression), _suppPct]] select (_suppPct > 0),
    ["", format [LLSTRING(LabelHealth), _hp]] select (_hp < 100),
    _extraSeg
] call FUNC(joinRow);

// Colour driven by the most urgent condition; shaken/wounded units go amber even
// without an explicit flag.
private _color = switch (true) do {
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

// Left icon mirrors what the unit is DOING; leaders get it in gold unless an
// urgent colour has taken the row over.
private _icon = switch (true) do {
    case (_downed):                 { ICON_HEAL };
    case (FLAG_FLEEING in _flags):  { ICON_RUN };
    case (FLAG_MOUNTED in _flags):  { ICON_GETIN };
    case (_behaviour == "COMBAT"):  { ICON_ATTACK };
    case (_behaviour == "STEALTH"): { ICON_SEARCH };
    default                         { ICON_MOVE };
};
private _iconC = _color;
if (_isLdr && { _color isEqualTo COL_NORMAL }) then { _iconC = COL_GOLD };

// Right icon is the threat indicator: danger cause beats target lock, matching
// which of the two took the inline segment above.
private _iconR  = "";
private _iconRC = COL_NORMAL;
switch (true) do {
    case (_dStr != ""):    { _iconR = ICON_DANGER; _iconRC = COL_WARN };
    case (_tgtType != ""): { _iconR = ICON_TARGET; _iconRC = COL_BAD };
};

[
    _text,
    _color,
    [_pkt, _dStr, _moralePct, _suppPct] call FUNC(selectionTooltip),
    _icon, _iconC, _iconR, _iconRC
]
