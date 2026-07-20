#include "script_component.hpp"
/*
 * Author: Maxim
 * Visual half of the attribute gate: greys out the gated rows of a ZEN
 * attribute window while the entity may not be edited — input children
 * disabled and faded, lock reason on the label tooltip. The numeric value box
 * is the exception: it is left at full brightness (ZEN's normal text colour)
 * but made read-only, so each row's value stays legible as unit info
 * (health/fuel/ammo/skill) without being editable.
 *
 * Wired in via gui.hpp: an invisible hook control merged into ZEN's
 * zen_common_RscDisplayScrollbars display schedules this one frame after the
 * window is created, once zen_attributes_fnc_open has built the rows and
 * stored them on the display. Gated rows are recognized by their statement:
 * ZEN keeps each row's statement next to its controls group, and
 * FUNC(wrapAttributes) recorded every statement it wrapped in
 * GVAR(gatedStatements).
 *
 * Enforcement does NOT live here — the wrapped statements in
 * FUNC(wrapAttributes) block an out-of-zone confirm regardless of what this
 * function greyed out (zone state can change while the window is open).
 *
 * Arguments:
 * 0: Attribute window <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call rtz_restrict_fnc_lockControls
 *
 * Public: No
 */

params [["_display", displayNull, [displayNull]]];

// The window may have died within the frame; other windows built on the same
// display class (no attribute rows stored) fall out here too
if (isNull _display) exitWith {};

private _controls = _display getVariable ["zen_attributes_controls", []];
if (_controls isEqualTo []) exitWith {};

private _entity = _display getVariable ["zen_attributes_entity", objNull];
if (_entity call FUNC(canEditSelection)) exitWith {};

{
    _x params ["_ctrlGroup", "", "_statement"];

    if (GVAR(gatedStatements) findIf {_x isEqualTo _statement} != -1) then {
        {
            // controlsGroupCtrl yields controlNull for IDCs the row's control
            // type does not have — commands on it are harmless no-ops
            private _ctrl = _ctrlGroup controlsGroupCtrl _x;
            _ctrl ctrlEnable false;
            _ctrl ctrlSetFade FADE_LOCKED;
            _ctrl ctrlCommit 0;
        } forEach [
            IDC_ZEN_ATTRIBUTE_COMBO,
            IDC_ZEN_ATTRIBUTE_SLIDER,
            IDC_ZEN_ATTRIBUTE_TOOLBOX,
            IDC_ZEN_ATTRIBUTE_MODE
        ];

        // The numeric value box (present on slider rows only): keep it enabled
        // and unfaded so it renders in ZEN's normal text colour rather than a
        // dimmed/disabled tint, then make it read-only by swallowing every
        // keystroke. The slider above is disabled, so the value cannot change
        // from either side. A control-level KeyDown returning true only affects
        // this box — the "never return true" caveat is about display #46.
        private _value = _ctrlGroup controlsGroupCtrl IDC_ZEN_ATTRIBUTE_EDIT;
        if (!isNull _value) then {
            _value ctrlEnable true;
            _value ctrlSetFade 0;
            _value ctrlCommit 0;
            _value ctrlAddEventHandler ["KeyDown", {true}];
        };

        (_ctrlGroup controlsGroupCtrl IDC_ZEN_ATTRIBUTE_LABEL) ctrlSetTooltip LLSTRING(MsgOutsideZone);
    };
} forEach _controls;
