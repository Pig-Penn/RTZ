# Path Planning: RTZ vs Zeus Wargame

`addons/path` originates from Zeus Wargame's Planning Mode. This is the audit of the two
implementations against each other: what RTZ got wrong on the way across, what it changed on
purpose, and what is still open.

Wargame references are line numbers in the unpacked test build at
`Documents/Github/Zeus Wargame (WAR)/keys/@ZEUS WARGAME [test build]/data/scripts/`,
principally `jac_WPfunctions.sqf` (the planning and scripted-move code) and
`jac_wargameMain.sqf` (state, settings, draw routines).

> **Verification status.** Everything here was derived by reading both implementations and is
> arithmetically checked, but **none of it has been tested in a running mission**. `hemtt check`
> passes. Part 4 lists what a live test still has to settle.

---

## 1. Defects found and fixed

### 1.1 Tactical spans aimed 45–180° wrong in seven of eight directions

`fnc_moveAnimation.sqf` returned only the table term as the steering offset:

```sqf
(GVAR(animDirections) select _sector) params ["_suffix", "_offset"];
// ... [_name, _offset]
```

`GVAR(animDirections)` is a verbatim copy of Wargame's `jack_animationDirectionArr`
(`jac_WPfunctions.sqf:3388`) — but Wargame never uses that table as the offset. It uses
(`jac_WPfunctions.sqf:3391-3402`):

```sqf
_facingDirMod = ((_index * 45) mod 360) + (jack_animationDirectionArr # _index # 1);
```

The table alone says how far a given strafe animation displaces the model off its own nose.
The **sector's own 45° term** is what turns that into "where the nose has to point for the
strafe to travel down this leg". Sector 0 — walking straight ahead — is the only sector whose
term is zero, so it was the only direction that ever aimed correctly.

| Sector | Suffix | Table | Wargame (`45·i + table`) | RTZ before |
|-------:|--------|------:|-------------------------:|-----------:|
| 0 | `f`  |   0 |   0 |   0 ✅ |
| 1 | `fr` | 315 |   0 | 315 ❌ |
| 2 | `r`  | 180 | 270 | 180 ❌ |
| 3 | `br` |  90 | 225 |  90 ❌ |
| 4 | `b`  |   0 | 180 |   0 ❌ |
| 5 | `bl` | 270 | 135 | 270 ❌ |
| 6 | `l`  | 180 |  90 | 180 ❌ |
| 7 | `fl` | 135 |  90 | 135 ❌ |

**Fixed** by adding the sector term in `fnc_moveAnimation.sqf`, before the memo lookup so
cached entries carry it too.

Worth knowing: the totals are *not* a clean `-45 · sector`. Sectors 1 and 7 (`fr`, `fl`) come
out 45° off the geometric ideal because Arma's diagonal move animations do not displace the
model at a true 45°. Wargame's own comment shows the author changing his mind mid-line
(`// fr = 225 315`). These are eyeballed constants with nothing to re-derive them from — carry
them, do not "correct" them.

### 1.2 Aircraft fine altitude drag was a deadlock

`fnc_airTarget.sqf` measured **one frame's** mouse travel against `PATH_HEAD`:

```sqf
private _delta = (_lastMouse select 1) - (getMousePosition select 1);
private _climbed = _head vectorAdd [0, 0, _delta * _rate];
```

But `PATH_HEAD` only moves when `fnc_appendPoint.sqf` *accepts* a sample, and it refuses any air
sample under `AIR_CLIMB_SPACING` (6 m). So each frame's climb was computed, refused, discarded,
and re-measured from the same unchanged head the next frame. **The drag was never integrated.**

The arithmetic: to clear 6 m in a single frame at `ALT_RATE` (250 m per screen sweep) needs
0.024 screen-units of mouse travel in that frame. A one-second full-screen drag at 60 fps gives
0.0167 → 4.2 m. Alt (fine) therefore did nothing at all, ever. Shift only appeared to work
because `ALT_RATE_FAST` is 4× coarser (16.7 m/frame, over the threshold).

**Fixed** with a `GVAR(altDrag)` accumulator that carries the drag across the frames it takes to
earn a point:

- accumulated in `fnc_airTarget.sqf`, clamped alongside the `AIR_MIN_ALT` terrain floor so a
  drag pushed into the ground does not bank travel the curator must undo;
