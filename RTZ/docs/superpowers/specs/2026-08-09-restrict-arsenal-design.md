# Restrict — Arsenal Gate

**Date:** 2026-08-09
**Component:** `rtz_restrict`
**Status:** Approved, not yet implemented

## Problem

`rtz_restrict` gates curator *servicing* — heal, repair, rearm, refuel, skill — to the
curator's editing areas. The arsenal walks straight around it. A curator who cannot
rearm an out-of-zone squad through the Ammo slider can open the arsenal on any man in
it and hand out full magazines, a fresh launcher, and a medkit.

Closing that requires a separate toggle, because arsenal access and servicing access
are not the same permission. A mission may want free servicing and locked loadouts, or
the reverse.

## Scope

Curator-side only. This restricts what a Zeus may open on a unit; it does not touch
what players may do at an arsenal crate.

Three curator entry points reach the arsenal, and all three are gated. Anything less
is not a restriction — the context menu is two clicks from the attributes window.

| Entry point | ZEN location |
| --- | --- |
| "Arsenal" button, Object attributes window | `zen_attributes` display registry, buttons array |
| Context menu → Loadout, and Loadout → Edit | `zen_context_menu_actions` config, `Loadout` class |
| Zeus module tree → Arsenal | `CfgVehicles >> zen_modules_moduleArsenal` |

All three funnel into `zen_common_fnc_openArsenal`, which would be the single obvious
chokepoint — but CBA compiles ZEN's functions final (`compileScript [_file, true]` in
`CBA_fnc_compileFunction`), so it cannot be wrapped by reassignment. Each entry point
is therefore gated where it is *invoked* rather than where it converges.

## Non-goals

Recorded here so a later reader knows these were considered and declined, not missed:

- **Context-menu servicing.** ZEN's context menu carries its own Heal / Repair /
  Rearm / Refuel actions, and the existing "Restrict Servicing" setting does not gate
  them. That bypass predates this work and stays open; it goes on the to-do list.
- **Other loadout writes.** `Loadout > Paste`, `Loadout > Reset` and
  `Loadout > SwitchWeapon` rewrite a unit's loadout without the arsenal. Ungated.
- **Persistent arsenals.** ZEN's *Add Full Arsenal* and ACE's *Add Arsenal* modules
  attach an arsenal to an object for players to use. Player-facing, out of scope.
- **ZEN's Inventory editor.** A separate display that edits container contents.

## Design

### Setting

One new CBA checkbox alongside the existing one, in the same category:

```sqf
[
    QGVAR(arsenal), "CHECKBOX",
    [LSTRING(Arsenal), LSTRING(Arsenal_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;
```

**Global**, like `QGVAR(enabled)` — a permission, not a display preference, so every
curator on the server plays under the same rule.

**Default `false`.** Unlike `QGVAR(enabled)`, this restriction is new; existing
missions keep their current behaviour until someone ticks the box.

Independent of `QGVAR(enabled)`, not nested under it.

### `FUNC(canEditEntity)` — the per-entity predicate

Every arsenal surface acts on exactly one entity: `_entity` for the attributes button,
`_hoveredEntity` for the context menu, `attachedTo _logic` for the module. The existing
`FUNC(canEdit)` answers a different question — whether a whole *selection scope* is in
zone — and its `SCOPE_*` cache is indexed by scope, so it does not fit.

```
Arguments: 0: Entity <OBJECT>
Return:    Editable <BOOLEAN>
```

Same semantics as `FUNC(canEdit)`, narrowed to one position:

- null curator → `true` (not a curator, nothing to restrict)
- no editing areas → `true` (the restriction never applies until one exists)
- `curatorEditingAreaType` honoured, compared against an explicit `false` exactly as
  `FUNC(canEdit)` does, so an unexpected value falls back to the whitelist reading
- dead or null entity → `true`, so a blocked verdict never depends on a corpse

It does **not** read `GVAR(arsenal)`. The setting check lives at each call site, which
keeps the predicate reusable if a later restriction needs it.

No cache. It runs a handful of times per menu build or window open, not per tick, and a
per-entity cache would be a bounded-HashMap problem for no measurable gain.

### Shared area walk

`FUNC(canEdit)` and `FUNC(canEditEntity)` both need "is this position inside an area,
and does that agree with `curatorEditingAreaType`". The whitelist/blacklist reading is
the subtle half, so it lives in exactly one place — a macro in `script_component.hpp`:

```cpp
// _areas entries are [id, centre, radius]. editableInside is
// curatorEditingAreaType compared against an explicit false, so an unexpected
// value reads as the usual whitelist rather than blocking everything.
#define IN_EDITABLE_AREA(pos,areas,editableInside) \
    (((areas findIf {pos distance2D (_x select 1) <= (_x select 2)}) != -1) isEqualTo editableInside)
```

A macro rather than a function because it sits inside `FUNC(canEdit)`'s per-entity
`findIf` — a call per entity per area walk is exactly the kind of per-tick cost the
component conventions warn about.

`FUNC(canEdit)` keeps its current structure otherwise: it still fetches
`curatorEditingArea` and `curatorEditingAreaType` once and reuses both across the whole
target list, and its `findIf` inverts to the same verdict it produces today.

### Gate 1 — Attributes window button

Extends the loop in `FUNC(initGate)` that already wraps the Damage button. ZEN localizes
button names at registration, so the row is matched on `localize "STR_A3_Arsenal"`.

ZEN's original condition is stashed in `GVAR(arsenalCondition)` and replaced with a
plain code literal — no `compile` over ZEN's own source, matching the reasoning already
recorded in `FUNC(initGate)`:

