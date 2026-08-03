#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens the ZEN-styled selection info dialog and keeps it live. After the dialog
 * is created, the listbox and header controls are grabbed back out of it and a
 * per-frame handler refreshes them ~4×/s from the latest selection state
 * (EGVAR(core,selUnits) / GVAR(unitData), maintained by EFUNC(core,selectionPoll)).
 *
 * The server only streams infantry data while a consumer is active, and only
 * gathers the expensive leader intel while a DIALOG is open, so this reports the
 * current selection once, immediately, before creating the dialog — the server
 * gathers straight off that event and the rows fill on the first refresh instead
 * of waiting for the poll and gather ticks to line up.
 *
 * The refresh updates rows in place — preserving scroll position — and only does
 * a full rebuild when the set/grouping of selected units actually changes. The
 * handler removes itself once the dialog's display is gone.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_openSelectionInfo
 *
 * Public: No
 */

// ZEN dialog row-control IDCs (see ZEN: addons\dialog\script_component.hpp).
// ZEN's LIST row reuses the COMBO control, so the list itself really does live
// under IDC_ROW_COMBO — ZEN defines no IDC_ROW_LIST at all.
#define ZEN_IDC_ROW_LABEL 1001
#define ZEN_IDC_ROW_COMBO 1003

// Constant save ID. Without one, ZEN synthesizes it by joinString-ing the whole
// content array — for this dialog, every row's label text. That paid to build a
// large string on every single open, and because the ID differed per selection,
// each confirm (OK) wrote one more permanent key into ZEN's zen_dialog_saved
// namespace, which grows for the rest of the mission. The LIST row forces its
// default anyway, so there is nothing here worth persisting per-selection.
#define DIALOG_SAVE_ID QGVAR(selInfoDialog)

if (EGVAR(core,selUnits) isEqualTo []) exitWith {
    [LLSTRING(MsgNoUnitsSelected)] call zen_common_fnc_showMessage;
};

// Don't stack a second dialog on top of an open one.
if (GVAR(dialogOpen)) exitWith {};

// Report the selection to the server right now, with the leader intel only this
// dialog shows forced on, so the rows fill on the first refresh instead of waiting
// for the poll and stream ticks to line up. The `true` is an override rather than
// a demand read because FUNC(setDemand) is not called until the dialog has
// actually been created below — if creation fails, GVAR(dialogOpen) stays false,
// no demand was ever registered, and the next poll tick re-reports without the
// flag, so there is no stranded subscription to clean up.
//
// This is one call because the engine builds the payload. It used to be built
// here: the slices, the hull gate re-derived from EFUNC(core,selectionPoll) with a
// comment warning it had to match EXACTLY, a write into that poll's private diff
// baseline, and the subscribe event — which was spelled QGVAR(watch) in THIS
// component and so expanded to "rtz_hud_watch", an event with no handler anywhere.
// The baseline write made that fail loudly rather than harmlessly: the poll then
// found its own next report identical to the baseline and suppressed the genuine
// send too, so the intel rows stayed empty until an unrelated selection change
// made the payload differ again.
[true] call EFUNC(core,reportNow);

([] call FUNC(buildSelectionRows)) params ["_header", "_rows", "_keys"];

// ZEN LIST label entry format is [text, tooltip, picture, textColor] — the
// right-side indicator icon is ours alone, applied by _fnc_apply below.
private _labels = _rows apply { _x params ["_t", "_c", "_tip", "_pic"]; [_t, _tip, _pic, _c] };

// ── ZEN grid geometry (mirrors defineCommonGrids.inc) so we can size the list
//    HEIGHT to the screen rather than ZEN's fixed 12-row default. ──────────────
private _gridWAbs = (safeZoneW / safeZoneH) min 1.2;   // GUI_GRID_WAbs
private _gh = (_gridWAbs / 1.2) / 25;                  // GUI_GRID_H  (row height)

// Tallest list that still fits: ZEN caps content height at safeZoneH - 4 grid rows,
// and the LIST row group is (visRows + 1) rows tall (1 row for the header label).
private _maxRows = (floor (safeZoneH / _gh) - 5) max 3;
private _visRows = (((count _rows) max 6) min _maxRows) max 3;

// Pass [] for the LIST values: ZEN auto-numbers the rows [0,1,…] via its own
// forEach. Do NOT build the index list with `apply { _forEachIndex }` — `apply`
// does not set _forEachIndex (only `forEach` does), so the values come back nil
// and zen_dialog_fnc_create aborts with "could not find default value".
private _created = [
    LLSTRING(EnableSelectionInfo),
    [["LIST", _header, [[], _labels, 0, _visRows, false], true]],
    { GVAR(dialogOpen) = false; [ARR_2(QGVAR(dialog),false)] call EFUNC(core,setDemand) },
    { GVAR(dialogOpen) = false; [ARR_2(QGVAR(dialog),false)] call EFUNC(core,setDemand) },
    [],
    DIALOG_SAVE_ID
] call zen_dialog_fnc_create;

