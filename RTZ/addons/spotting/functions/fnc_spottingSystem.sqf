#include "script_component.hpp"
/*
 * rtz_fnc_spottingSystem
 *
 * Tracks when one curator's AI units visually detect any hostile units in the mission.
 * Each spotting Zeus sees 3D world icons (drawIcon3D) above detected enemies
 * in the Zeus cursor view. On first contact the spotting group radios a
 * side-channel contact report to the spotting Zeus.
 *
 * Entry point + server detection loop. The pieces live in:
 *   FUNC(spottingClient) — per-player icon stores, Draw3D renderer, event
 *                          receivers, resync request, officer-zone toggle
 *   FUNC(unitMarker)     — NATO symbol classification for a group leader
 *   FUNC(echelonTex)     — echelon/size amplifier texture
 *   FUNC(emitSpot)       — signature-gated spotDetected/spotLost send
 *
 * Performance architecture:
 *  - Target knowledge in Arma is stored PER GROUP (every member's knowsAbout returns
 *    the group's value), so the server queries ONE representative unit per local AI
 *    group instead of every unit — the knowsAbout matrix shrinks from units x hostiles
 *    to groups x hostiles.
 *  - All units + vehicles are classified into per-side buckets in a single pass per
 *    tick; curators on the same side share one detection pass.
 *  - spotDetected is only sent when the rendered payload actually changes. The change
 *    signature embeds the destination player's netId, so a rejoined player (new player
 *    object) forces a one-shot full re-send with no JIP machinery. Clients additionally
 *    request a resync (QGVAR(spotResync)) once their handlers are registered, closing
 *    the "event sent before the client registered" race.
 *  - Per-class config lookups (display names, NCO/HQ name tests) are cached for the
 *    whole mission; chevron colours/names are pre-resolved server-side and shipped in
 *    the payload so the client Draw3D does no config or group traversal per frame.
 *
 * Requirements: CBA_A3
 * Loading: spawned by XEH_postInit once CBA settings initialize. Self-guards locality —
 * a hasInterface client block, then `if (!isServer) exitWith {}` before the server loop.
 */

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — register event handlers
// Runs on every machine with a screen: MP clients, listen-server host,
// and singleplayer (where isServer and hasInterface are both true).
// Guarded here, at the fork — FUNC(spottingClient) carries no guard of its own.
// ─────────────────────────────────────────────────────────────────────────────
if (hasInterface) then {
    call FUNC(spottingClient);
};

if (!isServer) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — configuration
// ─────────────────────────────────────────────────────────────────────────────

// Seconds between full spot-check passes comes from the CBA setting
// QGVAR(spotCheckInterval) (default 3), read live each loop so admins can retune
// a running mission.
private _GROUP_CALLOUT_COOLDOWN  = 600;  // Seconds before re-alerting about the same group after contact is lost.
private _SOFT_THRESHOLD  = 1.0;  // knowsAbout >= this → NATO marker above squad leader (heard).
private _HARD_THRESHOLD  = 1.5;  // knowsAbout >= this → wedge marker above individual (visually confirmed).
private _MKR_PREFIX      = "rtz_spot_";
private _WEDGE_TEXTURE   = "\a3\ui_f\data\gui\rsc\RscDisplayEGSpectator\UnitIcon_ca.paa";
private _WEDGE_ALPHA     = 0.60; // Base alpha of individual chevrons (distance fade multiplies on top). Group icons unaffected.

// Human-readable contact category for radio reports — "infantry", "armor", etc.
// Returns a mass/plural noun so it reads cleanly as "Enemy <x> spotted".
private _fnc_contactCategory = {
    params ["_unit"];
    private _veh = vehicle _unit;
    if (_veh isKindOf "Air")                                      exitWith { "aircraft" };
    if (_veh isKindOf "Ship" || { _veh isKindOf "Submarine" })    exitWith { "naval units" };
    if (_veh isKindOf "Tank")                                     exitWith { "armor" };
    if (_veh isKindOf "LandVehicle" && { _veh != _unit })         exitWith { "vehicles" };
    "infantry"
};

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — state
// ─────────────────────────────────────────────────────────────────────────────

// Active spots: spotKey → [markerName, spotterPlayer, payloadSignature]
// spotKey = "s_"/"w_" + (netId spottedUnit/leader) + "_" + (netId spotterCurator)
// payloadSignature is a string of the display params last sent to the client
// (including the destination player's netId); spotDetected is re-sent only when it
// changes, so steady-state ticks cost zero network messages per unchanged spot.
private _activeSpots = createHashMap;

