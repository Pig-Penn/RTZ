# Architecture

**Component structure.** The mod is split into `addons/` components, each an independent PBO. `main` is the build-time framework (prefix, version macros, CBA/ZEN dependency declarations, `script_macros.hpp`, `script_curator.hpp`) and ships no runtime code; `core` holds the two shared runtime engines; `common` holds shared infrastructure and the shared ZEN context-menu root (`CfgZenContext.hpp`); every other component depends on `rtz_main` (and usually `rtz_common`); anything that draws or streams also depends on `rtz_core`.

**The dependency graph is acyclic and fully declared** — every `EFUNC`/`EGVAR` edge appears in the calling component's `requiredAddons`, and nothing appears there that is not really called. That is a property worth re-checking after any move: a mutual `requiredAddons` pair leaves Arma's load order between the two undefined, and an edge that exists in code but not in config is the same bug waiting for a load-order change to expose it. `hud` ↔ `spotting` was exactly that pair, resolved by moving the two renderers to the component that owns their data.

`extras/` holds unbuilt, unchecked components (see its README). HEMTT scans `addons/` only.

Current components:

| Component | Purpose |
|---|---|
| `main` | Build-time framework: prefix, version, macros, CBA/ZEN/LAMBS dependencies. No runtime code. `script_macros.hpp` holds only what is genuinely mod-wide; `script_curator.hpp` holds the Zeus/ZEN *host* constants (display IDCs, `SELECTED_*`, `CHECK_CURATOR_INPUT`, `ACTION_INDEX_*`) |
| `core` | **The two shared runtime engines.** One `Draw3D` handler (`fnc_frameLoop`) draws the whole mod: it resolves the Zeus test, the camera basis and the mouse position ONCE per frame and dispatches to registered renderers, so N displays cost one camera query rather than N. One stream engine (`fnc_selectionPoll` / `fnc_streamServer` / `fnc_streamClient` / `fnc_registerStream`) feeds them: one client selection poll, one server watcher registry, one poll loop, one diffed snapshot event, one dispatch to each stream's registered receiver. Also the shared overlay-toggle halves every toggleable stream reuses. Knows nothing about any particular display. Its **public contract** is `script_macros_core.hpp`, included by absolute path by the components that draw or stream |
| `common` | Shared **infrastructure only**: the selection normalizers (`fnc_collectUnits`/`Squads`/`Vehicles`/`Specialists`), the errand engine (`fnc_approach`, `fnc_clearErrand`, `fnc_progressJob`, `fnc_errandToken`, `fnc_curatorsOf`, `fnc_grantCurators`), presentation helpers (`fnc_classInfo`, `fnc_sideColor`, `fnc_showCountMessage`, `fnc_placementPreview`), the context-menu clean-up, and the shared submenu anchors. Every other component requires this one, so a *feature* parked here is loaded by everyone whether they use it or not — which is why the countermeasures order, the keybind orders and the skill table left for `smoke`, `orders` and `skill` |
| `orders` | Direct curator keybind orders, each guarded by `CHECK_CURATOR_INPUT` and returning whether it consumed the press: camera-to-cursor, unit teleport, stance, fly height, combat mode, open inventory. Owns the three locality-routed receivers those orders send to (`switchStance`, `adjustHeliHeight`, `toggleCombatMode`) and the public per-vehicle `flyHeight` / per-group `holdFire` variables they write |
| `skill` | The built-in per-class skill table (`defaultSkills/`, one file per faction), applied to every spawned man-class unit from a `CAManBase` `InitPost` class event handler. Depends on nothing but the framework |
| `smoke` | Deploy countermeasures: fires the smoke launcher / flare / chaff dispenser of every selected vehicle that has one. Context action at the menu root, config-derived verdicts memoised in `GVAR(cmWeaponCache)` |
| `assemble` | AI orders to assemble/disassemble static weapons and UAVs from backpacks |
| `attack` | Order groups to find and destroy a target via waypoints |
| `captive` | Surrender/stand-down toggle (captive, AI disabled, hands-up pose), plus enemy-proximity capture: the prisoner is disarmed, joins his captor's group, transfers to the capturing curators, and both curators are paid half his economy value. Eligibility lives in one `CAN_SURRENDER` macro shared by the condition, collector, modifier and apply guard. `disableAI` does not travel with locality, so a `CAManBase` `"Local"` handler re-applies the state on whichever machine gains a surrendered unit. The capture watch (`fnc_captureTick`) is a shared per-frame engine over a server-side registry, created by the first surrender and destroyed by the last |
| `control` | Squad control: LAMBS reset, squad reload, squad hide/freeze toggle, ownership transfer for units left simulated elsewhere, and the dismount lock that stops a transport's AI crew/cargo bailing out (engine flags plus LAMBS force-eject suppression) |
| `delete` | Point-free deletion of units, vehicles, bodies and wrecks (context action + keybind); protects players, curator modules and headless clients |
| `economy` | Zeus point costs: categorization, cost registration, per-curator coefficients (`defaultCosts/`) |
| `loot` | AI orders to sweep nearby bodies, weapon holders, crates and unmanned vehicles and improve their loadout. Gear is classified through a lazily memoized `BIS_fnc_itemType` wrapper (`fnc_itemCategory` / `fnc_weaponScore`), and every take is ROLE-locked against the unit's *config* loadout (`fnc_unitRole`) so a sweep cannot rewrite squad composition. `fnc_lootPlan` is pure and decides what one unit would take from one target — run before dispatch, so nobody is marched to a target they have no use for — while `fnc_lootStep` executes it one step at a time, since engine take actions cannot be stacked and `rearm` must land last. Errand ownership rides entirely on `EFUNC(common,errandToken)`; there is deliberately no separate claim flag |
| `hud` | The selection info dialog, unit/vehicle tags, and the destination/target overlays — **its own** displays, with their gatherers and renderers. Not "every display": `supply`, `mine` and `spotting` each own theirs. Owns no engine — it is a consumer of `core` like any other component. Requires `rtz_orders` for one read: the vehicle overlay reports the fly-in height that component's keybind commands |
| `mine` | Mine placement, detection drawing, and disarm orders |
| `officer` | Officer auras and area buffs with cooldowns and monitors |
| `repair` | AI orders to repair vehicles |
| `route` | Route planning: a modal drawing session where each selected unit gets a drag handle and the curator traces the path it should take, in the 3D view or on the Zeus map, committing every route at once. A cleaned-up port of Zeus Wargame's Path Planning. Split cleanly by locality — the whole planning half is client-local (one renderer on `core`'s frame loop, one map Draw handler, one tick, no server traffic at all) and only the commit crosses the wire, as one targeted event per unit. Routes are drawn dense and executed sparse: `fnc_reducePath` resamples a several-hundred-point traced line down to a few dozen corner-preserving legs. Land vehicles execute on `setDriveOnPath` and the engine drives; everything else — men, aircraft, boats — rides one `doMove` chain, re-asserted only when `expectedDestination` shows the formation FSM stole the order, which is what makes a chain survive without disabling any AI. One shared tick over a bounded registry drives all of them (`fnc_followTick`, same shape as `reverse`) |
| `restrict` | Locks servicing attribute edits (health/fuel/ammo/skill/cargo/vehicle damage) outside the curator's editing zones (any curatorEditingArea, not just officer-planted ones, and honouring curatorEditingAreaType); each row is gated against exactly the selection subset it writes to; sliders stay visible as info |
| `reverse` | Order AI-driven land vehicles to back up in a straight line to a position (keybind). AI cannot be commanded to reverse, so the driver is taken off the navigation stack and the hull is pushed with `setVelocity` along an axis captured at order time. One shared per-frame engine (`fnc_reverseTick`) drives every maneuver from a `GVAR(active)` record registry and is created/destroyed with the first/last one; only the velocity push and arrival test run per frame, the abort conditions are throttled. All teardown routes through `fnc_endReverse`, which restores the driver captured at order time — not whoever is in the seat when it ends |
| `spotting` | AI spotting, end to end: the knowsAbout detection pass, contact callouts, the client stores, **and** the drawing — `fnc_drawSpots` / `fnc_drawRcIndicator` in the 3D view, `fnc_initCuratorDisplay` on the Zeus map. The renderers lived in `hud` until they were moved here; reading six of this component's globals from over there made the two mutually dependent with only one direction declared |
| `supply` | Supply vehicles repair/refuel/rearm the vehicles parked around them; owns a supply-lines stream on `core`'s engine |

