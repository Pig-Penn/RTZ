#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler body for QGVAR(squadHide) (registered in XEH_postInit).
 * Hides/unhides and freezes/unfreezes a batch of groups. hideObjectGlobal /
 * enableSimulationGlobal are server-only commands, so the client toggle
 * (FUNC(squadHideToggle)) dispatches here via CBA_fnc_serverEvent — one event
 * for the whole selection, hence the array rather than a single group.
 *
 * Arguments:
 * 0: Groups to toggle <ARRAY>
 * 1: True to hide & freeze, false to restore <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [[_group], true] call rtz_control_fnc_squadHideApply
 *
 * Public: No
 */

params ["_grps", "_hide"];

private _simulate = !_hide;

{
    if (!isNull _x) then {
        private _grp = _x;

        // Broadcast the state so every client's modifier reads the right label.
        SETPVAR(_grp,GVAR(squadHidden),_hide);

        private _grpUnits = units _grp;
        {
            _x hideObjectGlobal _hide;
            _x enableSimulationGlobal _simulate;
        } forEach _grpUnits;

        // A mounted squad must take its ride with it, else the vehicle stays
        // visible with a frozen invisible crew — a driverless ghost. Toggle any
        // vehicle whose live crew belongs entirely to this group. Nobody can
        // board or leave while frozen, so the unhide pass recomputes the same
        // vehicle set and restores it symmetrically.
        private _vehs = [];
        {
            private _v = objectParent _x;
            if (!isNull _v) then { _vehs pushBackUnique _v };
        } forEach _grpUnits;

        {
            private _veh = _x;
            // `_x` inside findIf is the crew member, not the vehicle — the
            // vehicle is held in _veh so the two never get confused.
            if ((crew _veh) findIf { alive _x && {!(_x in _grpUnits)} } == -1) then {
                _veh hideObjectGlobal _hide;
                _veh enableSimulationGlobal _simulate;
            };
        } forEach _vehs;
    };
} forEach _grps;