// Per-class display-name / NCO / HQ info comes from the shared mission-wide
// cache EFUNC(common,classInfo) — each class pays the config lookup exactly once.

// Force a full re-send of every active spot on the next tick. Starts true (first tick
// sends everything as new anyway); set again by QGVAR(spotResync), which each client
// fires once its event handlers are registered — closing the JIP race where a
// sig-gated send happened before the client could listen.
GVAR(spotForceResend) = true;
[QGVAR(spotResync), { GVAR(spotForceResend) = true }] call CBA_fnc_addEventHandler;

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — fire-blink (white flash on the wedge when a spotted unit shoots)
// ─────────────────────────────────────────────────────────────────────────────
// Rebuilt every tick: netId(spottedUnit) → [[wedgeMarker, spotterPlayer], …] for
// units currently wedge-spotted. The FiredMan handler reads it to know who, if
// anyone, is watching the shooter. Globals (not private) so the handler can see them.
GVAR(wedgeByUnit)        = createHashMap;
GVAR(blinkThrottle)      = createHashMap;   // netId → last blink-send time (rate limiter)
GVAR(spotGroupCooldowns) = createHashMap;   // (sideStr + "_" + leaderNetId) → time of last callout
GVAR(spotDebugLast)      = createHashMap;   // curatorNetId → last-logged resolution sig (diagnostic, on-change only)

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
    if (_now - (GVAR(blinkThrottle) getOrDefault [_id, 0]) < 0.1) exitWith {};
    GVAR(blinkThrottle) set [_id, _now];
    {
        _x params ["_mrkr", "_player"];
        // The lookup is rebuilt only once per check interval — the player may have
        // disconnected since; a null targetEvent destination would error.
        if (!isNull _player) then {
            [QGVAR(blink), [_mrkr], _player] call CBA_fnc_targetEvent;
        };
    } forEach _spotters;
}, true, []] call CBA_fnc_addClassEventHandler;

// ─────────────────────────────────────────────────────────────────────────────
// SERVER — main detection loop
// ─────────────────────────────────────────────────────────────────────────────

