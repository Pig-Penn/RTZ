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
 *  - Manned curators are resolved FIRST; with none, the tick skips straight to
 *    icon cleanup. Otherwise all units + vehicles are classified into per-side,
 *    per-GROUP buckets once per tick (spotter reps only for sides that actually have a
 *    curator); curators on the same side share one detection pass. That whole
 *    once-per-tick pass lives in FUNC(collectSides).
 *  - NOTHING SIDE-INVARIANT IS COMPUTED IN THE PER-SIDE LOOP. Which group an entity is
 *    in, what symbol and colour that group takes, how many men it holds, what its
 *    echelon amplifier is, its members' netIds and what each member's chevron looks
 *    like are all facts about the SPOTTED, not about the observer — so they are
 *    resolved once per tick and read back by every later curator side.
 *    FUNC(collectSides) does the grouping; FUNC(groupInvariants) fills the per-group
 *    bundle lazily on first use; a tick-scoped memo covers the per-member chevron
 *    tuples. What stays per side is exactly what depends on the observer: the
 *    knowsAbout scores, which members cross the thresholds, the latch and callout
 *    state, and the anchor's officer zone.
 *  - The knowledge matrix is INVERTED via the `targets` command: one engine call
 *    per spotter group returns every enemy that group already has on its target
 *    list (the same group-level store knowsAbout reads), so the per-member
 *    knowsAbout loop only runs over the groups that actually know the member —
 *    O(spotterGroups + contacts) instead of O(spotterGroups × hostiles).
 *  - spotDetected is only sent when the rendered payload actually changes. The change
 *    signature embeds the destination player's netId, so a curator module handed to a
 *    DIFFERENT player re-sends on its own. It does NOT cover a rejoin into the same
 *    slot: Arma hands the returning player the same unit object, so the netId — and
 *    every signature built from it — compares equal and nothing re-sends. JIP and
 *    rejoin recovery therefore rest on the client's QGVAR(spotResync) request, fired
 *    once its handlers are registered; that same request closes the "event sent
 *    before the client registered" race. The request is held per-player in
 *    GVAR(spotResendPlayers) and retired only when that player resolves to a
 *    targetable curator, so it survives a mission that assigns the curator module
 *    some ticks after the client asked (see FUNC(spottingSystem)).
 *  - Per-class config lookups (display names, NCO/HQ name tests, NATO symbol
 *    suffixes) are cached for the whole mission; chevron colours/names are
 *    pre-resolved server-side and shipped in the payload so the client Draw3D
 *    does no config or group traversal per frame.
 *  - Hostile groups NO spotter has any knowledge of are skipped before their members
 *    are ever walked. `targets` above already answers "which entities does any spotter
 *    group know about", so the leader key of each is collected into _activeGroupKeys as
 *    that pass runs — plus the leader of every live chevron latch on this side. A group
 *    outside that set scores _groupKnows = 0, fails the SOFT_THRESHOLD test and produces
 *    nothing, so the skip is behaviour-identical BY CONSTRUCTION; what it saves is the
 *    whole per-member loop (alive + latch lookup, per man) for every enemy group
 *    currently out of contact, which on a 200-500 AI mission is most of them.
 *    The gate is applied by walking _activeGroupKeys — the small set — and looking each
 *    key up in the hostile sides' pre-built group maps, NOT by walking every hostile
 *    entity to rediscover that most of them are out of contact. The `leader group` +
 *    `netId` per entity that used to answer "which group is this hostile in" is gone
 *    from this pass entirely: it is not a question about the observer, so
 *    FUNC(collectSides) answers it once per tick in the loops already walking allUnits
 *    and vehicles.
 *  - Once a member's knowsAbout crosses HARD_THRESHOLD (its chevron is shown),
 *    that result is latched per (spotter side, unit) for CHEVRON_LATCH_DURATION
 *    seconds: the per-spotter knowsAbout loop — the O(spotterReps) part of this
 *    pass — is skipped entirely for that unit while the latch is live, and its
 *    contribution to the group's aggregate knowledge is assumed unchanged. This
 *    trades a short (10s) lag in noticing a spotted unit go fully unknown again
 *    for not re-running the expensive check on every already-confirmed contact
 *    every tick.
 *  - The latch and callout-gate stores are NESTED, side object → HashMap(netId → …),
 *    resolved once per curator side. They used to be flat maps under a
 *    (str side + "_" + netId) key built per member per tick — see the store comments in
 *    FUNC(spottingSystem) for why that had to go.
 *  - HOW OFTEN THE PER-SIDE LOOP REALLY REPEATS WORK, stated exactly because this
 *    comment used to get it wrong (it claimed "two to four times, with curators
 *    typically on opposing sides"). The loop runs once per manned-curator side, but each
 *    pass unions only the sides HOSTILE to that spotter, so a given entity is touched
 *    once per MANNED-CURATOR SIDE HOSTILE TO IT — not once per curator, and not once per
 *    curator side. A straight two-curator-side session therefore touched each entity
 *    exactly once and carried no multiplier at all; a third mutually hostile curator
 *    side makes it twice. Both figures assume a curator is actually manning that side:
 *    AI-only factions never appear in _bySide. That is the number any future
 *    optimisation here has to be weighed against.
 *  - Payload signatures are ARRAYS compared with isEqualTo, not `str` of the same.
 *    They exist purely to answer "did this payload change?", and building a string
 *    to answer it meant one throwaway allocation per group AND per chevron on every
 *    tick — the per-entity-per-tick `str` CLAUDE.md rules out — to express a
 *    comparison the array does natively. Note that ==/!= REJECT arrays outright in
 *    SQF, so every signature comparison must be isEqualTo (see SPOT_SIG_OFF).
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

// Profiling gate (EFUNC(core,perfSample)), read ONCE per pass. This is the largest
// server-side cost in the mod and the first thing anyone tuning it needs a number for;
// the counters gathered under this flag also separate "scales with unit count" from
// "scales with curator sides x hostiles", which is the question the shape of a drop
// turns on. Everything it guards is skipped outright when off.
private _perf = GETMVAR(RTZ_perf,false);
private _t0   = 0;
private _perfHostile  = 0;
private _perfGroups   = 0;
private _perfChevrons = 0;
if (_perf) then { _t0 = diag_tickTime };

// Rebuild the fire-blink lookup from scratch each tick; the wedge block below
// repopulates it for units that are still wedge-spotted — unless the blink is switched
// off, in which case the map stays empty for the tick and the FiredMan handler in
// FUNC(spottingSystem) finds nothing to send. The createHashMap itself is
// unconditional: it is one allocation per TICK, and leaving a stale map behind when the
// setting is flipped off mid-mission would keep flashing icons for units that have since
// stopped being spotted.
GVAR(wedgeByUnit) = createHashMap;
private _blink = GETGVAR(enableFireBlink,true);

// Consume the GLOBAL force-resend flag (set at mission start, and by any bare
// QGVAR(spotResync)). The per-player pending requests in GVAR(spotResendPlayers)
// are NOT consumed here — FUNC(collectSides) retires each one individually, at the
// moment its player resolves to a targetable curator, so a request that arrived before
// the mission assigned that curator's module survives until it can be honoured.
private _forceResend = GVAR(spotForceResend);
GVAR(spotForceResend) = false;

// Curator logic modules are not units — alive always returns true even after
// the module is removed. Use !isNull to detect genuinely deleted curators.
private _curators = allCurators select { !isNull _x };

// Diagnostic toggle, read once per tick. FUNC(collectSides) both logs under it and
// forces its classification pass to run when it is set, so the logged spotter-group
// count is real even with no curator resolved.
private _dbg = GETMVAR(RTZ_debug,false);

// One shared empty map / empty array for every "missing" fallback in this pass. SQF
// evaluates getVariable / getOrDefault arguments EAGERLY, so spelling `createHashMap` or
// `[]` inline allocated and immediately discarded one per call — on the array cases below
// that is once per member and once per chevron, every tick, which is exactly the kind of
// per-entity-per-tick allocation the rest of this component is written to avoid.
// Safe to share because every use only ever READS the result (a getOrDefault, a count, a
// values, an isNotEqualTo, or a verbatim ride along a network payload), so no caller can
// write into either sentinel. Treat both as strictly read-only.
private _emptyMap = createHashMap;
private _emptyArr = [];

// Officer editing-area zones (officerNetId → [plantedCenter, radius]),
// published by rtz_officer (see fnc_applyArea) — a plain cross-addon global,
// not a GVAR, since rtz_spotting has no dependency on rtz_officer. Read once
// per tick (not per member) and looked up per already-iterated chevron below;
// defaults to an empty map when rtz_officer isn't loaded or its zoning
// system is off, so this costs one hashmap read and is otherwise a no-op.
// The stored center is where the area was PLANTED — rtz_officer areas never
// move once placed (see EFUNC(officer,monitorAreas)) — so the ring the client
// draws from it marks the ground the enemy Zeus can actually edit, not
// wherever the officer has since wandered.
//
// The [center, radius] pairs read out of this map ride into the payload signatures
// below BY REFERENCE, so this pass depends on rtz_officer never mutating one in place.
// It does not: EFUNC(officer,applyArea) always `set`s a freshly built array and
// `deleteAt`s to clear it, so a re-plant produces a NEW array and the isEqualTo
// comparison in FUNC(emitSpot) sees the change. Were that ever to become an in-place
// write, every signature holding the pair would silently track the mutation, compare
// equal to itself, and the client's ring would never update — the one non-obvious
// invariant the array signatures rest on.
private _officerZones = GETMVAR(RTZ_officerZoneMap,_emptyMap);

// ── The tick's side picture ───────────────────────────────────────────────
// Manned curators grouped by side, hostile candidates bucketed by side, and one
// representative spotter per local AI group on each side that has a curator. All three
// maps are keyed on the SIDE OBJECT — see FUNC(collectSides) for why that matters.
([_curators, _forceResend, _dbg] call FUNC(collectSides))
    params ["_bySide", "_sideEntities", "_sideSpotterReps"];

// HashMap used as a set for O(1) "is this spot still active?" checks.
// Declared before the detection pass so the cleanup always runs, even when
// there are no spotters this tick (all killed) — stale icons must be cleared.
private _currentKeys = createHashMap;

// memberNetId → that member's finished chevron tuple, for THIS TICK only. A chevron's
// look is a property of the spotted man, so a member visible to two hostile curator
// sides is built once instead of once each. Scoped to the pass and dropped with it, so
// unlike the mission-lifetime stores it needs no entry in FUNC(pruneStores).
private _chevronMemo = createHashMap;

// ── Spot detection: one pass per curator side ─────────────────────────────
// _x = the side (HashMap key); _y = that side's curator tuples.
{
    private _spotterSide  = _x;
    private _curatorsData = _y;

    // One representative per local AI group on this side — the spotter set.
    private _spotterReps = values (_sideSpotterReps getOrDefault [_spotterSide, _emptyMap]);
    if (_spotterReps isEqualTo []) then { continue };

    // This side's two inner stores, resolved ONCE here rather than by building a
    // composite key per member below (see FUNC(spottingSystem)'s store comments). Both
    // are created on first touch and live for the mission — FUNC(pruneStores) bounds
    // them per side.
    // get + isNil, not getOrDefault with a createHashMap default: SQF evaluates that
    // default EAGERLY, so it would allocate and discard a fresh map on every hit. Same
    // reasoning as the bucket lookups in FUNC(collectSides).
    // AFTER the spotter test, not before: a side with no living AI to see with can never
    // write to either store, and creating them anyway would leave an empty map that the
    // prune's cap gate — a `count > CAP` test — can by definition never collect.
    private _latchMap = GVAR(chevronLatch) get _spotterSide;
    if (isNil "_latchMap") then {
        _latchMap = createHashMap;
        GVAR(chevronLatch) set [_spotterSide, _latchMap];
    };
    private _lastSeenMap = GVAR(spotGroupLastSeen) get _spotterSide;
    if (isNil "_lastSeenMap") then {
        _lastSeenMap = createHashMap;
        GVAR(spotGroupLastSeen) set [_spotterSide, _lastSeenMap];
    };

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
    // pushBackUnique, not pushBack: that cross-crediting means one rep can reach
    // the same entry by two routes (its target list holding both a crewed vehicle
    // AND one of its occupants), and a duplicate rep only re-runs the knowsAbout
    // test below for a group that has already answered. The lists hold just the
    // groups that know the entry, so the uniqueness scan is over a handful.
    // _activeGroupKeys rides along: the leader netId of every entity any spotter knows
    // about. It is the "is this group in contact at all?" gate for the grouping walk
    // below, and it is built HERE because this loop already holds the target OBJECTS —
    // deriving it later from _knownBy's keys would mean an objectFromNetId per entry.
    // Recorded for the hull and crew cross-credits too, not just the target itself: they
    // are what put a mounted man (or a UAV's absent crew) into _knownBy, and a group
    // reachable only by that route must not be gated out.
    private _knownBy         = createHashMap;
    private _activeGroupKeys = createHashMap;
    {
        private _rep = _x;
        {
            private _tgt = _x;
            (_knownBy getOrDefault [netId _tgt, [], true]) pushBackUnique _rep;
            private _tgtLdr = leader group _tgt;
            if (!isNull _tgtLdr) then { _activeGroupKeys set [netId _tgtLdr, true] };

            if (_tgt isKindOf "CAManBase") then {
                private _hull = objectParent _tgt;
                if (!isNull _hull) then {
                    (_knownBy getOrDefault [netId _hull, [], true]) pushBackUnique _rep;
                    private _hullLdr = leader group _hull;
                    if (!isNull _hullLdr) then { _activeGroupKeys set [netId _hullLdr, true] };
                };
            } else {
                {
                    (_knownBy getOrDefault [netId _x, [], true]) pushBackUnique _rep;
                    private _crewLdr = leader group _x;
                    if (!isNull _crewLdr) then { _activeGroupKeys set [netId _crewLdr, true] };
                } forEach crew _tgt;
            };
        } forEach (_rep targets [true]);
    } forEach _spotterReps;

    // Union in the group of every LIVE chevron latch on this side. Belt and braces: the
    // latch fires at HARD_THRESHOLD and lasts CHEVRON_LATCH_DURATION (10 s), while
    // `targets [true]` returns anything with knowsAbout > 0 at all, so a latched member
    // falling out of every target list inside that window is close to impossible — but
    // if it did, its group would be gated out and its chevron would vanish early, which
    // is a visible regression rather than the invisible one the gate is allowed. The
    // walk is over THIS SIDE's confirmed contacts (the inner map), not over every side's.
    // A stale leaderNetId — the leader died and the group re-formed inside the window —
    // simply matches no bucket below, and the group is rebuilt from _knownBy on the next
    // pass exactly as it is today.
    {
        if ((_y select 0) > CBA_missionTime) then { _activeGroupKeys set [_y select 2, true] };
    } forEach _latchMap;

    // The group maps of every side hostile to us, pre-built once per tick by
    // FUNC(collectSides) (GRP_* in script_component.hpp).
    private _hostileGroups = [];
    {
        if ((_spotterSide getFriend _x) < 0.5) then { _hostileGroups pushBack _y };
    } forEach _sideEntities;
    if (_hostileGroups isEqualTo []) then { continue };

    // ── Select the groups in contact ──────────────────────────────────────
    // The contact gate is applied at GROUP granularity, by walking the (small) set of
    // groups some spotter knows about and looking each key up, instead of walking every
    // hostile ENTITY to rediscover that most of them are out of contact. Groups nobody
    // knows anything about used to be bucketed and then have EVERY member walked
    // (alive, netId, latch lookup) only to score _groupKnows = 0 and produce nothing.
    // `_activeGroupKeys` holds exactly the groups that can score above zero, so the
    // output is identical by construction.
    //
    // The `leader group` + `netId` per hostile entity that used to run here is gone
    // entirely: it is not a question about the observer, so FUNC(collectSides) answers
    // it once per tick in the loops already walking allUnits and vehicles. It was paid
    // once per manned-curator side hostile to the entity — once in a two-curator-side
    // session, twice with a third mutually hostile curator side.
    //
    // ALIAS THE KEY: the inner loop rebinds _x to a side's group map (docs/Knowledge
    // Base/Gotchas.md §2).
    private _groups   = [];
    private _seenKeys = createHashMap;
    {
        private _gk = _x;
        {
            private _tuple = _x get _gk;
            if (isNil "_tuple") then { continue };

            private _prevIdx = _seenKeys get _gk;
            if (isNil "_prevIdx") then {
                _seenKeys set [_gk, count _groups];
                _groups pushBack _tuple;
                continue;
            };

            // Same group reached through TWO hostile side buckets. Real, not defensive:
            // `setCaptive true` (EFUNC(captive,surrenderApply)) makes `side` answer
            // civilian while `group` still answers the unit's real group, so a
            // surrendered man sits in the civilian bucket under his squad's key. The
            // flat union this replaced merged them implicitly; without this a squad with
            // one surrendered member would draw as TWO groups with different anchors,
            // but only for a spotter hostile to both buckets.
            //
            // A NEW tuple, never an in-place append: these tuples are shared across
            // curator sides within the tick, so mutating one would leak this side's
            // merged member list into every later side's pass. GRP_INV resets to []
            // because a different member list is a different anchor, HQ test, men count
            // and echelon amplifier.
            private _prev = _groups select _prevIdx;
            _groups set [_prevIdx, [
                _prev select GRP_LEADER,
                (_prev select GRP_MEMBERS) + (_tuple select GRP_MEMBERS),
                _gk,
                (_prev select GRP_MEN) + (_tuple select GRP_MEN),
                (_prev select GRP_LDRIN) || {_tuple select GRP_LDRIN},
                []
            ]];
        } forEach _hostileGroups;
    } forEach _activeGroupKeys;

    if (_perf) then {
        // `hostile` still means "spottable entities hostile to this side", but it is now
        // summed off the group buckets rather than off a flat union that no longer
        // exists. Same population: everything in a bucket reached it through a group.
        { { _perfHostile = _perfHostile + count (_y select GRP_MEMBERS) } forEach _x } forEach _hostileGroups;
        _perfGroups = _perfGroups + count _groups;
    };

    // Side-level new contact accumulation: one callout per tick fires to all
    // curators on this side when any of them newly spots a group.
    private _sideNewReport = [objNull, [], []];

    {
        private _tuple = _x;
        _tuple params ["", "_members", "_leaderNetId"];

        // ── Side-invariant render facts, resolved at most once per group per TICK ──
        // The anchor resolution, the HQ test, the men count, the NATO symbol, the
        // colour, the echelon amplifier and every member's netId are facts about the
        // spotted group, not about who is looking at it — yet all of them used to be
        // recomputed inside this loop for every curator side that could see the group.
        // FUNC(groupInvariants) answers them once and the tuple carries the answer.
        //
        // The `set` is the ONE sanctioned in-place mutation of a shared tuple: it is an
        // idempotent memo fill, so two sides racing to it (they cannot — this is one
        // unscheduled pass) would write the same bundle. Everything else about a tuple
        // is read-only, because the next curator side is looking at the same array.
        private _inv = _tuple select GRP_INV;
        if (_inv isEqualTo []) then {
            _inv = [_tuple] call FUNC(groupInvariants);
            _tuple set [GRP_INV, _inv];
        };
        _inv params [
            "_leader", "_anchorId", "_leaderTex", "_mrkrColor",
            "_sideIdx", "_echelonTex", "_drawGroup", "_memberIds"
        ];

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
            // Parallel to _members and resolved with the group's other invariants — a
            // netId is fixed for the life of the object, and this used to be an engine
            // call per alive member per curator side.
            private _memberId = _memberIds select _forEachIndex;
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
            // Bare get/set on this side's inner map — no key to build. The stored
            // leaderNetId is what the contact gate above reads; it is this group's key,
            // which is in hand here and nowhere cheaper.
            private _latch  = _latchMap get _memberId;
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
                } forEach (_knownBy getOrDefault [_memberId, _emptyArr]);
                if (_uKnows >= HARD_THRESHOLD) then {
                    _latchMap set [_memberId, [CBA_missionTime + CHEVRON_LATCH_DURATION, _uBest, _leaderNetId]];
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

        // The anchor is the man the group icon is drawn over — FUNC(drawSpots) hangs
        // it directly above him and stems it back down to his body — so his own
        // chevron is a second marker on the same soldier. Drop it.
        //
        // Gated on _drawGroup because that is the flag deciding whether the group icon
        // is drawn at all: a lone infantryman, or a squad worn down to one survivor,
        // gets no group icon, and his chevron is then the ONLY thing marking him.
        //
        // His officer zone moves onto the group payload rather than dying with the
        // chevron. The [plantedCenter, radius] pair has only ever ridden the WEDGE
        // payload, so a silently dropped chevron would take an enemy officer's
        // editing-area ring off the Zeus map — and an officer leading his own squad is
        // the ordinary case, not an edge one. Read only when a chevron was actually
        // dropped: an anchor the spotters have not individually identified never had a
        // chevron, so never had a ring to keep.
        private _anchorZone = _emptyArr;
        if (_drawGroup) then {
            private _anchorIdx = _chevrons findIf { (_x select 1) isEqualTo _anchorId };
            if (_anchorIdx > -1) then {
                _chevrons deleteAt _anchorIdx;
                _anchorZone = _officerZones getOrDefault [_anchorId, _emptyArr];
            };
        };

        // The anchor's netId is part of the signature, not just of the spot KEY: the
        // key carries the ORIGINAL leader's netId, while the anchor sent to the client
        // can be a fallback member (see above) that changes as members die. Without it
        // the change-gated send in FUNC(emitSpot) never fires for that swap, and the
        // client keeps drawing on a stale object — whose !alive test then hides the
        // icon of a group that is still very much spotted. _anchorZone rides the
        // signature for the same reason the wedge signature carries its own: planting,
        // re-planting or clearing the area while the anchor stays spotted has to
        // re-send, or the client's ring never updates.
        // An ARRAY, not `str` of one — see the note in the header, and SPOT_SIG_OFF for
        // why that forces isEqualTo on every comparison.
        private _grpBaseSig = [_anchorId, _leaderTex, _mrkrColor, _echelonTex, _anchorZone];

        // Chevron colour and display name — once per member, shared by every curator
        // AND, through _chevronMemo, by every curator SIDE that can see him. Which
        // members reach _chevrons is side-dependent (it comes from _knownBy and this
        // side's latch map); what a chevron for one member LOOKS like is not — the
        // colour, the name, the officer zone and the signature are all properties of the
        // spotted man. A man is in exactly one group, so _mrkrColor and _leaderNetId
        // read inside the block are the same whichever side builds it first.
        //
        // getOrDefaultCall, NOT getOrDefault: SQF evaluates a getOrDefault default
        // EAGERLY, so the plain form would run the whole build on every HIT — which is
        // the opposite of the point. Same trap as the per-tick fallbacks above.
        // The block reads _member/_memberId by CLOSING OVER them, not from `_this`:
        // getOrDefaultCall runs its default with _this set to [key, hashMap]
        // (docs/Knowledge Base/Gotchas.md §3).
        private _chevronData = _chevrons apply {
            _x params ["_member", "_memberId"];
            _chevronMemo getOrDefaultCall [_memberId, {
                [_member, _memberId, _mrkrColor, _leaderNetId, _officerZones, _emptyArr] call FUNC(chevronEntry)
            }, true]
        };

        // Emit to each curator on this side with their own spot key and target player.
        {
            _x params ["_curator", "_player", "_curId", "_curForce"];

            private _leaderKey = "s_" + _leaderNetId + "_" + _curId;
            _currentKeys set [_leaderKey, true];
            [
                _leaderKey,
                [MKR_PREFIX + _leaderKey, _leader, _leaderTex, _mrkrColor, true, _echelonTex, _sideIdx, _leaderNetId, "", _anchorZone, _anchorId],
                _grpBaseSig,
                _player, _activeSpots, _drawGroup, _curForce
            ] call FUNC(emitSpot);

            // Chevrons: one per individual the team knows well (knowsAbout the unit).
            {
                _x params ["_member", "_memberId", "_wedgeColor", "_memberName", "_zone", "_wedgeBaseSig"];

                private _wedgeKey  = "w_" + _memberId + "_" + _curId;
                private _wedgeMrkr = MKR_PREFIX + _wedgeKey;
                _currentKeys set [_wedgeKey, true];
                [
                    _wedgeKey,
                    [_wedgeMrkr, _member, WEDGE_TEXTURE, _wedgeColor, false, "", _sideIdx, _leaderNetId, _memberName, _zone, _memberId],
                    _wedgeBaseSig,
                    _player, _activeSpots, true, _curForce
                ] call FUNC(emitSpot);

                // Register this wedge so the FiredMan handler can flash it white. Skipped
                // wholesale when the blink is switched off (GVAR(enableFireBlink)) — this
                // is the producing side of that setting and where the cost actually is:
                // one entry per chevron per watching curator, rebuilt every pass, plus a
                // targeted network event per shot for each of them.
                if (_blink) then {
                    (GVAR(wedgeByUnit) getOrDefault [_memberId, [], true]) pushBack [_wedgeMrkr, _player];
                };
            } forEach _chevronData;

        } forEach _curatorsData;

        if (_perf) then { _perfChevrons = _perfChevrons + count _chevronData };

        // Radio callout fires when this group is positively identified — best
        // knowsAbout >= HARD, the engine's own "freshly spotted / confirmed" value.
        // GVAR(spotGroupLastSeen) (keyed side+leader) holds the last time this side
        // had this group confirmed and is refreshed on EVERY tick it stays confirmed,
        // so a group under continuous observation is announced exactly once; only a
        // group that drops out of confirmed contact for GROUP_CALLOUT_COOLDOWN and is
        // then re-acquired reports again. Seeded at -1e10 so a group never yet seen
        // fires immediately.
        // Gating at HARD rather than SOFT keeps "Contact!" to genuine sightings: the
        // group icon (SOFT) still appears for merely-heard/decaying contacts, but the
        // audio callout only sounds on confirmation, when the first chevron shows.
        // Refreshing at the same HARD bar is what makes the gap meaningful — a group
        // that decays to heard-only and is later re-confirmed reports again, whereas
        // refreshing at SOFT would let a long-heard group cross HARD in silence.
        // The gap — not new-spot detection — dedupes, so a contact that ramps up
        // gradually (1.0 → 1.5 over several ticks) is still announced when it crosses.
        if (_groupKnows >= HARD_THRESHOLD) then {
            private _lastSeen = _lastSeenMap getOrDefault [_leaderNetId, -1e10];
            _lastSeenMap set [_leaderNetId, CBA_missionTime];
            if (CBA_missionTime - _lastSeen >= GROUP_CALLOUT_COOLDOWN) then {
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

    } forEach _groups;

    // ── Notify all curators on this side of new contacts ──────────────
    // One call for the whole side: the location lookup and phrasing are
    // computed once, so same-side curators hear the identical report.
    _sideNewReport params ["_reporter", "_reportCats", "_contactPos"];
    // alive, not just !isNull: a corpse is a valid object but sideChat on it is silent.
    // In practice this never fails when _reportCats is non-empty — representatives come
    // from allUnits (alive-only) and the chevron latch verifies `alive` before reusing
    // its spotter — so the case is a guard, not a lost report. Were it to fail, those
    // groups' last-seen stamps have already been refreshed, so they would stay silent
    // until they drop out of confirmed contact for GROUP_CALLOUT_COOLDOWN.
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
    // may have disconnected since the spot was emitted — isPlayer, not isNull, since
    // a departed player's body can persist as server-local AI (owner 2), which would
    // route the retraction to the server/host instead. See FUNC(collectSides) for the
    // full reasoning.
    // isNotEqualTo, not !=: a live signature is an ARRAY and SQF's equality operators
    // throw on those rather than comparing them (see SPOT_SIG_OFF).
    if (_spotSig isNotEqualTo SPOT_SIG_OFF && { isPlayer _spotterPlayer }) then {
        [QGVAR(spotLost), [_mrkrName], _spotterPlayer] call CBA_fnc_targetEvent;
    };
    _activeSpots deleteAt _x;
} forEach _toRemove;

// ── Housekeeping: keep the long-lived rate-limit maps bounded ──────────
// Entries for dead/deleted units would otherwise accumulate for the whole mission.
call FUNC(pruneStores);

// ── Profiling ──────────────────────────────────────────────────────────
// Counters, not just a time: this pass scales with CURATOR SIDES x HOSTILES, and the
// timing alone cannot tell a mission that grew from one where the curators split onto
// opposing sides. `grps` is what SURVIVED the contact gate — read against `hostile`, it
// says how much of the enemy force is in contact, which is the number that decides
// whether the gate is earning anything. The format runs once per pass and only under
// the flag.
//
// This figure is the WHOLE pass, FUNC(collectSides) included. That function reports
// separately, so subtract its line to get the detection loop alone — and the two
// scale with different things (collectSides with unit count, this with sides x
// hostiles), which is exactly why they are timed apart.
if (_perf) then {
    ["spotCheck", (diag_tickTime - _t0) * 1000,
        format ["sides=%1 hostile=%2 grps=%3 chev=%4", count _bySide, _perfHostile, _perfGroups, _perfChevrons]
    ] call EFUNC(core,perfSample);
};
