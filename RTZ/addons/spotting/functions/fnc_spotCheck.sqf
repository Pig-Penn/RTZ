#include "script_component.hpp"
/*
 * Author: Maxim
 * One full server-side spot-detection pass. Called on interval by the CBA
 * perFrameHandler registered in FUNC(spottingSystem); runs unscheduled.
 *
 * Performance architecture:
 *  - Target knowledge in Arma is stored PER GROUP (every member's knowsAbout returns
 *    the group's value), so the server queries ONE representative unit per local AI
 *    group instead of every unit — the knowsAbout matrix shrinks from units x hostiles
 *    to groups x hostiles.
 *  - All units + vehicles are classified into per-side buckets once per tick;
 *    curators on the same side share one detection pass.
 *  - The knowledge matrix is INVERTED via the `targets` command: one engine call
 *    per spotter group returns every enemy that group already has on its target
 *    list (the same group-level store knowsAbout reads), so the per-member
 *    knowsAbout loop only runs over the groups that actually know the member —
 *    O(spotterGroups + contacts) instead of O(spotterGroups × hostiles).
 *  - spotDetected is only sent when the rendered payload actually changes. The change
 *    signature embeds the destination player's netId, so a rejoined player (new player
 *    object) forces a one-shot full re-send with no JIP machinery. Clients additionally
 *    request a resync (QGVAR(spotResync)) once their handlers are registered, closing
 *    the "event sent before the client registered" race.
 *  - Per-class config lookups (display names, NCO/HQ name tests, NATO symbol
 *    suffixes) are cached for the whole mission; chevron colours/names are
 *    pre-resolved server-side and shipped in the payload so the client Draw3D
 *    does no config or group traversal per frame.
 *  - Once a member's knowsAbout crosses HARD_THRESHOLD (its chevron is shown),
 *    that result is latched per (spotter side, unit) for CHEVRON_LATCH_DURATION
 *    seconds: the per-spotter knowsAbout loop — the O(spotterReps) part of this
 *    pass — is skipped entirely for that unit while the latch is live, and its
 *    contribution to the group's aggregate knowledge is assumed unchanged. This
 *    trades a short (10s) lag in noticing a spotted unit go fully unknown again
 *    for not re-running the expensive check on every already-confirmed contact
 *    every tick.
 *
 * Tunables (GROUP_CALLOUT_COOLDOWN, SOFT/HARD_THRESHOLD, MKR_PREFIX,
 * WEDGE_TEXTURE, WEDGE_ALPHA) are #defined in script_component.hpp.
 *
 * Arguments:
 * 0: Active-spots map, spotKey → [markerName, spotterPlayer, payloadSignature] — mutated <HASHMAP>
 *    spotKey = "s_"/"w_" + (netId spottedUnit/leader) + "_" + (netId spotterCurator)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_activeSpots] call rtz_spotting_fnc_spotCheck
 *
 * Public: No
 */

params ["_activeSpots"];

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
//                   (alive, non-player; locality NOT filtered: knowsAbout only
//                   requires the SPOTTER to be local, and targets may sit on a
//                   client, e.g. under curator remote control).
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
// Men and vehicles are looped separately — allUnits is alive-only and all
// CAManBase, so the men's loop needs no alive/kind checks and no merged array
// is allocated. Buckets are fetched with get + isNil (not getOrDefault) so the
// default array/hashmap isn't allocated per entity on the hit path. Units with
// simulation disabled are skipped entirely — neither spottable (they present
// no meaningful target) nor usable as a spotter rep.
private _sideEntities    = createHashMap;
private _sideSpotterReps = createHashMap;
{
    if (isPlayer _x) then { continue };
    if (!simulationEnabled _x) then { continue };
    private _eSide  = side _x;
    private _sk     = str _eSide;
    private _bucket = _sideEntities get _sk;
    if (isNil "_bucket") then {
        _bucket = [_eSide, []];
        _sideEntities set [_sk, _bucket];
    };
    (_bucket select 1) pushBack _x;

    if (local _x && { !isNull group _x }) then {
        private _reps = _sideSpotterReps get _sk;
        if (isNil "_reps") then {
            _reps = createHashMap;
            _sideSpotterReps set [_sk, _reps];
        };
        _reps set [netId group _x, _x];
    };
} forEach allUnits;

