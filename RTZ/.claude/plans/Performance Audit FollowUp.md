# Performance Audit — Follow-Up Pass

A second read of the hot paths, after the first audit
(`docs/Knowledge Base/Performance Audit Questions.md`) and its fixes had landed. Its
answers are the premises this pass reasons from, so read that file first; the three that
matter most here are repeated inline where they bite.

**Nothing in this document has been implemented.** It is a findings list, written down so
the reasoning survives rather than being re-derived a third time.

## What was covered

- **Server tick path** — `fnc_spotCheck`, `fnc_collectSides`, `fnc_emitSpot`,
  `fnc_pruneStores`, the `FiredMan` blink handler in `fnc_spottingSystem`.
- **Client frame path** — `EFUNC(core,frameLoop)`, `fnc_drawSpots`, `fnc_drawUnitTags` /
  `fnc_drawVehicleTags` / `fnc_buildTagEntry`, `fnc_drawSupply`, `fnc_drawTarget`,
  `fnc_drawRcIndicator`.
- **Stream engine** — `fnc_selectionPoll`, `fnc_streamServer`, `EFUNC(hud,gatherUnitInfo)`,
  `EFUNC(supply,gatherSupply)`.
- **Every long-lived perFrameHandler** — `economy`'s income/curator tick,
  `officer`'s `fnc_monitorAreas` / `fnc_monitorAuras`, `captive`'s `fnc_captureTick`,
  `mine`'s `fnc_refreshMines`, `fnc_remoteControlIndicator`, `EFUNC(common,progressJob)`,
  `EFUNC(common,approach)`.
- **Memo stores** — `classInfoCache`, `headOffsetCache`, `magazineCapacities`,
  `markerTexCache` / `markerSuffixCache`, `loot`'s `scanCache`, and the three
  entity-keyed stores `fnc_pruneStores` bounds.

Not covered: `extras/`, which HEMTT does not build (audit §11).

Most of it is already tight, and the first audit's fixes are all visibly in place — the
two-phase chevron cull, the per-tick gather memo in `fnc_streamServer`, the
`_activeGroupKeys` contact gate, the capped prune stores, the class-keyed memos, the
`RTZ_perf` instrumentation. Two things are genuinely left.

---

## 1. `fnc_spotCheck` re-derives the hostile group picture once per curator SIDE

Four things inside the per-curator-side loop are computed that do not depend on who is
looking:

| Site | Work | Shape |
|---|---|---|
| `fnc_spotCheck.sqf:268` | `_allHostile append _y` per hostile side, then a walk doing `leader group _x` + `netId _ldr` **per hostile entity** | 2 engine calls × every hostile |
| `fnc_spotCheck.sqf:328` | `if !(_leader in _members)` | O(members) scan per group |
| `fnc_spotCheck.sqf:385` | `_isHQ = -1 < _members findIf { classInfo }` | a `call` + `typeOf` + hashmap read **per member** |
| `fnc_spotCheck.sqf:398` | `_menCount = { _x isKindOf "CAManBase" } count _members` | engine call per member |

Which group an entity belongs to, how many men that group holds, and whether it is a
command element are the same answers for every observer. Audit §8 says curators are
typically on **opposing** sides, so with three or more sides in play each of these runs two
to four times over 200–500 AI, every `spotCheckInterval` (3 s by default, §4) — and audit
§3 says this is a **listen server**, so that is the same machine also drawing the picture.

The grouping walk carries a comment defending itself: *"The `leader group` + `netId` per
hostile stays: it IS the question being asked."* That is true of **one** pass. It is not a
defence of running the pass per side.

### Proposed shape

`fnc_collectSides` already walks `allUnits` (`:147`) and `vehicles` (`:186`) exactly once
per tick. Have it return

```
side → HashMap(leaderNetId → [leader, members, leaderNetId, isHQ, menCount, leaderInMembers])
```

in place of the flat candidate list at `fnc_collectSides.sqf:118`. Then:

- **`menCount` and `leaderInMembers` become free.** The men's loop knows every entry it
  pushes is a man and the vehicle loop knows every entry it pushes is not, so an
  `isKindOf` per member per group per side collapses to an increment; and
  `leaderInMembers` is one `isEqualTo` at push time in place of an O(members) `in` scan
  per group per side. Note that `menCount` must **not** count hulls — a crewed hull rides
  in the member list alongside its crew, and counting it reads a 3-man tank crew as 4,
  which skews the echelon amplifier for every mechanised group.
- **`isHQ` stays LAZY.** This is the part worth getting right. Computing it in
  `fnc_collectSides` would pay an `EFUNC(common,classInfo)` call per member for *every
  group in the mission*, and audit §7 says most of the enemy force is out of contact at
  any moment — the whole reason `_activeGroupKeys` exists. Eager evaluation would be a
  worse trade than the per-side repetition it replaces. Instead leave slot 3 as a `-1`
  sentinel and have `fnc_spotCheck` fill it on the first side that asks; every later side
  reads it back. Computed at most once per group per tick in either regime, and zero times
  for a group nobody can see.
- **The per-side loop becomes a union** over the hostile sides' group maps, with the
  `_activeGroupKeys` gate applied at **group** granularity instead of per entity —
  O(hostile groups) of pure hashmap work, replacing O(hostile entities) of engine calls.

### The seam to watch

