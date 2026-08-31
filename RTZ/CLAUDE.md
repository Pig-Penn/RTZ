# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Real-Time Zeus (RTZ) is an Arma 3 mod written in SQF that adds real-time strategy elements to the Zeus system, following the [ACE3 coding guidelines](https://ace3.acemod.org/wiki/development/coding-guidelines) and CBA's modular component structure — the same conventions ACE3 and ZEN use.

It runs on servers with several curators, large numbers of units, and operations lasting several hours; players may connect and disconnect mid-mission. The units a curator spawns are local to that curator. Some units will have their simulation manually disabled when the fight is happening elsewhere.

## References

During development, you are encouraged to utilize online resources and websites, read Arma 3's source files, consult from other mods and repositories, and ask me questions.

Zeus Enhanced (ZEN), Community Base Addons (CBA), and LAMBS Danger FSM (LAMBS) are always loaded alongside RTZ and may be referenced directly. Any other well-structured Arma 3 mod is fair game as a reference too — ACE3 is a great example.

## Architecture

See [docs/Architecture.md](docs/Architecture.md) for the component structure, the component skeleton, the `core` drawing/streaming contracts, and ZEN integration.

## Conventions

- Use the CBA/ACE3 macro family from `script_macros.hpp`: `GVAR`/`QGVAR`/`EGVAR`, `FUNC`/`EFUNC`, `LLSTRING`/`CSTRING`, `PREP`, etc. Never hand-roll `rtz_component_name` identifiers.
- One function per `fnc_*.sqf` file, registered in `XEH_PREP.hpp`.
- Update the component's `stringtable.xml` whenever adding user-facing text; `hemtt check` validates stringtables.
- Mind locality: orders are typically initiated on the curator's client and executed where the unit is local (CBA target events / remoteExec patterns already used throughout the codebase).
- To stop a `forEach` early, use `break`, and test at the **top** of the loop body. `exitWith` there exits only the current *iteration* — it is a `continue`. Three "stop at the first hit" parameters shipped written that way and were completely inert; see `docs/Knowledge Base/Gotchas.md` §2. For a pure existence test prefer `findIf`, which short-circuits natively.
- Anything that runs per tick or per frame is a **multi-hour** cost here (see Overview above): give every `waitUntilAndExecute` a timeout, bound every long-lived HashMap, and keep `format`/`str` off paths that run per entity per tick — cache the finished string instead.

## Environment & Verification

- Building/linting uses [HEMTT](https://hemtt.dev) (installed via winget, on PATH): `hemtt check`
