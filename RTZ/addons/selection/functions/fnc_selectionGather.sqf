#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER ONLY. The infantry half of the selection data stream: tracks which
 * units each curator has reported (FUNC(selectionInfo)'s poll), gathers their AI
 * state where they are local, and pushes compact packets back to that curator's
 * client over QGVAR(selData).
 *
 * Subscription is on demand — clients report [] as soon as nothing is looking at
 * the data — so while no curator has the info dialog open and no unit tags are
 * visible this costs one `count == 0` check per tick.
 *
 * Loading: called unconditionally from XEH_postInit under isServer, NOT from the
 *   CBA_settingsInitialized gate. The enable* settings are all isGlobal 0
 *   (per-client display preferences); gating this on one would make a dedicated
 *   server decide whether to feed its clients based on its own copy of a client
 *   preference. Registers a CBA event handler and one PFH, no scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_selection_fnc_selectionGather
 *
 * Public: No
 */

if (!isServer) exitWith {};

// playerNetId → [selected unit netIds, dialogOpen]. Populated only for curators
// with an active consumer (clients report [] otherwise, which removes the
// entry), so the gather loop below touches exactly the players who are looking.
// The dialogOpen flag decides whether the expensive leader intel is gathered —
// see FUNC(gatherUnitInfo).
GVAR(selByPlayer) = createHashMap;

// playerNetId → the packet array last actually SENT to that client. The gather
// still runs every tick (unit state must be read to know it hasn't changed), but
// an identical result is not re-serialized onto the network — idle selections
// cost zero traffic. Entries are dropped whenever the client re-reports (forcing
// a fresh send: the client clears its own data on close) or unsubscribes.
GVAR(selLastSent) = createHashMap;

[QGVAR(selSelection), {
    params ["_player", "_sel", ["_detailed", false]];
    if (isNull _player) exitWith {};
    private _pk = netId _player;
    if (_sel isEqualTo []) exitWith {
        GVAR(selByPlayer) deleteAt _pk;
        GVAR(selLastSent) deleteAt _pk;
    };
    GVAR(selByPlayer) set [_pk, [_sel, _detailed]];
    // A fresh report always gets a full send — the client may have cleared its
    // data since (dialog close wipes it), so the diff baseline must not linger.
    GVAR(selLastSent) deleteAt _pk;
    // Gather + push immediately so a freshly opened dialog fills right away
    // instead of waiting for the next PFH tick.
    [_player, _sel, _detailed] call FUNC(pushSelData);
}] call CBA_fnc_addEventHandler;

// ── Gather loop ──────────────────────────────────────────────────────────────
// A CBA PFH rather than a spawned while/sleep thread: unscheduled, so the gather
// cadence never degrades under scheduler load. Ticks at GATHER_TICK and
// self-gates on the live GVAR(gatherInterval) setting (same pattern as
// rtz_spotting's spotCheckInterval), so admins can retune the cadence
// mid-mission without a restart. Entries whose player disconnected or dropped
// curator are pruned in passing (deleted AFTER the forEach — never mutate a
// HashMap mid-iteration).
[{
    params ["_state"];
    _state params ["_nextRun"];
    if (CBA_missionTime < _nextRun) exitWith {};
    _state set [0, CBA_missionTime + ((GETGVAR(gatherInterval,0.3)) max GATHER_TICK)];
    if (count GVAR(selByPlayer) == 0) exitWith {};
    private _stale = [];
    {
        // HashMap forEach: _x is the KEY (player netId), _y the VALUE.
        private _player = objectFromNetId _x;
        if (isNull _player || { isNull (getAssignedCuratorLogic _player) }) then {
            _stale pushBack _x;
            continue;
        };
        _y params ["_sel", "_detailed"];
        [_player, _sel, _detailed] call FUNC(pushSelData);
    } forEach GVAR(selByPlayer);
    {
        GVAR(selByPlayer) deleteAt _x;
        GVAR(selLastSent) deleteAt _x;
    } forEach _stale;
}, GATHER_TICK, [0]] call CBA_fnc_addPerFrameHandler;
