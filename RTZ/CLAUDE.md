# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Description

Real-Time Zeus (RTZ) is an Arma 3 mod written in SQF that adds real-time strategy elements to the Zeus system. It always follows the [ACE3 coding guidelines](https://ace3.acemod.org/wiki/development/coding-guidelines) and CBA's modular component structure — the same conventions ACE3 and ZEN use.

## References

Zeus Enhanced (ZEN), Community Base Addons (CBA), and LAMBS Danger FSM (LAMBS) will always be loaded alongside Real-Time Zeus (RTZ). Thus, you may utilize and reference their systems.

All other Arma 3 mods that are developed and structured correctly can be utilized as references for the development of Real-Time Zeus (RTZ). Advanced Combat Environment 3 (ACE3) is an example of a great reference.

## Usage

Real-Time Zeus (RTZ) will be used in servers with several curators, large numbers of units, and long operations lasting several hours. While it will not happen often, some players may connect and disconnect while the mission is in progress.

The units a curator controls will be units that are local to that curator in almost all cases.

## Environment & Verification

- A Stop hook (`.claude/settings.json`) runs `hemtt check` automatically at the end of every session and blocks with the error output if it fails. Fix any reported errors before finishing.
- Building/linting uses [HEMTT](https://hemtt.dev) (installed via winget, on PATH): `hemtt check`

## Architecture

See [docs/Architecture.md](docs/Architecture.md) for the component structure, the component skeleton, the `core` drawing/streaming contracts, and ZEN integration.

## Conventions

- Use the CBA/ACE3 macro family from `script_macros.hpp`: `GVAR`/`QGVAR`/`EGVAR`, `FUNC`/`EFUNC`, `LLSTRING`/`CSTRING`, `PREP`, etc. Never hand-roll `rtz_component_name` identifiers.
- One function per `fnc_*.sqf` file, registered in `XEH_PREP.hpp`.
- Update the component's `stringtable.xml` whenever adding user-facing text; `hemtt check` validates stringtables.
- Mind locality: orders are typically initiated on the curator's client and executed where the unit is local (CBA target events / remoteExec patterns already used throughout the codebase).
- To stop a `forEach` early, use `break`, and test at the **top** of the loop body. `exitWith` there exits only the current *iteration* — it is a `continue`. Three "stop at the first hit" parameters shipped written that way and were completely inert; see `docs/Knowledge Base/Gotchas.md` §2. For a pure existence test prefer `findIf`, which short-circuits natively.
- Anything that runs per tick or per frame is a **multi-hour** cost here (see Usage above): give every `waitUntilAndExecute` a timeout, bound every long-lived HashMap, and keep `format`/`str` off paths that run per entity per tick — cache the finished string instead.
