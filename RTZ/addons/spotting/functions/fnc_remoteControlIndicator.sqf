#include "script_component.hpp"
/*
 * Author: Maxim
 * When any curator takes direct ("remote") control of a unit, every OTHER
 * curator sees a remote-control icon hovering over that unit in their Zeus
 * view (drawIcon3D) - a tell that the unit is being puppeteered by a rival
 * game master rather than running on AI. The controlling Zeus sees nothing
 * (they are already in first person). Side- and spotting-agnostic: all other
 * curators always see it.
 *
 * Detection signal: the engine has no global getter for "who is remote
 * controlling X" - remoteControlled / isRemoteControlling are locality-bound
 * (must be read where the unit is local, which is the controller's machine),
 * so the server can't trust them. Instead we read the
 * "bis_fnc_moduleRemoteControl_owner" object variable, which the vanilla BI
 * Remote Control module - and ACE3 and Zeus Enhanced alike - set on the
 * controlled unit with the global (publicVariable) flag. That value is the
 * controlling player and is synced to every machine, including the server.
 *
 * Architecture: the server scans on a CBA per-frame handler (unscheduled -
 * immune to script-scheduler starvation, unlike a spawned sleep loop) and
 * pushes viewer-diffed QGVAR(rcDetected)/QGVAR(rcLost) target events keyed by
 * the unit's netId. Clients keep one hashmap, GVAR(rcDisplay): netId ->
 * [unit, color]; the spotting system suppresses its chevron for a unit by
 * testing `netId _unit in GVAR(rcDisplay)`.
 *
 * That scan is EVENT-DRIVEN, with the timer as a safety net. It walks allUnits with a
 * getVariable each, and taking remote control happens a handful of times in a
 * multi-hour operation - so running it every few seconds meant hundreds of reads per
 * tick, for the whole mission, to answer "no" (see docs/Knowledge Base/Performance
 * Audit Questions.md). Zeus remote control goes through selectPlayer, so CBA's
 * "unit" player event handler fires on the controller's own machine at BOTH takeover
 * and release; that client pokes the server, which marks itself dirty and runs the
 * very same scan on the next tick.
 *
 * The poke carries no payload and grants no authority: the server still re-reads
 * RC_OWNER_VAR itself and still drives the same diff. A poke that never arrives - an
 * unforeseen control path, a client that missed the event - costs latency and nothing
 * else, because the fallback timer (GVAR(rcCheckInterval), now a slow safety net rather
 * than the detection mechanism) runs the identical scan. That is deliberate: the
 * previous behaviour is the floor, not something the event replaces.
 *
 * Called by XEH_postInit after CBA_settingsInitialized. Self-guards locality;
 * registers handlers and returns (no scheduled loop).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_spotting_fnc_remoteControlIndicator
 *
 * Public: No
 */

// ─────────────────────────────────────────────────────────────────────────────
// SERVER - resync listener (registered BEFORE the client half below)
// ─────────────────────────────────────────────────────────────────────────────
// Force a re-send of every active indicator to its current viewers on the next
// scan. Set by QGVAR(rcResync), fired by each client once its handlers are
// registered - closing the JIP race where a viewer-diffed send happened before
// the client could listen. Re-sends are idempotent (the client `set` overwrites).
//
// This sits above the client fork deliberately: on a listen server
// CBA_fnc_serverEvent runs locally and immediately, so the host's own
// QGVAR(rcResync) would be dropped - and then explicitly cleared - if the handler
// and its `= false` initializer were still registered further down the file.
if (isServer) then {
    GVAR(rcForceResend) = false;
    // Marks the scan DIRTY as well as forcing the re-send. Those are two different
    // flags and only one of them makes the scan run: the loop below self-gates on
    // GVAR(rcDirty) or the GVAR(rcCheckInterval) fallback, and a resync set
    // neither — so the request sat until the 30 s safety net next came round,
    // unless some other client happened to fire QGVAR(rcChanged) in the meantime.
    // A resync means "look again now", which is what this flag says. Costs one
    // redundant pass when the scan was already due, which the loop is written to
    // tolerate (see the note on consuming the dirty flag before the scan).
    [QGVAR(rcResync), {
        GVAR(rcForceResend) = true;
        GVAR(rcDirty) = true;
    }] call CBA_fnc_addEventHandler;

    // "Somebody's player unit just changed - look again now." Set by QGVAR(rcChanged),
    // fired by any client whose CBA "unit" player event handler fires (below). Starts
    // true so the first tick scans immediately rather than waiting out the fallback
    // interval, which matters on a JIP into a mission where a takeover is already live.
    //
    // A flag rather than a payload: the client reports only THAT something changed. The
    // unit it would name is the one it now controls, which is not necessarily the one
    // that stopped being controlled, and RC_OWNER_VAR is global anyway - so the server
    // re-deriving both from its own read is simpler AND authoritative, where trusting a
    // client's account would be neither.
    GVAR(rcDirty) = true;
    [QGVAR(rcChanged), { GVAR(rcDirty) = true }] call CBA_fnc_addEventHandler;
};

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT - register event handlers
// Runs on every machine with a screen: MP clients, listen-server host,
// and singleplayer (where isServer and hasInterface are both true).
// ─────────────────────────────────────────────────────────────────────────────

