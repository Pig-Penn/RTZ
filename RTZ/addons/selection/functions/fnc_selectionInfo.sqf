#include "script_component.hpp"
/*
 * Author: Maxim
 * When a curator uses the context menu action, a ZEN-styled
 * dialog lists every selected friendly infantry unit with a live snapshot of the
 * same data the LAMBS Danger debug overlay shows:
 *   — behaviour / AI unit state and current command
 *   — LAMBS current task, group tactic, danger cause / range / timeout
 *   — current target + visibility, known-enemy and group-memory counts (leaders)
 *   — clamped morale %, suppression %, health %, downed state, and status flags
 *     (PATH OFF, MOVE OFF, FORCED, FLEEING, HIDDEN, INSIDE, BUSY, MOUNTED, WOUNDED)
 *
 * Data flow:
 *   Client poll (0.25 s) → tracks the curator's selection locally every tick,
 *   but only reports it to the server while someone is LOOKING at the data:
 *   the info dialog is open, or the unit head tags (FUNC(unitTags)) are
 *   visible. Idle curators stream nothing.
 *   FUNC(openSelectionInfo) additionally reports once immediately on open,
 *   and the server gathers + pushes straight from that report, so the dialog
 *   fills without waiting for a poll/gather tick to line up.
 *   Server gather (event-driven + PFH at the GVAR(gatherInterval) setting) →
 *   reads AI state where units are local (FUNC(gatherUnitInfo)), packages it
 *   into compact packets, and pushes to each reporting curator's client via
 *   CBA event — skipped when identical to the last push (diff-gated).
 *   Dialog refreshes itself (0.25 s PFH) while open, so the listing stays live.
 *
 * Rendering functions (FUNC(buildSelectionRows), FUNC(openSelectionInfo)) are
 * compiled separately via PREP and called by name.
 *
 * Requirements: CBA_A3, ZEN, LAMBS (optional — task/tactic rows blank without it).
 * Loading: called from XEH_postInit after CBA_settingsInitialized.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_selection_fnc_selectionInfo
 *
 * Public: No
 */

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — selection reporting, data receipt, and dialog
// ─────────────────────────────────────────────────────────────────────────────
if (hasInterface) then {

    // ── Client config ──────────────────────────────────────────────────────
    private _selPollInterval = 0.25;   // Seconds between selection polls.

    // ── Client state ───────────────────────────────────────────────────────
    // netId → data packet, last pushed by the server for our selection.
    GVAR(selData)       = createHashMap;
    // netIds currently selected (updated by the poll PFH below).
    // FUNC(openSelectionInfo) and FUNC(buildSelectionRows) read this directly.
    GVAR(selCurrent)    = [];
    // netIds of selected vehicles — set by the poll PFH; consumed by FUNC(vehicleOverlay).
    GVAR(selVehicleIds) = [];
    // True while the selection info dialog is open — guards against stacking
    // duplicates AND gates what the poll reports to the server.
    GVAR(selDialogOpen) = false;
    // Last selection list actually sent to the server. Shared with
    // FUNC(openSelectionInfo) (which reports once immediately on open), so the
    // poll and the dialog never double-send or strand a report server-side.
    GVAR(selReported)   = [];
    // How many eligible units/vehicles the curator's raw selection had beyond
    // the SEL_MAX_* cap, updated every poll tick. Without this, a selection
    // over the cap silently drops the extras from tags/dialog/cards with zero
    // feedback — FUNC(buildSelectionRows) reads GVAR(selOverflow) to note it
    // in the dialog header, and the poll below hints once (edge-triggered) on
    // GVAR(selVehOverflow) for the vehicle side, which has no dialog.
    GVAR(selOverflow)    = 0;
    GVAR(selVehOverflow) = 0;

    // Replace the whole infantry data set with the server's latest gather.
    [QGVAR(selData), {
        params ["_packets"];
        private _m = createHashMap;
        { _m set [_x select 0, _x] } forEach _packets;
        GVAR(selData) = _m;
    }] call CBA_fnc_addEventHandler;

    // ── Poll our curator's selection ───────────────────────────────────────
    // Selection state (GVAR(selCurrent) / GVAR(selVehicleIds)) is refreshed
    // locally every tick; the SERVER is only told about infantry while a data
    // consumer is active (info dialog open, or unit head tags visible), so
    // idle curators cost zero gather/network traffic.
    // State array [lastVehs, hadUnitOverflow, hadVehOverflow] is mutated in-place
    // each call — CBA PFH passes the same args object every iteration, providing
    // free persistent state (the overflow flags edge-trigger the truncation hint
    // below rather than re-firing it every tick).
    [{
        params ["_state", "_handle"];
        _state params ["_lastVehs", ["_hadUnitOverflow", false], ["_hadVehOverflow", false]];
        private _ids  = [];
        private _vehs = [];
        private _unitOverflow = 0;
        private _vehOverflow  = 0;
        if (!isNull (getAssignedCuratorLogic player) && { !isNull (findDisplay 312) }) then {
            private _objs = SELECTED_OBJECTS;
            private _grps = SELECTED_GROUPS;
            private _units = [];
            { if (_x isKindOf "CAManBase") then { _units pushBack _x } } forEach _objs;
            { if (_x isEqualType grpNull) then { _units append (units _x) } } forEach _grps;
            _units = _units arrayIntersect _units;
            // A virtual Zeus (VirtualMan_F) has no real side — it is the game
            // master, not a PvP officer, so the own-side filter must not apply.
            private _anySide = player isKindOf "VirtualMan_F";
            // alive covers null too, and every entry is already a CAManBase
            // (the pushBack filter and group expansion both guarantee it).
            _ids = (_units select { alive _x && { _anySide || { side _x == side player } } }) apply { netId _x };
            // Cap AFTER counting the true size — the difference is what silently
            // falls off the tags/dialog/gather below, surfaced via GVAR(selOverflow).
            _unitOverflow = 0 max ((count _ids) - SEL_MAX_UNITS);
            _ids = _ids select [0, SEL_MAX_UNITS];
            // AllVehicles-not-man: without the kind check, selected props /
            // ammo crates pass the "not a man" filter (they always did for a
            // virtual Zeus, whom the side filter exempts) and get gathered,
            // carded and tagged as if they were vehicles.
            _vehs = (_objs select { alive _x && { _x isKindOf "AllVehicles" } && { !(_x isKindOf "CAManBase") } && { _anySide || { side (group _x) == side player } } }) apply { netId _x };
            _vehOverflow = 0 max ((count _vehs) - SEL_MAX_VEHICLES);
            _vehs = _vehs select [0, SEL_MAX_VEHICLES];
        };
        GVAR(selCurrent)    = _ids;
        GVAR(selVehicleIds) = _vehs;
        GVAR(selOverflow)    = _unitOverflow;
        GVAR(selVehOverflow) = _vehOverflow;

        // One-shot hint on the RISING edge only (not selected → over-cap) so
        // holding an oversized selection doesn't spam a message every 0.25 s.
        // The unit dialog also notes this in its header (FUNC(buildSelectionRows));
        // vehicles have no dialog, so this hint is their only feedback.
        if (_unitOverflow > 0 && { !_hadUnitOverflow }) then {
            [format [LLSTRING(MsgSelectionTruncated), _unitOverflow, SEL_MAX_UNITS]] call zen_common_fnc_showMessage;
        };
        if (_vehOverflow > 0 && { !_hadVehOverflow }) then {
            [format [LLSTRING(MsgVehicleSelectionTruncated), _vehOverflow, SEL_MAX_VEHICLES]] call zen_common_fnc_showMessage;
        };
        _state set [1, _unitOverflow > 0];
        _state set [2, _vehOverflow > 0];

        // Report the selection only while a consumer is active: the info dialog,
        // or the unit head tags (GVAR(tagsVisible), owned by FUNC(unitTags) —
        // read defensively since that system may be disabled). An empty report
        // (consumers gone / selection cleared / Zeus closed) tells the server to
        // stop gathering for us.
        private _wantData = GVAR(selDialogOpen)
            || { GETGVAR(tagsVisible,false) };
        private _report = [[], _ids] select _wantData;
        if (_report isNotEqualTo GVAR(selReported)) then {
            GVAR(selReported) = _report;
            [QGVAR(selSelection), [player, _report]] call CBA_fnc_serverEvent;
            if (_report isEqualTo []) then { GVAR(selData) = createHashMap };
        };

        if (_vehs isNotEqualTo _lastVehs) then {
            _state set [0, _vehs];
            [QGVAR(selVehicles), [player, _vehs]] call CBA_fnc_serverEvent;
            if (_vehs isEqualTo []) then { GVAR(selVehicleData) = createHashMap };
        };
    }, _selPollInterval, [[], false, false]] call CBA_fnc_addPerFrameHandler;

    // ── Zeus Enhanced context menu action ──────────────────────────────────
    private _action = [
        "RTZ_ViewSelInfo",
        LLSTRING(ActionBehavior),
        ["\a3\ui_f\data\igui\cfg\simpletasks\types\intel_ca.paa", [1, 1, 1, 1]],
        { [] call FUNC(openSelectionInfo) },
        // Show-condition: ZEN lists the action when this returns true, so it
        // must be true when units ARE selected (was inverted, which hid the
        // action exactly when it had something to show).
        { GVAR(selCurrent) isNotEqualTo [] },
        [],
        {},
        {}
    ] call zen_context_menu_fnc_createAction;

    [_action, ["RTZ_Control"], 5] call zen_context_menu_fnc_addAction;
};