**Component skeleton.** New features are added as new components under `addons/`, following the same skeleton:
- `config.cpp` — `CfgPatches` (name, `requiredAddons`, version) plus includes for `CfgEventHandlers.hpp` / `CfgContext.hpp` / settings
- `script_component.hpp` — defines `COMPONENT`/`COMPONENT_BEAUTIFIED`, includes `script_mod.hpp` then `script_macros.hpp`, then `core/script_macros_core.hpp` if it draws or streams, and holds that component's visual/tunable `#define`s. A constant belongs to whichever component *uses* it — if two components need one, it goes in a header one of them owns and the other includes, not in `main`
- `XEH_PREP.hpp` — `PREP(fncName)` for every function in `functions/`, compiled once via `XEH_preInit.sqf`
- `XEH_preStart.sqf` / `XEH_preInit.sqf` / `XEH_postInit.sqf` — CBA Extended Event Handler lifecycle hooks (declared in `CfgEventHandlers.hpp`)
- `functions/fnc_*.sqf` — one function per file, standard SQF header comment (Author/Arguments/Return Value/Example/Public)
- `initSettings.inc.sqf` — CBA settings (included from `config.cpp`); `initKeybinds.inc.sqf` for CBA keybinds
- `stringtable.xml` — ALL user-facing text goes through stringtable entries (`CSTRING`/`LSTRING` macros), never hardcoded strings. Omit the file entirely if the component has no user-facing text (`skill` has none); `hemtt check` reports unused keys

