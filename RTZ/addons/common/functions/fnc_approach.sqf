#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: send one or more units walking to a spot, then run a completion hook.
 * Shared walk engine behind the mine-laying errand (rtz_mine) and the static-weapon
 * assemble/disassemble errands (rtz_assemble), which previously each carried their
 * own copy.
 *
 * The lead unit (first entry) is watched: on arrival FUNC onArrive runs, on the
 * lead's death, the loss of its ownership or the timeout FUNC onFail runs — so the
 * errand always resolves and nothing pathfinds forever. Each new order on the same
 * lead supersedes the last (a stale order's hooks never fire). Fully unscheduled
 * (CBA_fnc_waitUntilAndExecute, no spawn/sleep). Must run where the lead is local.
 *
 * Ownership is re-checked every tick, not merely assumed from that last sentence.
 * The doMove is issued ONCE, here, and an AI order does not survive its unit moving
 * to another machine — so an errand whose lead is handed to a headless client (or to
 * a client by rtz_control's transfer) silently stops walking. It used to sit there
 * until the full timeout elapsed and then report that the unit had been too slow,
 * which is the wrong cause and the wrong wait. It now fails on the spot and says so.
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
        // Ownership moved mid-walk. Tested HERE, not just at the end: the doMove
        // below was issued on this machine and does not survive a handover, so
        // every tick past it is spent waiting for an arrival that can no longer
        // happen. Without this the errand burned its whole timeout and then blamed
        // the walk. Same test rtz_path's followTick and rtz_slide's slideTick
        // each make for their own long-running orders.
        || {!local _lead}
        || {_lead getVariable [QGVAR(approachOrder), 0] != _order}
        || {_lead distance2D _pos <= _arriveDistance}
    },
    {
        params ["_lead", "_pos", "_arriveDistance", "_order", "_onArrive", "_onFail", "_args", "_curator"];
        // Superseded by a newer order — that order now owns the lead.
        if (_lead getVariable [QGVAR(approachOrder), 0] != _order) exitWith {};

        // Lost to another machine (rtz_control's transfer, a headless client
        // rebalancing, a JIP handover). Checked before the arrival test rather
        // than folded into it, because the two outcomes are not the same thing:
        // every onArrive hook in the mod does work that requires the unit to be
        // local — planting a mine, assembling a weapon, taking gear — so an
        // errand that ends this way must fail rather than run them against a unit
        // this machine no longer owns. Death still wins: a dead lead falls through
        // to the ordinary failure path below, which is silent by design.
        if (alive _lead && {!local _lead}) exitWith {
            [_curator, LLSTRING(ErrandOwnershipLost)] call FUNC(notifyCurator);
            _args call _onFail;
        };

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