- bounded to `±MAX_SEGMENT`, because a frame hitch lands one enormous delta and an accumulator
  past that ceiling is refused on every subsequent frame while it can only grow — which would
  wedge the altitude drag for the rest of the session;
- zeroed by `fnc_appendPoint.sqf` when it spends one, by `fnc_airTarget.sqf` on any frame the
  modifier is not held, and on grab / release / session open / session close.

### 1.3 Land vehicles stalled permanently when the engine dropped the path

`setDriveOnPath` was issued once in `fnc_startFollow.sqf` and never re-asserted. The engine's
driving path is fragile — any other order reaching the driver clears it (a group leader
re-forming, a danger FSM reaction, a LAMBS tactic, a JIP settling) and the vehicle simply stops.
Nothing reports it; the only evidence is a vehicle sitting still on a path it never finished,
which `STUCK_TIME` then takes a full 60 s to notice and abandon.

Wargame carries a fail-safe (`jac_WPfunctions.sqf:3768-3778`) that re-issues after ~10 s **but
only while the vehicle is still within 5 m of its first position**. That bound is the important
half: `setDriveOnPath` restarts from the head of the array it is given, so re-asserting after
the vehicle had made ground would drive it back to where it set off — worse than the stall.

**Fixed** in `fnc_followTick.sqf` with `DRIVE_RETRY_TIME` / `DRIVE_RETRY_DIST`, bounded the same
way.

> **A fix that was itself wrong first.** The initial version reset `FOLLOW_MOVED_AT` on each
> retry. That clock *is* the stuck timer, so resetting it meant a vehicle that could never start
> was re-issued every 10 s for the whole of `GVAR(timeout)` (20 min default) instead of being
> given up at `STUCK_TIME` — the retry defeated the check that exists to end exactly that case.
> The retry now rides its own `FOLLOW_RETRY_AT` field and never touches `MOVED_AT`, so the stuck
> clock runs on underneath and allows roughly five attempts before abandoning the path.

### 1.4 A crew swap mid-drag silently killed the trace

`fnc_planTick.sqf` re-pointed `PATH_UNIT` at whoever was driving now, but left
`GVAR(grabbed)`, `GVAR(hovered)` and `GVAR(hoveredPoint)` holding the *old* unit. Every lookup
in the mode is a `findIf` on `PATH_UNIT`, so after a swap the grabbed handle matched nothing:
the path stopped growing mid-trace and could not be released or re-grabbed until the mouse came
up. **Fixed** by re-pointing all three with the record.

### 1.5 Formation rank renumbered mid-path

`fnc_formationTrail.sqf` incremented `_rank` *after* the eligibility `continue`, so a follower
the curator took over by hand stopped consuming a rank and every follower behind it shifted down
one. On the ground that is a change of spacing. For a flight it moves the echelon to the other
side of the traced line and drops it a rank's worth of altitude — so the points already drawn
for that aircraft and the ones about to be belong to two different formations, and the path
steps sideways at the join. **Fixed** by claiming rank from position in the selection, before
eligibility is considered, so it is fixed for the session.

---

## 2. The executors, brought back to Wargame's philosophy

The original port kept RTZ's own executors and listed Wargame's as differences worth having.
That was the wrong call in three places, and this is the reasoning that replaced it.

The test is not "does the unit arrive". It is **does the drawn line get followed**. A curator
who traces a hedgerow, a valley floor or a specific side of a street has said something about
the route, not just the destination, and an executor that hands the leg to the AI throws that
away — the AI rounds corners, re-forms with its group, prefers roads, picks its own altitude,
and arrives somewhere near the line rather than on it. Wargame moves the unit itself for exactly
this reason, and it is right to.

What Wargame gets wrong is everything around that decision: the cadence (3–4 per-frame handlers
per unit), the unbounded waits, the missing clocks, and a per-point payload three quarters of
which is derivable. Those are implementation, and they are what got rewritten.

### 2.1 Infantry: puppeted end to end

`GVAR(infantryExecutor)`, three positions, defaulting to **Carried for the whole path**:

