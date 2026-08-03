#include "script_component.hpp"
/*
 * Author: Maxim
 * Entry point for the spotting system: tracks when one curator's AI units
 * visually detect any hostile units in the mission. Each spotting Zeus sees 3D
 * world icons (drawIcon3D) above detected enemies in the Zeus cursor view; on
 * first contact the spotting group radios a side-channel contact report.
 *
 * Registers the client half (FUNC(spottingClient)) on machines with a screen,
 * then sets up the server side: shared state, the fire-blink class event
 * handler, the resync listener, and a low-rate CBA perFrameHandler that runs
 * one detection pass (FUNC(spotCheck)) every GVAR(spotCheckInterval) seconds
 * (read live each tick so admins can retune a running mission).
 *
 * The pieces live in:
 *   FUNC(spotCheck)       — one full server detection pass
 *   FUNC(spottingClient)  — per-player icon stores, event receivers, resync
 *   EFUNC(hud,drawSpots)  — per-frame Zeus-view icon renderer. This component
 *                           decides WHAT is spotted; rtz_hud owns how it looks,
 *                           and rtz_core's frame loop is what calls it
 *   FUNC(unitMarker)      — NATO symbol classification for a group leader
 *   FUNC(echelonTex)      — echelon/size amplifier texture
 *   FUNC(emitSpot)        — signature-gated spotDetected/spotLost send
 *   FUNC(spotCallout)     — radio contact-report dispatch
 *   FUNC(contactCategory) — human-readable contact category
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_spotting_fnc_spottingSystem
 *
 * Public: No
 */

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — resync listeners (registered BEFORE the client half runs)
// ─────────────────────────────────────────────────────────────────────────────
// Two force-resend channels, both consumed by FUNC(spotCheck):
//
//   GVAR(spotForceResend)   — global one-shot, every curator re-sent next tick.
//     Starts true (the first tick sends everything as new anyway).
//
//   GVAR(spotResendPlayers) — playerNetId → true, a per-destination pending
//     request. Each client fires QGVAR(spotResync) with its own player object once
//     its event handlers are registered. This is the ONLY recovery path for a
//     rejoin into the same slot: the returning player keeps his unit object, so he
//     is neither a new recipient nor a changed payload, and the change-gated send
//     never fires (see FUNC(emitSpot)).
//
// The per-player channel exists because the global flag is consumed on the very
// next tick regardless of who was resolvable. A client fires its request from
// CBA_settingsInitialized, but the mission may not assign it a curator module until
// several ticks later (script-granted Zeus, BIS_fnc_moduleCurator on connect) — the
// global flag would be spent on a pass that did not include that player at all, and
// nothing would ever re-send. A pending per-player entry is instead retired only
// once that player actually resolves to a targetable curator, so the request cannot
// be burned early. A bare QGVAR(spotResync) with no player still sets the global
// flag, so any other caller keeps the old behaviour.
//
// This block sits above the client fork deliberately: on a listen server
// CBA_fnc_serverEvent runs locally and immediately, so the host's own
// QGVAR(spotResync) — fired at the tail of FUNC(spottingClient) — would be dropped
// on the floor if the handler were still registered further down the file.
if (isServer) then {
    GVAR(spotForceResend)   = true;
    GVAR(spotResendPlayers) = createHashMap;

    [QGVAR(spotResync), {
        params [["_player", objNull]];
        if (!isPlayer _player) exitWith { GVAR(spotForceResend) = true };
        GVAR(spotResendPlayers) set [netId _player, true];
    }] call CBA_fnc_addEventHandler;
};

// Runs on every machine with a screen: MP clients, listen-server host, and
// singleplayer (where isServer and hasInterface are both true). Guarded here,
// at the fork — FUNC(spottingClient) carries no guard of its own.
if (hasInterface) then {
    call FUNC(spottingClient);
};

if (!isServer) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — state
// ─────────────────────────────────────────────────────────────────────────────

