#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT ONLY. The ONE receiver for every snapshot the server's stream engine
 * pushes (QGVAR(update)), and the master-setting watchdog.
 *
 * Snapshots are routed by stream id into the store the display that consumes
 * them reads. The two selection feeds are unpacked into netId-keyed maps here,
 * because their consumers (tags, cards, dialog rows) look entities up by id; the
 * overlay feeds are stored RAW and baked lazily by their draw function on the
 * first frame after receipt, then reused — the same cache-on-dirty pattern the
 * tag renderers use, and the reason a snapshot carries an absolute reference
 * time rather than pre-computed ages.
 *
 * Overlay record layout, per stream id, in GVAR(streamData):
 *
 *   [_entries, _rxTime, _dirty, _refTime]
 *     _entries — raw server entries, replaced in place by their baked form
 *     _rxTime  — CBA_missionTime the snapshot landed, for client-side ageing
 *     _dirty   — set on receipt, cleared by the draw function once baked
 *     _refTime — server clock at send, the zero point of any age in _entries
 *
 * Every overlay entry, raw or baked, keeps the watched entity at index 0 — that
 * is what the deselect prune in FUNC(selectionPoll) and the in-flight filter
 * below both test.
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
 * call rtz_hud_fnc_streamClient
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// ── Snapshot receiver ────────────────────────────────────────────────────────
[QGVAR(update), {
    params ["_stream", "_entries", "_refTime"];

    switch (_stream) do {
        // Infantry packets: netId -> packet. The tag renderer and the dialog both
        // index by id, so unpack once here rather than per lookup per frame.
        case STREAM_UNIT: {
            private _m = createHashMap;
            { _m set [_x select 0, _x] } forEach _entries;
            GVAR(unitData) = _m;
            GVAR(unitTagsDirty) = true;
        };

        // Vehicle packets: same shape, feeding both the head tags and the cards.
        case STREAM_VEH: {
            private _m = createHashMap;
            { _m set [_x select 0, _x] } forEach _entries;
            GVAR(vehicleData) = _m;
            GVAR(vehicleTagsDirty) = true;
            GVAR(vehicleDataDirty) = true;
        };

        // Overlay streams: stored raw and marked dirty for the draw function to
        // bake. Entries for entities deselected while the snapshot was in flight
        // are dropped here rather than surviving to the draw.
        default {
            private _hulls = GVAR(selHulls);
            _entries = _entries select {!isNull (_x select 0) && {(_x select 0) in _hulls}};
            GVAR(streamData) set [_stream, [_entries, CBA_missionTime, true, _refTime]];
        };
    };
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
