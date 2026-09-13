#include "script_component.hpp"
/*
 * Author: Maxim
 * One beat of digging: re-plays the dig animation and re-queues itself until the
 * cell's time is up, then reports the cell finished. Runs where the digger is local.
 *
 * A chain of bounded waits rather than a per-frame handler. Nothing here needs to
 * run every frame, and this mod's operations run for hours — a persistent handler
 * per digger would be the wrong shape for a job whose only state is "how much
 * longer". The chain is bounded at both ends: it stops at _endAt, and it stops the
 * moment the digger is re-tasked or killed.
 *
 * "MedicOther" is the animation Zeus Wargame drives its own fortification work with.
 * It runs about DIG_ANIM_PERIOD, so it is re-played on that period rather than once.
 *
 * That same beat carries the DIG. Wargame sinks its hole 0.1 m at a time so the ground
 * is seen to go down while the unit works, and with nothing modelled on top that is the
 * only thing the curator has to watch; this reports a fraction on each animation replay
 * instead, which comes to a comparable ~15 steps over a default cell and needs no timer
 * of its own. What is sent is a FRACTION, never a height — the server owns the
 * heightmap and the pristine value to compute against.
 *
 * Arguments:
 * 0: Engineer <OBJECT>
 * 1: Trench id <NUMBER>
 * 2: Cell index <NUMBER>
 * 3: Mission time the cell was started at <NUMBER>
 * 4: Mission time the cell is finished at <NUMBER>
 * 5: Errand token this dig owns the digger under <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, 3, 0, CBA_missionTime, CBA_missionTime + 40, _token] call rtz_dig_fnc_digStep
 *
 * Public: No
 */

params ["_unit", "_trenchId", "_cellIndex", "_startAt", "_endAt", "_token"];

// Re-tasked mid-dig: the new order owns him now. Abandon without clearing the
// errand — clearing it would release him back into formation on top of whatever
// he was just given.
if (([_unit] call EFUNC(common,errandToken)) != _token) exitWith {};

if (!alive _unit) exitWith {};

// Tested BEFORE any progress is reported, so the fraction sent below is always short
// of 1 and full depth is reached exactly once, down the QGVAR(cellDone) path.
if (CBA_missionTime >= _endAt) exitWith {
    [_unit] call EFUNC(common,clearErrand);

    // Server-side, because the heightmap is: FUNC(buildCell) must not run here.
    [QGVAR(cellDone), [_trenchId, _cellIndex]] call CBA_fnc_serverEvent;
};

// Elapsed against the whole cell, not a step counted up here. A digger re-tasked and
// sent back, or a tick that ran late, then still reports where the hole should be
// rather than accumulating its own idea of it.
private _span = _endAt - _startAt;
private _fraction = if (_span > 0) then {(CBA_missionTime - _startAt) / _span} else {0};

// The first tick runs on arrival, at a fraction of zero. Nothing to say yet.
if (_fraction > 0) then {
    [QGVAR(cellProgress), [_trenchId, _cellIndex, _fraction]] call CBA_fnc_serverEvent;
};

_unit playActionNow "MedicOther";

[FUNC(digStep), _this, DIG_ANIM_PERIOD] call CBA_fnc_waitAndExecute;