if (!_created) exitWith {};
GVAR(dialogOpen) = true;
// The dialog is the ONLY consumer of the expensive per-unit intel (targetsQuery
// / checkVisibility in FUNC(gatherUnitInfo)), so it demands both the slice and
// the detail. The engine used to infer this by reading GVAR(dialogOpen) itself.
[ARR_3(QGVAR(dialog),true,true)] call EFUNC(core,setDemand);

// Grab the freshly-created dialog's controls. ZEN stashes the display in
// uiNamespace and the per-row controls groups under "zen_dialog_params".
private _display = GETUVAR(zen_common_display,displayNull);
private _controls = _display getVariable ["zen_dialog_params", []] param [0, []];
private _group = _controls param [0, []] param [0, controlNull];

if (isNull _display || { isNull _group }) exitWith { GVAR(dialogOpen) = false; [ARR_2(QGVAR(dialog),false)] call EFUNC(core,setDemand) };

private _listCtrl  = _group controlsGroupCtrl ZEN_IDC_ROW_COMBO;
private _labelCtrl = _group controlsGroupCtrl ZEN_IDC_ROW_LABEL;

// The dialog keeps ZEN's standard 26-column width — rows are built short enough
// to fit it (FUNC(buildSelectionRows)), and overflow detail lives in tooltips.

// Applies a built row model to the listbox. Full rebuild only when the structural
// key list changed; otherwise an in-place update that leaves scrolling untouched
// and skips rows identical to the last tick (the common case at 4 Hz — most
// refreshes change one or two rows, not all of them).
private _fnc_apply = {
    params ["_listCtrl", "_labelCtrl", "_header", "_rows", "_keys", "_rebuild", ["_lastRows", []]];

    _labelCtrl ctrlSetText _header;

    if (_rebuild) then {
        lbClear _listCtrl;
        {
            _x params ["_t", "_c", "_tip", "_pic", ["_picC", [1, 1, 1, 1]], ["_picR", ""], ["_picRC", [1, 1, 1, 1]]];
            private _i = _listCtrl lbAdd _t;
            _listCtrl lbSetColor             [_i, _c];
            _listCtrl lbSetTooltip           [_i, _tip];
            _listCtrl lbSetPicture           [_i, _pic];
            _listCtrl lbSetPictureColor      [_i, _picC];
            _listCtrl lbSetPictureRight      [_i, _picR];
            _listCtrl lbSetPictureRightColor [_i, _picRC];
        } forEach _rows;
    } else {
        {
            // Same keys ⇒ same row count/order as _lastRows: index-compare.
            if (_x isEqualTo (_lastRows param [_forEachIndex, []])) then { continue };
            _x params ["_t", "_c", "_tip", "_pic", ["_picC", [1, 1, 1, 1]], ["_picR", ""], ["_picRC", [1, 1, 1, 1]]];
            _listCtrl lbSetText              [_forEachIndex, _t];
            _listCtrl lbSetColor             [_forEachIndex, _c];
            _listCtrl lbSetTooltip           [_forEachIndex, _tip];
            _listCtrl lbSetPicture           [_forEachIndex, _pic];
            _listCtrl lbSetPictureColor      [_forEachIndex, _picC];
            _listCtrl lbSetPictureRight      [_forEachIndex, _picR];
            _listCtrl lbSetPictureRightColor [_forEachIndex, _picRC];
        } forEach _rows;
    };
};

// First pass adds ZEN-side pictures/colours plus our picture tints.
[_listCtrl, _labelCtrl, _header, _rows, _keys, true] call _fnc_apply;

[{
    params ["_args", "_handle"];
    _args params ["_display", "_listCtrl", "_labelCtrl", "_lastKeys", "_lastRows", "_fnc_apply"];

    // Dialog gone (OK / Cancel / ESC / Zeus closed) — stop and release the lock;
    // the selection poll notices open=false and re-reports so the server drops
    // back to the cheap gather.
    if (isNull _display) exitWith {
        GVAR(dialogOpen) = false;
        [QGVAR(dialog), false] call EFUNC(core,setDemand);
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // Zeus closed underneath the dialog — the selection poll has already
    // reported [] (it requires the curator display), so close the now-empty
    // shell too.
    if (isNull (findDisplay IDD_RSCDISPLAYCURATOR)) exitWith {
        GVAR(dialogOpen) = false;
        [QGVAR(dialog), false] call EFUNC(core,setDemand);
        [_handle] call CBA_fnc_removePerFrameHandler;
        _display closeDisplay 2;
    };

    ([] call FUNC(buildSelectionRows)) params ["_header", "_rows", "_keys"];
    private _rebuild = _keys isNotEqualTo _lastKeys;
    [_listCtrl, _labelCtrl, _header, _rows, _keys, _rebuild, _lastRows] call _fnc_apply;
    if (_rebuild) then { _args set [3, _keys] };
    _args set [4, _rows];
}, 0.25, [_display, _listCtrl, _labelCtrl, _keys, _rows, _fnc_apply]] call CBA_fnc_addPerFrameHandler;
