#include "script_component.hpp"
/*
 * Author: Maxim
 * Keeps the server's long-lived spotting maps bounded. Called once at the tail of every
 * detection pass (FUNC(spotCheck)).
 *
 * Every map here is keyed on something that outlives its own usefulness — a netId whose
 * unit has since died, a group that has left contact, a player who has disconnected — so
 * on a multi-hour operation (see CLAUDE.md, Usage) each would otherwise grow for the
 * whole mission. None of them is read often enough for the growth to show up as anything
 * but memory, which is exactly why it needs an explicit bound rather than a symptom to
 * chase.
 *
 * Each block is gated on its map exceeding a cap, so the walk is skipped outright in the
 * ordinary case. The caps are sized to the SIMULTANEOUS working set with room to spare
 * (see the sizing notes in script_component.hpp): a cap set near the true live count
 * means the map sits permanently above it and the walk runs every tick to free nothing —
 * a slow prune that never prunes, which costs more than the growth it was added to stop.
 *
 * Two of the four maps are NESTED (side → HashMap): the cap-gate-then-walk applies to
 * each side's INNER map, and an inner map that empties is dropped so a side that has
 * stopped having a curator does not leave a crumb for the rest of the mission. The outer
 * walk is over the handful of sides that have ever had one, so it needs no gate of its
 * own. See FUNC(spottingSystem) for why those two moved off composite string keys.
 *
 * Collect-then-delete throughout — never deleteAt inside a HashMap forEach.
 *
 * Split out of FUNC(spotCheck) because it runs once per tick rather than per contact, so
 * the extra `call` is free and the detection pass keeps its shape.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_spotting_fnc_pruneStores
 *
 * Public: No
 */

// Shared collect list for the two nested stores' emptied sides, reused rather than
// allocated twice — this runs on every detection tick and the second use `resize 0`s it
// after the first. Both walks are collect-then-delete for the usual reason: deleting
// from a HashMap inside its own forEach is undefined.
private _emptySides = [];

// Fire-blink rate limiter: netId → last blink-send time. The eviction window is generous
// against FIRE_BLINK_THROTTLE (0.1 s), so an entry still throttling a live shooter is
// never dropped early.
if (count GVAR(blinkThrottle) > BLINK_THROTTLE_CAP) then {
    private _cutoff = CBA_missionTime - BLINK_THROTTLE_WINDOW;
    private _old = [];
    { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(blinkThrottle);
    { GVAR(blinkThrottle) deleteAt _x } forEach _old;
};

// Callout gate: side → HashMap(leaderNetId → last time that side had the group
// confirmed). A stamp older than the cooldown means the group is already out of contact
// long enough to re-announce, so dropping the entry is indistinguishable from keeping it.
//
// NESTED, so the cap-gate-then-walk applies to each SIDE's inner map (see the sizing
// notes in script_component.hpp — they were always written against a per-side working
// set, so they carry over unchanged). The outer walk is over the handful of sides that
// have ever had a curator, which is why it is not itself gated.
//
// An emptied inner map is dropped rather than left behind: sides come and go with
// curator assignment over a multi-hour operation, and an empty map is the same
// mission-long crumb the caps exist to stop.
// _side / _inner are captured BEFORE the inner walk: that walk is a HashMap forEach of
// its own and rebinds _x and _y out from under this one.
{
    private _side  = _x;
    private _inner = _y;
    if (count _inner > GROUP_LAST_SEEN_CAP) then {
        private _cutoff = CBA_missionTime - GROUP_CALLOUT_COOLDOWN;
        private _old = [];
        { if (_y < _cutoff) then { _old pushBack _x } } forEach _inner;
        { _inner deleteAt _x } forEach _old;
        if (count _inner == 0) then { _emptySides pushBack _side };
    };
} forEach GVAR(spotGroupLastSeen);
{ GVAR(spotGroupLastSeen) deleteAt _x } forEach _emptySides;
_emptySides resize 0;

// Pending resync requests are retired when their player resolves to a curator
// (FUNC(collectSides)), so an entry only survives while that player is connected but not
// (yet) a Zeus — exactly the case the pending channel exists for. What it must not do is
// outlive the player: someone who requests a resync and then disconnects without ever
// being made curator would otherwise leave a permanent entry. Normally empty, and bounded
// by slot count even when not, so this is a no-op on the hot path — hence a plain
// non-empty test rather than a cap.
if (count GVAR(spotResendPlayers) > 0) then {
    private _stale = [];
    { if (!isPlayer (objectFromNetId _x)) then { _stale pushBack _x } } forEach GVAR(spotResendPlayers);
    { GVAR(spotResendPlayers) deleteAt _x } forEach _stale;
};

// Sticky chevron latches: side → HashMap(memberNetId → [expiryTime, spotter,
// leaderNetId]). An already-expired latch is dead weight — the next pass would fall
// through to the full knowsAbout scan for that member regardless, and FUNC(spotCheck)'s
// contact gate already ignores it.
// Same nested treatment as the callout gate above; see the note there.
{
    private _side  = _x;
    private _inner = _y;
    if (count _inner > CHEVRON_LATCH_CAP) then {
        private _old = [];
        { if ((_y select 0) < CBA_missionTime) then { _old pushBack _x } } forEach _inner;
        { _inner deleteAt _x } forEach _old;
        if (count _inner == 0) then { _emptySides pushBack _side };
    };
} forEach GVAR(chevronLatch);
{ GVAR(chevronLatch) deleteAt _x } forEach _emptySides;
