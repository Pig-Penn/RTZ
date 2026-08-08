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

// Fire-blink rate limiter: netId → last blink-send time. The eviction window is generous
// against FIRE_BLINK_THROTTLE (0.1 s), so an entry still throttling a live shooter is
// never dropped early.
if (count GVAR(blinkThrottle) > BLINK_THROTTLE_CAP) then {
    private _cutoff = CBA_missionTime - BLINK_THROTTLE_WINDOW;
    private _old = [];
    { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(blinkThrottle);
    { GVAR(blinkThrottle) deleteAt _x } forEach _old;
};

// Callout gate: (sideStr + "_" + leaderNetId) → last time that side had the group
// confirmed. A stamp older than the cooldown means the group is already out of contact
// long enough to re-announce, so dropping the entry is indistinguishable from keeping it.
if (count GVAR(spotGroupLastSeen) > GROUP_LAST_SEEN_CAP) then {
    private _cutoff = CBA_missionTime - GROUP_CALLOUT_COOLDOWN;
    private _old = [];
    { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(spotGroupLastSeen);
    { GVAR(spotGroupLastSeen) deleteAt _x } forEach _old;
};

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

// Sticky chevron latches: (spotterSideStr + "_" + memberNetId) → [expiryTime, spotter].
// An already-expired latch is dead weight — the next pass would fall through to the full
// knowsAbout scan for that member regardless.
if (count GVAR(chevronLatch) > CHEVRON_LATCH_CAP) then {
    private _old = [];
    { if ((_y select 0) < CBA_missionTime) then { _old pushBack _x } } forEach GVAR(chevronLatch);
    { GVAR(chevronLatch) deleteAt _x } forEach _old;
};