if (hasInterface) then {

    // Per-player storage: unitNetId → [unit, colorArray]. Side colour is
    // pre-resolved on the server; position, size, and fade alpha are computed
    // client-side each frame so the icon tracks the unit smoothly between the
    // server's check cycles. Also read by the spotting system (`netId in`)
    // to suppress its chevron while the RC icon is showing.
    //
    // NOT touched here. GVAR(rcDisplay) is created in XEH_preInit because
    // FUNC(drawSpots) reads it under a DIFFERENT setting gate and must never
    // find it nil. A `GVAR(rcDisplay) = createHashMap` sat here with a comment
    // claiming it merely cleared the store — it did not, it replaced it, and it
    // could not have been clearing anything either: this runs at postInit and the
    // only writer (the QGVAR(rcDetected) handler) is registered a dozen lines
    // below, so the map is provably still empty when execution reaches this point.
    //
    // The icon itself is drawn by FUNC(drawRcIndicator), registered with the
    // ONE shared Draw3D handler rtz_core owns. This used to be a Draw3D handler of
    // its own, which meant re-running the Zeus test and a fresh
    // positionCameraToWorld every frame alongside every other display doing the
    // same. The frame loop resolves that context once and also owns the
    // curator-view gates (Zeus open, map not covering the 3D view) this handler
    // used to repeat.
    [QGVAR(rcIndicator), LINKFUNC(drawRcIndicator), RENDER_WORLD, 40] call EFUNC(core,registerRenderer);

    // Store/update the controlled unit and colour (idempotent re-sends are cheap).
    [QGVAR(rcDetected), {
        params ["_id", "_unit", "_colorArray"];
        
        GVAR(rcDisplay) set [_id, [_unit, _colorArray]];
    }] call CBA_fnc_addEventHandler;

    // Remove the icon when the unit is released, or when this player should no
    // longer see it (became the controller, or stopped being a curator).
    [QGVAR(rcLost), {
        GVAR(rcDisplay) deleteAt (_this select 0);
    }] call CBA_fnc_addEventHandler;

    // Taking or releasing remote control goes through selectPlayer, so THIS is the
    // moment the server needs to look again. `remoteControlled` / `isRemoteControlling`
    // are locality-bound and only legal here, where the unit is local — but nothing is
    // read from them: the handler reports the bare fact of a change and lets the server
    // re-derive the picture from the global owner variable it already trusts. That keeps
    // the client out of the authority path entirely, and means the event only has to be
    // RIGHT ABOUT SOMETHING HAVING HAPPENED, not about what.
    //
    // It fires on respawn and team switch too. Those are equally rare and cost one
    // otherwise-idle scan, which is the same trade as being an event short.
    ["unit", { [QGVAR(rcChanged), []] call CBA_fnc_serverEvent }] call CBA_fnc_addPlayerEventHandler;

    // Handlers are registered — ask the server to force-resend every active
    // indicator on its next scan. Covers JIP/rejoin where the viewer-diffed send
    // fired before this machine could listen (the viewer is then recorded in
    // _activeRC and never re-sent). Same pattern as the spotting system's
    // spotResync; harmless no-op when nothing is under remote control.
    [QGVAR(rcResync), []] call CBA_fnc_serverEvent;
};

if (!isServer) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — detection loop (unscheduled CBA per-frame handler)
// ─────────────────────────────────────────────────────────────────────────────

// RC_CHECK_TICK (base tick of the loop, i.e. how often the two cheap gate tests
// below run) and RC_OWNER_VAR (set globally by BI/ACE/ZEN → readable on the
// server) are #defined in script_component.hpp. GVAR(rcCheckInterval) is the
// FALLBACK cadence — a client's QGVAR(rcChanged) poke is what normally triggers
// the scan; see the architecture note in the header.
// GVAR(rcForceResend) / GVAR(rcDirty) and their listeners are set up at the top
// of this file, above the client fork — see the notes there.

