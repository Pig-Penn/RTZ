#include "script_component.hpp"
/*
 * Author: Maxim
 * Installs the servicing restriction on one freshly opened ZEN attribute
 * window: every row FUNC(initGate) recognized as a servicing row gets a confirm
 * hook, and rows whose scope is already out of zone are greyed out.
 *
 * Wired in via gui.hpp — an invisible hook control merged into ZEN's
 * zen_common_RscDisplayScrollbars display schedules this one frame after the
 * window is created, once zen_attributes_fnc_open has built the rows and stored
 * them on the display (a control's onLoad fires during createDialog, before any
 * row exists). zen_attributes_fnc_open is compiled final by CBA and so cannot
 * be wrapped by reassignment.
 *
 * Enforcement is the hook, not the greying. ZEN's confirm calls each row's
 * onConfirm handler before it reads that row's pending value and skips any row
 * whose value came back nil, so FUNC(onConfirm) can refuse a row at confirm
 * time — which is what catches a zone lost while the window sat open. The
 * greying is only the advance warning, and a row greyed here stays greyed even
 * if the zone comes back; its input is disabled, so it has no pending value to
 * apply either way.
 *
 * Arguments:
 * 0: Attribute window <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call rtz_restrict_fnc_gateDisplay
 *
 * Public: No
 */

params [["_display", displayNull, [displayNull]]];

// The window may have died within the frame; other windows built on the same
// display class store no attribute rows and fall out here too
if (isNull _display) exitWith {};

private _controls = _display getVariable [ZEN_VAR_CONTROLS, []];
if (_controls isEqualTo []) exitWith {};

private _gatedRows = GVAR(gatedRows);
if (count _gatedRows == 0) exitWith {};

{
    _x params ["_ctrlGroup", "", "_statement"];

    private _scope = _gatedRows get (str _statement);
    if (isNil "_scope") then {continue};

    // A second install on the same row would chain our hook to itself and
    // recurse on confirm. Fresh windows build fresh controls so this cannot
    // happen today, but the failure mode is bad enough to guard.
    private _chained = _ctrlGroup getVariable QGVAR(chained);
    if (!isNil "_chained") then {continue};

    _ctrlGroup setVariable [QGVAR(scope), _scope];
    // Chained rather than replaced: ZEN's code-editor row installs a handler of
    // its own, and it is what turns control state into the pending value
    _ctrlGroup setVariable [QGVAR(chained), _ctrlGroup getVariable [ZEN_VAR_ON_CONFIRM, {}]];
    _ctrlGroup setVariable [ZEN_VAR_ON_CONFIRM, FUNC(onConfirm)];

    if ([_scope] call FUNC(canEdit)) then {continue};

    {
        // controlsGroupCtrl yields controlNull for IDCs this row's control type
        // does not have — skipped rather than commanded, as commands on a null
        // control log an error per call
        private _ctrl = _ctrlGroup controlsGroupCtrl _x;
        if (isNull _ctrl) then {continue};

        _ctrl ctrlEnable false;
        _ctrl ctrlSetFade FADE_LOCKED;
        _ctrl ctrlCommit 0;
    } forEach [
        IDC_ZEN_ATTRIBUTE_COMBO,
        IDC_ZEN_ATTRIBUTE_SLIDER,
        IDC_ZEN_ATTRIBUTE_TOOLBOX,
        IDC_ZEN_ATTRIBUTE_MODE
    ];

    // The numeric value box (slider rows only) is made read-only instead of
    // disabled: the row doubles as unit info, and a disabled edit renders in
    // the dimmed disabled colour rather than ZEN's normal text colour. The
    // slider above it is disabled, so the value cannot change from either side.
    // A control-level KeyDown returning true only swallows keys for this box —
    // the "never return true" caveat is about display #46 — but Escape and Tab
    // are still let through so the window closes and focus cycles normally.
    private _ctrlValue = _ctrlGroup controlsGroupCtrl IDC_ZEN_ATTRIBUTE_EDIT;

    if (!isNull _ctrlValue) then {
        _ctrlValue ctrlEnable true;
        _ctrlValue ctrlSetFade 0;
        _ctrlValue ctrlCommit 0;
        _ctrlValue ctrlAddEventHandler ["KeyDown", {
            params ["", "_key"];
            !(_key in [DIK_ESCAPE, DIK_TAB])
        }];
    };

    private _ctrlLabel = _ctrlGroup controlsGroupCtrl IDC_ZEN_ATTRIBUTE_LABEL;

    if (!isNull _ctrlLabel) then {
        _ctrlLabel ctrlSetTooltip LLSTRING(MsgOutsideZone);
    };
} forEach _controls;