// Fire-blink lookup, rebuilt by every detection pass:
// netId(spottedUnit) → [[wedgeMarker, spotterPlayer], …] for units currently
// wedge-spotted. The FiredMan handler reads it to know who, if anyone, is
// watching the shooter.
GVAR(wedgeByUnit)        = createHashMap;
GVAR(blinkThrottle)      = createHashMap;   // netId → last blink-send time (rate limiter)
GVAR(spotGroupLastSeen)  = createHashMap;   // (sideStr + "_" + leaderNetId) → last time that side had the group confirmed (callout gate)
GVAR(spotDebugLast)      = createHashMap;   // curatorNetId → last-logged resolution sig (diagnostic, on-change only)
GVAR(markerSuffixCache)  = createHashMap;   // "m"/"v" + class → NATO symbol suffix, mission-lifetime (fnc_unitMarker)
// (sidePrefix + suffix) → finished NATO texture path, mission-lifetime. The
// SUFFIX lookup above was already cached, but the `format` that turns it into a
// path was not, so every spotted group rebuilt the same handful of strings on
// every detection pass. There are only ~3 prefixes × ~13 suffixes, so this
// saturates within seconds and never grows again (fnc_unitMarker).
GVAR(markerTexCache)     = createHashMap;
GVAR(chevronLatch)       = createHashMap;   // (spotterSideStr + "_" + memberNetId) → [expiryTime, lastBestSpotter] (fnc_spotCheck)

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — fire-blink (white flash on the wedge when a spotted unit shoots)
// ─────────────────────────────────────────────────────────────────────────────
// One class event handler covers every infantryman's shot (current and future units),
// firing where the unit is local. Normal AI is server-local, so the blink fires here.
// Units under Zeus RC shift locality to the curator's client — those can still be
// wedge-spotted (locality not filtered on hostiles) but their shots won't reach this
// handler, so the white blink is silently skipped for RC'd units only.
// Cheap early-out for the common case: a shot nobody is watching does one lookup.
["CAManBase", "FiredMan", {
    params ["_unit"];

    private _id = netId _unit;
    private _spotters = GVAR(wedgeByUnit) getOrDefault [_id, []];

    if (_spotters isEqualTo []) exitWith {};
    // Throttle: cap to one blink event per 0.1 s per unit (slightly under the blink
    // duration so sustained auto-fire stays lit) to bound network cost in a firefight.
    private _now = CBA_missionTime;

    if (_now - (GVAR(blinkThrottle) getOrDefault [_id, 0]) < FIRE_BLINK_THROTTLE) exitWith {};
    GVAR(blinkThrottle) set [_id, _now];

    {
        _x params ["_mrkr", "_player"];
        // The lookup is rebuilt only once per check interval — the player may have
        // disconnected since. isPlayer, not isNull: a departed player's leftover AI
        // body is non-null and server-local, so owner is 2 and the blink would land
        // on the server/host instead (see FUNC(spotCheck)'s curator-resolution block).
        if (isPlayer _player) then {
            [QGVAR(blink), [_mrkr], _player] call CBA_fnc_targetEvent;
        };
    } forEach _spotters;
}, true, []] call CBA_fnc_addClassEventHandler;

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — detection loop (unscheduled CBA per-frame handler)
// ─────────────────────────────────────────────────────────────────────────────
// The PFH fires once per second (the setting's minimum) and self-gates on the
// live GVAR(spotCheckInterval) value, so the interval can be retuned mid-mission.
// Unscheduled — immune to script-scheduler starvation, unlike a spawned sleep
// loop. PFH args carry the active-spots map (spotKey → [markerName,
// spotterPlayer, payloadSignature]) and the next-run time, mutated in place.
[{
    (_this select 0) params ["_activeSpots", "_nextRun"];
    if (CBA_missionTime < _nextRun) exitWith {};
    (_this select 0) set [1, CBA_missionTime + ((GETGVAR(spotCheckInterval,3)) max 1)];
    [_activeSpots] call FUNC(spotCheck);
}, 1, [createHashMap, 0]] call CBA_fnc_addPerFrameHandler;
