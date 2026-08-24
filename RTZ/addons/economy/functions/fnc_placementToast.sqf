#include "script_component.hpp"
/*
 * Author: Maxim
 * Shows a Zeus feedback message with the cost of the class the curator has
 * just selected for placement. Attached as a TreeSelChanged handler to every
 * create tree whose leaves are single CfgVehicles classes (IDCS_CREATE_TREES);
 * group, module and marker placement has no such class and is never hooked.
 *
 * The feedback control is driven directly rather than through
 * zen_common_fnc_showMessage: that goes to BIS_fnc_showCuratorFeedbackMessage,
 * which plays an error sound on every call. A cost hint fires on every tree
 * selection change, so the sound would play on every arrow key press.
 *
 * Arguments:
 * 0: Create tree <CONTROL>
 * 1: Path of the newly selected entry <ARRAY of NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrlTree, [0, 1, 2]] call rtz_economy_fnc_placementToast
 *
 * Public: No
 */

if (!GVAR(enable) || {!GVAR(placementToast)}) exitWith {};

params ["_ctrlTree", "_path"];

private _class = _ctrlTree tvData _path;

// Category nodes carry no data, and the recent tree also lists groups and markers
if (_class isEqualTo "") exitWith {};
if (!isClass (configFile >> "CfgVehicles" >> _class) || {_class isKindOf "Logic"}) exitWith {};

// The BIS function throttles itself on this variable; honour it in both
// directions so the two cannot fight over the same control, and so holding an
// arrow key down does not rewrite the control every frame
if ((missionNamespace getVariable ["bis_fnc_showcuratorfeedbackmessage_time", -1]) > time) exitWith {};
missionNamespace setVariable ["bis_fnc_showcuratorfeedbackmessage_time", time + 0.1];

private _ctrlMessage = (ctrlParent _ctrlTree) displayCtrl IDC_CURATOR_FEEDBACKMESSAGE;

_ctrlMessage ctrlSetText str (_class call FUNC(getCost));
_ctrlMessage ctrlSetFade 1;
_ctrlMessage ctrlCommit 0;
_ctrlMessage ctrlSetFade 0;
_ctrlMessage ctrlCommit 0.1;

// The BIS fade-out is a spawned script kept in this variable; kill it so a
// message shown just before this one cannot fade ours out early
if (!isNil "BIS_fnc_moduleCurator_feedbackMessage") then {
    terminate BIS_fnc_moduleCurator_feedbackMessage;
};

// Only the newest toast may fade the shared control out
private _token = GVAR(toastToken) + 1;
GVAR(toastToken) = _token;

[{
    params ["_ctrlMessage", "_token"];

    // A newer message owns the control, or the display closed under us
    if (_token != GVAR(toastToken) || {isNull _ctrlMessage}) exitWith {};

    _ctrlMessage ctrlSetFade 1;
    _ctrlMessage ctrlCommit TOAST_FADE;
}, [_ctrlMessage, _token], TOAST_DURATION] call CBA_fnc_waitAndExecute;