**Where does a new feature go?** Its own component, not `common`. The test is whether anything *else* calls it: `common` is for code with real external callers, and every component requires it, so a feature parked there is loaded by everyone who will never use it. Small is not a reason to merge — `attack` is 307 lines and `delete` is 371.

**Drawing and streaming go through `core`.** Two rules, both there to stop the duplication this architecture was built to undo:

- **Never call `addMissionEventHandler ["Draw3D", …]`.** Register a renderer instead:
  `[QGVAR(myThing), ELINKFUNC(mycomp,drawMyThing), RENDER_WORLD, 50] call EFUNC(core,registerRenderer)`.
  `RENDER_WORLD` renderers receive the shared frame context (camera position, camera-right/up, mouse, clock, view distance — indexed by the `CTX_*` macros) and are skipped while the Zeus map covers the 3D view. `RENDER_UI` renderers drive controls on the curator display, receive the display (or `displayNull`), and are called on Zeus-closed frames so they can tear their controls down. Unregister when the display is switched off — that is what makes it free, and with every renderer gone the loop never builds a camera basis. The only sanctioned exception is a short-lived, camera-free draw such as `common/fnc_placementPreview`.
- **Never build a second selection poll or server gather loop.** Declare a stream — **both halves in one call**:
  ```sqf
  [
      STREAM_MINE, LINKFUNC(gatherMine), SRC_HULLS, QEGVAR(core,pollInterval), 2,
      ELINKFUNC(core,receiveOverlay),                 // or your own receiver
      [                                               // omit for an always-on feed
          LINKFUNC(drawMine), QGVAR(enableMineDisplay),
          [LLSTRING(MsgMinesHidden), LLSTRING(MsgMinesShown)],
          [LLSTRING(ActionDrawMines), LLSTRING(ActionHideMines)],
          COLOR_MINE
      ]
  ] call EFUNC(core,registerStream);
  ```
  The engine owns the watcher registry, the per-stream cadence, the resolve of each selection slice (`SRC_UNITS` / `SRC_VEHS` / `SRC_HULLS`, resolved once per watcher per tick), the send diff, the targeted push, and the dispatch to your receiver. **Declare the wording, never hardcode it in the engine** — the toggle statement and `modifierFunction` are shared (`EFUNC(core,toggleOverlay)` / `EFUNC(core,overlayActionModifier)`) and read what you registered. `rtz_supply` is the worked example of a component owning a stream from outside `core`.
