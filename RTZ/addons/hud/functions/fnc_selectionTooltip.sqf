#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds one unit row's hover tooltip: the full LAMBS-style field dump that the
 * row itself deliberately leaves out.
 *
 * The row carries only urgent or interesting information, because it has to fit
 * ZEN's standard dialog width. Everything else — plain AI state, current command,
 * the exact morale/suppression figures, the danger cause the row could not fit,
 * the flag list — lives here, where there is room for it.
 *
 * The danger string arrives resolved rather than being looked up again: the row
 * has already decided whether the danger cause or the target won the one inline
 * slot, and both halves must agree on that.
 *
 * Arguments:
 * 0: Unit packet, layout FUNC(gatherUnitInfo) <ARRAY>
 * 1: Resolved danger-cause label, "" for none <STRING>
 * 2: Morale as a clamped 0-100 percentage <NUMBER>
 * 3: Suppression as a 0-100 percentage <NUMBER>
 *
 * Return Value:
 * Tooltip text <STRING>
 *
 * Example:
 * [_pkt, _dStr, _moralePct, _suppPct] call rtz_hud_fnc_selectionTooltip
 *
 * Public: No
 */

params ["_pkt", "_dStr", "_moralePct", "_suppPct"];

_pkt params [
    "", "_isLdr", "", "_role", "", "_name",
    "", "_state", "_cmd", "", "", "_flags", "",
    "_task", "_tactic", "", "_dangerDist", "_dangerTimeout",
    "_tgtType", ["_tgtVis", -1], "_known", "_groupMem", "_isLocal"
];

private _tip = format ["%1 — %2", _name, _role];

// Nothing below this line is meaningful for a unit owned elsewhere — the packet
// carries its defaults, and printing them would be inventing AI state.
if (!_isLocal) exitWith { _tip + "\n" + LLSTRING(TipNotLocal) };

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
    // Visibility is gathered only while this dialog is open, so it is present
    // here; -1 would mean a packet from before the open.
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
    // Same localized remap the tags use — the packet carries tokens, never text.
    private _flagLabels = ((_flags apply { GVAR(tagLabels) getOrDefault [_x, _x] }) select { _x != "" });
    if (_flagLabels isNotEqualTo []) then {
        _tip = _tip + "\n" + format [LLSTRING(TipFlags), _flagLabels joinString ", "];
    };
};

_tip
