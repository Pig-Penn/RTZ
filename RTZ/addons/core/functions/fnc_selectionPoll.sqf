#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT ONLY. The ONE place this curator's Zeus selection is resolved, and the
 * ONE subscription sent to the server's stream engine.
 *
 * Previously this job was done twice: the selection dialog's poll resolved units
 * and vehicles on a 0.25 s PFH, while the AI-state overlays re-resolved
 * `curatorSelected` INSIDE their Draw3D handler — sixty times a second, plus a
 * `vehicle` lookup per selected entity — purely to notice a change the poll
 * already tracked four times a second. Both then sent their own subscribe event
 * to their own server registry.
 *
 * Published state, read by every display and by the subscription below:
 *   GVAR(selUnits)    — selected friendly infantry, netIds, side-filtered and
 *                       capped at SEL_MAX_UNITS
 *   GVAR(selVehicles) — selected vehicles, netIds, capped at SEL_MAX_VEHICLES
 *   GVAR(selHulls)    — the whole selection resolved to distinct hulls, as
 *                       objects: a crewman resolves to his vehicle, which moves
 *                       and fights as one. What the AI-state overlays watch.
 *                       Filtered to AllVehicles and capped at SEL_MAX_HULLS.
 *   GVAR(selOverflow) — eligible units dropped by the cap, for the dialog header
 *
 * Subscription: one QGVAR(watch) event carrying all three slices plus the active
 * stream ids, sent only when the payload actually changes. What goes in it is
 * decided entirely by FUNC(buildReport) — the selection slices are consumer-gated
 * through FUNC(setDemand), so an idle curator streams nothing, and the flag for
 * the expensive per-unit intel rides along since only a consumer that displays it
 * should make the server gather it (see rtz_hud's gatherUnitInfo). Those rules
 * used to be spelled out here AND in FUNC(reportNow); they are not any more.
 *
 * Loading: called unconditionally from XEH_postInit — it is engine infrastructure
 * and reads no setting to install itself. It used to be deferred behind rtz_hud's
 * "Selection Info" setting, which meant an admin switching off one display also
 * silently killed the hull slice that other addons' overlays (rtz_supply) depend
 * on. Registers one PFH, no scheduled ops — `call`ed, not `spawn`ed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_core_fnc_selectionPoll
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// State array [hadUnitOverflow, hadVehOverflow] is mutated in place each call —
// a CBA PFH passes the same args object every iteration, providing free
// persistent state. The overflow flags edge-trigger the truncation hint below
// rather than re-firing it every tick.
[{
    params ["_state"];
    _state params ["_hadUnitOverflow", "_hadVehOverflow"];

    private _ids   = [];
    private _vehs  = [];
    private _hulls = [];
    private _unitOverflow = 0;
    private _vehOverflow  = 0;

    if (!isNull (getAssignedCuratorLogic player) && {!isNull (findDisplay IDD_RSCDISPLAYCURATOR)}) then {
        // A Zeus selection arrives as two DISJOINT lists: entities picked
        // individually land in `curatorSelected select 0`, while a group picked by
        // its group icon lands in `select 1` with NONE of its units in `select 0`.
        // ACE3 gates its Zeus "Units" and "Groups" submenus on those two indices
        // independently, and ZEN tests both lists with equivalent predicates —
        // neither would make sense if one were a superset of the other.
        //
        // Expanded ONCE here so all three slices below see the same selection.
        // Only the unit slice used to do this, for itself, which left the hull
        // slice — and therefore every AI-state overlay — blind to a group-icon
        // selection while the head tags worked from the same poll. Nothing on
        // screen explained the difference.
        //
        // Copied before appending: never mutate the array a command handed back.
        // The copy is skipped entirely when no group is selected, which is the
        // ordinary case — a box select over a base can run to hundreds of entries
        // and this is a 4 Hz loop for the whole operation.
        //
        // Dead members are dropped at the expansion rather than in each slice:
        // `units` keeps returning a body until it is deleted, the unit slice
        // filters `alive` anyway, and the hull slice deliberately does not, so
        // without this a wiped squad would hold live hull slots against the cap.
        private _objs = SELECTED_OBJECTS;
        private _grps = SELECTED_GROUPS;
        if (_grps isNotEqualTo []) then {
            _objs = +_objs;
            {
                // ALIAS: the inner loop rebinds _x to a unit. Safe either way — _x
                // is created in the called scope (docs/Knowledge Base/Gotchas.md §2)
                // — but a group and its members are the pair worth naming apart.
                private _grp = _x;
                if (_grp isEqualType grpNull) then {
                    { if (alive _x) then { _objs pushBack _x } } forEach (units _grp);
                };
            } forEach _grps;
        };

        // A virtual Zeus (VirtualMan_F) has no real side — it is the game master,
        // not a PvP officer, so the own-side filter must not apply.
        private _anySide = player isKindOf "VirtualMan_F";
        private _curSide = side player;

        private _units = [];
        { if (_x isKindOf "CAManBase") then { _units pushBack _x } } forEach _objs;
        // A man selected individually AND as part of a selected group is in the
        // list twice; the same dedupe ZEN's getSelectedUnits ends with.
        _units = _units arrayIntersect _units;

        // alive covers null too, and every entry is already a CAManBase — the
        // pushBack filter above guarantees it.
        _ids = (_units select {alive _x && {_anySide || {side _x == _curSide}}}) apply {netId _x};
        // Cap AFTER counting the true size — the difference is what silently falls
        // off the tags/dialog/gather, surfaced via GVAR(selOverflow).
        _unitOverflow = 0 max ((count _ids) - SEL_MAX_UNITS);
        _ids = _ids select [0, SEL_MAX_UNITS];

        // AllVehicles-not-man: without the kind check, selected props / ammo
        // crates pass the "not a man" filter (they always did for a virtual Zeus,
        // whom the side filter exempts) and get gathered, carded and tagged as if
        // they were vehicles. Empty hulls are excluded too — Zeus auto-selects a
        // vehicle the instant it's placed, and an uncrewed vehicle has no side,
        // no crew stat, nothing the tag says that the model doesn't already show.
        _vehs = (_objs select {
            alive _x
            && { _x isKindOf "AllVehicles" }
            && { !(_x isKindOf "CAManBase") }
            && { crew _x isNotEqualTo [] }
            && { _anySide || { VEH_SIDE_OK(_x,_curSide) } }
        }) apply {netId _x};
        _vehOverflow = 0 max ((count _vehs) - SEL_MAX_VEHICLES);
        _vehs = _vehs select [0, SEL_MAX_VEHICLES];

        // Hull set for the AI-state overlays: the whole selection — group-icon
        // picks included, via the expansion at the top — collapsed to distinct
        // vehicles. Deliberately NOT side-filtered: these overlays report what the
        // curator's own selection is doing, and the server re-resolves whoever
        // steers/aims each hull anyway.
        //
        // Filtered to AllVehicles (which covers CAManBase) because this slice is
        // the one that crosses the wire as OBJECTS: without it, a box select over
        // a base put every prop, module, logic and ammo crate in the payload, on
        // every selection change, and made the server run every SRC_HULLS
        // gatherer over all of them. None of those entries could ever draw —
        // expectedDestination, targetKnowledge and rtz_supply's servicing record
        // exist only on a man or a vehicle, so all three gatherers were already
        // returning [] for them.
        //
        // Capped like the other two slices, but by STOPPING at the cap rather than
        // truncating afterwards. `pushBackUnique` is a linear scan of the array so far,
        // so walking the whole selection was O(n²) with a `vehicle` engine call per
        // entity — four times a second, for the whole operation — and the box select
        // over a base that the AllVehicles filter above exists for is exactly the case
        // that makes n large. The result is unchanged: truncating afterwards yielded
        // "the first SEL_MAX_HULLS distinct hulls in _objs order", which is precisely
        // what breaking at that count produces.
        //
        // `break` at the TOP of the body, per CLAUDE.md: an `exitWith` here would exit
        // only the current ITERATION and silently behave as a `continue` (see
        // docs/Knowledge Base/Gotchas.md §2).
        //
        // No truncation toast: an oversized selection already fires the unit and/or
        // vehicle hint above, and a third message about a slice with no dialog of its
        // own is noise.
        {
            if (count _hulls >= SEL_MAX_HULLS) then { break };
            if (isNull _x) then { continue };
            if !(_x isKindOf "AllVehicles") then { continue };
            _hulls pushBackUnique (vehicle _x);
        } forEach _objs;
    };

    GVAR(selUnits)    = _ids;
    GVAR(selVehicles) = _vehs;
    GVAR(selHulls)    = _hulls;
    GVAR(selOverflow) = _unitOverflow;

    // One-shot hint on the RISING edge only (not selected → over-cap) so holding
    // an oversized selection doesn't spam a message every tick. The unit dialog
    // also notes this in its header (FUNC(buildSelectionRows)); vehicles have no
    // dialog, so this hint is their only feedback.
    if (_unitOverflow > 0 && {!_hadUnitOverflow}) then {
        [format [LLSTRING(MsgSelectionTruncated), _unitOverflow, SEL_MAX_UNITS]] call zen_common_fnc_showMessage;
    };
    if (_vehOverflow > 0 && {!_hadVehOverflow}) then {
        [format [LLSTRING(MsgVehicleSelectionTruncated), _vehOverflow, SEL_MAX_VEHICLES]] call zen_common_fnc_showMessage;
    };
    _state set [0, _unitOverflow > 0];
    _state set [1, _vehOverflow > 0];

    // ── Subscription ─────────────────────────────────────────────────────────
    // Every slice is consumer-gated: reported only while some display has asked
    // for it through FUNC(setDemand), with the "detailed" flag — which gates the
    // two expensive server reads — riding along on the same registry. The hull
    // slice is gated on an overlay being switched on instead (GVAR(activeStreams)),
    // which is the same statement made by the component that owns the switch.
    //
    // A registry, not reads of rtz_hud's display globals. That is what this used
    // to be, and it is why the engine could not be separated from that one
    // component; it also had to be spelled GETGVAR rather than a bare read,
    // because a nil from a display that had not initialised yet would abort the
    // rest of this handler — the whole subscription — rather than read false
    // (docs/Knowledge Base/Gotchas.md §2). Demand entries only exist once set, so there is
    // nothing to read defensively.
    //
    // The payload itself is built by FUNC(buildReport), from the globals written
    // above, so this loop and FUNC(reportNow) cannot drift apart on what a
    // subscription means. An entirely empty payload unsubscribes.
    private _report = [] call FUNC(buildReport);
    if (_report isEqualTo GVAR(reported)) exitWith {};

    // Copied, not aliased. Element 3 is GVAR(activeStreams), which
    // FUNC(toggleOverlay) mutates IN PLACE — an aliased baseline would silently
    // follow it and compare equal to the very change it is supposed to detect.
    // This runs only when the report changed, so the copy is free in steady state.
    GVAR(reported) = +_report;

    _report params ["_repUnits", "_repVehs", "_repHulls", "_streams"];

    [QGVAR(watch), [player] + _report] call CBA_fnc_serverEvent;

    // Drop data the server will now stop refreshing, so a stale packet can never
    // outlive its subscription and be drawn as if it were current.
    //
    // Delivered as an EMPTY SNAPSHOT to each affected stream's own receiver rather
    // than by clearing the stores directly. Clearing directly is what this used to
    // do — GVAR(unitData), GVAR(vehicleData) and their dirty flags — which meant
    // the engine reached into one particular component's stores by name, and could
    // not have cleared anyone else's. Every receiver already handles "here are the
    // current entries"; [] is simply the case where there are none, so this needs
    // no second code path in any of them.
    private _fnc_clearSlice = {
        params ["_source"];
        {
            if (_y != _source) then { continue };
            private _receiver = GVAR(streamReceivers) getOrDefault [_x, LINKFUNC(receiveOverlay)];
            [_x, [], time] call _receiver;
        } forEach GVAR(streamSources);
    };

    if (_repUnits isEqualTo []) then { [SRC_UNITS] call _fnc_clearSlice };
    if (_repVehs  isEqualTo []) then { [SRC_VEHS]  call _fnc_clearSlice };

    if (_repHulls isEqualTo []) then {
        [SRC_HULLS] call _fnc_clearSlice;
    } else {
        // Entries for entities deselected since the last snapshot drop on the
        // spot rather than lingering until the next server push. Objects compare
        // directly — no netId round-trip for a set the client already holds.
        // ALIAS THE KEY: the inner `select` block rebinds _x to a snapshot entry
        // and leaves it clobbered for the rest of this iteration
        // (docs/Knowledge Base/Gotchas.md §2).
        {
            private _stream = _x;
            private _rec = GVAR(streamData) get _stream;
            if (!isNil "_rec") then {
                _rec set [0, (_rec select 0) select {(_x select 0) in _repHulls}];
            };
        } forEach _streams;
    };
}, SEL_POLL_INTERVAL, [false, false]] call CBA_fnc_addPerFrameHandler;