if (!isServer) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — configuration
// ─────────────────────────────────────────────────────────────────────────────
// Defines rather than privates: they are read inside stored code (event handler,
// PFH, push function) that runs long after this registration scope is gone.


// ─────────────────────────────────────────────────────────────────────────────
// SERVER — state
// ─────────────────────────────────────────────────────────────────────────────

// playerNetId → array of selected unit netIds. Populated only for curators whose
// info dialog is OPEN (clients report [] on close, which removes the entry), so
// the gather loop below touches exactly the players who are actually looking.
GVAR(selByPlayer) = createHashMap;

// playerNetId → the packet array last actually SENT to that client. The gather
// still runs every tick (unit state must be read to know it hasn't changed), but
// an identical result is not re-serialized onto the network — idle selections
// cost zero traffic. Entries are dropped whenever the client re-reports (forcing
// a fresh send: the client clears its own data on close) or unsubscribes.
GVAR(selLastSent) = createHashMap;

// Gather packets for one curator's reported selection and push them to their
// client. Called from the report event (instant dialog fill) and the PFH loop.
GVAR(fnc_pushSelData) = {
    params ["_player", "_sel"];
    private _cSide   = side _player;
    // Virtual Zeus (VirtualMan_F) is the game master, not a PvP officer —
    // exempt from the own-side filter below (mirrors the client poll's _anySide filter).
    private _anySide = _player isKindOf "VirtualMan_F";
    private _packets = [];
    {
        private _unit = objectFromNetId _x;
        if (isNull _unit || { !alive _unit }) then { continue };
        if (!_anySide && { side _unit != _cSide }) then { continue };
        _packets pushBack ([_unit] call FUNC(gatherUnitInfo));
    } forEach (_sel select [0, SEL_MAX_UNITS]);
    // Diff-gate: nothing changed since the last send → skip the network hop.
    // objNull default so a missing entry never compares equal to any array.
    private _pk = netId _player;
    if (_packets isEqualTo (GVAR(selLastSent) getOrDefault [_pk, objNull])) exitWith {};
    GVAR(selLastSent) set [_pk, _packets];
    [QGVAR(selData), [_packets], _player] call CBA_fnc_targetEvent;
};