| Position | Behaviour |
|---|---|
| `EXEC_AI` | Own navigation for every leg. Marked stretches do nothing. |
| `EXEC_SPANS` | Own navigation, puppeted only inside the stretches marked with Alt. This is what the port used to do unconditionally. |
| `EXEC_SCRIPTED` | Puppeted end to end. Wargame's executor. |

`fnc_setPuppet.sqf` (was `fnc_setTactical.sqf`) is the whole state machine: `disableAI "MOVE"` /
`"ANIM"`, a directional movement animation from `fnc_moveAnimation`, an `AnimDone` handler to
re-loop it, and a `Hit` handler to remember whoever shot the unit. `fnc_followTick` steers the
hull toward the leg each wake.

Walking forward is not a special case — it is the facing span asking for sector 0, which is the
`f` animation with a zero steering offset. That collapses three executors into one code path
whose only difference is whether an animation was asked for.

**Better than Wargame, specifically:**

- **`fnc_moveAnimation` picks its pace from the group's speed mode.** Wargame derives the
  animation by walking `InterpolateFrom` / `InterpolateTo` / `ConnectTo` / `connectFrom` four
  levels deep out of whatever the unit is currently playing, `arrayIntersect`ing the result,
  running it through a nine-stage filter cascade and taking the most frequent survivor — per
  unit, every time stance, speed mode, leg damage or ground slope changes. RTZ assembles the
  name from the four things that actually select it and memoises on exactly that key. A squad on
  Limited walks its path; one on Normal runs it; a man with his legs shot walks whatever the
  group is set to.
- **Combat reaction is bounded.** `fnc_combatPause.sqf` breaks the path to engage what shoots at
  the unit or walks into its arc, then resumes. Wargame's equivalent has no deadline, so a unit
  that can see a target it cannot resolve — behind glass, across a river, armoured — never walks
  again. `ENGAGE_MAX_TIME` ends it; `ENGAGE_COOLDOWN` stops a target flickering in and out of
  line of sight from stopping and starting the puppet several times a second.
- **Pausing is *leaving*, not a flag.** `fnc_combatPause` calls `fnc_setPuppet` with `""` and
  lets the tick's ordinary "walk this leg" path re-enter afterwards. Wargame carries a second,
  parallel description of the puppet state for the paused case, with its own `disableAI` calls,
  and that duplication is where its resume loop can strand a unit with `MOVE` off.
- **Doors are cached by class.** `fnc_openDoors.sqf` asks `selectionNames` once per building
  *class* and keeps the model-space position of each door. Wargame runs the same sweep over the
  nearest building every half second, per unit.
- **The stuck clock is held off during an engagement**, so a firefight longer than `STUCK_TIME`
  does not abandon the path of everyone in it.

**What is still given up, honestly:** a puppet cannot take cover and cannot path around
something it was walked into. `STUCK_TIME` is the backstop. Wargame has neither the backstop nor
the option to refuse; RTZ has both.

### 2.2 Aircraft and boats: their own flight model

`GVAR(scriptedFlight)`, on by default. `fnc_flightTick.sqf` sets attitude and velocity directly,
off the traced line, on the shared tick.

This is not a preference. `setDriveOnPath` has **no effect at all** on Air or Ship — it needs an
AI steering component neither has — so the alternative is a `doMove` chain, which gives the AI a
destination and no line. A traced valley run comes back as a straight leg over the ridge.

The model is Wargame's, with its constants: forward vector from the current position to the leg,
attitude leaned into travel by a per-domain pitch, cruise scaled down for how hard the path
bends within the next few legs, speed chased rather than jumped to, and a helicopter flare over
the last legs of a one-way path.

**Better than Wargame, specifically:**

- **Cadence.** Wargame runs a `0.0005` handler per aircraft and then throttles the movement
  inside it to every tenth wake, arriving at roughly six steps a second by the most expensive
  route available. This runs at `TICK_INTERVAL` on the handler everything else already shares —
  and it is not an approximation, because `setVelocity` persists until something changes it.
- **Liftoff is bounded.** Wargame `waitUntil`s for the aircraft to leave the ground, in a spawned
  thread, with no timeout — so an aircraft that cannot lift (damaged rotor, hangar roof) leaks
  that thread for the rest of the mission. `FLIGHT_LIFTOFF_TIME` takes over regardless, which is
  also the better failure: the first leg is above the aircraft, so the velocity applied lifts it.
