# Supply Target Picker — Design

**Date:** 2026-09-06
**Component:** `rtz_supply`
**Source:** `docs/Ramblings.md` → Refine §4, "For the supply addon, add a picker like the one that the attack context menu button has."

## Summary

Replace `rtz_supply`'s blanket radius sweep with an aimed picker modelled on
`rtz_attack`'s destroy order. The curator selects supply vehicles, clicks
**Resupply**, and a `zen_common_fnc_selectPosition` session opens: a ring shows
each truck's service radius, the cursor names the service it would perform, and
one click services the single vehicle under it.

Every selected truck that can help the clicked vehicle contributes, which
requires the target claim to become **per-service** rather than exclusive per
target. That change also fixes an existing limitation: today a repair truck and
a fuel truck aimed at one damaged, empty tank contend for a single lock, so the
tank receives one service instead of both.

## Motivation

`FUNC(orderResupply)` currently resolves its own targets — everything
serviceable within `GVAR(serviceRadius)` of each selected truck — and the
curator has no say in it. Supply is finite (`getRepairCargo` / `getFuelCargo` /
`getAmmoCargo` deplete as the engine services), so "which vehicle gets the last
of it" is a real tactical decision the order does not currently expose.

`rtz_attack`'s destroy order already establishes the picker idiom in this
codebase: cursor label, colour swap, per-frame validity, one-shot click. This
brings supply into line with it.

## Accepted trade-off

The sweep is removed, not kept alongside. A parked column of five vehicles
therefore costs five menu-opens rather than one click. This is deliberate: the
picker is the better order when a truck is nearly dry, and one code path is
worth more than two. If the column case proves painful in play, re-arming the
picker on `Shift+click` (the shift state is already handed to the
`selectPosition` callback) is a small additive change to the click handler and
requires nothing else in this design to move.

## Behaviour

### Opening

The context entry keeps its existing `condition` (`FUNC(canResupply)`) and
`modifierFunction` (`FUNC(resupplyActionModifier)`). The entry still relabels
itself Repair / Refuel / Rearm when every selected truck offers exactly one
service, and that label is reused as the cursor's valid-state text.

`FUNC(orderResupply)` becomes the picker opener:

1. `_supplies = [_objects] call FUNC(getSupplyVehicles)`. Empty → `MsgSupplyEmpty`
   toast, no picker. (A truck can spend its last store between the menu being
   built and the click; this is the existing guard and its existing wording.)
2. Install the service-radius ring drawing.
3. `zen_common_fnc_selectPosition` with `_supplies` as the objects, so ZEN draws
   its own line from **every participating truck** to the cursor at no cost —
   the curator can see which trucks are in play.

### Aiming

Two resolvers, split by cost:

- **`FUNC(findServiceTarget)`** — `[_position, _supplies]` → the nearest vehicle
  to the click within `PICK_SNAP_RADIUS` that is also inside `GVAR(serviceRadius)`
  of at least one selected truck. Distance tests only, no deficit walk. Returns
  `objNull` when there is none. Mirrors `EFUNC(attack,findTarget)`.
- **`FUNC(serviceProviders)`** — `[_target, _supplies]` → the selected trucks
  that can actually help it: within radius, side-compatible, and carrying at
  least one service with a non-zero deficit that is not already claimed by
  another live truck. This is the expensive one — `FUNC(serviceDeficit)` walks
  every turret's magazines for the ammo term.

Cursor states, in resolution order:

