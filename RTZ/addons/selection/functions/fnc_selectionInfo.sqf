#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT ONLY. Tracks this curator's Zeus selection, subscribes to the server's
 * infantry data stream while something is looking at it, and registers the
 * context menu entry that opens the selection info dialog.
 *
 * The dialog (FUNC(openSelectionInfo)) lists every selected friendly infantry
 * unit with a live snapshot of the same data the LAMBS Danger debug overlay
 * shows:
 *   — behaviour / AI unit state and current command
 *   — LAMBS current task, group tactic, danger cause / range / timeout
 *   — current target + visibility, known-enemy and group-memory counts (leaders)
 *   — clamped morale %, suppression %, health %, downed state, and status flags
 *
 * Data flow:
 *   Client poll (0.25 s) → tracks the selection locally every tick, but only
 *   reports it to the server while someone is LOOKING at the data: the info
 *   dialog is open, or the unit head tags (FUNC(unitTags)) are visible. Idle
 *   curators stream nothing. The report also carries whether the DIALOG
 *   specifically is open, because the dialog is the only consumer of the
 *   expensive leader intel — see FUNC(gatherUnitInfo).
 *   FUNC(openSelectionInfo) additionally reports once immediately on open, and
 *   the server gathers + pushes straight from that report, so the dialog fills
 *   without waiting for a poll/gather tick to line up.
 *   Server gather (FUNC(selectionGather)) → reads AI state where units are local
 *   and pushes compact packets back over QGVAR(selData).
 *   Dialog refreshes itself (0.25 s PFH) while open, so the listing stays live.
 *
 * Requirements: CBA_A3, ZEN, LAMBS (optional — task/tactic rows blank without it).
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableSelectionInfo). Registers CBA + PFH + UI handlers only, no
 *   scheduled ops — `call`ed, not `spawn`ed.
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

if (!hasInterface) exitWith {};

// ── Client config ────────────────────────────────────────────────────────────
#define SEL_POLL_INTERVAL 0.25

// ── Client state ─────────────────────────────────────────────────────────────
// netId → data packet, last pushed by the server for our selection.
GVAR(selData)       = createHashMap;
// netIds currently selected (updated by the poll PFH below).
// FUNC(openSelectionInfo), FUNC(buildSelectionRows) and FUNC(unitTags) read this.
GVAR(selCurrent)    = [];
// netIds of selected vehicles — set by the poll PFH; consumed by
// FUNC(vehicleOverlay) and FUNC(vehicleTags).
GVAR(selVehicleIds) = [];
// True while the selection info dialog is open — guards against stacking
// duplicates AND gates what the poll reports to the server.
GVAR(selDialogOpen) = false;
// Last report actually sent to the server, as [netIds, dialogOpen]. Shared with
// FUNC(openSelectionInfo) (which reports once immediately on open), so the poll
// and the dialog never double-send or strand a report server-side. The dialog
// flag rides along in the diff so OPENING the dialog on an unchanged selection
// still re-reports — the server needs to know to start gathering leader intel.
GVAR(selReported)   = [[], false];
// How many eligible units the curator's raw selection had beyond SEL_MAX_UNITS,
// updated every poll tick. Without this, an over-cap selection silently drops
// the extras from tags/dialog/gather with zero feedback —
// FUNC(buildSelectionRows) reads it to note the truncation in the dialog header.
// The vehicle side has no dialog, so its overflow only ever produces the
// edge-triggered hint below and is not published.
GVAR(selOverflow)   = 0;

// Replace the whole infantry data set with the server's latest gather.
[QGVAR(selData), {
    params ["_packets"];
    private _m = createHashMap;
    { _m set [_x select 0, _x] } forEach _packets;
    GVAR(selData) = _m;
}] call CBA_fnc_addEventHandler;

