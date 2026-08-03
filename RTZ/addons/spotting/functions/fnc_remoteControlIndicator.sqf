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
 * Architecture: the server polls on a CBA per-frame handler (unscheduled -
 * immune to script-scheduler starvation, unlike a spawned sleep loop) and
 * pushes viewer-diffed QGVAR(rcDetected)/QGVAR(rcLost) target events keyed by
 * the unit's netId. Clients keep one hashmap, GVAR(rcDisplay): netId ->
 * [unit, color]; the spotting system suppresses its chevron for a unit by
 * testing `netId _unit in GVAR(rcDisplay)`.
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
    [QGVAR(rcResync), { GVAR(rcForceResend) = true }] call CBA_fnc_addEventHandler;
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
    // EFUNC(hud,drawSpots) reads it under a DIFFERENT setting gate and must never
    // find it nil. A `GVAR(rcDisplay) = createHashMap` sat here with a comment
    // claiming it merely cleared the store — it did not, it replaced it, and it
    // could not have been clearing anything either: this runs at postInit and the
    // only writer (the QGVAR(rcDetected) handler) is registered a dozen lines
    // below, so the map is provably still empty when execution reaches this point.
    //
    // The icon itself is drawn by EFUNC(hud,drawRcIndicator), registered with the
    // ONE shared Draw3D handler rtz_core owns. This used to be a Draw3D handler of
    // its own, which meant re-running the Zeus test and a fresh
    // positionCameraToWorld every frame alongside every other display doing the
    // same. The frame loop resolves that context once and also owns the
    // curator-view gates (Zeus open, map not covering the 3D view) this handler
    // used to repeat.
    [QGVAR(rcIndicator), ELINKFUNC(hud,drawRcIndicator), RENDER_WORLD, 40] call EFUNC(core,registerRenderer);

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

// RC_CHECK_TICK (base tick of the scan loop; the live GVAR(rcCheckInterval)
// setting is the effective cadence) and RC_OWNER_VAR (set globally by
// BI/ACE/ZEN → readable on the server) are #defined in script_component.hpp.
// GVAR(rcForceResend) and its QGVAR(rcResync) listener are set up at the top of
// this file, above the client fork — see the note there.

[{
    // Active indicators: unitNetId → [viewerPlayers, colorArray]. viewerPlayers
    // is the set of curator players currently shown the icon for this unit;
    // tracking it lets us send QGVAR(rcDetected) only to newly-eligible viewers
    // and QGVAR(rcLost) to viewers who dropped out (released control ends up in
    // the cleanup pass; role changes in the per-unit diff). The colour is
    // resolved once per takeover and cached. State lives in the PFH args
    // hashmap, mutated in place across ticks. Ticks at RC_CHECK_TICK and
    // self-gates on the live GVAR(rcCheckInterval) setting (RC changes are
    // infrequent — default 3 s), retunable mid-mission.
    (_this select 0) params ["_activeRC", "_nextRun"];
    if (CBA_missionTime < _nextRun) exitWith {};
    (_this select 0) set [1, CBA_missionTime + ((GETGVAR(rcCheckInterval,3)) max RC_CHECK_TICK)];

    // Every unit presently under remote control. allUnits is global (all
    // machines) and contains only the living, so death self-cleans next tick;
    // the owner variable is global too, so this is authoritative on the server.
    // The owner is always set on a man (effectiveCommander), so a crewed-vehicle
    // takeover is covered via that man's vehicle anchor client-side.
    private _rcUnits = allUnits select { !isNull (_x getVariable [RC_OWNER_VAR, objNull]) };

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
