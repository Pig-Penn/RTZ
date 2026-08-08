#include "script_component.hpp"
/*
 * Author: Maxim
 * Writes a built row model into the selection dialog's listbox.
 *
 * Two paths. A full rebuild (lbClear + lbAdd) is only correct — and only needed —
 * when the STRUCTURAL key list changed, i.e. the set or grouping of selected units
 * is different; it also resets the scroll position, which is why it is avoided.
 * Otherwise the rows are updated in place, which leaves scrolling untouched, and
 * rows identical to last tick are skipped outright: at 4 Hz most refreshes change
 * one or two rows out of up to SEL_MAX_UNITS, not all of them.
 *
 * The in-place path can index-compare against _lastRows precisely BECAUSE the keys
 * were unchanged — same keys means same row count and same order.
 *
 * Arguments:
 * 0: The listbox control <CONTROL>
 * 1: The header label control <CONTROL>
 * 2: Header line <STRING>
 * 3: Rows, from FUNC(buildSelectionRows) <ARRAY>
 * 4: Full rebuild rather than in-place update <BOOL>
 * 5: Rows written last tick, for the skip compare <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [_listCtrl, _labelCtrl, _header, _rows, true] call rtz_hud_fnc_applySelectionRows
 *
 * Public: No
 */

params ["_listCtrl", "_labelCtrl", "_header", "_rows", "_rebuild", ["_lastRows", []]];

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
