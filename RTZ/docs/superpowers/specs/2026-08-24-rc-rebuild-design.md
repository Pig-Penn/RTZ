# Remote-control rebuild — design

**Date:** 2026-08-24
**Status:** implemented and confirmed working in-game (2026-08-24)
**Components:** `addons/control/` only

## Summary

A unit released from Zeus remote control comes back unable to aim. It turns toward a
target and never puts the gun on it — combat-ineffective, and invisible until it fails
to shoot. This is engine bug **T179189**, not an RTZ fault.

`rtz_control`'s existing reset clears the *pose* the unit was let go in. That is a real
and separate fix, and it works. It does not touch the aiming corruption, and nothing
short of recreating the unit does.

This replaces the pose reset with a **full unit rebuild**: a new unit of the same type
in the same group, carrying the old one's state, with the old one deleted. It fires
automatically on release, behind the setting that already governs this.

## The finding

A remedy ladder (`scratchpad/rc-aiming-ladder.sqf`) was run in-game against a live
broken unit, cheapest candidate first, stopping at the first success:

| # | Attempt | Result |
|---|---|---|
| 0 | RTZ's existing "Reset" action — LAMBS hard `taskReset`, new group, `joinSilent` | **failed** |
| 1 | `disableAI "ALL"` then `enableAI "ALL"` — force the AI subsystem to restart | **failed** |
| 2 | Re-apply every skill value (`aimingAccuracy`, `aimingShake`, `aimingSpeed`, …) | **failed** |
| 3 | Re-seat the weapon — `setUnitLoadout` + `selectWeapon primaryWeapon` | **failed** |
| 4 | Fresh group via `createGroup` + `joinSilent` | **failed** |
| 5 | Full unit rebuild — `createUnit`, copy state, `deleteVehicle` the original | **works** |

Steps 1–4 are the entire space of cheap remedies. That 0 fails is the load-bearing
result: it means the LAMBS hard reset already shipped in `fnc_resetApply` can never fix
this, so there is no version of "make the existing reset better" that resolves it.
Recreation is not the heavy option, it is the only option.

## Reference implementation

**`jac_wargameMain.sqf:2040–2140`** (Zeus Wargame). Wargame hit the same bug and reached
the same conclusion, and its comment says so outright:

> `///// when exiting direct control, create a new unit that is the exact same, in order to fix an issue with the AI aiming`

Its rebuild is the floor for the carry-over list below, not a wish list — every field it
copies is a field it presumably lost first. Two things it does that we deliberately
change:

- It captures the variable snapshot at remote-control **start** (`jac_wargameMain.sqf:1996`),
  so anything set during the control session is lost. We capture at **release**.
- It re-adds the unit to the **releasing curator's** module only
  (`addCuratorEditableObjects` at `:2118`). A unit editable by several curators comes
  back editable by one. We re-add for every curator that had it.

Wargame's generic variable sweep is otherwise sound and is adopted wholesale: it walks
`allVariables _unit`, keeps `[name, value]` for every non-nil entry, and re-applies them
after the rebuild.

## Decisions

| Decision | Choice | Why |
|---|---|---|
| Trigger | **Automatic on release** | The break is invisible until a unit fails to shoot, so a curator will not know to ask for it. This is what the reset feature is *for*. |
| Setting | **Reuse `GVAR(enableRcReset)`**, default stays `true` | It already exists, is per-client, and its whole purpose is "unstick a released unit". The rebuild becomes how it does that rather than a second switch to reason about. Its stringtable description is rewritten to say the unit is recreated. |
| Carry-over depth | **Wargame's engine list + RTZ's own state** | A rebuilt unit stays a first-class RTZ citizen rather than a stranger the mod has forgotten about. |
| Migration mechanism | **None — no event, no listeners** | A unit that can be remote controlled is never puppeted by `path` and never mid-errand for `assemble`, so no component is holding hand-added state on it. There is nothing to migrate and nobody to tell. |
| Variable locality | **Re-applied public** | Wargame's choice, and forced: the engine offers no way to ask whether a variable was originally set public. |

## Why nothing else needs telling

CBA's Extended Event Handlers **re-run on `createUnit`**. Every handler ACE3, ZEN, LAMBS
and RTZ register through XEH is therefore re-attached to the new unit for free, along with
its `init` state. Only *hand-added* `addEventHandler` calls are lost.

A census of hand-added per-unit handlers on infantry across RTZ finds exactly four, and
none of them can be live on a unit arriving here:

| Component | Handler | Site | Why unreachable |
|---|---|---|---|
| `path` | `AnimDone` — puppet walk loop | `fnc_setPuppet.sqf:123` | A puppeted unit is not one a curator is remote controlling |
| `path` | `Hit` — combat pause | `fnc_setPuppet.sqf:135` | as above |
| `assemble` | `WeaponAssembled` on the gunner | `fnc_buildWeapon.sqf:157` | A unit mid-errand is not one a curator is remote controlling |
| `assemble` | `WeaponDisassembled` on the gunner | `fnc_packWeapon.sqf:133` | as above |

`control`'s own `GetIn`/`GetOut` pair (`fnc_dismountApply.sqf:82,90`) is on the *vehicle*,
not the man. `slide` and `airstrike` hold unit objects in long-lived `GVAR(active)`
registries and are unreachable for a stronger reason still: `RC_RESET_ELIGIBLE` rejects
any unit inside a vehicle, and both registries only ever contain crewed vehicles and their
drivers.

So this deletes an object nothing else in the mod is currently holding, and needs no
migration contract, no notification event and no listeners.

