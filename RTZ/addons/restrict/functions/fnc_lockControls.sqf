#include "script_component.hpp"
/*
 * Author: Maxim
 * Visual half of the attribute gate: called right after ZEN builds an
 * attribute window (zen_attributes_fnc_open is wrapped in XEH_postInit) with
 * the same arguments. When the entity may not be edited, every gated row —
 * looked up in GVAR(gatedLabels), matched by the label ZEN wrote into the row
 * group — is greyed out: input children disabled and faded, lock reason on the
 * label tooltip. The values themselves stay readable, which is the point:
 * the sliders double as unit info.
 *
 * Enforcement does NOT live here — the wrapped statements in
 * FUNC(wrapAttributes) block an out-of-zone confirm regardless of what this
 * function greyed out (zone state can change while the window is open).
 *
 * Arguments:
 * 0: Entity the display was opened for <OBJECT|GROUP>
 * 1: Display type <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, "Object"] call rtz_restrict_fnc_lockControls
 *
 * Public: No
 */

params ["_entity", ["_type", "", [""]]];

private _labels = GVAR(gatedLabels) getOrDefault [_type, []];
if (_labels isEqualTo []) exitWith {};

if (_entity call FUNC(canEditSelection)) exitWith {};

// ZEN parks its scrollbars display here (zen_common fnc_open line 34)
private _display = uiNamespace getVariable ["zen_common_display", displayNull];
if (isNull _display) exitWith {};

// Only touch the window this open call actually produced — fnc_open can exit
// early (no active rows), leaving a stale display behind this variable
if (_display getVariable ["zen_attributes_entity", objNull] isNotEqualTo _entity) exitWith {};

{
    _x params ["_ctrlGroup"];

    private _ctrlLabel = _ctrlGroup controlsGroupCtrl IDC_ZEN_ATTRIBUTE_LABEL;

    if (_labels isEqualTo true || {ctrlText _ctrlLabel in _labels}) then {
        {
            // controlsGroupCtrl yields controlNull for IDCs the row's control
            // type does not have — commands on it are harmless no-ops
            private _ctrl = _ctrlGroup controlsGroupCtrl _x;
            _ctrl ctrlEnable false;
            _ctrl ctrlSetFade FADE_LOCKED;
            _ctrl ctrlCommit 0;
        } forEach [
            IDC_ZEN_ATTRIBUTE_COMBO,
            IDC_ZEN_ATTRIBUTE_EDIT,
            IDC_ZEN_ATTRIBUTE_SLIDER,
            IDC_ZEN_ATTRIBUTE_TOOLBOX,
            IDC_ZEN_ATTRIBUTE_MODE
        ];

        _ctrlLabel ctrlSetTooltip LLSTRING(MsgOutsideZone);
    };
} forEach (_display getVariable ["zen_attributes_controls", []]);