The flat union implicitly merged a group whose members straddled two side buckets: the
buckets key on `side _x` while the grouping keys on `netId (leader group _x)`. Those agree
for anything with a crew — `side` of a man in a group answers with the group's side, and
`side` of a crewed hull answers through its crew — so a group should always land whole in
one bucket. Keep an explicit merge path anyway rather than assume it, and **build a new
tuple on merge rather than mutating**: the tuples are shared across curator sides within a
tick, so an in-place `append` would leak one side's merged member list into the next side's
pass. That is the same class of aliasing bug as the `GVAR(activeStreams)` baseline copy in
`fnc_selectionPoll` and the officer-zone `isEqualTo` invariant documented at
`fnc_spotCheck.sqf:150`.

Also: `_perfHostile` (`fnc_spotCheck.sqf:301`) currently counts `_allHostile`, which will no
longer exist. It has to keep meaning "entities hostile to this side" or the `hostile=`
counter stops answering the question §2 uses it for — sum `count (_y select 1)` across the
hostile sides' group maps, under the `RTZ_perf` gate only.

**Risk:** moderate. Behaviour-identical by construction, but it moves the shape of the
component's central data structure.

---

## 2. The fire-blink `FiredMan` handler cannot bail cheaply

`fnc_spottingSystem.sqf:162` is a `CAManBase` class event handler, so it fires on **every
infantry shot mod-wide** — audit §10 confirms the feature is used and wanted, so the
handler is staying. Before it can decide there is nothing to do it pays:

```sqf
params ["_unit"];
private _id = netId _unit;                                  // engine call
private _spotters = GVAR(wedgeByUnit) getOrDefault [_id, []];  // eager [] allocation
if (_spotters isEqualTo []) exitWith {};
```

SQF evaluates `getOrDefault`'s default **eagerly**, so that `[]` is built and discarded on
every shot whether or not the shooter is spotted by anyone. That is precisely the trap this
component documents and avoids everywhere else — the shared `_emptyArr` sentinel at
`fnc_spotCheck.sqf:135`, the `get` + `isNil` bucket lookups in `fnc_collectSides`, and the
`GVAR(rcDisplay)` note at `fnc_drawSpots.sqf:188`, which is the same bug found in a
per-frame path.

There is also no cheap "is anything spotted at all?" gate. `GVAR(wedgeByUnit)` is rebuilt
from scratch every detection tick (`fnc_spotCheck.sqf:106`) and is empty whenever no
chevron is live on any side — including the whole time the blink setting is off, since
`fnc_spotCheck` skips populating it. Testing `count` on it costs nothing and skips the
`netId` entirely.

### Proposed shape

Hoist the map, gate on `count == 0` before touching `netId`, and replace the eager default
with `get` + `isNil`:

```sqf
private _map = GVAR(wedgeByUnit);
if (count _map == 0) exitWith {};
params ["_unit"];
private _spotters = _map get (netId _unit);
if (isNil "_spotters") exitWith {};
```

The `GETGVAR(enableFireBlink,true)` read stays first — it is one missionNamespace lookup
and it is what makes the setting free.

**Risk:** very low. Roughly six lines, no data-structure change.

---

## Considered and rejected

- **Caching spot keys / marker names per (entity, curator).** The emit loop builds
  `"w_" + _memberId + "_" + _curId` and `MKR_PREFIX + _wedgeKey` per chevron per curator
  per tick, and throws both away in steady state when `fnc_emitSpot` finds the signature
  unchanged. Real, but it is roughly three string allocations per chevron per curator per
  3 s — and the memo would be a mission-lifetime entity-keyed map, so it would need its own
  entry in `fnc_pruneStores`. Not worth the prune.
- **Hoisting the payload array out of the per-curator emit loop.** Only element 0 (the
  marker name) varies per curator, so it looks like it could be built once per group and
  patched per recipient. It cannot: `CBA_fnc_targetEvent` to a **local** player — the
  ordinary case on a listen server — hands the array to the receiver by reference, and
  `fnc_spottingClient` stores it. Mutating it afterwards would corrupt the client store.
- **Gating the hover `worldToScreen` in `fnc_drawSupply` / `fnc_drawTarget`.** Both run one
  per entry per frame unconditionally, purely to test cursor proximity — where
  `fnc_drawSpots` gates its equivalent at `HOVER_MAX_DIST` (50 m). But both are bounded by
  `SEL_MAX_HULLS` (32, and audit §12 says curators never approach it), and adding a
  distance gate would change *when a distant icon is hoverable*, which is a behaviour
  change for no measured gain.
- **Memoizing `EFUNC(economy,getCost)`'s `toLowerANSI`.** It allocates a string per class
  per call ahead of the `GVAR(categories)` memo, but it runs on `CuratorObjectRegistered`,
  not on a tick, and `GVAR(overrides)` is settings-mutable so a final-cost cache would need
  invalidation wiring for a cost that is not on a hot path.

---

## Before anything more invasive than these two

Audit §1 says nothing has ever actually been profiled, and that is still true — `RTZ_perf`
was built for exactly this and has not been run in anger.

Findings 1 and 2 are both **structural**: strictly less work in every regime, no tuning
constants, no behaviour trade. They stand without measurement. Anything beyond them should
wait on one `RTZ_perf = true` run in a real operation, so that the `collectSides`,
`spotCheck`, `rcScan` and per-renderer lines say where the time actually goes. Per §2 the
answer will differ between missions, and the counters (`units=`, `sides=`, `hostile=`,
`grps=`, `chev=`) are what separate a cost that tracks mission size from one that tracks
how many curators are opposed and how much of the enemy is in contact.
