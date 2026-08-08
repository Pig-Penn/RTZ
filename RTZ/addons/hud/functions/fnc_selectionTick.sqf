#include "script_component.hpp"
/*
 * Author: Maxim
 * Per-frame handler body behind the open selection info dialog: tears the dialog
 * down when it or Zeus goes away, and otherwise refreshes its rows — but only
 * when something has actually changed.
 *
 * The gate is the point. FUNC(buildSelectionRows) is the expensive half and was
 * being run every tick regardless; the rebuild-vs-in-place diff downstream only
 * ever saved the engine-side lbSet* calls. Building the model runs a bucketing
 * pass, a leader reorder and a group descriptor, then roughly eight `format`s,
 * three switch(true) chains and a joinString PER UNIT (up to SEL_MAX_UNITS), plus
 * more per group. At 4 Hz that was several hundred `format` calls a second
 * producing byte-identical strings — exactly the per-tick string building
 * CLAUDE.md rules out on a multi-hour operation.
 *
 * TWO things can change the model, and one does not imply the other:
 *   - a new snapshot landed (GVAR(selRowsDirty), set by FUNC(receiveUnitData));
 *   - the curator changed selection. EGVAR(core,selUnits) updates locally the
 *     moment that happens, a poll interval before the matching snapshot lands, so
 *     gating on the flag alone would leave a deselected unit on screen until the
 *     server caught up.
 * Comparing the id list is at most SEL_MAX_UNITS string compares, against the
 * several hundred formats it guards.
 *
 * State lives in the PFH's own args array, mutated in place — a CBA PFH passes the
 * same object every iteration, which is free persistent state.
 *
 * Arguments:
 * 0: PFH args, [display, listCtrl, labelCtrl, lastKeys, lastRows, lastSel] <ARRAY>
 * 1: PFH handle <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_args, _handle] call rtz_hud_fnc_selectionTick
 *
 * Public: No
 */

params ["_args", "_handle"];
_args params ["_display", "_listCtrl", "_labelCtrl", "_lastKeys", "_lastRows", "_lastSel"];

// Dialog gone (OK / Cancel / ESC / Zeus closed) — stop and release the lock; the
// selection poll notices the demand withdrawn and re-reports, so the server drops
// back to the cheap gather.
if (isNull _display) exitWith {
    call FUNC(releaseSelectionInfo);
    [_handle] call CBA_fnc_removePerFrameHandler;
};

// Zeus closed underneath the dialog — the selection poll has already reported []
// (it requires the curator display), so close the now-empty shell too.
if (isNull (findDisplay IDD_RSCDISPLAYCURATOR)) exitWith {
    call FUNC(releaseSelectionInfo);
    [_handle] call CBA_fnc_removePerFrameHandler;
    _display closeDisplay 2;
};

private _sel = EGVAR(core,selUnits);
if (!GVAR(selRowsDirty) && {_sel isEqualTo _lastSel}) exitWith {};

GVAR(selRowsDirty) = false;
// Copied: the poll replaces this global wholesale rather than mutating it, but a
// baseline that can follow a store this function does not own is a compare that
// can never fail.
_args set [5, +_sel];

([] call FUNC(buildSelectionRows)) params ["_header", "_rows", "_keys"];

private _rebuild = _keys isNotEqualTo _lastKeys;
[_listCtrl, _labelCtrl, _header, _rows, _rebuild, _lastRows] call FUNC(applySelectionRows);

if (_rebuild) then { _args set [3, _keys] };
_args set [4, _rows];
