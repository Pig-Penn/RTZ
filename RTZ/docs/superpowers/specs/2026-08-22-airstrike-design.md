# Airstrike — design

**Date:** 2026-08-22
**Status:** approved, ready for an implementation plan
**Component:** `addons/airstrike/` (new)

## Summary

A ZEN context action that orders **one selected aircraft** to fly a scripted attack
run against a curator-chosen point, delivering a curator-chosen weapon from its own
pylon loadout.

The curator right-clicks with a single aircraft selected, picks a weapon from a
submenu built out of that aircraft's real loadout, then presses on the target and
drags to set the bearing the aircraft will attack along. The aircraft flies itself to
a run-in position, is put on rails for the terminal run, releases, and pulls off.

## Reference implementations

Three, all read before this was written:

- **`zen_modules_fnc_moduleCAS`** (ZEN, always loaded). The Zeus CAS module as it
  actually behaves in our environment. Spawns a plane 3000 m out at 1000 m,
  `disableAI` MOVE/TARGET/AUTOTARGET, strips every weapon that is not the chosen
  strike type, drives it with `setVelocityTransformation` down a straight line, and
  at 1000 m out creates an **invisible laser target** at the aim point, does
  `reveal`/`doWatch`/`doTarget` on it and hammers `fireAtTarget` every 0.1 s for 3 s.
  Then deletes the plane, its crew and its group.

  It cheats twice, and both cheats are exactly what we do not get: it **spawns** the
  aircraft already in a firing position, so it never has to reposition an existing
  one; and it **deletes** the aircraft afterwards, so it never has to hand a puppeted
  plane back to the AI in a sane state. Those two gaps are most of this component.

- **`jac_fnc_tacticalAirSupport`** (Zeus Wargame). The same idea applied to an
  *existing* aircraft, which is our case. Contributes the run-in geometry
  (1500 m / 750 m / 1200 m release for planes), the cruise-from-`maxSpeed`
  derivation, and the confirmation that on-rails is the workable answer here.
  Its precomputed curved approach paths (`jac_fnc_parabolicPath`, semicircle
  turnarounds, 50-point interpolated splices) are **deliberately not ported** — see
  Ingress below.

- **`SAAI_fnc_selectWeapon`** (Smart Aircraft AI). The weapon-classification pass —
  bomb / AGM / rocket / gun buckets with per-type engagement envelopes — which is the
  shape `fnc_strikeWeapons` follows.

## Decisions

| Decision | Choice | Why |
|---|---|---|
| Asset model | Task the **already-selected** aircraft | Matches every other RTZ order (`_objects` = selection) and uses the plane's real loadout, ammo and mortality. No spawning, no despawning, no cooldown economy. |
| Control model | **Fully on rails from the moment ordered** | Predictable and cinematic. The AI will not fly a coherent attack run and will not attack a bare position at all. |
| Target input | **Press-drag-release**: point plus attack bearing | The bearing decides which ridge the aircraft comes over and which way ordnance walks. `zen_common_fnc_selectPosition` is click-only, so the component owns a small modal session. |
| Weapon choice | **Submenu of the aircraft's real weapons** | Reads the actual pylon loadout with live ammo counts. Same `insertChildren` pattern as `mine/fnc_placeActions`. |
| Multiplicity | **Exactly one aircraft** | Removes deconfliction, stagger and per-aircraft weapon resolution entirely. |
| Component home | **Its own component**, no `rtz_path` edge | Architecture.md's answer to "where does a new feature go". `rtz_path` is disabled by default, so depending on it would couple a feature to an optional one. |
| Ingress | **Bounded turn-rate steering** | Replaces Wargame's precomputed parabolic geometry with per-tick heading rotation. Produces a natural arc including a full reversal, in ~15 lines instead of ~80, with no path building. |

## Out of scope for v1

Recorded so the boundary is explicit and so none of these are half-built:

- **Helicopters.** Planes only. The flight profile is a constants table, so a second
  profile is additive.
- **Guided delivery.** No `FiredMan` handler re-aiming projectiles. Accuracy is
  therefore module-grade: the laser target makes tracking weapons work well, but dumb
  bombs obey ballistics from a scripted release and land *near* the mark rather than
  *on* it. `fnc_release` is kept as a separate function precisely so this can be added
  without reworking the engine.
