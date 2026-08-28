#include "script_component.hpp"
/*
 * Author: Maxim
 * Brings the counter-battery system up or takes it down, on whichever machine
 * calls it. Run from CBA_settingsInitialized and again from CBA_SettingChanged, so
 * it must be idempotent in both directions — it refuses to start twice and refuses
 * to stop what was never started.
 *
 * Three machines get three different things out of this file, and a listen-server
 * host gets two of them:
 *
 *   every machine — the ArtilleryShellFired mission event handler, added and
 *     REMOVED by stored id. This is what makes the component genuinely free while
 *     switched off, and it is the one structural advantage it has over
 *     rtz_spotting's fire-blink handler: that one is a CLASS event handler, which
 *     cannot be removed once added, so it is stuck testing a variable on every
 *     infantry shot in the mission forever.
 *
 *   server — the QGVAR(shotReported) receiver and the track registry.
 *
 *   curator client — the QGVAR(contact) receiver and the curator-display hooks
 *     that attach the map overlay.
 *
 * The receivers and hooks are registered ONCE, on the first enable, and never
 * removed. That is deliberate rather than lazy: with the system off no reporter
 * sends anything, so an unsubscribed event costs exactly one dead hashmap entry,
 * and FUNC(startDisplay) already refuses to attach anything while GVAR(enabled) is
 * false. Removing them would buy nothing and add two more teardown paths to get
 * wrong.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_battery_fnc_startSystem
 *
 * Public: No
 */

private _enabled = GVAR(enabled);

// ── The detector, added and removed by id ────────────────────────────────────
// Registered on EVERY machine, not just the server. The units a curator spawns are
// local to that curator (CLAUDE.md, Usage), so most guns in an RTZ mission are
// owned by a client and a server-only handler would never see them fire.
// FUNC(detectShot) then gates on `local _vehicle` to pick exactly one reporter —
// ArtilleryShellFired fires both on the PC that triggered the action AND on the PC
// where the vehicle is local, so without that gate one shot could be reported twice.
if (_enabled) then {
    if (GVAR(missionEH) == -1) then {
        GVAR(missionEH) = addMissionEventHandler ["ArtilleryShellFired", {_this call FUNC(detectShot)}];
    };
} else {
    if (GVAR(missionEH) != -1) then {
        removeMissionEventHandler ["ArtilleryShellFired", GVAR(missionEH)];
        GVAR(missionEH) = -1;
    };
};

// ── Server: the track registry and the fan-out receiver ──────────────────────
// The nil test is the once-flag: a disable EMPTIES the registry rather than
// deleting it, so a later re-enable finds it non-nil and does not register a second
// receiver for the same event.
if (isServer) then {
    if (_enabled) then {
        if (isNil QGVAR(tracks)) then {
            // gunNetId -> track record; see FUNC(dispatchContact) for the layout.
            // Keyed on the gun's netId because an Object is not a legal HashMap key
            // (Gotchas §3).
            GVAR(tracks) = createHashMap;
            // Monotonic. The client store is keyed on THIS, never on the gun's
            // netId — a netId would let a client objectFromNetId straight back to
            // the real gun and read its true position, which is the whole thing the
            // offset exists to hide.
            GVAR(nextTrackId) = 0;

            [QGVAR(shotReported), LINKFUNC(dispatchContact)] call CBA_fnc_addEventHandler;
        };
    } else {
        if (!isNil QGVAR(tracks)) then {
            // Emptied, not deleted. Tracks carry the offsets a client's live circles
            // were drawn from, and re-enabling should start a fresh picture rather
            // than resume one the curators watched expire.
            GVAR(tracks) = createHashMap;
        };
    };
};

if (!hasInterface) exitWith {};

// ── Curator client: the contact receiver and the display hooks ───────────────
if (_enabled && {!GVAR(hooked)}) then {
    GVAR(hooked) = true;

    [QGVAR(contact), LINKFUNC(receiveContact)] call CBA_fnc_addEventHandler;

    // The curator display and its map control are destroyed and recreated every
    // time Zeus opens, and a control's event handlers die with it — so the overlay
    // is attached per display instance, exactly as rtz_mine does it.
    ["zen_curatorDisplayLoaded", {_this call FUNC(startDisplay)}] call CBA_fnc_addEventHandler;
    ["zen_curatorDisplayUnloaded", {call FUNC(stopDisplay)}] call CBA_fnc_addEventHandler;
};

// A disable must not leave a stale picture behind for a later re-enable to show as
// if it were live.
if (!_enabled) then {
    GVAR(contacts) = createHashMap;
    GVAR(nextExpiry) = 1e11;
};

// Apply the change to a display that is already open. FUNC(startDisplay) is the
// attach AND the detach, so this one call covers both directions; with Zeus closed
// there is no control to touch and the next zen_curatorDisplayLoaded will do it.
if (isNull (findDisplay IDD_RSCDISPLAYCURATOR)) exitWith {};

[] call FUNC(startDisplay);