[QGVAR(selSelection), {
    params ["_player", "_sel"];
    if (isNull _player) exitWith {};
    private _pk = netId _player;
    if (_sel isEqualTo []) exitWith {
        GVAR(selByPlayer)  deleteAt _pk;
        GVAR(selLastSent) deleteAt _pk;
    };
    GVAR(selByPlayer) set [_pk, _sel];
    // A fresh report always gets a full send — the client may have cleared its
    // data since (dialog close wipes it), so the diff baseline must not linger.
    GVAR(selLastSent) deleteAt _pk;
    // Gather + push immediately so a freshly opened dialog fills right away
    // instead of waiting for the next PFH tick.
    [_player, _sel] call GVAR(fnc_pushSelData);
}] call CBA_fnc_addEventHandler;

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — gather loop (infantry only; vehicle gather is in FUNC(vehicleDataStream))
// ─────────────────────────────────────────────────────────────────────────────
// A CBA PFH rather than a spawned while/sleep thread: unscheduled, so the gather
// cadence never degrades under scheduler load. Entries whose player disconnected
// or dropped curator are pruned in passing (deleted AFTER the forEach — never
// mutate a HashMap mid-iteration).

// The PFH ticks at GATHER_TICK and self-gates on the live GVAR(gatherInterval)
// setting (same pattern as rtz_spotting's spotCheckInterval), so admins can
// retune the cadence mid-mission without a restart.
[{
    (_this select 0) params ["_nextRun"];
    if (CBA_missionTime < _nextRun) exitWith {};
    (_this select 0) set [0, CBA_missionTime + ((GETGVAR(gatherInterval,0.3)) max GATHER_TICK)];
    if (count GVAR(selByPlayer) == 0) exitWith {};
    private _stale = [];
    {
        // HashMap forEach: _x is the KEY (player netId), _y the VALUE (selection).
        private _player = objectFromNetId _x;
        if (isNull _player || { isNull (getAssignedCuratorLogic _player) }) then {
            _stale pushBack _x;
            continue;
        };
        [_player, _y] call GVAR(fnc_pushSelData);
    } forEach GVAR(selByPlayer);
    {
        GVAR(selByPlayer)  deleteAt _x;
        GVAR(selLastSent) deleteAt _x;
    } forEach _stale;
}, GATHER_TICK, [0]] call CBA_fnc_addPerFrameHandler;