- **Consumers of the infantry slice must declare demand:** `[QGVAR(myDisplay), true] call EFUNC(core,setDemand)` (third argument `true` if you need the expensive per-unit intel). The poll streams that slice only while someone asks, so a display that forgets gets no packets — and one that never withdraws keeps the feed alive for nothing.
- **To force an immediate re-subscription, call `[] call EFUNC(core,reportNow)`** — never build the payload or write `EGVAR(core,reported)` yourself. That baseline is the poll's private diff state, and hand-rolling around it is a trap that has already been sprung twice: `hud`'s selection dialog spelled the subscribe event `QGVAR(watch)` inside its own component (so it expanded to `rtz_hud_watch`, an event with no handler) *and* wrote the baseline first, which made the poll suppress the genuine send too — the dialog's intel rows stayed empty on first open. The same block also re-derived the hull-slice gate with a comment warning it had to match `selectionPoll` exactly. `reportNow` builds the payload from the engine's own state by the engine's own rules; pass `true` only when you need the detail flag *before* your `setDemand` call has run.

All of `core`'s shared contracts (`RENDER_*`, `CTX_*`, `SRC_*`, `SEL_MAX_*`, `VEH_SIDE_OK`, `SIDE_NUM`) live in **`addons/core/script_macros_core.hpp`**, and a consuming component pulls them in from its own `script_component.hpp`:

```cpp
#include "\x\rtz\addons\core\script_macros_core.hpp"
```

These used to sit in `main/script_macros.hpp` on the belief that "component headers are not visible to each other". They are — an absolute PBO path resolves any component's header from any other, and ACE3 relies on this: ten medical components include `\z\ace\addons\medical_engine\script_macros_medical.hpp`. Keeping the contract with the component that implements it means `attack`, `loot` and `economy` — which neither draw nor stream — no longer parse it, and a `CTX_*` index can change without touching the one addon every other addon depends on.

What *does* belong in `main`: the `GETVAR`/`SETVAR` family, `VEHICLE_TYPES`, the `PREP` override, and (in `script_curator.hpp`) the Zeus/ZEN host constants, since those describe the environment rather than any RTZ subsystem. ZEN structures its own `main` the same way.

**Nothing in `core` may name a specific display.** That is the invariant the whole split exists to protect: it was violated by a `case STREAM_UNIT` in the snapshot receiver, by hardcoded renderer/setting tables in preInit, and by the poll reading two of `hud`'s globals to decide what to stream — which is what forced `mine`, `spotting` and `supply` to depend on a component full of tags and dialogs. If you find yourself adding a stream id or a display's variable name to `core`, the contract is missing something instead.

Gatherers report **absolute** times, never ages or progress figures: an age changes every tick and defeats the send diff, while a frozen timestamp diffs away and is aged client-side each frame — which also makes the readout climb smoothly between polls instead of stepping.

**ZEN integration.** Context menu actions are declared per-component in `CfgContext.hpp` (`zen_context_menu_actions`); `common/CfgZenContext.hpp` holds the shared RTZ context-menu root. Toggle-style actions keep their label in sync (Show ↔ Hide) via a `fnc_modifyAction` in their component. `common` provides the selection-normalization helpers (`fnc_collectUnits`, `fnc_collectSquads`, `fnc_collectVehicles`) that expand ZEN selections (e.g. vehicles → crew) into flat lists — entry points should go through them.