while { true } do {
    // Rebuild the fire-blink lookup from scratch each tick; the wedge block below
    // repopulates it for units that are still wedge-spotted.
    GVAR(wedgeByUnit) = createHashMap;

    // Consume the pending force-resend flag (set at start and by client resyncs).
    private _forceResend = GVAR(spotForceResend);
    GVAR(spotForceResend) = false;

    // Curator logic modules are not units — alive always returns true even after
    // the module is removed. Use !isNull to detect genuinely deleted curators.
    private _curators = allCurators select { !isNull _x };

    // Diagnostic toggle, read once per tick. When on, each curator's resolution is
    // logged the first time it changes — this is THE check for "does the server
    // resolve joined/JIP clients' curators to a targetable player?". A curator that
    // logs player=<NULL>/owner=-1, or never logs at all, is being silently skipped.
    private _dbg = GETMVAR(RTZ_debug,false);

    // Officer editing-area zone radii (officerNetId → radius), published by
    // rtz_officer (see fnc_officerAreaApply) — a plain cross-addon global, not
    // a GVAR, since rtz_spotting has no dependency on rtz_officer. Read once per
    // tick (not per member) and looked up per already-iterated chevron below;
    // defaults to an empty map when rtz_officer isn't loaded or its zoning
    // system is off, so this costs one hashmap read and is otherwise a no-op.
    private _officerZoneRadii = GETMVAR(RTZ_officerZoneRadiusMap,createHashMap);

    // ── Classify every unit and vehicle ONCE per tick ────────────────────────
    // _sideEntities:    sideStr → [side, entities[]] — spottable hostile candidates
    //                   (alive, non-player, of a spottable kind; locality NOT filtered:
    //                   knowsAbout only requires the SPOTTER to be local, and targets
    //                   may sit on a client, e.g. under curator remote control).
    // _sideSpotterReps: sideStr → HashMap(group netId → representative unit).
    //                   Target knowledge is stored per GROUP, so one member answers
    //                   knowsAbout for the whole group; crewed vehicles are covered by
    //                   their effective commander (a vehicle's knowledge IS its crew
    //                   group's), and empty vehicles — which know nothing — drop out.
    //                   `local` keeps the knowsAbout source server-local and excludes
    //                   AI in player-led groups (local to that player's client), same
    //                   as the old per-unit filter. Spotter units are drawn from ALL
    //                   server-local AI (not just curatorEditableObjects) so that
    //                   dynamically-spawned units from a late-joining curator are
    //                   never missed due to editable-object list lag.
    private _sideEntities    = createHashMap;
    private _sideSpotterReps = createHashMap;
    {
        private _e = _x;
        if (!alive _e || { isPlayer _e }) then { continue };
        if !(_e isKindOf "CAManBase"
            || { _e isKindOf "LandVehicle" }
            || { _e isKindOf "Air" }
            || { _e isKindOf "Ship" }) then { continue };
        private _eSide = side _e;
        private _sk    = str _eSide;
        ((_sideEntities getOrDefault [_sk, [_eSide, []], true]) select 1) pushBack _e;

        if (local _e) then {
            private _rep = if (_e isKindOf "CAManBase") then { _e } else { effectiveCommander _e };
            if (!isNull _rep && { !isPlayer _rep } && { !isNull group _rep }) then {
                (_sideSpotterReps getOrDefault [_sk, createHashMap, true]) set [netId group _rep, _rep];
            };
        };
    } forEach (allUnits + vehicles);

    // ── Group manned curators by side ─────────────────────────────────────────
    // Only manned curators can be spotters — a player object is required as the
    // CBA_fnc_targetEvent destination. Headless curators are skipped entirely.
    // Same-side curators share the same spotter pool and see the same hostiles, so
    // the entire knowsAbout matrix is computed once per side and emitted to each.
    // Tuple: [curator, player, playerNetId (signature part), curatorNetId (key part)].
    private _bySide = createHashMap;   // sideStr → [side, curatorTuples[]]
    {
        private _curator = _x;
        private _player  = getAssignedCuratorUnit _curator;

        if (_dbg) then {
            private _curatorSide = if (isNull _player) then { sideUnknown } else { side _player };
            private _repCount = count (_sideSpotterReps getOrDefault [str _curatorSide, createHashMap]);
            private _sig = format ["%1|%2|%3", _player, _curatorSide, _repCount];
            if (_sig != (GVAR(spotDebugLast) getOrDefault [netId _curator, ""])) then {
                GVAR(spotDebugLast) set [netId _curator, _sig];
                diag_log text format ["[RTZ] server curator %1: player=%2 owner=%3 side=%4 spotterGroups=%5",
                    netId _curator, _player, (if (isNull _player) then {-1} else {owner _player}), _curatorSide, _repCount];
            };
        };

        if (isNull _player) then { continue };
        private _curatorSide = side _player;
        ((_bySide getOrDefault [str _curatorSide, [_curatorSide, []], true]) select 1)
            pushBack [_curator, _player, netId _player, netId _curator];
    } forEach _curators;

    // HashMap used as a set for O(1) "is this spot still active?" checks.
    // Declared before the detection pass so the cleanup always runs, even when
    // there are no spotters this tick (all killed) — stale icons must be cleared.
    private _currentKeys = createHashMap;

    // ── Spot detection: one pass per curator side ─────────────────────────────
    {
        _y params ["_spotterSide", "_curatorsData"];

        // One representative per local AI group on this side — the spotter set.
        private _spotterReps = values (_sideSpotterReps getOrDefault [_x, createHashMap]);
        if (_spotterReps isEqualTo []) then { continue };

        // All alive, non-player entities hostile to this side: union of the
        // pre-bucketed sides whose relation to us is hostile.
        private _allHostile = [];
        {
            _y params ["_entSide", "_entities"];
            if ((_spotterSide getFriend _entSide) < 0.5) then { _allHostile append _entities };
        } forEach _sideEntities;
        if (_allHostile isEqualTo []) then { continue };

        // Group hostile units by their group leader.
        // Skip units whose group has no man leader (empty vehicles, ungrouped objects) —
        // leader group returns objNull for those, which would collapse them all to key "".
        private _grpMap = createHashMap;
        {
            private _ldr = leader group _x;
            if (isNull _ldr) then { continue };
            private _gk  = netId _ldr;
            ((_grpMap getOrDefault [_gk, [_ldr, [], _gk], true]) select 1) pushBack _x;
        } forEach _allHostile;

        // Side-level new contact accumulation: one callout per tick fires to all
        // curators on this side when any of them newly spots a group.
        private _sideNewReport = [objNull, [], []];

        {
            _x params ["_leader", "_members", "_leaderNetId"];

            // Team awareness, computed ONCE for all curators on this side, ONE
            // knowsAbout per (spotter group, member):
            //   _groupKnows — best knowsAbout across members (knows the GROUP) → group icon.
            //   _chevrons   — members known individually (knowsAbout the UNIT >= HARD) → chevron each.
            private _groupKnows  = 0;
            private _grpReporter = objNull;   // spotter unit that best knows this group
            private _chevrons    = [];        // [member, memberNetId]
            {
                private _member = _x;
                if !(alive _member) then { continue };
                private _uKnows = 0;
                private _uBest  = objNull;
                {
                    private _k = _x knowsAbout _member;
                    if (_k > _uKnows) then { _uKnows = _k; _uBest = _x; };
                } forEach _spotterReps;
                if (_uKnows > _groupKnows) then { _groupKnows = _uKnows; _grpReporter = _uBest; };
                if (_uKnows >= _HARD_THRESHOLD && { _member isKindOf "CAManBase" }) then {
                    _chevrons pushBack [_member, netId _member];
                };
            } forEach _members;

            // Nothing known about this group → no icon and (since chevrons need a
            // higher bar than the group) no chevrons either.
            if (_groupKnows < _SOFT_THRESHOLD) then { continue };

            // HQ: any member whose class display name says "officer" / "HQ" makes the
            // whole group a command element, so the group frame becomes the staff symbol.
            private _isHQ = -1 < _members findIf { ([_x] call EFUNC(common,classInfo)) select 2 };
            // Classify once per group; colour is the side colour, shared by the
            // group icon and every chevron below.
            ([_leader, _isHQ] call FUNC(unitMarker)) params ["_leaderTex", "_mrkrColor", "_sideIdx"];

            // Group icon. Drawn for groups of >1 member, OR whenever the leader is in a
            // vehicle (a single-crewed vehicle is still worth marking). A lone infantryman
            // shows no group icon — its members still chevron below.
            private _grpCount   = count _members;
            private _drawGroup  = (_grpCount > 1) || { !isNull objectParent _leader };
            private _echelonTex = [_leader, _grpCount] call FUNC(echelonTex);   // size amplifier
            private _grpBaseSig = str [_leaderTex, _mrkrColor, _echelonTex];

            // Chevron colour and display name — once per member, shared by every curator.
            private _chevronData = _chevrons apply {
                _x params ["_member", "_memberId"];
                ([_member] call EFUNC(common,classInfo)) params ["_memberName", "_isLeaderName"];
                // NCOs — any unit whose class display name contains "leader" (Squad
                // Leader, Team Leader, …) — get the brighter "own-group" palette
                // (EFUNC(common,sideColor) leader variant) so leadership reads at a glance.
                private _base = if (_isLeaderName)
                    then { [side _member, true] call EFUNC(common,sideColor) }
                    else { _mrkrColor };
                private _wedgeColor = [_base#0, _base#1, _base#2, _WEDGE_ALPHA];
                // Incapacitated (BIS revive / setUnconscious) overrides → civilian-purple chevron.
                if (lifeState _member isEqualTo "INCAPACITATED") then {
                    _wedgeColor = [0.5, 0.0, 0.5, _WEDGE_ALPHA];
                };
                // Officer zone ring: 0 for the overwhelming majority (non-officers,
                // or officers with no active area) — one O(1) lookup, no extra pass.
                private _zoneRadius = _officerZoneRadii getOrDefault [_memberId, 0];
                [_member, _memberId, _wedgeColor, _memberName, _zoneRadius, str [_wedgeColor, _leaderNetId, _zoneRadius]]
            };

            // Emit to each curator on this side with their own spot key and target player.
            {
                _x params ["_curator", "_player", "_playerId", "_curId"];

                private _leaderKey = "s_" + _leaderNetId + "_" + _curId;
                _currentKeys set [_leaderKey, true];
                [
                    _leaderKey,
                    [_MKR_PREFIX + _leaderKey, _leader, _leaderTex, _mrkrColor, true, _echelonTex, _sideIdx, _leaderNetId, ""],
                    _grpBaseSig + _playerId,
                    _player, _activeSpots, _drawGroup, _forceResend
                ] call FUNC(emitSpot);

                // Chevrons: one per individual the team knows well (knowsAbout the unit).
                {
                    _x params ["_member", "_memberId", "_wedgeColor", "_memberName", "_zoneRadius", "_wedgeBaseSig"];
                    private _wedgeKey  = "w_" + _memberId + "_" + _curId;
                    private _wedgeMrkr = _MKR_PREFIX + _wedgeKey;
                    _currentKeys set [_wedgeKey, true];
                    [
                        _wedgeKey,
                        [_wedgeMrkr, _member, _WEDGE_TEXTURE, _wedgeColor, false, "", _sideIdx, _leaderNetId, _memberName, _zoneRadius],
                        _wedgeBaseSig + _playerId,
                        _player, _activeSpots, true, _forceResend
                    ] call FUNC(emitSpot);

                    // Register this wedge so the FiredMan handler can flash it white.
                    (GVAR(wedgeByUnit) getOrDefault [_memberId, [], true]) pushBack [_wedgeMrkr, _player];
                } forEach _chevronData;

            } forEach _curatorsData;

            // Radio callout fires when this group is positively identified — best
            // knowsAbout >= HARD, the engine's own "freshly spotted / confirmed" value —
            // gated once per contact by the per-group cooldown (keyed side+leader, and
            // seeded at -1e10 so a never-announced group fires immediately). Gating at
            // HARD rather than SOFT keeps "Contact!" to genuine sightings: the group icon
            // (SOFT) still appears for merely-heard/decaying contacts, but the audio
            // callout only sounds on confirmation, when the first chevron shows. The
            // cooldown — not new-spot detection — dedupes, so a contact that ramps up
            // gradually (1.0 → 1.5 over several ticks) still gets announced when it
            // crosses HARD, and re-announces after being lost and re-acquired.
            if (_groupKnows >= _HARD_THRESHOLD) then {
                private _sideGroupKey = str _spotterSide + "_" + _leaderNetId;
                if (time - (GVAR(spotGroupCooldowns) getOrDefault [_sideGroupKey, -1e10]) >= _GROUP_CALLOUT_COOLDOWN) then {
                    GVAR(spotGroupCooldowns) set [_sideGroupKey, time];
                    (_sideNewReport select 1) pushBackUnique ([_leader] call _fnc_contactCategory);
                    if (isNull (_sideNewReport select 0)) then {
                        // Representatives are always men (crew are represented by their
                        // effective commander), so the reporter can sideChat directly.
                        _sideNewReport set [0, _grpReporter];
                        _sideNewReport set [2, getPos _leader];
                    };
                };
            };

        } forEach (values _grpMap);

        // ── Notify all curators on this side of new contacts ──────────────
        // One call for the whole side: the location lookup and phrasing are
        // computed once, so same-side curators hear the identical report.
        _sideNewReport params ["_reporter", "_reportCats", "_contactPos"];
        if (_reportCats isNotEqualTo [] && { !isNull _reporter }) then {
            [_reporter, _reportCats, _curatorsData apply { _x select 1 }, _contactPos] call FUNC(spotCallout);
        };

    } forEach _bySide;

    // ── Cleanup: remove icons for spots that are no longer active ─────────
    // Always runs — even when no side produced spots this tick (all spotters dead),
    // _currentKeys is empty so every active spot is collected and cleared.
    // HashMap forEach: _x is the key (spotKey string), _y is the value (array).
    // _forEachIndex is only a sequential counter — never use it as the map key.
    private _toRemove = [];
    {
        if !(_x in _currentKeys) then { _toRemove pushBack _x; };
    } forEach _activeSpots;

    {
        private _spotData = _activeSpots get _x;
        _spotData params ["_mrkrName", "_spotterPlayer", "_spotSig"];
        // Don't re-send spotLost for entries already marked off — the client cleared
        // the icon when _draw = false first fired; a second event is a no-op but wastes
        // a targeted network message per stale-off entry per cleanup pass. The player
        // may have disconnected since the spot was emitted — skip null destinations.
        if (_spotSig != "_off_" && { !isNull _spotterPlayer }) then {
            [QGVAR(spotLost), [_mrkrName], _spotterPlayer] call CBA_fnc_targetEvent;
        };
        _activeSpots deleteAt _x;
    } forEach _toRemove;

    // ── Housekeeping: keep the long-lived rate-limit maps bounded ──────────
    // Entries for dead/deleted units would otherwise accumulate for the whole
    // mission. Collect-then-delete — never deleteAt inside a HashMap forEach.
    if (count GVAR(blinkThrottle) > 128) then {
        private _cutoff = CBA_missionTime - 5;   // blink throttle window is 0.1 s — anything older is dead weight
        private _old = [];
        { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(blinkThrottle);
        { GVAR(blinkThrottle) deleteAt _x } forEach _old;
    };
    if (count GVAR(spotGroupCooldowns) > 256) then {
        private _cutoff = time - _GROUP_CALLOUT_COOLDOWN;   // expired cooldowns re-fire anyway
        private _old = [];
        { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(spotGroupCooldowns);
        { GVAR(spotGroupCooldowns) deleteAt _x } forEach _old;
    };

    sleep ((GETGVAR(spotCheckInterval,3)) max 1);
};