- **The passed-the-waypoint test is one dot product.** Wargame's `…WPHelper` is four nested
  fallbacks including a field-of-view check against a re-derived direction. Both answer the same
  question — a fast hull can enter and leave a leg inside one step, so distance alone misses it.
- **The pitch is scaled by speed in hand.** Wargame leans by a flat constant, so its helicopter
  sits nose-down 20° while hovering onto a landing point, which is the one moment a helicopter is
  unmistakably level.
- **Landing is handed back to the AI.** `fnc_endFollow` gives the hull a height to hold, then
  `land "LAND"` when the path was drawn onto the ground, then takes the scripted velocity off a
  helicopter finishing a one-way route. Wargame calls `landAt` with an argument shape the command
  does not take.

### 2.3 Point storage

Wargame carries `[position, isTactical, animationName, facingOffset]` on **every** point, and
positions in AGL.

RTZ carries bare ASL positions and a **span list** (`PATH_FACING`), because two of Wargame's
three extra terms are derived from the first and the third only changes a handful of times in a
path. The animation name in particular cannot be stored at draw time at all — it depends on the
unit's stance, weapon and speed mode, which the drawing client does not know — so it is resolved
where the unit is local and memoised there.

The performance argument for a per-point payload is O(1) lookup, and that is kept: `FOLLOW_SPAN`
is a cursor into the span list, and leg indices only ever go up, so the span in force advances
with them and the lookup is an integer compare per tick however many spans were drawn.

ASL stays. Every geometry test that validates a point is ASL, so storing AGL means an
`AGLToASL` on every single append — which is what Wargame does, on the hottest path it has. Only
drawing wants AGL, and drawing is decimated.

**What did change is the thing that actually mattered**, and it is the real content of Wargame's
"one point every 0.25 m": a scripted executor walks or flies the polyline literally, so every
point it is not given is a corner it cuts. Each profile now carries two commit spacings and
`fnc_commitPaths` picks by executor (`PROF_COMMIT_SPACING` for a `doMove` chain,
`PROF_SCRIPTED_SPACING` for a scripted one — 20 m against 4 m on foot, 80 m against 30 m in the
air). `fnc_reducePath` still drops points on a straight run and still keeps every corner, so a
scripted infantry path leaves as a few dozen legs rather than the eight hundred Wargame would
send for the same 200 m. Arrival radii dropped to match (`ARRIVAL_PUPPET`, `ARRIVAL_FLIGHT_*`) —
on a scripted executor the hull is *placed*, so the radius is nothing but the width of the tube
the path is tracked within.

### 2.4 Colours

Wargame stores a path colour on the unit, so a given unit keeps it across sessions. That is the
right instinct and it is now RTZ's too (`fnc_colorFor.sqf`) — a curator plans the same company
four or five times over an operation, and a colour that means "the lead section" for the whole
mission is worth having.

What is not carried over is the picker: `[random 1.1, random 1.1, random 1.1, 1]` retried until
it finds an unused one, up to six hundred spins, regularly landing on near-black, on white, or
on two greens indistinguishable at 400 m. RTZ keeps its twelve hand-picked colours and hands out
the **least-used** one rather than cycling by index, so a session of thirteen paths repeats one
colour instead of restarting the whole order.

### 2.5 Re-task timing (was open, §3.3)

Wargame waits 0.2 s between ending a scripted move and starting the next (0.25 s on foot) and
warns explicitly that ordering immediately after teardown "causes weird behaviour"
(`jac_wargameMain.sqf:2312-2313`).

Reproduced, without a spawn or a `waitAndExecute` per order. `fnc_startFollow` no longer orders
anything: it builds the record with `FOLLOW_START_AT`, and `fnc_launchFollow` issues the first
order from the tick at that time. A fresh path launches on the next tick; a re-task launches one
`RETASK_SETTLE` later. The launch also now happens on a pass that has already re-checked the
unit is alive, local and still in its seat, which a commit event cannot do for a moment 0.25 s
in the future.

### 2.6 `setEffectiveCommander` (was open, §3.2)

