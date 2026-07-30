#include "script_component.hpp"
/*
 * Author: Maxim
 * Fills and sizes one pooled vehicle stat card from a packet, for
 * FUNC(vehicleOverlay). Children are positioned relative to the card's controls
 * group; the caller positions the group itself and needs the height back to stack
 * the next card.
 *
 * Minimized (GVAR(vehCardsMini)), the card is just the accent strip + title bar:
 * the body and both readout bars are hidden and their layout — including the
 * ctrlTextHeight round-trip — is skipped entirely.
 *
 * Arguments:
 * 0: Card bundle <ARRAY> (from FUNC(vehicleCardCreate))
 * 1: Vehicle packet <ARRAY> (layout: FUNC(gatherVehicleInfo))
 *
 * Return Value:
 * Card height in UI units <NUMBER>
 *
 * Example:
 * [_bundle, _packet] call rtz_selection_fnc_vehicleCardLayout
 *
 * Public: No
 */

params ["_bundle", "_pkt"];

_bundle params ["_grp", "_bg", "_accent", "_titleBg", "_title", "_body",
    "_fuelBg", "_fuelFill", "_fuelLbl", "_hullBg", "_hullFill", "_hullLbl"];
_pkt params ["", "_sideNum", "_dName", "", "_fuelPct", "_healthPct"];

private _innerX = ACCENT_W + PAD_X;
private _innerW = CARD_W - _innerX - PAD_X;
private _mini   = GVAR(vehCardsMini);

// Pooled controls: visibility must be re-asserted both ways, or a card recycled
// after un-minimizing keeps its children hidden.
{ _x ctrlShow !_mini } forEach
    [_body, _fuelBg, _fuelFill, _fuelLbl, _hullBg, _hullFill, _hullLbl];

_title ctrlSetText toUpper _dName;
_title ctrlSetPosition [_innerX, 0, _innerW, TITLE_H];

private _cardH = TITLE_H;
if (!_mini) then {
    // Lays out one labelled readout bar (bg, proportional fill, text inset).
    private _fnc_layoutBar = {
        params ["_barBg", "_fill", "_lbl", "_y", "_label", "_pct", "_col"];
        _barBg ctrlSetPosition [_innerX, _y, _innerW, BAR_H];
        _fill  ctrlSetPosition [_innerX, _y, _innerW * (((_pct max 0) min 100) / 100), BAR_H];
        _fill  ctrlSetBackgroundColor _col;
        _lbl   ctrlSetText format [LLSTRING(CardBarValue), _label, _pct];
        _lbl   ctrlSetPosition [_innerX + 0.0045, _y, _innerW - 0.009, BAR_H];
        { _x ctrlCommit 0 } forEach [_barBg, _fill, _lbl];
    };

    // Width must be committed before ctrlTextHeight reports the wrapped height of
    // the fresh markup.
    _body ctrlSetPosition [_innerX, TITLE_H + 0.0045, _innerW, 0.5];
    _body ctrlCommit 0;
    _body ctrlSetStructuredText parseText ([_pkt] call FUNC(vehicleCardBody));
    private _bodyH = ctrlTextHeight _body;
    _body ctrlSetPosition [_innerX, TITLE_H + 0.0045, _innerW, _bodyH];
    _body ctrlCommit 0;

    private _yBar = TITLE_H + 0.0045 + _bodyH + 0.0055;

    private _fuelCol = switch (true) do {
        case (_fuelPct < 15): { [1.00, 0.38, 0.38, 0.90] };
        case (_fuelPct < 40): { [1.00, 0.78, 0.30, 0.90] };
        default               { [0.72, 0.78, 0.84, 0.90] };
    };
    [_fuelBg, _fuelFill, _fuelLbl, _yBar, LLSTRING(CardFuel), _fuelPct, _fuelCol] call _fnc_layoutBar;

    private _hullCol = switch (true) do {
        case (_healthPct < 40): { [1.00, 0.38, 0.38, 0.90] };
        case (_healthPct < 70): { [1.00, 0.78, 0.30, 0.90] };
        default                 { [0.55, 0.80, 0.42, 0.90] };
    };
    [_hullBg, _hullFill, _hullLbl, _yBar + BAR_H + BAR_GAP, LLSTRING(CardHull), _healthPct, _hullCol] call _fnc_layoutBar;

    _cardH = _yBar + BAR_H + BAR_GAP + BAR_H + 0.0075;
};

_bg      ctrlSetPosition [0, 0, CARD_W, _cardH];
_titleBg ctrlSetPosition [ACCENT_W, 0, CARD_W - ACCENT_W, TITLE_H];

private _sideCol = SIDE_TINTS select _sideNum;
_accent ctrlSetBackgroundColor [_sideCol#0, _sideCol#1, _sideCol#2, 0.95];
_accent ctrlSetPosition [0, 0, ACCENT_W, _cardH];

{ _x ctrlCommit 0 } forEach [_bg, _accent, _titleBg, _title];

_cardH
