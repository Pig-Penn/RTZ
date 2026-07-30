#include "script_component.hpp"
/*
 * Author: Maxim
 * Creates one pooled vehicle stat-card control bundle on the given display, for
 * FUNC(vehicleOverlay). Every control is created disabled so the cards never
 * swallow a Zeus click.
 *
 * Cards are pooled and recycled, so this only runs when the selection grows past
 * the current pool size (or the Zeus display was recreated and the pool flushed).
 * The caller positions and fills the bundle — see FUNC(vehicleCardLayout).
 *
 * Arguments:
 * 0: Display to create on <DISPLAY>
 *
 * Return Value:
 * Card bundle <ARRAY>
 *   0 group  1 bg  2 accent  3 titleBg  4 title  5 body
 *   6 fuelBg  7 fuelFill  8 fuelLabel  9 hullBg  10 hullFill  11 hullLabel
 *
 * Example:
 * [_display] call rtz_selection_fnc_vehicleCardCreate
 *
 * Public: No
 */

params ["_disp"];

private _grp = _disp ctrlCreate ["RscControlsGroupNoScrollbars", -1];
_grp ctrlEnable false;

private _fnc_child = {
    params ["_class"];
    private _c = _disp ctrlCreate [_class, -1, _grp];
    _c ctrlEnable false;
    _c
};

private _bg = ["RscText"] call _fnc_child;
_bg ctrlSetBackgroundColor CARD_BG;

private _accent = ["RscText"] call _fnc_child;

private _titleBg = ["RscText"] call _fnc_child;
_titleBg ctrlSetBackgroundColor GVAR(vehThemeColor);

private _title = ["RscText"] call _fnc_child;
_title ctrlSetFont "PuristaMedium";
_title ctrlSetFontHeight 0.0235;
_title ctrlSetTextColor [1, 1, 1, 1];

private _body = ["RscStructuredText"] call _fnc_child;

// Two identical readout bars (fuel, hull): background, proportional fill, label.
private _bars = [];
for "_i" from 0 to 1 do {
    private _barBg = ["RscText"] call _fnc_child;
    _barBg ctrlSetBackgroundColor BAR_BG;
    private _fill = ["RscText"] call _fnc_child;
    private _lbl  = ["RscText"] call _fnc_child;
    _lbl ctrlSetFont "RobotoCondensedBold";
    _lbl ctrlSetFontHeight 0.0130;
    _lbl ctrlSetTextColor [0.95, 0.97, 1.00, 0.95];
    _bars append [_barBg, _fill, _lbl];
};

[_grp, _bg, _accent, _titleBg, _title, _body] + _bars
