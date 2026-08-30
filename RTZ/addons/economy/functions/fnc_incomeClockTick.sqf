#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. One tick of the income clock: writes the next payout's size and how
 * long until it lands into the Zeus clock bar's mission-countdown slot — the
 * field that reads "--:--:--" for the whole operation on a mission with no time
 * limit.
 *
 * HOW THE SLOT IS TAKEN. The clock bar is vanilla, not ZEN: the "Loop" case of
 * \a3\ui_f_curator\ui\scripts\RscDisplayCurator.sqf rewrites all three fields
 * every frame, rate-limited by a "clocktime" variable it keeps on the assigned
 * curator logic. Writing that variable further ahead than this tick's own period
 * suppresses vanilla's writes entirely, which is why the two never alternate in
 * the slot — and why this has to write the other two fields itself while it holds
 * the lease. Nothing is patched and nothing is hidden, so simply ceasing to
 * renew the lease hands the whole bar back within CLOCK_LEASE seconds; that is
 * the entire teardown, and it is what every release condition below relies on.
 *
 * The lease is renewed on EVERY tick rather than only when the readout changes:
 * it is a deadline, not a flag, and a tick that skipped it would let vanilla back
 * in two seconds later.
 *
 * State lives in the PFH's own args array, mutated in place — a CBA PFH passes the
 * same object every iteration, which is free persistent state (same as
 * EFUNC(hud,selectionTick)). It carries the last string written and the last
 * full-bar state so an unchanged readout costs no engine call at all; only the
 * once-a-second `format` remains, which is nowhere near the per-entity-per-tick
 * string building CLAUDE.md rules out.
 *
 * Arguments:
 * 0: PFH args, [display, durationCtrl, daytimeCtrl, countdownCtrl, defaultColour, lastText, lastFull] <ARRAY>
 * 1: PFH handle <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_args, _handle] call rtz_economy_fnc_incomeClockTick
 *
 * Public: No
 */

params ["_args", "_handle"];
_args params ["_display", "_ctrlDuration", "_ctrlDaytime", "_ctrlCountdown", "_defaultColour", "_lastText", "_lastFull"];

// Zeus closed — the display and its controls are gone, and the next open starts a
// fresh tick from FUNC(startIncomeClock)
if (isNull _display) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
};

// No curator assigned to this machine: there is no logic to hold the lease on,
// and no points to count down to
private _logic = getAssignedCuratorLogic player;
if (isNull _logic) exitWith {};

// Everything that means the slot is not ours. All of these can change mid-session
// — settings toggles, and a mission countdown started by a module — so they are
// tested here rather than gating the handler's registration. BIS_fnc_missionTimeLeft
// returns a negative number when the mission has no time limit at all, which is
// the case this whole display exists for; anything else is a real timer and wins.
if (
    !GVAR(incomeClock)
    || {!GVAR(enable)}
    || {GVAR(income) <= 0}
    || {GVAR(nextIncome) < 0}
    || {([] call BIS_fnc_missionTimeLeft) >= 0}
) exitWith {
    // Once, on the tick that releases: drop the tint and stop renewing the lease.
    // Vanilla reclaims all three fields on its own within CLOCK_LEASE.
    if (_lastText isNotEqualTo "") then {
        _ctrlCountdown ctrlSetTextColor _defaultColour;
        _args set [5, ""];
        _args set [6, -1];
    };
};

_logic setVariable ["clocktime", time + CLOCK_LEASE];

private _remaining = (GVAR(nextIncome) - CBA_missionTime) max 0;
// The same floor the server schedules on (INCOME_INTERVAL, script_component.hpp),
// so the payout size printed here and the one paid out are the same figure and the
// "one field or two" decision below matches the spacing actually being used.
private _interval = INCOME_INTERVAL;

// Both settings are GLOBAL, so this is the same figure the server will pay out
// (see the income tick in XEH_postInit). Whole numbers print bare — a payout of
// "3.0" points reads like a precision the economy does not have.
private _amount = GVAR(income) * _interval / 60;
private _amountText = if (_amount == floor _amount) then {str (floor _amount)} else {_amount toFixed 1};

// Fields are zero-padded, so the readout keeps a fixed width and does not shift
// its left edge as it counts down — the control is right-aligned.
//
// The minutes field is dropped entirely on an interval of a minute or less, where
// it could only ever read "00". Chosen off the SETTING rather than off the
// remaining seconds: at exactly 60 the latter would show "1:00" for one second
// and then fall back to "59", changing format mid-countdown. Reading the setting
// means an interval only ever counts in one shape.
//
// Minutes are NOT taken modulo 60. A longer wait than the interval is possible for
// one cycle after the interval is lowered mid-mission — the payout already
// scheduled keeps the old spacing — and letting that read "12:30" is honest where
// wrapping would be wrong.
private _clock = if (_interval > 60) then {
    private _mins = floor (_remaining / 60);
    private _secs = floor (_remaining - _mins * 60);
    format [
        "%1%2:%3%4",
        ["", "0"] select (_mins < 10), _mins,
        ["", "0"] select (_secs < 10), _secs
    ]
} else {
    private _secs = floor _remaining;
    format ["%1%2", ["", "0"] select (_secs < 10), _secs]
};
private _text = format [LLSTRING(IncomeClockFormat), _amountText, _clock];

if (_text isNotEqualTo _lastText) then {
    _ctrlCountdown ctrlSetText _text;
    _args set [5, _text];
};

// A full bar caps the payout in FUNC(addPoints), so the countdown is running
// toward points that will be thrown away — the tint goes on to say so. Below a
// full bar the readout keeps the control's own colour and sits with the rest of
// the clock. Written only on the transition: there is no getter for a control's
// text colour, so the args array is the record of what it currently holds.
private _full = (curatorPoints _logic) >= 1;
if (_full isNotEqualTo _lastFull) then {
    _ctrlCountdown ctrlSetTextColor ([_defaultColour, COLOR_INCOME] select _full);
    _args set [6, _full];
};

// The other two fields, exactly as the suppressed vanilla loop writes them
_ctrlDuration ctrlSetText ("+" + ([time / 3600] call BIS_fnc_timeToString));
_ctrlDaytime ctrlSetText ([dayTime, "HH:MM"] call BIS_fnc_timeToString);
