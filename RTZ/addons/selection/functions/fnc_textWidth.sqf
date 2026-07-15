#include "script_component.hpp"
/*
 * rtz_fnc_textWidth
 *
 * Measures a tag string's on-screen width in UI-x coordinates (the same space
 * worldToScreen / getMousePosition return) with a hidden RscText fonted and
 * sized to match the tags' drawIcon3D calls, so icon placement and the
 * coloured status-word split land exactly at the real text edges at any
 * resolution or UI scale. Shared by rtz_fnc_unitTags and rtz_fnc_vehicleTags.
 *
 * The measuring control is created once on the main mission display and
 * reused; if it can't be made yet (no display) the call degrades to a rough
 * per-character estimate.
 *
 * Arguments:
 *   0: Text to measure <STRING>
 *   1: Font height (drawIcon3D text size) <NUMBER>
 *
 * Return Value:
 *   Width in UI-x units <NUMBER>
 *
 * Example:
 *   ["Rifleman · HP 62", 0.03] call rtz_fnc_textWidth
 *
 * Public: No
 */

params ["_text", "_size"];

if (_text == "") exitWith { 0 };

private _ctrl = uiNamespace getVariable QGVAR(measureCtrl);
if (isNil "_ctrl" || { isNull _ctrl } || { isNull (ctrlParent _ctrl) }) then {
    private _disp = findDisplay 46;
    _ctrl = controlNull;
    if (!isNull _disp) then {
        _ctrl = _disp ctrlCreate ["RscText", -1];
        _ctrl ctrlSetFont "RobotoCondensedBold";
        _ctrl ctrlShow false;
        uiNamespace setVariable [QGVAR(measureCtrl), _ctrl];
    };
};
if (isNull _ctrl) exitWith { (count _text) * _size * 0.26 };  // fallback estimate

_ctrl ctrlSetFontHeight _size;
_ctrl ctrlSetText _text;
ctrlTextWidth _ctrl