Applied, guarded much harder than Wargame's. `setDriveOnPath` is obeyed through the hull's
effective commander, so a vehicle whose commander sits in another group — or is not aboard —
can silently refuse the path; Wargame realigns at six separate call sites before driving
(`jac_WPfunctions.sqf:1270`, `:3714`; `jac_wargameMain.sqf:2309`, `:6629`, `:7453`, `:8942`),
consistently enough to read as a prerequisite.

Wargame passes `leader _driverGRP`, who need not be in the vehicle, and setting it wrong is
worse than the stall it prevents. `fnc_startFollow` only touches it when the current answer is
nobody actually aboard, and only ever sets it to the driver the path is addressed to.

### 2.7 Road snapping (was open, §3.5)

`fnc_snapToRoad.sqf` returned `getPosASL _road` — the road **segment object's** origin. Segments
are 10–25 m long, so every sample inside one resolved to the same position and was refused by
the spacing gate until the forward bias walked the probe onto the next segment: a row of dots one
segment apart with straight lines between them, which on a curve is a line that leaves the road.

Now the probe is projected onto the segment itself, using the endpoints `getRoadInfo` carries,
clamped to its ends and measured in the ground plane so the point is pulled along the road
rather than along its gradient. One dot product. Falls back to the old behaviour when a road
object answers without endpoints.

---

## 3. Deliberate differences that remain

These are RTZ's documented departures. They are not defects and should not be "fixed" toward
Wargame without a specific reason.

| Area | Wargame | RTZ | Why RTZ differs |
|---|---|---|---|
| Handler cadence | 3–4 PFHs **per unit** (0.001 steering, 0.1 combat, 0.5 doors, 0.0005 air) | One shared handler at `TICK_INTERVAL` 0.1; movement every wake, conditions on a 0.5 s stagger | Sessions here run several curators, large unit counts, multi-hour ops. This is the one part of Wargame's design that could not be carried over at any quality. |
| Point storage | AGL, four values per point | ASL, bare position; facing as a span list with an O(1) cursor | §2.3 |
| Draw decimation | Stride switches at 225 / 3000 / 6000 points via four interacting index variables, duplicated verbatim in both draw routines | One distance-scaled budget, shared by both renderers | |
| Commit | `remoteExec` to everyone, each machine tests locality and discards | One `CBA_fnc_targetEvent` per unit | A 30-unit plan cost every client 30 payloads to throw away. |
| Blocked samples | Hand-rolled nearest-door search per blocked sample | `calculatePath` + splice | The engine's pathfinder already knows which doors open. |
| Path colours | `while {random 1.1}` picker, up to 600 spins, lands on near-black | 12-colour palette, least-used pick, kept on the entity | §2.4 |
| Planning freeze | Always on, `disableAI "PATH"` | Opt-in, `doStop` | `disableAI "PATH"` would make `fnc_pathKind` reject the very units the freeze created. |
| PP layer | 1501 | 663201 | Both mods load together; sharing a layer means whichever destroys last wins and the other's tint can never be removed. |
| Executor choice | None — always scripted | Settings, defaulting to scripted | A mission that would rather never lose a unit's own navigation can say so. Wargame cannot. |

---

## 4. Open — needs a live test

### 4.1 Puppet arrival radius against commit spacing

`ARRIVAL_PUPPET` is 2.5 m against a `PROF_SCRIPTED_SPACING` of 4 m; Wargame runs 1 m against
0.25 m sampling. If a hand-steered man reliably fails to close the last 2.5 m — pushed off by a
slope, a corpse, a doorframe — the leg never advances and `STUCK_TIME` abandons the path after a
full minute of walking on the spot. **If puppets stall on obstacles, raise this first**; if they
visibly cut corners, lower it and lower `PROF_SCRIPTED_SPACING` with it.

### 4.2 Flight constants against real aircraft

`FLIGHT_ACCEL` / `FLIGHT_DECEL` are sized for `TICK_INTERVAL` rather than carried from Wargame's
per-frame figures, and `FLIGHT_TURN_FULL` (45°) replaces Wargame's saturating-at-8° horizontal
score. Both are arithmetically reasonable and neither has been flown. The failure modes to watch
for: a plane that cannot hold the traced line through a corner (raise `FLIGHT_TURN_PLANE` or
lower `FLIGHT_TURN_FULL`), and a helicopter that oscillates around its cruise (lower
`FLIGHT_DECEL`).

