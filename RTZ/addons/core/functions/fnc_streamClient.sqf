#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT ONLY. The ONE receiver for every snapshot the server's stream engine
 * pushes (QGVAR(update)), and the master-setting watchdog.
 *
 * Snapshots are routed to the receiver the stream registered with
 * FUNC(registerStream) — this file holds no knowledge of any particular feed.
 * The receivers themselves are FUNC(receiveOverlay) (the default: store raw, bake
 * lazily at draw time), FUNC(receiveUnitData) and FUNC(receiveVehicleData) (unpack
 * into netId-keyed maps, because their consumers index by id).
 *
 * Loading: called unconditionally from XEH_postInit on every interface machine —
 * it reads no setting to install itself, and a store nothing writes to costs
 * nothing. Registers two CBA event handlers, no scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_core_fnc_streamClient
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// ── Snapshot receiver ────────────────────────────────────────────────────────
// Pure dispatch. This was a `switch (_stream)` with a case per feed, which meant
// the shared engine hardcoded the ids of rtz_hud's own two selection displays and
// silently gave every other stream the overlay treatment by falling through to
// `default`. A stream now declares its receiver with FUNC(registerStream), so this
// neither knows nor needs to know what any of them are.
[QGVAR(update), {
    // getOrDefault, not get: a snapshot can outrun its registration on a JIP
    // client (the server is already streaming when this machine's postInit runs),
    // and the overlay store is the right home for anything unclaimed — it is what
    // the `default` case did.
    private _receiver = GVAR(streamReceivers) getOrDefault [_this select 0, LINKFUNC(receiveOverlay)];
    _this call _receiver;
}] call CBA_fnc_addEventHandler;

// ── Master setting watchdog ──────────────────────────────────────────────────
// None of the display settings require a mission restart, so switching one OFF
// while its display is running has to stop it — otherwise the curator is left
// with a live display and no context action to turn it off with.
["CBA_SettingChanged", {
    params ["_name", "_value"];
    if (_value isEqualTo true) exitWith {};
    // Lowercased: CBA_SettingChanged is not guaranteed to report the name in the
    // case it was registered with.
    _name = toLower _name;
    {
        // _x: stream id, _y: its (lowercased) master setting name
        if (_name == _y && {_x in GVAR(activeStreams)}) then {
            [_x, false] call FUNC(toggleOverlay);
        };
    } forEach GVAR(streamSettings);
}] call CBA_fnc_addEventHandler;
