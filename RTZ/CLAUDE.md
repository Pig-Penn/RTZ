# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Description

Real-Time Zeus (RTZ) is an Arma 3 mod written in SQF that adds real-time strategy elements to the Zeus interface. It always follows the [ACE3 coding guidelines](https://ace3.acemod.org/wiki/development/coding-guidelines) and CBA's modular component structure — the same conventions ACE3 and ZEN use.

## References

Zeus Enhanced (ZEN), Community Base Addons (CBA), and LAMBS Danger FSM (LAMBS) will always be loaded alongside Real-Time Zeus (RTZ). Thus, you may utilize and reference their systems.

All other Arma 3 mods that are developed and structured correctly can be utilized as references for the development of Real-Time Zeus (RTZ). Advanced Combat Environment 3 (ACE3) is an example of a great reference.

## Environment & Verification

- A Stop hook (`.claude/settings.json`) runs `hemtt check` automatically at the end of every session and blocks with the error output if it fails. Fix any reported errors before finishing.
- Building/linting uses [HEMTT](https://hemtt.dev) (installed via winget, on PATH): `hemtt check`

## Architecture

**Component structure.** The mod is split into `addons/` components, each an independent PBO. `main` is the framework core (prefix, version macros, CBA/ZEN dependency declarations, `script_macros.hpp`); `common` holds shared functions and the shared ZEN context-menu root (`CfgZenContext.hpp`); every other component depends on `rtz_main` (and usually `rtz_common`).

Current components:

| Component | Purpose |
|---|---|
| `main` | Framework core: prefix, version, macros, CBA/ZEN/LAMBS dependencies |
| `common` | Shared helpers: unit/squad/vehicle collection, skills, smoke deployment, stance, teleport, placement preview |
| `assemble` | AI orders to assemble/disassemble static weapons and UAVs from backpacks |
| `attack` | Order groups to find and destroy a target via waypoints |
| `captive` | Surrender/stand-down toggle, plus enemy-proximity capture that transfers the prisoner and pays out both curators |
| `control` | Squad control: LAMBS reset, squad reload, squad hide toggle |
| `dismount` | Unload-in-combat behavior for vehicle passengers |
| `economy` | Zeus point costs: categorization, cost registration, per-curator coefficients (`defaultCosts/`) |
| `loot` | AI orders to loot bodies/objects |
| `mine` | Mine placement, detection drawing, and disarm orders |
| `officer` | Officer auras and area buffs with cooldowns and monitors |
| `overlays` | Destination and target line overlays for groups |
| `repair` | AI orders to repair vehicles |
| `restrict` | Locks servicing attribute edits (health/fuel/ammo/skill) outside the curator's editing zones (any curatorEditingArea, not just officer-planted ones); sliders stay visible as info | 
| `reverse` | Order vehicles to reverse to a position (keybind) |
| `selection` | Selection info panel, unit/vehicle tags, vehicle data overlay |
| `spotting` | AI spotting system: contact callouts, 3D contact markers, curator display |
| `supply` | Supply vehicles repair/refuel/rearm the vehicles parked around them |

**Component skeleton.** New features are added as new components under `addons/`, following the same skeleton:
- `config.cpp` — `CfgPatches` (name, `requiredAddons`, version) plus includes for `CfgEventHandlers.hpp` / `CfgContext.hpp` / settings
- `script_component.hpp` — defines `COMPONENT`/`COMPONENT_BEAUTIFIED`, includes `script_mod.hpp` then `script_macros.hpp`, and holds that component's visual/tunable `#define`s
- `XEH_PREP.hpp` — `PREP(fncName)` for every function in `functions/`, compiled once via `XEH_preInit.sqf`
- `XEH_preStart.sqf` / `XEH_preInit.sqf` / `XEH_postInit.sqf` — CBA Extended Event Handler lifecycle hooks (declared in `CfgEventHandlers.hpp`)
- `functions/fnc_*.sqf` — one function per file, standard SQF header comment (Author/Arguments/Return Value/Example/Public)
- `initSettings.inc.sqf` — CBA settings (included from `config.cpp`); `initKeybinds.inc.sqf` for CBA keybinds
- `stringtable.xml` — ALL user-facing text goes through stringtable entries (`CSTRING`/`LSTRING` macros), never hardcoded strings

**ZEN integration.** Context menu actions are declared per-component in `CfgContext.hpp` (`zen_context_menu_actions`); `common/CfgZenContext.hpp` holds the shared RTZ context-menu root. Toggle-style actions keep their label in sync (Show ↔ Hide) via a `fnc_modifyAction` in their component. `common` provides the selection-normalization helpers (`fnc_collectUnits`, `fnc_collectSquads`, `fnc_collectVehicles`) that expand ZEN selections (e.g. vehicles → crew) into flat lists — entry points should go through them.

## Conventions

- Use the CBA/ACE3 macro family from `script_macros.hpp`: `GVAR`/`QGVAR`/`EGVAR`, `FUNC`/`EFUNC`, `LLSTRING`/`CSTRING`, `PREP`, etc. Never hand-roll `rtz_component_name` identifiers.
- One function per `fnc_*.sqf` file, registered in `XEH_PREP.hpp`.
- Update the component's `stringtable.xml` whenever adding user-facing text; `hemtt check` validates stringtables.
- Mind locality: orders are typically initiated on the curator's client and executed where the unit is local (CBA target events / remoteExec patterns already used throughout the codebase).