[{
    // Active indicators: unitNetId → [viewerPlayers, colorArray]. viewerPlayers
    // is the set of curator players currently shown the icon for this unit;
    // tracking it lets us send QGVAR(rcDetected) only to newly-eligible viewers
    // and QGVAR(rcLost) to viewers who dropped out (released control ends up in
    // the cleanup pass; role changes in the per-unit diff). The colour is
    // resolved once per takeover and cached. State lives in the PFH args
    // hashmap, mutated in place across ticks. Ticks at RC_CHECK_TICK and
    // self-gates on the dirty flag or the live GVAR(rcCheckInterval) fallback,
    // retunable mid-mission.
    (_this select 0) params ["_activeRC", "_nextRun"];
    // Dirty flag FIRST: a client reporting a player-unit change (see the QGVAR(rcChanged)
    // listener above) is what normally drives this, and the timer is the safety net
    // behind it. Consumed here, before the scan, so an event arriving mid-scan is not
    // swallowed — the worst case is one redundant pass.
    private _dirty = GVAR(rcDirty);
    if (!_dirty && {CBA_missionTime < _nextRun}) exitWith {};
    GVAR(rcDirty) = false;
    (_this select 0) set [1, CBA_missionTime + ((GETGVAR(rcCheckInterval,30)) max RC_CHECK_TICK)];

    private _perf = GETMVAR(RTZ_perf,false);
    private _t0   = 0;
    if (_perf) then { _t0 = diag_tickTime };

    // Every unit presently under remote control. allUnits is global (all
    // machines) and contains only the living, so death self-cleans next tick;
    // the owner variable is global too, so this is authoritative on the server.
    // The owner is always set on a man (effectiveCommander), so a crewed-vehicle
    // takeover is covered via that man's vehicle anchor client-side.
    //
    // This select is the whole reason the loop is event-driven: it is a getVariable per
    // LIVING UNIT, and at the scale this mod targets that is several hundred reads for an
    // answer that is almost always the empty array.
    private _rcUnits = allUnits select { !isNull (_x getVariable [RC_OWNER_VAR, objNull]) };

    if (_perf) then {
        ["rcScan", (diag_tickTime - _t0) * 1000,
            format ["units=%1 rc=%2 trigger=%3", count allUnits, count _rcUnits, ["timer", "event"] select _dirty]
        ] call EFUNC(core,perfSample);
    };

    // Consume the pending resync flag BEFORE the early exit — with nothing
    // active there is nothing to resend, and a new takeover reaches every
    // viewer as newly-eligible anyway, so letting it linger would only force
    // a pointless re-send later.
    private _force = GVAR(rcForceResend);
    GVAR(rcForceResend) = false;

    // Common case: nothing controlled now or last tick — skip the curator scan.
    if (_rcUnits isEqualTo [] && {count _activeRC == 0}) exitWith {};

    // Current Zeus players — the only possible viewers (a player object is the
    // required CBA_fnc_targetEvent destination). getAssignedCuratorLogic is the
    // reliable "is this player a curator right now?" test.
    private _curatorPlayers = allPlayers select { !isNull getAssignedCuratorLogic _x };

    // netIds controlled this tick, for the cleanup pass below.
    private _currentIds = [];

    {
        private _unit       = _x;
        private _controller = _unit getVariable [RC_OWNER_VAR, objNull];
        private _id         = netId _unit;
        _currentIds pushBack _id;

        private _prev        = _activeRC getOrDefault [_id, []];
        private _prevViewers = _prev param [0, []];
        private _color       = _prev param [1, []];

        // Side colour of the controlled unit — shared palette with the spotting
        // markers, brighter NCO variant for "leader" display names. Class test
        // and colour both come from the cached shared helpers; resolved once
        // when the takeover is first seen.
        if (_color isEqualTo []) then {
            _color = [side _unit, ([_unit] call EFUNC(common,classInfo)) select 1] call EFUNC(common,sideColor);
        };

        // Show to every curator EXCEPT the one doing the controlling.
        private _viewers = _curatorPlayers select { _x != _controller };

        // Newly-eligible viewers (incl. JIP / mid-takeover joiners) get the icon;
        // on a forced resync every current viewer is re-sent (idempotent set).
        {
            [QGVAR(rcDetected), [_id, _unit, _color], _x] call CBA_fnc_targetEvent;
        } forEach (_viewers - ([_prevViewers, []] select _force));

        // Viewers who dropped out since last tick get it retracted. A viewer who
        // disconnected entirely has no client to notify — isPlayer, not isNull,
        // since a departed player's body can persist as server-local AI (owner 2),
        // which would route the retraction to the server/host instead.
        {
            if (isPlayer _x) then {
                [QGVAR(rcLost), [_id], _x] call CBA_fnc_targetEvent;
            };
        } forEach (_prevViewers - _viewers);

        _activeRC set [_id, [_viewers, _color]];
    } forEach _rcUnits;

    // ── Cleanup: units no longer under remote control ─────────────────────────
    // `keys` returns a copy, so deleting from the map mid-iteration is safe.
    {
        if !(_x in _currentIds) then {
            private _id = _x;
            {
                if (isPlayer _x) then {
                    [QGVAR(rcLost), [_id], _x] call CBA_fnc_targetEvent;
                };
            } forEach ((_activeRC deleteAt _id) param [0, []]);
        };
    } forEach keys _activeRC;
}, RC_CHECK_TICK, [createHashMap, 0]] call CBA_fnc_addPerFrameHandler;
