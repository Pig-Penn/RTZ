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
 *   GVAR(selOverflow) — eligible units dropped by the cap, for the dialog header
 *
 * Subscription: one QGVAR(watch) event carrying all three slices plus the active
 * stream ids, sent only when the payload actually changes. The infantry slice is
 * consumer-gated through FUNC(setDemand) — reported only while some display has
 * asked for it, so an idle curator streams nothing — and a second demand flag for
 * the expensive per-unit intel rides along, since only a consumer that displays it
 * should make the server gather it (see rtz_hud's gatherUnitInfo).
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
        private _objs = SELECTED_OBJECTS;

        // A virtual Zeus (VirtualMan_F) has no real side — it is the game master,
        // not a PvP officer, so the own-side filter must not apply.
        private _anySide = player isKindOf "VirtualMan_F";
        private _curSide = side player;

        private _units = [];
        { if (_x isKindOf "CAManBase") then { _units pushBack _x } } forEach _objs;
        { if (_x isEqualType grpNull) then { _units append (units _x) } } forEach SELECTED_GROUPS;
        _units = _units arrayIntersect _units;

        // alive covers null too, and every entry is already a CAManBase (the
        // pushBack filter and the group expansion both guarantee it).
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
            && {_x isKindOf "AllVehicles"}
            && {!(_x isKindOf "CAManBase")}
            && {count crew _x > 0}
            && {_anySide || {VEH_SIDE_OK(_x,_curSide)}}
        }) apply {netId _x};
        _vehOverflow = 0 max ((count _vehs) - SEL_MAX_VEHICLES);
        _vehs = _vehs select [0, SEL_MAX_VEHICLES];

        // Hull set for the AI-state overlays: the raw selection collapsed to
        // distinct vehicles. Deliberately NOT side-filtered or capped — these
        // overlays report what the curator's own selection is doing, and the
        // server re-resolves whoever steers/aims each hull anyway.
        {
            if (!isNull _x) then { _hulls pushBackUnique (vehicle _x) };
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
    // Infantry is consumer-gated: reported only while some display has asked for
    // it through FUNC(setDemand), and the "detailed" flag — which gates the two
    // expensive server reads — only while a consumer asks for that too. The other
    // slices are not gated here: a vehicle card is expected the instant a vehicle
    // is selected, and the overlays are already gated by being switched on at all
    // (GVAR(activeStreams)).
    //
    // A registry, not two reads of rtz_hud's display globals. That is what this
    // used to be, and it is why the engine could not be separated from that one
    // component; it also had to be spelled GETGVAR rather than a bare read,
    // because a nil from a display that had not initialised yet would abort the
    // rest of this handler — the whole subscription — rather than read false
    // (docs/Knowledge Base/Gotchas.md §2). Demand entries only exist once set, so there is
    // nothing to read defensively.
    private _wantUnits = false;
    private _detailed  = false;
    {
        _y params ["_u", "_d"];
        if (_u) then { _wantUnits = true };
        if (_d) then { _detailed  = true };
    } forEach GVAR(demands);

    private _streams = GVAR(activeStreams);

    // Empty out the slices no active consumer wants, so the server neither
    // gathers nor sends them. An entirely empty payload unsubscribes.
    private _repUnits = [[], _ids] select _wantUnits;
    private _repHulls = [[], _hulls] select (_streams isNotEqualTo []);

    private _report = [_repUnits, _vehs, _repHulls, _streams, _detailed];
    if (_report isEqualTo GVAR(reported)) exitWith {};
    GVAR(reported) = _report;

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
    if (_vehs isEqualTo [])     then { [SRC_VEHS]  call _fnc_clearSlice };

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
                _rec set [0, (_rec select 0) select {(_x select 0) in _hulls}];
            };
        } forEach _streams;
    };
}, SEL_POLL_INTERVAL, [false, false]] call CBA_fnc_addPerFrameHandler;