Cruise is `(config maxSpeed × coefficient) min SPEED_CAP` used as **m/s**, which is Wargame's
convention and the reason its helicopters cruise at a sane 60 m/s. The same figure is km/h on
the `limitSpeed` fallback branch. That unit change across one `if` is the sharpest edge in the
component.

### 4.3 Attitude on a steep climb

`fnc_flightTick` derives the hull's lateral axis from the horizontal component of travel, and
falls back to the hull's current heading below `FLIGHT_HEADING_MIN`. A helicopter ordered
straight up should keep its heading and only move its nose. Untested, and the degenerate case
(`setVectorDirAndUp` with near-parallel arguments) is the one that would look worst.

### 4.4 Door opening across building sets

`fnc_openDoors` filters selections containing `door` and not `handle`, and animates
`<name>_rot`, `<name>A_move` and `<name>B_move` — Wargame's three sources. Modded building sets
with other naming conventions will simply not open, silently. Worth a look on whatever terrain
the mod is actually run on.

### 4.5 `REPLAN_TOLERANCE` on the AI fallback

`fnc_followTick` re-issues `doMove` when `expectedDestination` drifts more than 3 m off the
current leg. LAMBS — the source of the technique — uses `distanceSqr` thresholds of 1 and 4
(`lambs_main/functions/UnitAction/fnc_doAssault.sqf:110`, `fnc_doAssaultMemory.sqf:90`), so
RTZ's is the more lenient of the two. The risk is the other way round: `doMove` snaps its
destination to the navmesh, and if that snap routinely exceeds 3 m on a given terrain the
comparison never settles and the order is re-issued every tick. Only reachable now with the
executor settings turned down, which is also the configuration where it matters least.

---

## 5. Files touched

| File | Change |
|---|---|
| `functions/fnc_moveAnimation.sqf` | Sector term in the steering offset (1.1); pace from speed mode (2.1) |
| `functions/fnc_setPuppet.sqf` | Was `fnc_setTactical.sqf`. Adds the `Hit` handler and the `switchMove` release (2.1) |
| `functions/fnc_combatPause.sqf` | New — bounded engage-and-resume for a puppet (2.1) |
| `functions/fnc_openDoors.sqf` | New — class-cached door opening for a puppet (2.1) |
| `functions/fnc_flightTick.sqf` | New — scripted flight and sailing (2.2) |
| `functions/fnc_launchFollow.sqf` | New — the deferred first order (2.5) |
| `functions/fnc_colorFor.sqf` | New — least-used palette pick, kept on the entity (2.4) |
| `functions/fnc_followTick.sqf` | Two cadences, three executor branches, span cursor, combat and doors |
| `functions/fnc_startFollow.sqf` | Executor resolution, flight profile, `setEffectiveCommander` (2.6), no direct order |
| `functions/fnc_endFollow.sqf` | Flight teardown: hold height, land, kill velocity (2.2) |
| `functions/fnc_commitPaths.sqf` | Resample at the spacing the receiving executor can use (2.3) |
| `functions/fnc_snapToRoad.sqf` | Project onto the road segment (2.7) |
| `functions/fnc_beginPlanning.sqf` | Colours through `fnc_colorFor` (2.4) |
| `functions/fnc_appendPoint.sqf` | Alt gating reads the executor setting; zero `altDrag` (1.2) |
| `functions/fnc_airTarget.sqf` | Accumulate, clamp and bound the altitude drag (1.2) |
| `functions/fnc_handleInput.sqf`, `fnc_beginPlanning.sqf`, `fnc_endPlanning.sqf` | Zero `altDrag` with the rest of session state (1.2) |
| `functions/fnc_planTick.sqf` | Re-point grab / hover / cut pick on a crew swap (1.4) |
| `functions/fnc_formationTrail.sqf` | Claim rank before eligibility (1.5) |
| `script_component.hpp` | Executor constants, the flight/combat/door blocks, ten new record fields |
| `XEH_preInit.sqf`, `XEH_PREP.hpp` | Second commit spacing per profile, door cache, new functions |
| `initSettings.inc.sqf`, `stringtable.xml` | `infantryExecutor` (list, replaces `tacticalMove`), `scriptedFlight` |