- **Repeat passes.** One pass per order. A second pass is a second order.
- **Restoring the aircraft's previous task.** After the pull-off it flies out on a
  `doMove`; its prior waypoints are not captured or restored. Note this is distinct
  from *teardown*, which is mandatory — see below.
- **Zeus map support.** The aim session is 3D-view only. Adding it later is a
  `fnc_drawAimMap` plus a `Draw` handler on `IDC_RSCDISPLAYCURATOR_MAINMAP`, with no
  rework of anything else.
- **Economy integration.** No point cost is charged for a strike.

## Architecture

`requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "zen_common", "zen_context_menu"}`.

The component splits by locality, the way `rtz_path` does:

- **Aiming half — entirely on the curator's client.** The context submenu, the modal
  drag session, the renderer. Nothing is broadcast and nothing is authoritative until
  the mouse is released. The curator owns the selection and the cursor, so the server
  has no reason to hear about a strike being aimed.
- **Execution half — runs where the aircraft is local.** One targeted CBA event
  carries the order across the wire. Everything after it is `setVelocity`,
  `setVectorDirAndUp`, `setVelocityTransformation` and `disableAI`, none of which
  travel with locality.

The aim renderer registers on `rtz_core` (`RENDER_WORLD`, unregistered when the
session closes) rather than adding its own `Draw3D` handler. **No stream is
declared** — a strike needs no polled selection data, so `setDemand` never enters
into it.

## Files

Standard component skeleton — `config.cpp`, `script_component.hpp`, `CfgContext.hpp`,
`CfgEventHandlers.hpp`, `XEH_PREP.hpp`, `XEH_preStart.sqf`, `XEH_preInit.sqf`,
`XEH_postInit.sqf`, `initSettings.inc.sqf`, `stringtable.xml` — plus:

| Function | Runs on | Purpose |
|---|---|---|
| `fnc_strikeWeapons` | either | Classify the aircraft's weapons; return usable ones with live ammo |
| `fnc_canStrike` | client | Condition for the root context action |
| `fnc_strikeActions` | client | `insertChildren` — one child row per usable weapon |
| `fnc_beginAiming` | client | Open the modal aim session |
| `fnc_handleAimInput` | client | Install the display handlers, hand back their ids |
| `fnc_drawAim` | client | `RENDER_WORLD` renderer — target ring, approach arrow, range readout |
| `fnc_endAiming` | client | **Single** teardown owner for the session |
| `fnc_orderStrike` | client | Re-validate, dispatch the targeted event, draw the hint |
| `fnc_executeStrike` | aircraft-local | Receiver: capture restore state, build the record, start the tick |
| `fnc_strikeTick` | aircraft-local | The engine — one handler over a bounded registry |
| `fnc_steerToward` | aircraft-local | Bounded-turn-rate heading and bank push |
| `fnc_release` | aircraft-local | Laser target plus the `fireAtTarget` burst |
| `fnc_endStrike` | aircraft-local | **Single** teardown owner for a strike |

Two teardown owners rather than one, because the session and the strike have disjoint
lifetimes: the session is over the instant the order is sent, and the strike may
outlive the curator's client entirely.

## Data flow

1. Curator right-clicks with one aircraft selected. ZEN evaluates
   `condition = QUOTE([ARR_2(_position,_objects)] call FUNC(canStrike))` — the
   **wrapped** `_objects` convention, since mixing the two conventions fails silently
   and leaves only an RPT type error behind.
2. The root entry expands via `insertChildren = QUOTE(_this call FUNC(strikeActions))`,
   which receives `[_position, _objects]` and returns one row per usable weapon:
   `[name, format [LLSTRING(WeaponLabel), displayName, ammo], picture, statement,
   {true}, [_weapon, _muzzle, _turretPath, _type]]`. If it returns `[]` the parent
   action hides itself.
3. Clicking a row calls `fnc_beginAiming`, which opens the modal session on the
   curator display and installs the renderer.
4. Curator presses LMB on the target, drags in the direction they want the aircraft to
   fly, and releases. Escape or RMB cancels. A press whose drag is shorter than
   `MIN_AIM_DRAG` falls back to the aircraft's current heading, so the gesture
   degrades gracefully to a plain click.
