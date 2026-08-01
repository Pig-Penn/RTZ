#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT half of the overlay stream engine — ONE Draw3D handler and ONE
 * snapshot receiver shared by every overlay, in place of a full copy of the
 * machinery per overlay.
 *
 * Per frame it does the expensive, overlay-independent work exactly once —
 * the Zeus-open test, the selection change test, positionCameraToWorld,
 * getMousePosition — then hands that frame context to each active stream's
 * draw function. Two overlays therefore cost one camera query per frame, not
 * two, and one selection sync, not two.
 *
 * Subscription is selection-driven: whenever curatorSelected changes (which
 * covers select, deselect and Zeus closing, since that reads as an empty
 * selection) the resolved hull list plus the active stream ids go to the server
 * in one QGVAR(watch) event. Watched entities are hulls — a crewman resolves to
 * his vehicle, which moves and fights as one — and the server re-resolves
 * whoever steers/aims each tick, so seat changes between syncs stay covered.
 *
 * Snapshots arrive per stream on QGVAR(update) and are stored RAW; the baking
 * (localised labels, side colours) happens lazily in the stream's draw function
 * on the first frame after receipt and is then reused, the same
 * cache-on-dirty pattern EFUNC(selection,unitTags) uses. Record layout, per
 * stream id, in GVAR(data):
 *
 *   [_entries, _rxTime, _dirty, _refTime]
 *     _entries — raw server entries, replaced in place by their baked form
 *     _rxTime  — CBA_missionTime the snapshot landed, for client-side ageing
 *     _dirty   — set on receipt, cleared by the draw function once baked
 *     _refTime — server clock at send, the zero point of any age in _entries
 *
 * Every entry, raw or baked, keeps the watched unit at index 0 — that is what
 * the deselect prune and the in-flight filter test.
 *
 * Loading: called unconditionally from XEH_postInit (see the note there).
 * Registers a Draw3D MEH and two CBA event handlers, no scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_overlays_fnc_streamClient
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Stream id -> the two halves of its client contract. LINKFUNC rather than a
// stored Code value so a PREP recompile is picked up.
GVAR(drawFncs) = createHashMapFromArray [
    [STREAM_DEST, LINKFUNC(drawDestination)],
    [STREAM_TGT,  LINKFUNC(drawTarget)]
];

// Stream id -> the master setting that must stay true for it to run. Lowercased
// because CBA_SettingChanged is not guaranteed to report the name in the case it
// was registered with.
GVAR(streamSettings) = createHashMapFromArray [
    [STREAM_DEST, toLower QGVAR(enableDestinationDisplay)],
    [STREAM_TGT,  toLower QGVAR(enableTargetDisplay)]
];

// Engine planningMode → short label. Keys are normalized (uppercase, spaces
// stripped) because the engine reports e.g. "LEADER PLANNED" at runtime while
// the wiki documents "LeaderPlanned". VEHICLEPLANNED is the mode every driving
// vehicle reports — without it they all showed the raw engine string.
// DONOTPLAN means "not moving", which is a plan of its own, not a direct one.
GVAR(destModeLabels) = createHashMapFromArray [
    ["LEADERPLANNED",      LLSTRING(ModePlanned)],
    ["LEADERDIRECT",       LLSTRING(ModeDirect)],
    ["VEHICLEPLANNED",     LLSTRING(ModePlanned)],
    ["FORMATIONPLANNED",   LLSTRING(ModeFormation)],
    ["DONOTPLANFORMATION", LLSTRING(ModeFormation)],
    ["DONOTPLAN",          LLSTRING(ModeHolding)]
];

// ── Draw pass ────────────────────────────────────────────────────────────────
[missionNamespace, "Draw3D", {
    if (GVAR(active) isEqualTo []) exitWith {};

    // Resolved ONCE for every overlay. getAssignedCuratorLogic as well as the
    // display: a machine showing the curator display without an assigned
    // curator gets [] back from curatorSelected, and SELECTED_OBJECTS would
    // then index into an empty array.
    private _inZeus = !isNull (findDisplay IDD_RSCDISPLAYCURATOR)
        && {!isNull (getAssignedCuratorLogic player)};
    private _sel = if (_inZeus) then { SELECTED_OBJECTS } else { [] };

    if (_sel isNotEqualTo GVAR(selection)) then {
        GVAR(selection) = _sel;

        private _watched = [];
        {
            if (!isNull _x) then { _watched pushBackUnique (vehicle _x) };
        } forEach _sel;
        GVAR(watched) = _watched;

        // Deselected units' overlays drop on the spot rather than after a tick.
        // Objects compare directly — no netId round-trip for a set the client
        // already holds.
        {
            private _rec = GVAR(data) get _x;   // _x: stream id
            if (!isNil "_rec") then {
                _rec set [0, (_rec select 0) select {(_x select 0) in _watched}];
            };
        } forEach GVAR(active);

        [QGVAR(watch), [player, _watched, GVAR(active)]] call CBA_fnc_serverEvent;
    };

    // Curator-view overlay only — never bleed into first person / plain map.
    if (!_inZeus) exitWith {};

    // Shared frame context: one camera query and one mouse query for every
    // active overlay.
    private _camPos = positionCameraToWorld [0, 0, 0];
    private _mouse  = getMousePosition;
    private _now    = CBA_missionTime;

    {
        private _rec = GVAR(data) get _x;
        if (isNil "_rec") then { continue };            // no snapshot yet
        if ((_rec select 0) isEqualTo []) then { continue };
        private _draw = GVAR(drawFncs) get _x;
        if (isNil "_draw") then { continue };           // stream with no renderer
        [_rec, _camPos, _mouse, _now] call _draw;
    } forEach GVAR(active);
}] call CBA_fnc_addBISEventHandler;

// ── Snapshot receiver ────────────────────────────────────────────────────────
// Stored raw and marked dirty; the stream's draw function bakes it on the next
// frame. Entries for units deselected while the snapshot was in flight are
// dropped here rather than surviving to the draw.
[QGVAR(update), {
    params ["_stream", "_entries", "_refTime"];

    private _watched = GVAR(watched);
    _entries = _entries select {!isNull (_x select 0) && {(_x select 0) in _watched}};

    GVAR(data) set [_stream, [_entries, CBA_missionTime, true, _refTime]];
}] call CBA_fnc_addEventHandler;

// ── Master setting watchdog ──────────────────────────────────────────────────
// The settings no longer require a mission restart, so switching one OFF while
// its overlay is running has to stop it — otherwise the curator is left with a
// live overlay and no context action to turn it off with.
["CBA_SettingChanged", {
    params ["_name", "_value"];
    if (_value isEqualTo true) exitWith {};
    _name = toLower _name;
    {
        // _x: stream id, _y: its (lowercased) master setting name
        if (_name == _y && {_x in GVAR(active)}) then {
            [_x, false] call FUNC(toggleOverlay);
        };
    } forEach GVAR(streamSettings);
}] call CBA_fnc_addEventHandler;
