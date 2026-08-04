#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: send one or more units walking to a spot, then run a completion hook.
 * Shared walk engine behind the mine-laying errand (rtz_mine) and the static-weapon
 * assemble/disassemble errands (rtz_assemble), which previously each carried their
 * own copy.
 *
 * The lead unit (first entry) is watched: on arrival FUNC onArrive runs, on the
 * lead's death or the timeout FUNC onFail runs — so the errand always resolves and
 * nothing pathfinds forever. Each new order on the same lead supersedes the last
 * (a stale order's hooks never fire). Fully unscheduled (CBA_fnc_waitUntilAndExecute,
 * no spawn/sleep). Must run where the lead is local.
 *
 * Arguments:
 * 0: Units <ARRAY of OBJECT, or OBJECT> — first entry is the watched lead
 * 1: Position <ARRAY>
 * 2: Arrival Distance <NUMBER>
 * 3: Timeout <NUMBER> — seconds before the errand expires
 * 4: On Arrive <CODE> — run with _args when the lead reaches the spot alive
 * 5: On Fail <CODE> — run with _args on the lead's death or the timeout (default {})
 * 6: Arguments <ARRAY> — passed to onArrive/onFail as _this (default [])
 * 7: Force Move <BOOL> — LAMBS force-move + stance UP on all units during the walk (default false)
 * 8: Curator <OBJECT> — toast target on timeout (default objNull)
 * 9: Timeout Message <STRING> — toast text on timeout (default "")
 *
 * Return Value:
 * None
 *
 * Example:
 * [[_unit], _pos, 2, 20, {_this call fnc_plant}, {}, [_unit]] call rtz_common_fnc_approach
 *
 * Public: No
 */

params ["_units", "_pos", "_arriveDistance", "_timeout", "_onArrive", ["_onFail", {}], ["_args", []], ["_forceMove", false], ["_curator", objNull], ["_timeoutMsg", ""]];

if (_units isEqualType objNull) then { _units = [_units] };

private _lead = _units param [0, objNull];
if (isNull _lead) exitWith {};

// Supersede any pending order on the lead so only the newest one can resolve.
private _order = (_lead getVariable [QGVAR(approachOrder), 0]) + 1;
_lead setVariable [QGVAR(approachOrder), _order];

// lambs_danger_forceMove (inert without LAMBS) keeps the danger FSM from seizing
// the units mid-errand; setUnitPosWeak requests the pose without hard-locking it.
{
    if (!isNull _x && {alive _x}) then {
        if (_forceMove) then {
            _x setVariable ["lambs_danger_forceMove", true];
            _x setUnitPosWeak "UP";
        };
        _x doMove _pos;
    };
} forEach _units;

[
    {
        params ["_lead", "_pos", "_arriveDistance", "_order"];
        !alive _lead
        || {_lead getVariable [QGVAR(approachOrder), 0] != _order}
        || {_lead distance2D _pos <= _arriveDistance}
    },
    {
        params ["_lead", "_pos", "_arriveDistance", "_order", "_onArrive", "_onFail", "_args"];
        // Superseded by a newer order — that order now owns the lead.
        if (_lead getVariable [QGVAR(approachOrder), 0] != _order) exitWith {};

        if (alive _lead && {_lead distance2D _pos <= _arriveDistance}) then {
            _args call _onArrive;
        } else {
            _args call _onFail;
        };
    },
    [_lead, _pos, _arriveDistance, _order, _onArrive, _onFail, _args, _curator, _timeoutMsg],
    _timeout,
    {
        params ["_lead", "_pos", "_arriveDistance", "_order", "_onArrive", "_onFail", "_args", "_curator", "_timeoutMsg"];
        // Superseded by a newer order — stay silent, that order owns the lead.
        if (_lead getVariable [QGVAR(approachOrder), 0] != _order) exitWith {};

        [_curator, _timeoutMsg] call FUNC(notifyCurator);
        _args call _onFail;
    }
] call CBA_fnc_waitUntilAndExecute;
