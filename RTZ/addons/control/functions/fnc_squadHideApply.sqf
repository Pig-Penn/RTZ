#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler body for QGVAR(squadHide) (registered in XEH_postInit).
 * Hides/unhides and freezes/unfreezes a batch of groups, plus any CREWLESS
 * vehicles the curator picked out. hideObjectGlobal / enableSimulationGlobal
 * are server-only commands, so the client toggle (FUNC(squadHideToggle))
 * dispatches here via CBA_fnc_serverEvent — one event for the whole selection,
 * hence the arrays rather than a single group.
 *
 * The two lists are disjoint by construction: a CREWED vehicle is reached
 * through its crew's group below, under a guard that refuses any vehicle whose
 * crew is not wholly in the batch, so the toggle never puts one in _vehs.
 *
 * Arguments:
 * 0: Groups to toggle <ARRAY>
 * 1: Crewless vehicles to toggle <ARRAY>
 * 2: True to hide & freeze, false to restore <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [[_group], [_emptyVehicle], true] call rtz_control_fnc_squadHideApply
 *
 * Public: No
 */

params ["_grps", "_vehs", "_hide"];

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
        private _crewVehs = [];
        {
            private _v = objectParent _x;
            if (!isNull _v) then { _crewVehs pushBackUnique _v };
        } forEach _grpUnits;

        {
            private _veh = _x;
            // `_x` inside findIf is the crew member, not the vehicle — the
            // vehicle is held in _veh so the two never get confused.
            if ((crew _veh) findIf { alive _x && {!(_x in _grpUnits)} } == -1) then {
                _veh hideObjectGlobal _hide;
                _veh enableSimulationGlobal _simulate;
            };
        } forEach _crewVehs;
    };
} forEach _grps;

// A crewless vehicle has no group to ride along with, so it is toggled directly
// and carries the state variable itself — that is what a vehicle-only selection
// reads back in FUNC(squadHideActionModifier).
{
    if (!isNull _x) then {
        SETPVAR(_x,GVAR(squadHidden),_hide);

        _x hideObjectGlobal _hide;
        _x enableSimulationGlobal _simulate;
    };
} forEach _vehs;