5. `fnc_orderStrike` re-validates — still alive, still AI-crewed, still airborne, still
   holding ammo in the chosen weapon — then
   `[QGVAR(execute), [_plane, _aimASL, _bearing, _weaponData], _plane] call CBA_fnc_targetEvent`,
   and draws a ZEN hint with an `ICON` at the aim point and a `LINE` along the bearing,
   as `attack/fnc_orderDestroy` does.
6. On the aircraft's owner, `fnc_executeStrike` ends any strike already running on that
   aircraft, captures restore state, builds the record, pushes it into `GVAR(active)`,
   and creates the tick if it is the first.
7. The tick runs the phases. `fnc_endStrike` is the only exit from any of them.

## The condition (`fnc_canStrike`)

Stated in one place because it is otherwise implied in three, and because
`fnc_orderStrike` re-runs exactly the same gate after the aim — a curator can spend
several seconds drawing a bearing, and the aircraft can die, land, run dry or change
hands in that window.

The selection is normalized through `EFUNC(common,collectVehicles)`, so clicking a
crewman orders the aircraft they are riding in, matching every other RTZ vehicle order.
The action appears only when all of the following hold:

1. The normalized selection resolves to **exactly one** vehicle. Two aircraft means no
   action, not an arbitrary pick — a silent choice between two planes is worse than no
   button.
2. That vehicle `isKindOf "Plane"`. Helicopters are out of scope for v1 and are
   rejected here rather than half-supported downstream.
3. It is `alive`, and its driver is alive and `!isPlayer`.
4. It is airborne — `!isTouchingGround`. A plane on the deck has no run-in to fly.
5. `fnc_strikeWeapons` returns at least one usable weapon with ammo.

`GVAR(enabled)` gates the whole thing first, and it **defaults to off** — see Settings
below. The condition is a plain `condition`, not a `modifierFunction`, so it is not
subject to the "modifier runs before condition" hazard — but `GVAR(enabled)` is still
initialised in `XEH_preInit` rather than behind `CBA_settingsInitialized`, so no path
can read it nil.

## Weapon classification (`fnc_strikeWeapons`)

Walks the aircraft's weapons across all turrets (`allTurrets`, `weaponsTurret`) and
buckets each by `(_weapon call BIS_fnc_itemType) select 1`:

| Bucket | `itemType` | Notes |
|---|---|---|
| `TYPE_BOMB` | `bomblauncher` | Longest, highest release |
| `TYPE_MISSILE` | `missilelauncher` | Guided; gets the module's `+20 m` aim offset and a one-shot cap |
| `TYPE_ROCKET` | `rocketlauncher` | Unguided pods |
| `TYPE_GUN` | `machinegun`, `cannon` | Shortest release |