**If that ever stops being true** — if some component starts writing hand-added handlers or
transient errand state to units that *can* be remote controlled — the fix is an event
raised **before** the capture, so listeners release their state while the unit still
exists and it is never copied onto the replacement. Raising one afterwards would mean
un-copying, which is strictly worse. The reasoning is recorded in `fnc_rcRebuild`'s header
so the next person does not have to re-derive it.

## Architecture

```
zen_remoteControlStopped          (ex-controller's client)
        │
        ├─ fnc_rcReset            unchanged — pre-filter, then CBA_fnc_globalEvent
        │
        ▼  QGVAR(rcReset)  [global]
   every machine
        │
        ├─ fnc_rcResetApply       unchanged — waits out the ownership handover,
        │                         re-tests RC_RESET_ELIGIBLE in the statement
        │
        ▼  (on the machine that ends up owning the unit)
   fnc_rcRebuild
        │
        ├─ capture engine state + allVariables snapshot
        ├─ createUnit into the same group
        ├─ apply state, grant curators from the original, deleteVehicle _old
        └─ re-attach attachments, setPosATL, re-join group, restore leadership
```

Everything above `fnc_rcRebuild` is untouched. The global dispatch, the locality wait and
the `RC_RESET_ELIGIBLE` re-test in the statement are already correct for this and their
reasoning (a network handover still in flight at dispatch time, so no machine can name
the next owner) applies unchanged.

## Files

| File | Change |
|---|---|
| `addons/control/functions/fnc_rcRebuild.sqf` | **new** — the rebuild |
| `addons/control/functions/fnc_rcResetApply.sqf` | the pose-reset block (`doAnimation` / `setUnitPos` / `doWatch` / `lookAt`) replaced by a call to `FUNC(rcRebuild)`; guards and locality wait unchanged; diagnostic block stripped |
| `addons/control/script_component.hpp` | `RC_REBUILD_SETTLE`, `RC_AI_FEATURES` |
| `addons/control/XEH_PREP.hpp` | `PREP(rcRebuild);` |
| `addons/control/stringtable.xml` | `RcReset` / `RcReset_Description` rewritten — it now replaces the unit |
| `docs/Architecture.md` | `control` row: the reset now rebuilds |
| `docs/Knowledge Base/Gotchas.md` | T179189, and the XEH-survives-`createUnit` rule |

## The carry-over contract

Captured on the owning machine immediately before `createUnit`, applied immediately after.

**Engine state**

`typeOf`, group, whether it was group leader, `getPosATL`, `getDir`, `getUnitLoadout`,
`rank`, `face`, `name`, `setDamage` from `getDammage`, `getSuppression`, `captive`,
`unitPos`, `combatMode`, `isObjectHidden`, `synchronizedObjects`, `attachedObjects`,
`vehicleVarName` plus its `missionNamespace` binding.

**AI features** — all seventeen, read with `checkAIFeature` and re-applied globally, since
`disableAI` is machine-local and does not travel:

```
AIMINGERROR ANIM AUTOCOMBAT AUTOTARGET CHECKVISIBLE COVER FSM LIGHTS
MINEDETECTION MOVE NVG PATH RADIOPROTOCOL SUPPRESSION TARGET TEAMSWITCH WEAPONAIM
```

**Variables** — `allVariables _unit`, keeping `[name, value]` for each non-nil entry,
re-applied public. This is what carries RTZ's per-unit state (`path`'s `color`,
`assemble`'s contexts, `common`'s `approachOrder`, `supply`'s `claim`, `orders`'
`flyHeight`, `captive`'s `surrendered`/`captured`) and ACE medical state without a
hand-maintained list.

**Curator editability** — the set of curator modules whose `curatorEditableObjects`
contained the old unit, re-added for each.

## Timing and locality

The rebuild runs where the unit is local, which is what `fnc_rcResetApply`'s wait already
establishes. Wargame's `sleep 0.2` after `createUnit` and `sleep 0.1` after `deleteVehicle`
become bounded `CBA_fnc_waitAndExecute` steps, per the per-tick rule in CLAUDE.md — this
is unscheduled code and `sleep` is illegal in it regardless.

`hideObject` / `hideObjectGlobal` and the AI-feature re-application are global operations
and are remote-executed, matching Wargame. Everything else is local to the owning machine.

## Verification

`hemtt check` covers none of this — it is all runtime behaviour. In-game, with an enemy
rifleman ~50 m in front of a BLUFOR unit:

1. Take control, aim at the sky, release. The unit **engages and hits**. This is the
   whole point and the ladder's success criterion.
2. The unit is still selectable in Zeus, by every curator who could edit it before.
3. Its loadout, name, face, rank, damage and stance survive.
4. It is still in its original group, in formation, and still leads it if it led before.
5. `vehicleVarName` still resolves in the debug console.
6. A unit whose AI another RTZ order had deliberately disabled comes back still disabled,
   not silently switched on.
7. Release a unit on a dedicated server where the owner is a headless client — the
   rebuild happens on the HC, not the releasing curator's machine.

## Known limitations

- **Object identity changes.** Any mission-maker script, trigger or waypoint holding a
  direct reference to the old object breaks. Inherent to the only remedy that works.
- **Variables come back public.** Not recoverable; see Decisions.
- **A curator who disconnects mid-control** still never fires `zen_remoteControlStopped`,
  so the unit is never rebuilt. Pre-existing and upstream, unchanged by this.
- **Vehicle crew are excluded, and correctly so.** `RC_RESET_ELIGIBLE` rejects units in
  vehicles. This is not a gap: T179189 does not break the aiming of a remote-controlled
  crewman, so there is nothing to rebuild. Confirmed in-game. Rebuilding a seated crewman
  would mean recreating it into a specific seat for no benefit.
- **Hand-added event handlers on the old unit from mods outside RTZ** are lost. XEH
  handlers are not. Nothing can be done about the former from here.