{
    if (!alive _x || { isPlayer _x }) then { continue };
    if (!simulationEnabled _x) then { continue };
    if !(_x isKindOf "LandVehicle"
        || { _x isKindOf "Air" }
        || { _x isKindOf "Ship" }) then { continue };
    private _eSide  = side _x;
    private _sk     = str _eSide;
    private _bucket = _sideEntities get _sk;
    if (isNil "_bucket") then {
        _bucket = [_eSide, []];
        _sideEntities set [_sk, _bucket];
    };
    (_bucket select 1) pushBack _x;

    if (local _x) then {
        private _rep = effectiveCommander _x;
        if (!isNull _rep && { !isPlayer _rep } && { !isNull group _rep }) then {
            private _reps = _sideSpotterReps get _sk;
            if (isNil "_reps") then {
                _reps = createHashMap;
                _sideSpotterReps set [_sk, _reps];
            };
            _reps set [netId group _rep, _rep];
        };
    };
} forEach vehicles;

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
    private _spotterSideStr = str _spotterSide;

    // One representative per local AI group on this side — the spotter set.
    private _spotterReps = values (_sideSpotterReps getOrDefault [_x, createHashMap]);
    if (_spotterReps isEqualTo []) then { continue };

    // ── Invert the knowledge matrix ───────────────────────────────────
    // `targets [true]` returns every enemy this rep's GROUP has on its target
    // list — anything with knowsAbout > 0, including stale/heard contacts, so
    // SOFT_THRESHOLD graduation below is unaffected. Building targetNetId →
    // [candidate reps] here means the member loop below runs knowsAbout only
    // against groups that genuinely know the member; every other rep×member
    // pair — the overwhelming majority on a big mission — is never touched.
    // Knowledge crosses the hull both ways (the engine's target list may carry
    // either object for a crewed vehicle, but knowsAbout answers for both): a
    // known enemy VEHICLE also credits its crew, and a known MAN who has since
    // mounted also credits his vehicle — the member loop below walks men and
    // hulls as separate entries.
    private _knownBy = createHashMap;
    {
        private _rep = _x;
        {
            (_knownBy getOrDefault [netId _x, [], true]) pushBack _rep;
            if (_x isKindOf "CAManBase") then {
                private _hull = objectParent _x;
                if (!isNull _hull) then {
                    (_knownBy getOrDefault [netId _hull, [], true]) pushBack _rep;
                };
            } else {
                { (_knownBy getOrDefault [netId _x, [], true]) pushBack _rep } forEach crew _x;
            };
        } forEach (_rep targets [true]);
    } forEach _spotterReps;

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
        private _gk    = netId _ldr;
        private _tuple = _grpMap get _gk;
        if (isNil "_tuple") then {
            _tuple = [_ldr, [], _gk];
            _grpMap set [_gk, _tuple];
        };
        (_tuple select 1) pushBack _x;
    } forEach _allHostile;

    // Side-level new contact accumulation: one callout per tick fires to all
    // curators on this side when any of them newly spots a group.
    private _sideNewReport = [objNull, [], []];

    {
        _x params ["_leader", "_members", "_leaderNetId"];

        // The group leader is not necessarily a SPOTTABLE entity: _allHostile
        // excludes players and simulation-disabled units, but grouping above keys
        // on `leader group`, so an AI squad led by a player reports the PLAYER as
        // its leader. Anchoring the group icon on him would track a player's exact
        // position for the enemy Zeus every frame (and seed the callout's location
        // lookup) — precisely what the isPlayer filter exists to prevent, and not
        // something his chevron-less members ever reveal. Fall back to a member that
        // genuinely is spotted. _leaderNetId keeps the ORIGINAL leader's netId as the
        // group key, so chevron→group association (the hover peek in FUNC(draw3D))
        // and the callout cooldown are unaffected.
        if !(_leader in _members) then { _leader = _members select 0 };

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
            private _memberId = netId _member;
            // Sticky chevron latch: a member that crossed HARD_THRESHOLD recently
            // skips the knowsAbout loop entirely for CHEVRON_LATCH_DURATION seconds —
            // that per-spotter loop is the expensive part of this pass, and a unit
            // just confirmed spotted is assumed still known for a short memory window
            // rather than re-verified every tick.
            // The latched spotter must still be alive: it is reused below as the
            // group's callout author (_grpReporter), and a dead unit cannot
            // sideChat — the report would be consumed by the cooldown and never
            // heard. A dead latch falls through to the full knowsAbout scan,
            // which only ever draws from the live _spotterReps.
            private _latchKey = _spotterSideStr + "_" + _memberId;
            private _latch    = GVAR(chevronLatch) get _latchKey;
            private _uKnows = 0;
            private _uBest  = objNull;
            if (!isNil "_latch" && { (_latch select 0) > CBA_missionTime } && { alive (_latch select 1) }) then {
                _uKnows = HARD_THRESHOLD;
                _uBest  = _latch select 1;
            } else {
                // Only reps whose group has this member (or its hull) on their
                // target list can score above zero — everyone else is skipped.
                {
                    private _k = _x knowsAbout _member;
                    if (_k > _uKnows) then { _uKnows = _k; _uBest = _x; };
                } forEach (_knownBy getOrDefault [_memberId, []]);
                if (_uKnows >= HARD_THRESHOLD) then {
                    GVAR(chevronLatch) set [_latchKey, [CBA_missionTime + CHEVRON_LATCH_DURATION, _uBest]];
                };
            };
            if (_uKnows > _groupKnows) then { _groupKnows = _uKnows; _grpReporter = _uBest; };
            if (_uKnows >= HARD_THRESHOLD && { _member isKindOf "CAManBase" }) then {
                _chevrons pushBack [_member, _memberId];
            };
        } forEach _members;

        // Nothing known about this group → no icon and (since chevrons need a
        // higher bar than the group) no chevrons either.
        if (_groupKnows < SOFT_THRESHOLD) then { continue };

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
            private _wedgeColor = [_base#0, _base#1, _base#2, WEDGE_ALPHA];
            // Incapacitated (BIS revive / setUnconscious) overrides → civilian-purple chevron.
            if (lifeState _member isEqualTo "INCAPACITATED") then {
                _wedgeColor = COLOR_INCAPACITATED;
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
                [MKR_PREFIX + _leaderKey, _leader, _leaderTex, _mrkrColor, true, _echelonTex, _sideIdx, _leaderNetId, ""],
                _grpBaseSig + _playerId,
                _player, _activeSpots, _drawGroup, _forceResend
            ] call FUNC(emitSpot);

            // Chevrons: one per individual the team knows well (knowsAbout the unit).
            {
                _x params ["_member", "_memberId", "_wedgeColor", "_memberName", "_zoneRadius", "_wedgeBaseSig"];
                private _wedgeKey  = "w_" + _memberId + "_" + _curId;
                private _wedgeMrkr = MKR_PREFIX + _wedgeKey;
                _currentKeys set [_wedgeKey, true];
                [
                    _wedgeKey,
                    [_wedgeMrkr, _member, WEDGE_TEXTURE, _wedgeColor, false, "", _sideIdx, _leaderNetId, _memberName, _zoneRadius],
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
        if (_groupKnows >= HARD_THRESHOLD) then {
            private _sideGroupKey = str _spotterSide + "_" + _leaderNetId;
            if (CBA_missionTime - (GVAR(spotGroupCooldowns) getOrDefault [_sideGroupKey, -1e10]) >= GROUP_CALLOUT_COOLDOWN) then {
                GVAR(spotGroupCooldowns) set [_sideGroupKey, CBA_missionTime];
                (_sideNewReport select 1) pushBackUnique ([_leader] call FUNC(contactCategory));
                // Claim the author slot while it is still unfilled OR holds a unit
                // that has since died (alive objNull is false, so this covers both).
                // Testing `alive` rather than `isNull` keeps one group's casualty
                // from poisoning the whole side's report: a later group with a live
                // spotter takes the slot over, and the position follows the author
                // so the callout always names the group it came from.
                if (!alive (_sideNewReport select 0) && { alive _grpReporter }) then {
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
    // alive, not just !isNull: a corpse is a valid object but sideChat on it is
    // silent, and the per-group cooldown has already been consumed by now.
    if (_reportCats isNotEqualTo [] && { alive _reporter }) then {
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
if (count GVAR(blinkThrottle) > BLINK_THROTTLE_CAP) then {
    private _cutoff = CBA_missionTime - BLINK_THROTTLE_WINDOW;   // blink throttle window is FIRE_BLINK_THROTTLE — anything older is dead weight
    private _old = [];
    { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(blinkThrottle);
    { GVAR(blinkThrottle) deleteAt _x } forEach _old;
};
if (count GVAR(spotGroupCooldowns) > SPOT_COOLDOWN_CAP) then {
    private _cutoff = CBA_missionTime - GROUP_CALLOUT_COOLDOWN;   // expired cooldowns re-fire anyway
    private _old = [];
    { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(spotGroupCooldowns);
    { GVAR(spotGroupCooldowns) deleteAt _x } forEach _old;
};
if (count GVAR(chevronLatch) > CHEVRON_LATCH_CAP) then {
    private _old = [];
    { if ((_y select 0) < CBA_missionTime) then { _old pushBack _x } } forEach GVAR(chevronLatch);   // already-expired latches are dead weight
    { GVAR(chevronLatch) deleteAt _x } forEach _old;
};
