#include "script_component.hpp"
/*
 * rtz_control_fnc_squadHideApply
 *
 * SERVER handler body for QGVAR(squadHideApply) (registered in XEH_postInit).
 * Hides/unhides and freezes/unfreezes one group. hideObjectGlobal /
 * enableSimulationGlobal are server-only commands, so the client toggle
 * (FUNC(squadHideToggle)) dispatches here via CBA_fnc_serverEvent.
 *
 * Parameters:
 *   0: Group   — group to toggle
 *   1: Boolean — true = hide & freeze; false = restore
 */
params ["_grp", "_hide"];
if (isNull _grp) exitWith {};

// Broadcast the group state so every client's modifier reads the right label.
SETPVAR(_grp,GVAR(squadHidden),_hide);
private _grpUnits = units _grp;
{
    _x hideObjectGlobal _hide;
    _x enableSimulationGlobal (!_hide);
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
    if ((crew _x) findIf { alive _x && {!(_x in _grpUnits)} } == -1) then {
        _x hideObjectGlobal _hide;
        _x enableSimulationGlobal (!_hide);
    };
} forEach _vehs;
