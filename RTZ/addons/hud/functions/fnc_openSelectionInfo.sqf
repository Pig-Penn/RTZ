#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens the ZEN-styled selection info dialog and starts the handler that keeps it
 * live. After the dialog is created, the listbox and header controls are grabbed
 * back out of it and FUNC(selectionTick) refreshes them ~4x/s from the latest
 * selection state (EGVAR(core,selUnits) / GVAR(unitData), maintained by
 * EFUNC(core,selectionPoll)).
 *
 * The server only streams the infantry slice while a consumer demands it, and
 * only gathers the expensive leader intel while something asks for the detail, so
 * this reports the current selection once, immediately, before creating the
 * dialog — the server gathers straight off that event and the rows fill on the
 * first refresh instead of waiting for the poll and gather ticks to line up.
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
// This is one call because the engine builds the payload (EFUNC(core,buildReport)).
// It used to be built here: the slices, the hull gate re-derived from
// EFUNC(core,selectionPoll) with a comment warning it had to match EXACTLY, a
// write into that poll's private diff baseline, and the subscribe event — which
// was spelled QGVAR(watch) in THIS component and so expanded to "rtz_hud_watch",
// an event with no handler anywhere. The baseline write made that fail loudly
// rather than harmlessly: the poll then found its own next report identical to
// the baseline and suppressed the genuine send too, so the intel rows stayed
// empty until an unrelated selection change made the payload differ again.
[true] call EFUNC(core,reportNow);

([] call FUNC(buildSelectionRows)) params ["_header", "_rows", "_keys"];

// ZEN LIST label entry format is [text, tooltip, picture, textColor] — the
// right-side indicator icon is ours alone, applied by FUNC(applySelectionRows).
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
    { call FUNC(releaseSelectionInfo) },
    { call FUNC(releaseSelectionInfo) },
    [],
    DIALOG_SAVE_ID
] call zen_dialog_fnc_create;

if (!_created) exitWith {};
GVAR(dialogOpen) = true;

// The dialog is the ONLY consumer of the expensive per-unit intel (targetsQuery /
// checkVisibility in FUNC(gatherUnitInfo)), so it demands the infantry slice AND
// the detail on top of it. The engine used to infer this by reading
// GVAR(dialogOpen) itself.
[QGVAR(dialog), [SRC_UNITS], true] call EFUNC(core,setDemand);

// Grab the freshly-created dialog's controls. ZEN stashes the display in
// uiNamespace and the per-row controls groups under "zen_dialog_params".
private _display = GETUVAR(zen_common_display,displayNull);
private _controls = _display getVariable ["zen_dialog_params", []] param [0, []];
private _group = _controls param [0, []] param [0, controlNull];

if (isNull _display || { isNull _group }) exitWith { call FUNC(releaseSelectionInfo) };

private _listCtrl  = _group controlsGroupCtrl ZEN_IDC_ROW_COMBO;
private _labelCtrl = _group controlsGroupCtrl ZEN_IDC_ROW_LABEL;

// The dialog keeps ZEN's standard 26-column width — rows are built short enough
// to fit it (FUNC(buildSelectionRows)), and overflow detail lives in tooltips.

// First pass adds ZEN-side pictures/colours plus our picture tints.
[_listCtrl, _labelCtrl, _header, _rows, true] call FUNC(applySelectionRows);

// _lastSel starts [] rather than the current selection so the first tick always
// builds once more — the report fired above may well have landed by then, and
// that is the refresh that fills the intel rows.
[
    LINKFUNC(selectionTick), 0.25,
    [_display, _listCtrl, _labelCtrl, _keys, _rows, []]
] call CBA_fnc_addPerFrameHandler;