```sqf
_x set [3, {
    (_this call GVAR(arsenalCondition))
    && {!GVAR(arsenal) || {[_this] call FUNC(canEditEntity)}}
}];
```

`_this` is the entity — ZEN evaluates button conditions as `_entity call _condition`.

ZEN checks the condition both when creating the button and when it is clicked, so a
zone lost while the window sat open is caught. Out of zone the button simply does not
appear, the same behaviour the Damage button already has.

The `isNil` guard the Damage wrapper uses is repeated, so a second `initGate` run cannot
chain the wrapper to itself.

### Gate 2 — Zeus Arsenal module

`zen_modules_fnc_initModule` resolves a module's function through
`getText (configOf _logic >> "function")`, so overriding that config entry is the hook.
`addons/restrict/CfgVehicles.hpp`:

```cpp
class CfgVehicles {
    class zen_modules_moduleBase;
    class zen_modules_moduleArsenal: zen_modules_moduleBase {
        function = QFUNC(moduleArsenal);
    };
};
```

`FUNC(moduleArsenal)` reads the attached unit *without* consuming the logic, so the
allowed path can hand the logic to ZEN untouched:

```sqf
params ["_logic"];

private _unit = attachedTo _logic;

if (GVAR(arsenal) && {!isNull _unit} && {!([_unit] call FUNC(canEditEntity))}) exitWith {
    deleteVehicle _logic;
    [LLSTRING(MsgOutsideZone)] call zen_common_fnc_showMessage;
};

_this call zen_modules_fnc_moduleArsenal
```

The delegate is passed `_logic`, not the unit — ZEN's function takes the logic, deletes
it itself, and owns the null / non-infantry / dead cases and their messages. An allowed
placement is therefore indistinguishable from stock ZEN. Only the blocked path deletes
the logic here, because ZEN never gets to.

A logic dropped on empty ground has a null `attachedTo` and falls through to ZEN, which
reports "no unit selected" as it always did.

Module functions run only where the logic is local — the placing curator's client — so
`getAssignedCuratorLogic player` is the right curator to test against.

### Gate 3 — Context menu

Config patch in `addons/restrict/CfgContext.hpp`, the mechanism eleven other RTZ
components already use to extend `zen_context_menu_actions`.

`FUNC(getActiveActions)` does not evaluate a parent's children when the parent's
condition is false. Gating `Loadout`'s condition would therefore hide Copy, Paste, Reset
and SwitchWeapon along with it — more restriction than this feature is scoped for. So
the two arsenal paths are gated differently:

```cpp
class zen_context_menu_actions {
    class Loadout {
        // condition left alone: it keeps the submenu — and Copy/Paste/Reset/
        // SwitchWeapon with it — alive out of zone
        statement = QUOTE(_hoveredEntity call FUNC(openArsenal));
        class Edit {
            condition = QUOTE(_hoveredEntity call FUNC(canEditLoadout));
            statement = QUOTE(_hoveredEntity call FUNC(openArsenal));
        };
    };
};
```

- **`Loadout > Edit`** — condition gated, so the entry disappears out of zone,
  consistent with the Damage and Arsenal buttons
- **`Loadout` root** — statement gated, so clicking the parent row shows
  "Outside an editing zone" instead of opening the arsenal

`FUNC(canEditLoadout)` = `(_this call zen_context_actions_fnc_canEditLoadout) &&
{!GVAR(arsenal) || {[_this] call FUNC(canEditEntity)}}` — ZEN's own predicate is called
rather than reimplemented, so alive/`CAManBase` stays in sync with ZEN.

`FUNC(openArsenal)` = gate, then `_this call zen_common_fnc_openArsenal`, else message.
Both the root and `Edit` route through it, so the statement cannot be reached by a path
that skipped the condition check.

`requiredAddons` gains `zen_context_menu` and `zen_modules`; `zen_common` and
`zen_attributes` are already listed. Load order is what makes the config patches land
on top of ZEN's classes rather than under them.

## Files

| File | Change |
| --- | --- |
| `initSettings.inc.sqf` | new checkbox |
| `functions/fnc_canEditEntity.sqf` | new — per-entity predicate |
| `functions/fnc_canEditLoadout.sqf` | new — context-menu condition |
| `functions/fnc_openArsenal.sqf` | new — gated context-menu statement |
| `functions/fnc_moduleArsenal.sqf` | new — gated module function |
| `functions/fnc_canEdit.sqf` | use the shared area walk |
| `functions/fnc_initGate.sqf` | wrap the Arsenal button |
| `script_component.hpp` | `IN_EDITABLE_AREA` macro |
| `XEH_PREP.hpp` | register the four new functions |
| `config.cpp` | `requiredAddons`, include the two new config files |
| `CfgVehicles.hpp` | new — module function override |
| `CfgContext.hpp` | new — Loadout patch |
| `stringtable.xml` | `Arsenal`, `Arsenal_Description` |
| `docs/Ramblings.md` | tick item 8; record the context-menu servicing gap |

## Verification

`hemtt check` must pass — it validates configs and stringtables, and the Stop hook runs
it regardless.

In-game, with the setting on and at least one editing area, against a unit outside it:

1. Object attributes window shows no Arsenal button; a unit inside still shows it
2. Context menu → Loadout → Edit is absent; Copy, Paste, Reset and SwitchWeapon remain
3. Context menu → Loadout clicked directly shows "Outside an editing zone"
4. Arsenal module dropped on the unit shows the message and opens nothing; dropped on a
   unit inside, it opens normally
5. With the setting off, all four behave exactly as stock ZEN
6. With the setting on and the curator holding no editing areas, all four behave exactly
   as stock ZEN
