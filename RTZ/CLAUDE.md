# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Description

Real-Time Zeus (RTZ) is an Arma 3 mod written in SQF that adds real-time strategy elements to the Zeus system. It always follows the [ACE3 coding guidelines](https://ace3.acemod.org/wiki/development/coding-guidelines) and CBA's modular component structure — the same conventions ACE3 and ZEN use.

## References

Zeus Enhanced (ZEN), Community Base Addons (CBA), and LAMBS Danger FSM (LAMBS) will always be loaded alongside Real-Time Zeus (RTZ). Thus, you may utilize and reference their systems.

All other Arma 3 mods that are developed and structured correctly can be utilized as references for the development of Real-Time Zeus (RTZ). Advanced Combat Environment 3 (ACE3) is an example of a great reference.

## Usage

Real-Time Zeus (RTZ) will be used in servers with several curators, large numbers of units, and long operations lasting several hours. While it will not happen often, some players may connect and disconnect while the mission is in progress.

## Environment & Verification

- A Stop hook (`.claude/settings.json`) runs `hemtt check` automatically at the end of every session and blocks with the error output if it fails. Fix any reported errors before finishing.
- Building/linting uses [HEMTT](https://hemtt.dev) (installed via winget, on PATH): `hemtt check`

## Architecture

**Component structure.** The mod is split into `addons/` components, each an independent PBO. `main` is the framework core (prefix, version macros, CBA/ZEN dependency declarations, `script_macros.hpp`); `common` holds shared functions and the shared ZEN context-menu root (`CfgZenContext.hpp`); every other component depends on `rtz_main` (and usually `rtz_common`).

Current components:

| Component | Purpose |
|---|---|
| `main` | Framework core: prefix, version, macros, CBA/ZEN/LAMBS dependencies |
| `common` | Shared helpers: unit/squad/vehicle collection, skills, smoke deployment, stance, teleport, placement preview, curator message reporting |
| `assemble` | AI orders to assemble/disassemble static weapons and UAVs from backpacks |
| `attack` | Order groups to find and destroy a target via waypoints |
| `captive` | Surrender/stand-down toggle (captive, AI disabled, hands-up pose), plus enemy-proximity capture: the prisoner is disarmed, joins his captor's group, transfers to the capturing curators, and both curators are paid half his economy value. Eligibility lives in one `CAN_SURRENDER` macro shared by the condition, collector, modifier and apply guard. `disableAI` does not travel with locality, so a `CAManBase` `"Local"` handler re-applies the state on whichever machine gains a surrendered unit. The capture watch (`fnc_captureTick`) is a shared per-frame engine over a server-side registry, created by the first surrender and destroyed by the last |
| `control` | Squad control: LAMBS reset, squad reload, squad hide/freeze toggle, ownership transfer for units left simulated elsewhere, and the dismount lock that stops a transport's AI crew/cargo bailing out (engine flags plus LAMBS force-eject suppression) |
| `delete` | Point-free deletion of units, vehicles, bodies and wrecks (context action + keybind); protects players, curator modules and headless clients |
| `economy` | Zeus point costs: categorization, cost registration, per-curator coefficients (`defaultCosts/`) |
| `loot` | AI orders to sweep nearby bodies, weapon holders, crates and unmanned vehicles and improve their loadout. Gear is classified through a lazily memoized `BIS_fnc_itemType` wrapper (`fnc_itemCategory` / `fnc_weaponScore`), and every take is ROLE-locked against the unit's *config* loadout (`fnc_unitRole`) so a sweep cannot rewrite squad composition. `fnc_lootPlan` is pure and decides what one unit would take from one target — run before dispatch, so nobody is marched to a target they have no use for — while `fnc_lootStep` executes it one step at a time, since engine take actions cannot be stacked and `rearm` must land last. Errand ownership rides entirely on `EFUNC(common,errandToken)`; there is deliberately no separate claim flag |
| `hud` | **Every curator-view display, and the two engines behind them.** One `Draw3D` handler (`fnc_frameLoop`) draws the whole mod: it resolves the Zeus test, the camera basis and the mouse position ONCE per frame and dispatches to registered renderers, so N displays cost one camera query rather than N. One stream engine (`fnc_selectionPoll` / `fnc_streamServer` / `fnc_streamClient`) feeds them: one client selection poll, one server watcher registry, one poll loop, one diffed snapshot event. Owns the selection info dialog, unit/vehicle tags, vehicle stat cards, and the destination/target overlays |
| `mine` | Mine placement, detection drawing, and disarm orders |
| `officer` | Officer auras and area buffs with cooldowns and monitors |
| `repair` | AI orders to repair vehicles |
| `restrict` | Locks servicing attribute edits (health/fuel/ammo/skill/cargo/vehicle damage) outside the curator's editing zones (any curatorEditingArea, not just officer-planted ones, and honouring curatorEditingAreaType); each row is gated against exactly the selection subset it writes to; sliders stay visible as info | 
| `reverse` | Order AI-driven land vehicles to back up in a straight line to a position (keybind). AI cannot be commanded to reverse, so the driver is taken off the navigation stack and the hull is pushed with `setVelocity` along an axis captured at order time. One shared per-frame engine (`fnc_reverseTick`) drives every maneuver from a `GVAR(active)` record registry and is created/destroyed with the first/last one; only the velocity push and arrival test run per frame, the abort conditions are throttled. All teardown routes through `fnc_endReverse`, which restores the driver captured at order time — not whoever is in the seat when it ends |
| `spotting` | AI spotting DETECTION: the knowsAbout pass, contact callouts, and the client stores behind the contact markers and the remote-control indicator. It decides *what* is spotted; `hud` owns how it looks, and `spotting` registers those renderers with the frame loop |
| `supply` | Supply vehicles repair/refuel/rearm the vehicles parked around them; owns a supply-lines stream on `hud`'s engine |

**Component skeleton.** New features are added as new components under `addons/`, following the same skeleton:
- `config.cpp` — `CfgPatches` (name, `requiredAddons`, version) plus includes for `CfgEventHandlers.hpp` / `CfgContext.hpp` / settings
- `script_component.hpp` — defines `COMPONENT`/`COMPONENT_BEAUTIFIED`, includes `script_mod.hpp` then `script_macros.hpp`, and holds that component's visual/tunable `#define`s
- `XEH_PREP.hpp` — `PREP(fncName)` for every function in `functions/`, compiled once via `XEH_preInit.sqf`
- `XEH_preStart.sqf` / `XEH_preInit.sqf` / `XEH_postInit.sqf` — CBA Extended Event Handler lifecycle hooks (declared in `CfgEventHandlers.hpp`)
- `functions/fnc_*.sqf` — one function per file, standard SQF header comment (Author/Arguments/Return Value/Example/Public)
- `initSettings.inc.sqf` — CBA settings (included from `config.cpp`); `initKeybinds.inc.sqf` for CBA keybinds
- `stringtable.xml` — ALL user-facing text goes through stringtable entries (`CSTRING`/`LSTRING` macros), never hardcoded strings

**Drawing and streaming go through `hud`.** Two rules, both there to stop the duplication this architecture was built to undo:

- **Never call `addMissionEventHandler ["Draw3D", …]`.** Register a renderer instead:
  `[QGVAR(myThing), ELINKFUNC(mycomp,drawMyThing), RENDER_WORLD, 50] call EFUNC(hud,registerRenderer)`.
  `RENDER_WORLD` renderers receive the shared frame context (camera position, camera-right/up, mouse, clock, view distance — indexed by the `CTX_*` macros) and are skipped while the Zeus map covers the 3D view. `RENDER_UI` renderers drive controls on the curator display, receive the display (or `displayNull`), and are called on Zeus-closed frames so they can tear their controls down. Unregister when the display is switched off — that is what makes it free, and with every renderer gone the loop never builds a camera basis. The only sanctioned exception is a short-lived, camera-free draw such as `common/fnc_placementPreview`.
- **Never build a second selection poll or server gather loop.** Declare a stream:
  `[STREAM_MINE, LINKFUNC(gatherMine), SRC_HULLS, QEGVAR(hud,pollInterval), 2] call EFUNC(hud,registerStream)`.
  The engine owns the watcher registry, the per-stream cadence, the resolve of each selection slice (`SRC_UNITS` / `SRC_VEHS` / `SRC_HULLS`, resolved once per watcher per tick), the send diff and the targeted push. A stream is a gatherer plus a renderer — `rtz_supply` is the worked example of a component owning one from outside `hud`.

Both contracts (`RENDER_*`, `CTX_*`, `SRC_*`) live in `main/script_macros.hpp`, not in `hud`'s own header, because component headers are not visible to each other.

Gatherers report **absolute** times, never ages or progress figures: an age changes every tick and defeats the send diff, while a frozen timestamp diffs away and is aged client-side each frame — which also makes the readout climb smoothly between polls instead of stepping.

**ZEN integration.** Context menu actions are declared per-component in `CfgContext.hpp` (`zen_context_menu_actions`); `common/CfgZenContext.hpp` holds the shared RTZ context-menu root. Toggle-style actions keep their label in sync (Show ↔ Hide) via a `fnc_modifyAction` in their component. `common` provides the selection-normalization helpers (`fnc_collectUnits`, `fnc_collectSquads`, `fnc_collectVehicles`) that expand ZEN selections (e.g. vehicles → crew) into flat lists — entry points should go through them.

## Conventions

- Use the CBA/ACE3 macro family from `script_macros.hpp`: `GVAR`/`QGVAR`/`EGVAR`, `FUNC`/`EFUNC`, `LLSTRING`/`CSTRING`, `PREP`, etc. Never hand-roll `rtz_component_name` identifiers.
- One function per `fnc_*.sqf` file, registered in `XEH_PREP.hpp`.
- Update the component's `stringtable.xml` whenever adding user-facing text; `hemtt check` validates stringtables.
- Mind locality: orders are typically initiated on the curator's client and executed where the unit is local (CBA target events / remoteExec patterns already used throughout the codebase).
- To stop a `forEach` early, use `break`, and test at the **top** of the loop body. `exitWith` there exits only the current *iteration* — it is a `continue`. Three "stop at the first hit" parameters shipped written that way and were completely inert; see `docs/Gotchas.md` §2. For a pure existence test prefer `findIf`, which short-circuits natively.
- Anything that runs per tick or per frame is a **multi-hour** cost here (see Usage above): give every `waitUntilAndExecute` a timeout, bound every long-lived HashMap, and keep `format`/`str` off paths that run per entity per tick — cache the finished string instead.
