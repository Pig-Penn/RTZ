# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Real-Time Zeus (RTZ) is an Arma 3 mod written in SQF that adds real-time strategy elements to the Zeus interface. It depends on [CBA A3](https://github.com/CBATeam/CBA_A3) and [Zeus Enhanced (ZEN)](https://github.com/zen-mod/ZEN), and follows the [ACE3 coding guidelines](https://ace3.acemod.org/wiki/development/coding-guidelines) and CBA's modular component structure — the same conventions ACE3 and ZEN use.

## Commands

Building uses [HEMTT](https://hemtt.dev):

```
hemtt check
```

## Architecture

**Component structure.** The mod is split into `addons/` components, each an independent PBO: `main` is the framework core (prefix, version, CBA/ZEN dependency declarations in `CfgSettings.hpp`). New features should be added as new components under `addons/`, each depending on `rtz_main`, following the same skeleton:
- `config.cpp` — `CfgPatches` (name, `requiredAddons`, version) plus includes for `CfgEventHandlers.hpp` / `CfgContext.hpp` / settings
- `script_component.hpp` — defines `COMPONENT`/`COMPONENT_BEAUTIFIED`, includes `script_mod.hpp` then `script_macros.hpp`, and holds that component's visual/tunable `#define`s
- `XEH_PREP.hpp` — `PREP(fncName)` for every function in `functions/`, compiled once via `XEH_preInit.sqf`
- `XEH_preStart.sqf` / `XEH_preInit.sqf` / `XEH_postInit.sqf` — CBA Extended Event Handler lifecycle hooks (declared in `CfgEventHandlers.hpp`)
- `functions/fnc_*.sqf` — one function per file, standard SQF header comment (Author/Arguments/Return Value/Example/Public)

**Macro conventions** (from CBA's `script_macros_common.hpp`, included via `addons/main/script_macros.hpp`): `GVAR(x)` / `QGVAR(x)` for component-namespaced globals, `FUNC(x)` / `QFUNC(x)` for component-namespaced functions, `EGVAR`/`GETGVAR` for reaching into another component's globals, `LSTRING`/`CSTRING`/`LLSTRING` for stringtable lookups. `PREP(fncName)` compiles via `CBA_fnc_compileFunction` (cached) unless `DISABLE_COMPILE_CACHE` is defined in that component's `script_component.hpp`, in which case it falls back to a plain `compile preprocessFileLineNumbers`.

**ZEN integration**: the context menu action is declared in `CfgContext.hpp` (`zen_context_menu_actions`), calls `fnc_toggleUnits` on the selected/hovered objects, and its label is kept in sync (Show ↔ Hide) by `fnc_modifyAction`. `fnc_getUnits` normalizes the ZEN selection — expanding vehicles to their crew — into a flat unit list; every entry point into `unit_info` goes through it.

**Settings**: all settings are CBA settings (`CBA_fnc_addSetting`, client-side) registered in `initSettings.inc.sqf`, read at draw-time via `GVAR(...)`.