Rejected outright: `countermeasureslauncher` (that is `rtz_smoke`'s subject), and any
weapon whose magazines are air-to-air only — `aiAmmoUsageFlags == 256` on the
magazine's ammo, the same test Wargame uses. A weapon with `ammo == 0` is not offered.

The **config-derived half is memoised per vehicle class** in a `GVAR(weaponCache)`
HashMap, the way `smoke/GVAR(cmWeaponCache)` and `supply/GVAR(capabilities)` already
do. Ammo counts are live and read per call; classification is not and is read once
per class. The submenu is built at menu-open, never per tick, so the `format` in the
label is not on a hot path.

## The aim session

Client-local and modal. `fnc_beginAiming` records the pending strike in
`GVAR(aiming)`, registers `fnc_drawAim` on `rtz_core`, and installs handlers via
`fnc_handleAimInput`, which hands back `[[eventType, id], ...]` so `fnc_endAiming`
removes precisely those and leaves ZEN's own handlers on the same display alone —
the contract `path/fnc_handleInput` already uses.

- `MouseButtonDown` (button 0) — latch the aim point from
  `zen_common_fnc_getPosFromScreen`. Consumed.
- `MouseMoving` — update the live bearing from aim point to cursor. Not consumed.
- `MouseButtonUp` (button 0) — commit via `fnc_orderStrike`, then `fnc_endAiming`.
  Consumed.
- `MouseButtonDown` (button 1) and `KeyDown` (Escape) — cancel. Consumed.

Unlike `path`, this session **is** opened by clicking a context-menu entry, so it needs
the "ignore the frame we started on" guard that `common/fnc_placementPreview` carries
and `path` explicitly does not: without it, the same click that picked the weapon would
latch the aim point instantly.

`fnc_drawAim` receives `rtz_core`'s shared frame context and draws: a ring at the aim
point, an arrow through it along the current bearing, and the slant range. It tints
invalid (aircraft died, went non-local, ran dry) so the curator sees a dead order
before releasing.

## The strike engine

One record per striking aircraft in `GVAR(active)`, indexed by macros in
`script_component.hpp`:

```cpp
#define STRIKE_PLANE     0   // the aircraft
#define STRIKE_DRIVER    1   // the unit whose AI this strike disabled
#define STRIKE_AIM       2   // aim point ASL
#define STRIKE_BEARING   3   // direction of flight, degrees
#define STRIKE_WEAPON    4   // [weapon, muzzle, turretPath, type]
#define STRIKE_PHASE     5
#define STRIKE_START     6   // run-in start point ASL
#define STRIKE_RESTORE   7   // captured AI flags / behaviour / combat mode / flyInHeight
#define STRIKE_RAIL      8   // origin, velocity, vectorDir, vectorUp, t0 - filled on entry to RUN
#define STRIKE_LASER     9   // objNull until the firing window opens
#define STRIKE_SHOTS    10
#define STRIKE_NEXTFIRE 11
#define STRIKE_PHASE_AT 12   // deadline for the current phase
#define STRIKE_DEADLINE 13   // hard deadline for the whole strike
#define STRIKE_CHECK    14   // next throttled-condition time
```

### Three phases, not four

Firing is a **flag inside the run**, not a phase of its own, because the rail has to
keep driving the aircraft while it shoots. That is how the module does it — a nested
loop inside the flight loop — and splitting them would leave two things owning the
aircraft's velocity at once.

**`PHASE_INGRESS`.** The run-in start is
`_aim getPos [RUN_IN_DISTANCE, _bearing + 180]`, at
`getTerrainHeightASL + RUN_IN_ALTITUDE`. Each tick, `fnc_steerToward` rotates the
current heading toward that point by at most `TURN_RATE * dt`, sets velocity along the
new heading at cruise, and sets attitude with bank proportional to the turn actually
applied. This is the whole of the ingress geometry: a target behind the aircraft
produces a reversal because the rotation simply takes longer, with nothing precomputed.

Exits when the aircraft is within `RUN_IN_CAPTURE` of the start point **and** its
heading is within `HEADING_TOLERANCE` of the ordered bearing. Both, so it cannot drop
onto the rail sideways.

**`PHASE_RUN`.** On entry, the rail is captured: origin = current position ASL,
`vectorDir` = origin `vectorFromTo` aim, velocity = that direction times cruise,
`vectorUp` = current, pitch from `-90 + atan (range / altitude)` via
`BIS_fnc_setPitchBank`, duration = `range / cruise`. Each tick then calls
`setVelocityTransformation` with the aim point raised by
`_offset + _fireProgress * AIM_RAISE` — the module's own fudge, which walks the burst
instead of stacking it on one spot. `_offset` is `20` for `TYPE_MISSILE` and `0`
otherwise.

When slant range crosses `RELEASE_RANGE` for the weapon's type, the firing window
opens: create the laser target (`LaserTargetE`/`LaserTargetW` by side, `createVehicle`
with `"NONE"` so it is not curator-editable), `reveal`/`doWatch`/`doTarget`, then
`fireAtTarget [_laser, _weapon]` every `FIRE_DELAY`. The window closes on
`FIRE_DURATION` elapsed, the shot cap, or the weapon running dry.

**`PHASE_EGRESS`.** Restore, `flyInHeight`, `doMove` to a point `EGRESS_DISTANCE`
further along the bearing, delete the laser target, deregister after `EGRESS_SETTLE`.

### Constants

In `script_component.hpp`. Run-in geometry from Wargame, firing figures from the
module, shot cap from Wargame.

```cpp
#define RUN_IN_DISTANCE   1500   // m, from the aim point to the run-in start
#define RUN_IN_ALTITUDE    750   // m above terrain at the run-in start
#define RUN_IN_CAPTURE     150   // m, close enough to drop onto the rail
#define HEADING_TOLERANCE   15   // deg, aligned enough to drop onto the rail
#define EGRESS_DISTANCE   4000   // m beyond the aim point

#define TURN_RATE           12   // deg/s, ingress steering cap
#define BANK_MAX            60   // deg at full turn rate
#define CRUISE_COEF        0.5   // fraction of the aircraft config maxSpeed
#define CRUISE_MIN          40   // m/s floor

#define FIRE_DURATION        3   // s, firing window
#define FIRE_DELAY         0.1   // s between fireAtTarget calls
#define AIM_RAISE           12   // m per unit of fire progress
#define MAX_SHOTS           26   // 1 instead when weaponLockSystem != 0

#define INGRESS_TIMEOUT    120   // s
#define RUN_TIMEOUT         40   // s
#define EGRESS_SETTLE        3   // s
#define STRIKE_TIMEOUT     180   // s, hard deadline for the whole strike
#define CHECK_INTERVAL    0.25   // s, throttle for the abort conditions

#define MIN_AIM_DRAG        25   // m of world drag below which the bearing falls
                                 // back to the aircraft's current heading
```

Cruise is derived per aircraft as `(maxSpeed * CRUISE_COEF) / 3.6`, floored at
`CRUISE_MIN`, rather than the module's flat `115` — because a Buzzard and a Caesar BTT
have no business flying the same rail. `CRUISE_COEF` is Wargame's attack-run figure
(`maxSpeedOG * 0.5`), **not** its lower approach figure: at `0.25` a light propeller
aircraft would be flown at a walking pace and only the floor would rescue it, which
means the floor rather than the aircraft would be deciding its speed.

`RELEASE_RANGE` is a per-type table, which is the whole reason the weapon is chosen
*before* the aim rather than after:

| Type | Release range |
|---|---|
| `TYPE_BOMB` | 1200 m |
| `TYPE_MISSILE` | 1500 m |
| `TYPE_ROCKET` | 900 m |
| `TYPE_GUN` | 700 m |

### Cadence

One `CBA_fnc_addPerFrameHandler` at every frame, created by the first strike and
destroyed by the last. Per-frame is what the rail needs to stay smooth, and is what
the module uses — but **only the rail and the arrival test run at that rate.** The
abort conditions change on human timescales and are throttled to `CHECK_INTERVAL`,
exactly as `slide/fnc_slideTick` does.

This is a per-frame cost in a mod whose conventions warn about per-frame costs. It is
acceptable here because a strike *terminates* — unlike a tag overlay it is not live for
hours — and because the registry is bounded to one record per aircraft and the whole
run carries a hard `STRIKE_TIMEOUT`.

## Failure, locality, teardown

**`fnc_endStrike` is the only exit** from every phase and every abort. It restores
precisely what `fnc_executeStrike` captured — `enableAI` for MOVE / TARGET /
AUTOTARGET on the captured driver, `setBehaviour`, `setCombatMode`, `flyInHeight` —
deletes the laser target, removes the record, and destroys the per-frame handler when
the registry empties.

Two traps the codebase has already paid for, both of which apply:

- **The restore must land where the aircraft is now.** A strike that ends *because*
  ownership moved would otherwise restore into thin air and leave a plane with its AI
  permanently disabled. `fnc_endStrike` therefore takes a local flag and targets
  `QGVAR(release)` at the new owner for the half it cannot apply itself — the contract
  `slide/fnc_endSlide` already carries. The driver is **captured at order time** rather
  than read at teardown, for the same reason `slide` captures its driver: the unit in
  the seat at teardown may not be the unit whose AI was disabled.
- **A re-order must replace, not stack.** `fnc_executeStrike` calls `fnc_endStrike` on
  any existing record for that aircraft before building the new one. This is the bug
  shape `attack/fnc_addWaypoint` carries a comment about — a curator who re-tasks
  repeatedly otherwise accrues one watch per order.

Abort conditions, all evaluated on the `CHECK_INTERVAL` throttle and all routed through
`fnc_endStrike`:

- aircraft dead or null — covers a curator deleting it mid-run
- driver dead or null
- aircraft no longer local (`!local _plane`) — the honest outcome, as
  `path/fnc_flightTick` concludes for the same reason
- chosen weapon dry before the firing window opened
- current phase deadline blown
- `STRIKE_TIMEOUT` blown

Every `waitUntilAndExecute` in the component takes a timeout and a timeout branch that
performs the same cleanup, so a case that lands just past the deadline is still handled
on the way out.

On the aiming side, `fnc_endAiming` is likewise the only exit — from commit, from
Escape, from RMB, and from the curator display closing under the session. A session
left open is a renderer on `rtz_core`'s shared frame loop for the rest of the mission.

## Settings and text

`initSettings.inc.sqf` declares one CBA setting, `GVAR(enabled)` — `CHECKBOX`,
**default `false`**, **Global** scope — matching `mine/initSettings.inc.sqf` exactly in
name, default and scope. It is initialised in `XEH_preInit` so no path can read it nil.
Everything else is a compile-time `#define`, since the constants are tuning rather than
per-server policy.

Two properties of that setting are load-bearing rather than stylistic:

- **Default off.** This is a new, opt-in system that takes an aircraft off its AI and
  flies it on rails. No mission should get that for free by upgrading the mod, which is
  the same reasoning `rtz_path` records for its own default-off `enable`.
- **Global, not client-local.** The two halves of this component run on *different
  machines*: the aim session runs on the curator's client and `fnc_executeStrike` runs
  wherever the aircraft is local. If the two disagreed, a curator with the feature on
  could send `QGVAR(execute)` to a machine that never expected to receive it. `rtz_path`
  carries this exact hazard for its commit event and resolves it the same way.

Because the setting is global rather than trusted, `fnc_executeStrike` re-checks
`GVAR(enabled)` on arrival and drops the event if it is off. The condition on the
curator's client is a UI gate, not an authorization.

`stringtable.xml` carries every user-facing string — the root action name, the weapon
row format, and the failure messages shown through `zen_common_fnc_showMessage`
("no usable ordnance", "aircraft is not airborne", "strike aborted"). No hardcoded
strings anywhere, and `hemtt check` validates the file.

The root action sits at the context-menu **root**, not under a submenu — the same place
`attack`, `assemble` and `smoke` sit — and is declared in this component's own
`CfgContext.hpp`.

## Verification

There is no SQF test runner in this repo, so verification is `hemtt check` (which the
Stop hook runs) plus an in-game matrix in `.hemtt/missions/test.Altis`:

1. Jet with bombs, target ahead — ordinary run.
2. Target directly **behind** the aircraft — the turn-rate steering must produce a
   clean reversal, not a corkscrew. **This is the item that decides whether turn-rate
   steering was the right call.**
3. Gun run vs. bomb run on the same aircraft — visibly different release ranges.
4. Aircraft shot down mid-run — no orphaned laser target, no plane left with AI
   disabled.
5. Second strike ordered while one is running — replaced, not stacked.
6. Escape mid-aim — renderer unregistered, no handlers left on the display.
7. Aircraft with no usable ordnance, or on the ground — the action does not appear.
8. Ownership transferred mid-strike via `rtz_control` — the strike ends and the plane
   flies normally afterwards. **This is the item most likely to break first.**

## Known limitations and upgrade path

- **Accuracy is module-grade.** Without projectile re-guidance, dumb bombs land near
  the aim point rather than on it. The upgrade is a `FiredMan` handler in `fnc_release`
  that steers each projectile onto the aim point and walks successive shots along the
  bearing, which is what Wargame does. `fnc_release` is a separate function so this
  lands without touching the engine.
- **Planes only.** A helicopter profile is a second row in the constants table plus a
  no-dive attitude rule.
- **One pass.** Repeat passes would loop `PHASE_EGRESS` back into `PHASE_INGRESS` with
  a pass cap and a cancel path.
- **The aircraft's prior orders are discarded.** Capturing and restoring waypoints
  would make a strike an interruption rather than a replacement.
- **3D view only.** Map support is a `fnc_drawAimMap` plus a `Draw` handler on
  `IDC_RSCDISPLAYCURATOR_MAINMAP`.