// ── Poll our curator's selection ─────────────────────────────────────────────
// Selection state (GVAR(selCurrent) / GVAR(selVehicleIds)) is refreshed locally
// every tick; the SERVER is only told about infantry while a data consumer is
// active (info dialog open, or unit head tags visible), so idle curators cost
// zero gather/network traffic.
// State array [lastVehs, hadUnitOverflow, hadVehOverflow] is mutated in-place
// each call — CBA PFH passes the same args object every iteration, providing
// free persistent state (the overflow flags edge-trigger the truncation hint
// below rather than re-firing it every tick).
[{
    params ["_state"];
    _state params ["_lastVehs", "_hadUnitOverflow", "_hadVehOverflow"];
    private _ids  = [];
    private _vehs = [];
    private _unitOverflow = 0;
    private _vehOverflow  = 0;
    if (!isNull (getAssignedCuratorLogic player) && { !isNull (findDisplay IDD_RSCDISPLAYCURATOR) }) then {
        private _objs = SELECTED_OBJECTS;
        private _units = [];
        { if (_x isKindOf "CAManBase") then { _units pushBack _x } } forEach _objs;
        { if (_x isEqualType grpNull) then { _units append (units _x) } } forEach SELECTED_GROUPS;
        _units = _units arrayIntersect _units;
        // A virtual Zeus (VirtualMan_F) has no real side — it is the game
        // master, not a PvP officer, so the own-side filter must not apply.
        private _anySide  = player isKindOf "VirtualMan_F";
        private _curSide  = side player;
        // alive covers null too, and every entry is already a CAManBase
        // (the pushBack filter and group expansion both guarantee it).
        _ids = (_units select { alive _x && { _anySide || { side _x == _curSide } } }) apply { netId _x };
        // Cap AFTER counting the true size — the difference is what silently
        // falls off the tags/dialog/gather below, surfaced via GVAR(selOverflow).
        _unitOverflow = 0 max ((count _ids) - SEL_MAX_UNITS);
        _ids = _ids select [0, SEL_MAX_UNITS];
        // AllVehicles-not-man: without the kind check, selected props / ammo
        // crates pass the "not a man" filter (they always did for a virtual
        // Zeus, whom the side filter exempts) and get gathered, carded and
        // tagged as if they were vehicles.
        _vehs = (_objs select {
            alive _x
            && { _x isKindOf "AllVehicles" }
            && { !(_x isKindOf "CAManBase") }
            && { _anySide || { VEH_SIDE_OK(_x,_curSide) } }
        }) apply { netId _x };
        _vehOverflow = 0 max ((count _vehs) - SEL_MAX_VEHICLES);
        _vehs = _vehs select [0, SEL_MAX_VEHICLES];
    };
    GVAR(selCurrent)    = _ids;
    GVAR(selVehicleIds) = _vehs;
    GVAR(selOverflow)   = _unitOverflow;

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

    // Report the selection only while a consumer is active: the info dialog, or
    // the unit head tags (GVAR(tagsVisible), owned by FUNC(unitTags) — read
    // defensively since that system may be disabled). An empty report (consumers
    // gone / selection cleared / Zeus closed) tells the server to stop gathering
    // for us.
    private _wantData = GVAR(selDialogOpen) || { GETGVAR(tagsVisible,false) };
    private _report = [[[], false], [_ids, GVAR(selDialogOpen)]] select _wantData;
    if (_report isNotEqualTo GVAR(selReported)) then {
        GVAR(selReported) = _report;
        [QGVAR(selSelection), [player] + _report] call CBA_fnc_serverEvent;
        if ((_report select 0) isEqualTo []) then { GVAR(selData) = createHashMap };
    };

    // The vehicle stream is not consumer-gated: the overlay cards and the
    // vehicle tags each decide for themselves whether to draw, and a card is
    // expected the instant a vehicle is selected. Reported on change only.
    if (_vehs isNotEqualTo _lastVehs) then {
        _state set [0, _vehs];
        [QGVAR(selVehicles), [player, _vehs]] call CBA_fnc_serverEvent;
        // isNil guard: FUNC(vehicleDataStream) owns that map and only exists
        // when a vehicle display is enabled — don't conjure it here otherwise.
        if (_vehs isEqualTo [] && { !isNil QGVAR(selVehicleData) }) then {
            GVAR(selVehicleData) = createHashMap;
        };
    };
}, SEL_POLL_INTERVAL, [[], false, false]] call CBA_fnc_addPerFrameHandler;

// ── Zeus Enhanced context menu action ────────────────────────────────────────
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
