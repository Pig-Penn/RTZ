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
 *    icon cleanup. Otherwise all units + vehicles are classified into per-side
 *    buckets once per tick (spotter reps only for sides that actually have a
 *    curator); curators on the same side share one detection pass.
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

// Consume the GLOBAL force-resend flag (set at mission start, and by any bare
// QGVAR(spotResync)). The per-player pending requests in GVAR(spotResendPlayers)
// are NOT consumed here — each entry is retired individually below, at the moment
// its player resolves to a targetable curator, so a request that arrived before the
// mission assigned that curator's module survives until it can be honoured.
private _forceResend = GVAR(spotForceResend);
GVAR(spotForceResend) = false;

// Curator logic modules are not units — alive always returns true even after
// the module is removed. Use !isNull to detect genuinely deleted curators.
private _curators = allCurators select { !isNull _x };

// Diagnostic toggle, read once per tick. The per-curator resolution logging it
// gates lives AFTER the classification pass (which it also forces to run), so
// the logged spotter-group count is real — see the debug block below.
private _dbg = GETMVAR(RTZ_debug,false);

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
// One shared empty map for every "missing" fallback in this pass. SQF evaluates
// getVariable / getOrDefault arguments EAGERLY, so spelling createHashMap inline
// allocated and immediately discarded a map on every single call — the same
// mistake XEH_preInit documents having already fixed once for GVAR(rcDisplay).
// Safe to share because every use below only ever READS the result (a plain
// getOrDefault, a count, a values), so no caller can write into the sentinel.
private _emptyMap = createHashMap;

private _officerZones = GETMVAR(RTZ_officerZoneMap,_emptyMap);

// ── Group manned curators by side ─────────────────────────────────────────
// Resolved BEFORE the unit/vehicle classification so a tick with no manned
// curator — vacant Zeus slots, a headless-only setup — skips the
// O(allUnits + vehicles) bucketing entirely and falls straight through to the
// icon cleanup at the bottom (the detection loop iterates _bySide, so with it
// empty the pass is already a no-op).
// Only PLAYER-manned curators can be spotters — a live player object is required
// as the CBA_fnc_targetEvent destination. Headless curators are skipped entirely,
// and so are curator modules still bound to a departed player: a playable Zeus slot
// whose AI is not disabled leaves the unit object behind, so getAssignedCuratorUnit
// keeps returning a non-null, server-local, NON-player body. `owner` of that body is
// 2, so an isNull-only guard would route every one of that curator's spots to the
// server — a silent no-op on a dedicated server (whose keys then never age out of
// _activeSpots), but on a listen server the host has the receivers registered and
// would render a departed curator's entire contact picture as its own. isPlayer is
// the same test FUNC(remoteControlIndicator) already uses, and
// `isPlayer objNull` is false, so it subsumes the null check.
// Same-side curators share the same spotter pool and see the same hostiles, so
// the entire knowsAbout matrix is computed once per side and emitted to each.
// Tuple: [curator, player, curatorNetId (key part), forceResend (this
// destination's own force flag)]. The player's netId is resolved here for the
// pending-resync lookup but is NOT carried: it used to ride along so every
// signature could be suffixed with it, which FUNC(emitSpot) now detects directly
// as a recipient change instead.
private _bySide = createHashMap;   // sideStr → [side, curatorTuples[]]
{
    private _player = getAssignedCuratorUnit _x;
    if (!isPlayer _player) then { continue };
    private _curatorSide = side _player;
    private _playerId    = netId _player;

    // Retire this player's pending resync request HERE — the first tick on which
    // they resolve to a targetable curator — and fold it into a per-destination
    // force flag. Doing it at the point of resolution (rather than consuming a
    // global flag unconditionally at the top of the pass) is what makes a request
    // that arrived before the curator module was assigned still get honoured.
    private _pending = _playerId in GVAR(spotResendPlayers);
    if (_pending) then { GVAR(spotResendPlayers) deleteAt _playerId };

    ((_bySide getOrDefault [str _curatorSide, [_curatorSide, []], true]) select 1)
        pushBack [_x, _player, netId _x, _forceResend || _pending];
} forEach _curators;