| Condition | Label | Colour |
| --- | --- | --- |
| Target found, providers non-empty | `ActionResupply` (or Repair / Refuel / Rearm, per the action's own label) | `COLOR_VALID` |
| Target found, providers empty | `NothingNeeded` | `COLOR_NEUTRAL` |
| No target | `NoTarget` | `COLOR_INVALID` |

Out-of-range reads as `NoTarget` rather than earning its own wording: the ring
already draws the boundary, so the cursor does not need to restate it.

### Per-frame cost

The modifier function runs every frame the picker is open, and `serviceProviders`
walks magazines. Per CLAUDE.md, per-frame walks are the cost to guard against.
So:

- `findServiceTarget` (distance-only) runs every frame.
- `serviceProviders` is cached in the picker's argument array, keyed on the
  resolved target. It recomputes only when the target under the cursor changes,
  or when `PICK_REFRESH` (0.25 s) has elapsed since the last computation for
  that target.

A picker session therefore costs a handful of deficit walks, not one per frame.

### The ring

For the life of the picker, a ring at `GVAR(serviceRadius)` is drawn around each
selected supply vehicle:

- Map: `drawEllipse` on the curator map control.
- 3D: `RING_SEGMENTS` × `drawLine3D`.

`FUNC(drawServiceRadius)` owns both. Installed by the opener, torn down inside
the `selectPosition` callback — which fires on confirm *and* on every abort path
(ESC, pause menu, Zeus display closed, a selected truck deleted), so there is
exactly one teardown site and no way to strand the handlers.

### Clicking

The click re-resolves target and providers rather than trusting the cached frame
result — the cache is a drawing optimisation, not the order.

- Providers empty → `MsgNothingToService` toast, no event.
- Otherwise one `QGVAR(resupply)` server event carrying `[[truck, target], ...]`,
  one entry per provider, plus the ordering curator. `MsgResupplying` toast.

## Claim model

### Today

```sqf
_target setVariable [QGVAR(claim), [_supply, _until]];
```

One holder per target, for every service. Two trucks with **disjoint** stock
(repair and fuel) contend anyway, and the loser is dropped from the order
entirely.

### After

```sqf
// Indices match the order FUNC(supplyCapabilities) returns
_target setVariable [QGVAR(claim), [
    [byRepair, expires],  // CLAIM_REPAIR
    [byFuel,   expires],  // CLAIM_FUEL
    [byAmmo,   expires]   // CLAIM_AMMO
]];
```

`FUNC(serviceVehicles)` computes **granted** capabilities: the services this
truck carries, minus those currently held by a *different* live truck whose
claim has not expired. It then:

- measures its deficit against `_granted`, not against its full capabilities;
- claims only the granted slots;
- monitors only the granted services.

A repair truck and a fuel truck take disjoint slots and work one tank together.
Two fuel trucks still cannot both take `CLAIM_FUEL`, so the invariant the
existing comments rest on — *each job measures a deficit only it is closing* —
holds unchanged.

The existing free-slot rules carry over per slot: a slot is available when
nobody holds it, the holder is this same truck (a repeat order supersedes its
own job), the holder is dead, or the claim has expired. `CLAIM_GRACE` keeps its
role as the backstop for jobs that never reach `FUNC(endService)`.

## Single-target orders

One click produces one order per provider truck, each with exactly one target.
The multi-target machinery has no remaining caller, so the order collapses to a
single object rather than keeping a list that is always length 1.

- **`FUNC(serviceVehicles)`** — `[_supply, _target, _curator]`. Validates one
  target, computes granted capabilities, claims the granted slots, snapshots one
  deficit, fires one `QGVAR(service)` event, starts the job.
- **`FUNC(serviceTick)`** — loses the `_work` list, the mark-and-compact pass,
  the `_startTotal` subtraction for dropped targets, and the per-target claim
  release. Becomes: target dead or outside the radius → stop; otherwise
  `_progress = 1 - (live / start)`, then the existing stall detection and
  overlay drift re-stamp, unchanged in substance.
- **`FUNC(applyService)`** — `[_supply, _target, _capabilities]`. Drops the
  `forEach`; keeps the `local` guard, which is what makes the `actionNow`
  dispatch correct.
- **`FUNC(endService)`** — releases the granted claim slots still held by this
  truck. Reporting logic and its `_timedOut` / `_succeeded` reasoning are
  unchanged; the count it reports is now 0 or 1.

The overlay record keeps its shape as a one-element list:

```sqf
_supply setVariable [QGVAR(servicing), [[_target], time, _timeout]];
```

so `FUNC(gatherSupply)` and `FUNC(drawSupply)` need no changes at all. Two
trucks servicing one tank draw two lines from two origins, which is the correct
reading of what is happening.

## Consequence: `FUNC(findTargets)` collapses

With the sweep gone, `FUNC(findTargets)` has exactly one caller left —
`FUNC(canResupply)`, which asks for `_limit = 1`. It is an existence test, so it
becomes one: a `findIf` over `nearEntities` returning a boolean, keeping the
same side and deficit filters and the same short-circuit.

`MAX_SERVICE_TARGETS` is removed with it. That cap existed to stop one click
producing "a hundred-odd claims, a hundred-odd events and a hundred supply
lines"; one click can no longer produce more than one of each.

The menu condition itself is unchanged in meaning: the entry is still offered
only when some selected truck has work within its radius, so the picker never
opens on an order that cannot succeed.

## Files

**New**

- `functions/fnc_findServiceTarget.sqf`
- `functions/fnc_serviceProviders.sqf`
- `functions/fnc_drawServiceRadius.sqf`

**Rewritten**

- `functions/fnc_orderResupply.sqf` — picker opener and click handler
- `functions/fnc_serviceVehicles.sqf` — single target, granted capabilities, per-service claims
- `functions/fnc_serviceTick.sqf` — single target

**Trimmed**

- `functions/fnc_applyService.sqf` — single target
- `functions/fnc_endService.sqf` — per-service claim release
- `functions/fnc_findTargets.sqf` — existence test

**Edited**

- `script_component.hpp` — add `PICK_SNAP_RADIUS`, `PICK_REFRESH`,
  `RING_SEGMENTS`, `COLOR_VALID`, `COLOR_NEUTRAL`, `COLOR_INVALID`,
  `COLOR_RING`, `CLAIM_REPAIR` / `CLAIM_FUEL` / `CLAIM_AMMO`; remove
  `MAX_SERVICE_TARGETS`
- `stringtable.xml` — add `NoTarget`, `NothingNeeded`
- `XEH_PREP.hpp` — register the three new functions
- `XEH_postInit.sqf` — `QGVAR(resupply)` payload is now `[[truck, target], ...]`
- `CfgContext.hpp` — `statement` comment only; the statement expression is unchanged

**Untouched**

`fnc_canResupply`, `fnc_supplyCapabilities`, `fnc_serviceDeficit`,
`fnc_ammoRatio`, `fnc_getSupplyVehicles`, `fnc_resupplyActionModifier`,
`fnc_gatherSupply`, `fnc_drawSupply`, `initSettings.inc.sqf`

## Error handling

| Case | Behaviour |
| --- | --- |
| Picker aborted (ESC, Zeus closed, truck deleted) | Ring torn down, no event sent |
| `selectPosition` already active | ZEN calls back with `_confirmed = false`; treated as abort |
| Truck ran dry between menu and click | Providers empty → `MsgNothingToService` |
| Target's every relevant slot already claimed | Providers empty → `MsgNothingToService` |
| Target dies or leaves radius mid-service | `FUNC(serviceTick)` stops the job; no toast — the curator watched it |
| Supply truck destroyed mid-service | Existing `FUNC(endService)` guard: no toast |
| Stale or hand-crafted `QGVAR(resupply)` event | `FUNC(serviceVehicles)` re-validates type, nullity, liveness, kind, radius and side server-side, and recomputes capabilities from live cargo — all existing guards, retained |

## Verification

No test harness exists for SQF in this repository. Verification is:

1. `hemtt check` — builds and validates the stringtable.
2. In-game, in Zeus:
   - Ring appears at `serviceRadius` around each selected truck.
   - Cursor reads Refuel / Repair / Rearm / Resupply on a serviceable vehicle,
     `NothingNeeded` on a full one, `NoTarget` on empty ground and outside the ring.
   - Clicking one vehicle services only that vehicle.
   - A repair truck and a fuel truck selected together, aimed at one damaged and
     empty tank, both service it and draw two supply lines.
   - Two fuel trucks aimed at the same tank produce one order, not two.
   - A truck with no stock left drops off the menu entirely.
