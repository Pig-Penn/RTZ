# Regroup CBA settings into thematic subcategories

## Context

Every RTZ component registers its settings under `[ELSTRING(main,DisplayName), LSTRING(DisplayName)]` — one CBA subcategory per component. With 17 components doing this (`path`, `slide`, `orders`, `control`, `common`, `delete`, `restrict`, `assemble`, `captive`, `smoke`, `mine`, `repair`, `supply`, `loot`, `economy`, `spotting`, `officer`), the "Real-Time Zeus" settings tree has 17 flat subcategory entries, several holding just one setting (`common`, `delete`, `restrict`, `smoke`).

The codebase already has a working precedent for something better: `addons/hud/initSettings.inc.sqf` and `addons/core/initSettings.inc.sqf` share one "Overlays" subcategory across two components, via `ELSTRING(core,CategoryOverlays)`. A code comment there documents the sharp edge — **CBA groups settings by the exact localized string, not the stringtable key**, so two components only land in the same bucket if they reference the literal same key. `addons/restrict/config.cpp` also has a comment describing a past mistake: `restrict` once borrowed `ELSTRING(common,DisplayName)` as a workaround for a missing string, which silently dragged `rtz_common` into its `requiredAddons` and dumped its settings under "Common". That's the failure mode to design around.

Goal: fold the 17 single-component subcategories into ~6 thematic ones (plus the `hud`/`core` ones, left as-is since they already work this way), without repeating the `restrict` mistake — i.e. without any component picking up a new `requiredAddons` dependency it doesn't otherwise need. `extras/` (`casualty`, `unit_info`, `vehicle_info`) is excluded — per `extras/README.md` it's unbuilt, unchecked, superseded code that HEMTT doesn't even compile.

## Approach

Centralize the new shared category strings in `addons/main/stringtable.xml`, and reference them via `ELSTRING(main, CategoryXxx)`. Every component already requires `rtz_main` (confirmed via `grep requiredAddons addons/*/config.cpp` — `rtz_main` is universal, `main` is the only component that doesn't list it), so this sharing introduces **zero new dependencies** anywhere — sidestepping exactly the coupling that bit `restrict`. This also keeps a single, discoverable home for every category label instead of picking an arbitrary "owner" component per group.

Each component's own `STR_RTZ_<Comp>_DisplayName` key stays in its stringtable untouched (still used elsewhere, e.g. `restrict`'s comment confirms these keys have a life outside settings) — only the `_category` array in `initSettings.inc.sqf` changes from `LSTRING(DisplayName)` to `ELSTRING(main, CategoryXxx)`.

### New groups (6 subcategories replacing 17)

| New subcategory | Components folded in | Settings |
|---|---|---|
| **Zeus Tools** | `common`, `delete`, `control`, `restrict` | 8 — curator-facing editing/UI toggles (context menu cleanup, delete, squad hide/reload/reset/ownership/dismount, restrict servicing to editing zones) |
| **Movement** | `path`, `slide`, `orders` | 12 — path planning, straight-line vehicle driving, move-order tuning (teleport distance/cooldown, heli height step) |
| **Field Actions** | `smoke`, `assemble`, `mine`, `repair` | 12 — context-menu actions performed on units/vehicles (countermeasures, raise/pack statics, mine placement, repair order) |
| **Personnel** | `captive`, `loot` | 7 — handling of surrendered/dead units |
| **Logistics & Economy** | `supply`, `economy` | 10 — resupply order tuning, curator income/points |
| **Combat Systems** | `spotting`, `officer` | 9 — detection/spotting, leadership aura zones |

`hud` (Dog Tags / Vehicle Tags / Overlays) and `core` (Overlays) are left untouched — they're the existing example this plan generalizes.

### Mechanical change per component

1. **`addons/main/stringtable.xml`**: add one `STR_RTZ_Main_CategoryXxx` key per new group (6 keys total), e.g. `STR_RTZ_Main_CategoryZeusTools` = "Zeus Tools", `STR_RTZ_Main_CategoryMovement` = "Movement", etc.
2. **Each of the 17 components' `initSettings.inc.sqf`**: change
   ```sqf
   private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];
   ```
   to
   ```sqf
   private _category = [ELSTRING(main,DisplayName), ELSTRING(main,CategoryXxx)];
   ```
   picking the right `CategoryXxx` per the table above. No other line in these files changes — settings, defaults, descriptions, locality comments all stay exactly as they are. `economy`'s file has a `forEach` inside the `deleteRefund` setting's `isServer` callback (line 1) — same one-line swap, nothing else touches it.
3. **`.claude/skills/new-addon/SKILL.md`**: leave its scaffold (`private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];`) as the default for genuinely new, ungrouped components — not part of this change, just noting it's the one place with the old pattern that isn't being touched, since new components should default to their own bucket until it's clear they belong in an existing theme.

### Verification

- `hemtt check` (the Stop hook already runs this) — validates every stringtable key referenced by `LSTRING`/`ELSTRING` actually exists, catching any typo'd `CategoryXxx` key immediately.
- Spot-check in-game or via a quick read of the built stringtable that the "Real-Time Zeus" CBA settings tree now shows 6 new grouped subcategories (plus the unchanged Dog Tags/Vehicle Tags/Overlays) instead of the 17 old ones, and that a setting that used to be findable under e.g. "Real-Time Zeus > Mines" is now under "Real-Time Zeus > Field Actions".
