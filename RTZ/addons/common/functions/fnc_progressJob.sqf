#include "script_component.hpp"
/*
 * Author: Maxim
 * Runs a timed job as a single per-frame handler, handing each tick the SHARE of
 * the work elapsed since the last one. Shared loop scaffolding behind rtz_supply's
 * vehicle servicing and rtz_repair's engineer repair job, which previously each
 * carried their own copy.
 *
 * The share is measured against the clock rather than counted per tick, so a late
 * or skipped tick catches up instead of short-changing the total. That is what
 * makes the interval a WRITE GRANULARITY knob and never a speed knob — halving it
 * doubles the number of writes and changes nothing about how long the job takes.
 *
 * Steps must therefore apply their share as a DELTA against the target's live
 * value, never as an absolute interpolated figure: a vehicle shot up mid-job then
 * keeps the new damage (the job just keeps chipping away at the original deficit)
 * instead of having it silently erased by the next write.
 *
 * Each new job of the SAME KIND on the same owner supersedes the last — the older
 * loop removes itself on its next tick without running its end hook, so repeated
 * orders never leave two loops fighting over one target with different snapshots.
 * The counter only ever counts up and is deliberately never cleared: a superseded
 * loop that has not ticked yet must not find its own number back on the owner.
 *
 * The kind matters because one object can legitimately own two unrelated jobs at
 * once — a damaged supply truck is the owner of its own resupply run AND the
 * target of an engineer's repair — so each caller passes its own job id and the
 * two counters never collide.
 *
 * Arguments:
 * 0: Owner <OBJECT> — the thing the job belongs to; carries the supersede counter
 * 1: Job Id <STRING> — kind of job, so unrelated jobs on one owner don't supersede
 * 2: Duration <NUMBER> — seconds of work, clamped to a minimum of 1
 * 3: Interval <NUMBER> — seconds between ticks (write granularity only)
 * 4: On Step <CODE> — [_args, _step, _progress]; return false to stop the job early
 * 5: Arguments <ARRAY> — passed to onStep/onEnd, mutable across ticks (default [])
 * 6: On End <CODE> — [_args, _ranToFullProgress]; skipped when superseded (default {})
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, "repair", 20, 0.5, {_this call fnc_step}, [_workers], {_this call fnc_done}] call rtz_common_fnc_progressJob
 *
 * Public: No
 */

params ["_owner", "_jobId", "_duration", "_interval", "_onStep", ["_args", []], ["_onEnd", {}]];

if (isNull _owner) exitWith {};

// Built once per order, never per tick
private _varName = QGVAR(jobOrder) + "_" + _jobId;

// Supersede any pending job of this kind on this owner so two loops never fight
// over the same target with different snapshots
private _order = (_owner getVariable [_varName, 0]) + 1;
_owner setVariable [_varName, _order];

[{
    params ["_state", "_handle"];
    _state params ["_owner", "_varName", "_order", "_onStep", "_onEnd", "_args", "_startTime", "_duration", "_lastProgress"];

    // A newer job took over — it owns this target now, so leave without running
    // the end hook over its work
    if (_owner getVariable [_varName, 0] != _order) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    private _progress = ((CBA_missionTime - _startTime) / _duration) min 1;

    // Share of the total job to apply this tick, measured against the clock so a
    // late or skipped tick catches up instead of short-changing the total
    private _step = _progress - _lastProgress;
    _state set [8, _progress];

    private _continue = [_args, _step, _progress] call _onStep;
    private _full = _progress >= 1;

    if (_full || {_continue isEqualTo false}) then {
        [_handle] call CBA_fnc_removePerFrameHandler;

        [_args, _full] call _onEnd;
    };
}, _interval, [
    _owner,
    _varName,
    _order,
    _onStep,
    _onEnd,
    _args,
    CBA_missionTime,
    _duration max 1,
    0                               // share of the job already applied
]] call CBA_fnc_addPerFrameHandler;