// ── Classify every unit and vehicle ONCE per tick ────────────────────────
// _sideEntities:    sideStr → [side, entities[]] — spottable hostile candidates
//                   (alive, non-player; locality NOT filtered: knowsAbout only
//                   requires the SPOTTER to be local, and targets may sit on a
//                   client, e.g. under curator remote control).
// _sideSpotterReps: sideStr → HashMap(group netId → representative unit),
//                   collected ONLY for sides that actually have a manned curator
//                   (_bySide keys) — no other side's knowledge is ever queried,
//                   so building its rep map would be pure waste.
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
// The whole pass is gated on a curator having resolved this tick — with _bySide
// empty nothing downstream would ever read its output. RTZ_debug forces it so
// the per-curator resolution log below can report a real spotter-group count.
private _sideEntities    = createHashMap;
private _sideSpotterReps = createHashMap;
if (count _bySide > 0 || _dbg) then {
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

        if (_sk in _bySide && { local _x } && { !isNull group _x }) then {
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

        // Spottable only when the hull's group has a man leader. The grouping pass
        // further down keys on `leader group` and discards anything answering objNull,
        // so a hull without one never produced an icon anyway — it was merely walked
        // once per curator side first. `vehicles` is every vehicle on the map, which on
        // a populated terrain means hundreds of alive ambient cars, so testing it here
        // keeps them out of _allHostile and out of the per-side grouping walk entirely.
        if (!isNull (leader group _x)) then {
            private _bucket = _sideEntities get _sk;
            if (isNil "_bucket") then {
                _bucket = [_eSide, []];
                _sideEntities set [_sk, _bucket];
            };
            (_bucket select 1) pushBack _x;
        };

        // Spotter rep regardless of the above: UAV crew are absent from allUnits (see
        // allUnitsUAV), so a UAV's knowledge is only reachable via its hull's
        // effective commander here.
        if (_sk in _bySide && { local _x }) then {
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

    // Diagnostic: each curator's resolution is logged the first time it changes —
    // THE check for "does the server resolve joined/JIP clients' curators to a
    // targetable player?". A curator that logs owner=-1, or never logs at all,
    // is being silently skipped; the logged player object is the raw
    // getAssignedCuratorUnit result, so a curator held by a departed player shows
    // a non-null body next to owner=-1. Runs after the classification (which
    // _dbg forces on even with no curator resolved) so spotterGroups is the real
    // rep count for the curator's side — an unresolved curator reads side
    // sideUnknown, whose bucket is always empty, matching its true picture.
    if (_dbg) then {
        {
            private _player = getAssignedCuratorUnit _x;
            private _curatorSide = if (!isPlayer _player) then { sideUnknown } else { side _player };
            private _repCount = count (_sideSpotterReps getOrDefault [str _curatorSide, _emptyMap]);
            private _sig = format ["%1|%2|%3", _player, _curatorSide, _repCount];

            if (_sig != (GVAR(spotDebugLast) getOrDefault [netId _x, ""])) then {
                GVAR(spotDebugLast) set [netId _x, _sig];
                diag_log text format ["[RTZ] server curator %1: player=%2 owner=%3 side=%4 spotterGroups=%5",
                    netId _x, _player, (if (!isPlayer _player) then {-1} else {owner _player}), _curatorSide, _repCount];
            };
        } forEach _curators;
    };
};

// HashMap used as a set for O(1) "is this spot still active?" checks.
// Declared before the detection pass so the cleanup always runs, even when
// there are no spotters this tick (all killed) — stale icons must be cleared.
private _currentKeys = createHashMap;

// ── Spot detection: one pass per curator side ─────────────────────────────
{
    _y params ["_spotterSide", "_curatorsData"];
    private _spotterSideStr = str _spotterSide;

    // One representative per local AI group on this side — the spotter set.
    private _spotterReps = values (_sideSpotterReps getOrDefault [_x, _emptyMap]);
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
    // pushBackUnique, not pushBack: that cross-crediting means one rep can reach
    // the same entry by two routes (its target list holding both a crewed vehicle
    // AND one of its occupants), and a duplicate rep only re-runs the knowsAbout
    // test below for a group that has already answered. The lists hold just the
    // groups that know the entry, so the uniqueness scan is over a handful.
    private _knownBy = createHashMap;
    {
        private _rep = _x;
        {
            (_knownBy getOrDefault [netId _x, [], true]) pushBackUnique _rep;
            if (_x isKindOf "CAManBase") then {
                private _hull = objectParent _x;
                if (!isNull _hull) then {
                    (_knownBy getOrDefault [netId _hull, [], true]) pushBackUnique _rep;
                };
            } else {
                { (_knownBy getOrDefault [netId _x, [], true]) pushBackUnique _rep } forEach crew _x;
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
        // genuinely is spotted, preferring a MAN — a crewed hull rides in _members
        // alongside its crew, and anchoring on the man both classifies correctly
        // (FUNC(unitMarker), FUNC(contactCategory)) and still renders on the hull,
        // since FUNC(drawSpots) anchors every icon on `vehicle _unit`. findIf
        // returns -1 when the group is men-less (a UAV), where index 0 — the hull —
        // is what we want. _leaderNetId keeps the ORIGINAL leader's netId as the group
        // key, so chevron→group association (the hover peek in FUNC(drawSpots))
        // and the callout last-seen gate are unaffected; the anchor itself rides in
        // _grpBaseSig below.
        if !(_leader in _members) then {
            _leader = _members select ((_members findIf { _x isKindOf "CAManBase" }) max 0);
        };

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

        // Group icon. Drawn for groups of >1 man, OR whenever the anchor is in a
        // vehicle (a single-crewed vehicle is still worth marking), OR whenever the
        // anchor IS a vehicle — a hull whose crew never reach _members because they
        // are absent from allUnits (a UAV). A lone infantryman shows no group icon;
        // its members still chevron below.
        // Men only: crewed hulls ride in _members alongside their crew, so counting
        // raw members read a 3-man tank crew as 4 and skewed the echelon amplifier
        // for every mechanised group.
        private _menCount   = { _x isKindOf "CAManBase" } count _members;
        private _drawGroup  = (_menCount > 1)
            || { !isNull objectParent _leader }
            || { !(_leader isKindOf "CAManBase") };
        private _echelonTex = [_leader, _menCount] call FUNC(echelonTex);   // size amplifier
        private _anchorId   = netId _leader;

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
        private _anchorZone = [];
        if (_drawGroup) then {
            private _anchorIdx = _chevrons findIf { (_x select 1) isEqualTo _anchorId };
            if (_anchorIdx > -1) then {
                _chevrons deleteAt _anchorIdx;
                _anchorZone = _officerZones getOrDefault [_anchorId, []];
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
        private _grpBaseSig = str [_anchorId, _leaderTex, _mrkrColor, _echelonTex, _anchorZone];

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
            // Surrendered (rtz_captive) overrides → white-flag chevron, so a
            // curator can pick the men who have given up out of a firefight
            // without hovering them. Captured prisoners keep the flag: capture
            // never clears QEGVAR(captive,surrendered).
            //
            // A SOFT read, like the officer zone map below and rtz_hud's read of
            // QEGVAR(orders,flyHeight): a public variable by name, with a false
            // default, so rtz_captive being absent is a supported configuration
            // and no requiredAddons edge is implied (see config.cpp).
            if (_member getVariable [QEGVAR(captive,surrendered), false]) then {
                _wedgeColor = COLOR_SURRENDERED;
            };
            // Incapacitated (BIS revive / setUnconscious) overrides → civilian-purple chevron.
            // Last, so it wins over the surrender flag above: a man who gave up and
            // was then dropped anyway is down first and surrendered second.
            if (lifeState _member isEqualTo "INCAPACITATED") then {
                _wedgeColor = COLOR_INCAPACITATED;
            };
            // Officer zone ring: [] for the overwhelming majority (non-officers,
            // or officers with no active area) — one O(1) lookup, no extra pass.
            // The [plantedCenter, radius] pair rides the wedge payload verbatim
            // and is folded into the signature, so planting, re-planting or
            // clearing the area while the officer stays spotted re-sends the
            // wedge and the client updates/clears its ring the same tick.
            private _zone = _officerZones getOrDefault [_memberId, []];
            [_member, _memberId, _wedgeColor, _memberName, _zone, str [_wedgeColor, _leaderNetId, _zone]]
        };

        // Emit to each curator on this side with their own spot key and target player.
        {
            _x params ["_curator", "_player", "_curId", "_curForce"];

            private _leaderKey = "s_" + _leaderNetId + "_" + _curId;
            _currentKeys set [_leaderKey, true];
            [
                _leaderKey,
                [MKR_PREFIX + _leaderKey, _leader, _leaderTex, _mrkrColor, true, _echelonTex, _sideIdx, _leaderNetId, "", _anchorZone],
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
                    [_wedgeMrkr, _member, WEDGE_TEXTURE, _wedgeColor, false, "", _sideIdx, _leaderNetId, _memberName, _zone],
                    _wedgeBaseSig,
                    _player, _activeSpots, true, _curForce
                ] call FUNC(emitSpot);

                // Register this wedge so the FiredMan handler can flash it white.
                (GVAR(wedgeByUnit) getOrDefault [_memberId, [], true]) pushBack [_wedgeMrkr, _player];
            } forEach _chevronData;

        } forEach _curatorsData;

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
            private _sideGroupKey = _spotterSideStr + "_" + _leaderNetId;
            private _lastSeen     = GVAR(spotGroupLastSeen) getOrDefault [_sideGroupKey, -1e10];
            GVAR(spotGroupLastSeen) set [_sideGroupKey, CBA_missionTime];
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

    } forEach (values _grpMap);

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
    // route the retraction to the server/host instead. See the curator-resolution
    // block above for the full reasoning.
    if (_spotSig != "_off_" && { isPlayer _spotterPlayer }) then {
        [QGVAR(spotLost), [_mrkrName], _spotterPlayer] call CBA_fnc_targetEvent;
    };
    _activeSpots deleteAt _x;
} forEach _toRemove;

// ── Housekeeping: keep the long-lived rate-limit maps bounded ──────────
// Entries for dead/deleted units would otherwise accumulate for the whole
// mission. Collect-then-delete — never deleteAt inside a HashMap forEach.
if (count GVAR(blinkThrottle) > BLINK_THROTTLE_CAP) then {
    private _cutoff = CBA_missionTime - BLINK_THROTTLE_WINDOW;   // window is generous vs. FIRE_BLINK_THROTTLE (0.1s) so live entries are never evicted early
    private _old = [];
    { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(blinkThrottle);
    { GVAR(blinkThrottle) deleteAt _x } forEach _old;
};
if (count GVAR(spotGroupLastSeen) > GROUP_LAST_SEEN_CAP) then {
    // A stamp this old means the group is already out of contact long enough to
    // re-announce, so dropping it is indistinguishable from keeping it.
    private _cutoff = CBA_missionTime - GROUP_CALLOUT_COOLDOWN;
    private _old = [];
    { if (_y < _cutoff) then { _old pushBack _x } } forEach GVAR(spotGroupLastSeen);
    { GVAR(spotGroupLastSeen) deleteAt _x } forEach _old;
};
// Pending resync requests are retired when their player resolves to a curator, so
// an entry only survives while that player is connected but not (yet) a Zeus —
// exactly the case the pending channel exists for. What it must not do is outlive
// the player: someone who requests a resync and then disconnects without ever being
// made curator would otherwise leave a permanent entry. Normally empty, and bounded
// by slot count even when not, so this is a no-op on the hot path.
if (count GVAR(spotResendPlayers) > 0) then {
    private _stale = [];
    { if (!isPlayer (objectFromNetId _x)) then { _stale pushBack _x } } forEach GVAR(spotResendPlayers);
    { GVAR(spotResendPlayers) deleteAt _x } forEach _stale;
};
if (count GVAR(chevronLatch) > CHEVRON_LATCH_CAP) then {
    private _old = [];
    { if ((_y select 0) < CBA_missionTime) then { _old pushBack _x } } forEach GVAR(chevronLatch);   // already-expired latches are dead weight
    { GVAR(chevronLatch) deleteAt _x } forEach _old;
};
