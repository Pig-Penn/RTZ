# Weapon-aim overlay ("Draw Aim" — line from a unit's barrel to where it points)

## Context

A curator overlay that draws a line from a selected unit's weapon along the
**actual barrel direction** to where it is pointing — a "muzzle line". Unlike the
existing **Draw Targets** overlay (`fnc_targetDisplay.sqf`), which draws a line to
where the AI *believes its assigned target is* (`assignedTarget` / `targetKnowledge`
sensor state), this draws where the weapon is *physically aimed right now*
(`weaponDirection`), independent of whether the unit has a target at all. The two
are complementary: Targets = intent, Aim = current pose.

Accuracy bar (user's words): "not perfectly accurate, but close enough." That
tolerance is what unlocks the simpler architecture below.

Sits alongside the other overlays in **`rtz_context`** (destination, target) and
clones their context-action / toggle / action-modifier / display quartet.

## Key engine reads

- **`_unit weaponDirection (currentWeapon _unit)`** → world-space unit vector of the
  weapon's barrel (reflects live aim/sway, not just body facing). For a vehicle,
  `currentWeapon _veh` returns the selected turret weapon and the same call gives
  that turret's direction.
- **`eyePos _unit`** → PositionASL of the aim/eye origin — good enough as the ray
  start for infantry. For vehicles it approximates the optic; acceptable for a
  strategic overlay, and can be refined later with a turret memory point if needed.
- **`lineIntersectsSurfaces [_originASL, _endASL, _unit, vehicle _unit, true, 1, "GEOM", "NONE"]`**
  → optional raycast so the line stops at the first real surface/object instead of
  hanging in the air. Returns `[]` when nothing is hit (open sky / out of range) —
  then fall back to the fixed-length endpoint.
- `draw3D` wants AGL, so convert both ends with `ASLToAGL`.

## Architecture decision — client-side only (no server poll)

**This is the important divergence from `fnc_targetDisplay.sqf`.** The target
overlay needs a server-side watcher registry + 2 s poll loop + per-curator
`CBA_fnc_targetEvent` stream because `assignedTarget` / `targetKnowledge` are **AI
sensor state that only exists on the machine that owns the unit** (per the CLAUDE.md
locality rule). `weaponDirection` and `eyePos` are **not** sensor state — they are
animation/pose reads, and a remote unit's aim pose is network-synced (you can watch
a remote AI swing its rifle). So they can be read **directly in the client Draw3D
handler for the local curator's selection**, with no server round-trip at all —
the same "evaluate entirely client-side, skip the watcher registry" simplification
the grenade-warning plan used with `curatorSelected`.

Benefits: one file, no `QGVAR(*Watch)` / `QGVAR(*Update)` events, no server PFH, no
per-curator `GVAR(*Watchers)` HashMap, and the line updates **every frame** (live
sway) instead of snapping every 2 s.

**Risk / fallback:** if in-testing the synced remote aim proves too coarse or lags
noticeably for AI the curator doesn't own, fall back to the proven target-overlay
architecture — a server PFH reads `weaponDirection`/`eyePos` where the unit is local
and streams `[netId, originASL, dirVector]` snapshots per curator. Structure the
display file so that swap is contained (draw loop consumes an `[origin, endpoint]`
list either way). Start client-only; only add the server half if testing demands it.

## Rendering (client Draw3D, mirrors targetDisplay's client half)

Inside `if (hasInterface)`, one `addMissionEventHandler ["Draw3D", {...}]` gated on
`GVAR(aimEnabled)`:

- Bail unless `!isNull (findDisplay 312)` (curator view only, never bleed into first
  person / plain map) — same guard as targetDisplay.
- Resolve the watch set from the live selection the same way targetDisplay does:
  `SELECTED_OBJECTS`, `pushBackUnique (vehicle _x)` to dedupe whole crews to the hull.
  (No selection-sync/server-subscribe bookkeeping needed here — just iterate the
  current selection each frame, since there is no server to tell.)
- For each entity:
  - `private _wpn = currentWeapon _entity; if (_wpn == "") then { continue };`
    (skips unarmed units — nothing to aim).
  - `private _origin = eyePos _entity;` (ASL).
  - `private _dir = _entity weaponDirection _wpn;` — skip if `_dir isEqualTo [0,0,0]`
    (degenerate / no weapon selected).
  - `private _end = _origin vectorAdd (_dir vectorMultiply MAX_AIM_RANGE);`
  - **Optional raytrace** (setting-gated, see `traceToImpact` below): if enabled,
    `lineIntersectsSurfaces [_origin, _end, _entity, vehicle _entity, true, 1, "GEOM", "NONE"]`;
    if the result is non-empty, replace `_end` with `(_hits select 0) select 0`.
  - Camera cull + fade exactly like targetDisplay
    (`MAX_DRAW_DIST` / `FADE_NEAR` linearConversion on `_camPos distance _fromAGL`).
  - `drawLine3D [ASLToAGL _origin, ASLToAGL _end, _color]`, side-coloured via
    `[side _entity, false] call EFUNC(common,sideColor)` so it reads as one system
    with the other overlays (own-side line colour).
  - Optionally a small `drawIcon3D` crosshair/impact marker at `_end` (reuse
    targetDisplay's `impactpoint_ca.paa`) — cheap, keeps parity with Draw Targets.

**Jitter note:** live `weaponDirection` includes sway, so the endpoint dances,
especially when raytracing (the impact point flickers between objects). Two cheap
tamers, both worth having: (a) prefer the **fixed-length** line by default and make
the raytrace opt-in; (b) optionally smooth `_dir` across frames by lerping toward the
previous frame's stored direction per netId. Start with fixed-length + no smoothing
(simplest), add smoothing only if it reads badly.

## Files

- **New:** `Real-Time Zeus/addons/context/functions/fnc_aimDisplay.sqf` — client
  Draw3D renderer (whole feature, client-only; no server half in the recommended
  approach). Header block modelled on `fnc_targetDisplay.sqf` but documenting the
  `weaponDirection` client-read rationale above.
- **New:** `Real-Time Zeus/addons/context/functions/fnc_aimContext.sqf` — registers
  the "Draw Aim" toggle under `RTZ_Overlays` (clone `fnc_targetContext.sqf`, index 4).
- **New:** `Real-Time Zeus/addons/context/functions/fnc_aimToggle.sqf` — flips
  `GVAR(aimEnabled)`, clears state when off, toasts via `EFUNC(common,showMessage)`
  (clone `fnc_targetToggle.sqf`, minus the `serverEvent` unsubscribe — nothing to
  unsubscribe from).
- **New:** `Real-Time Zeus/addons/context/functions/fnc_aimActionModifier.sqf` —
  live label/tint off→"Draw Aim" / on→"Hide Aim" (clone `fnc_targetActionModifier.sqf`).
- **Edit:** `Real-Time Zeus/addons/context/XEH_PREP.hpp` — add `PREP(aimDisplay);`
  `PREP(aimContext);` `PREP(aimToggle);` `PREP(aimActionModifier);`.
- **Edit:** `Real-Time Zeus/addons/context/XEH_preInit.sqf` — inside the
  `if (hasInterface)` block, add `GVAR(aimEnabled) = false;` (and, if smoothing is
  added later, `GVAR(aimSmooth) = createHashMap;`).
- **Edit:** `Real-Time Zeus/addons/context/XEH_postInit.sqf` — inside the
  `CBA_settingsInitialized` handler, alongside the target overlay block:
  ```sqf
  if (GVAR(enableAimDisplay)) then {
      if (hasInterface) then {
          [] call FUNC(aimContext);
          [] spawn FUNC(aimDisplay);
      };
  };
  ```
  (client-only — no server registration needed in the recommended approach).
- **Edit:** `Real-Time Zeus/addons/context/initSettings.inc.sqf` — add under
  `["Real-Time Zeus", "Context Menu"]`:
  - `QGVAR(enableAimDisplay)` (CHECKBOX, default true) — "Draw Aim" / "Add a context
    menu action to show a line along where a selected unit's weapon is pointed."
  - `QGVAR(aimTraceToImpact)` (CHECKBOX, default true) — "Aim Line To Impact" /
    "Stop the aim line at the first surface it hits instead of drawing a fixed length."
  - `QGVAR(aimMaxRange)` (SLIDER, [50, 2000, 500, 0]) — "Aim Line Range" / max metres
    the aim line extends (and the raytrace cap).

No new addon dependencies — every command used (`weaponDirection`, `currentWeapon`,
`eyePos`, `lineIntersectsSurfaces`, `ASLToAGL`, `drawLine3D`/`drawIcon3D`,
`SELECTED_OBJECTS`, `EFUNC(common,sideColor)`) is already available to `rtz_context`.

## Verification

1. `hemtt build` (or `/deploy`) to rebuild `rtz_context.pbo` into `@Real-Time Zeus/addons/`.
2. Load in Arma, open Zeus, select an armed AI infantryman. Toggle "Draw Aim" on via
   the RTZ context menu — confirm a side-coloured line extends from the unit along
   its weapon and tracks as the unit turns/aims.
3. Point the unit at a wall/vehicle with `aimTraceToImpact` on — confirm the line
   terminates at the surface. Turn it toward open sky — confirm it falls back to the
   fixed `aimMaxRange` length.
4. Select a manned vehicle turret — confirm the line follows the turret barrel.
5. **Remote-unit check (the architecture risk):** in a 2-curator session, as curator
   A select a squad that is server-local or owned by curator B, and confirm the aim
   lines still track that unit's aim reasonably (this validates the client-side
   `weaponDirection` read on non-owned units). If the lines are frozen/wildly wrong,
   escalate to the server-poll fallback documented above.
6. Deselect / close Zeus — confirm the lines clear. Toggle off — confirm they clear.
7. `/rpt` to confirm no script errors and a fresh `[RTZ] context postInit —` stamp
   (not a stale PBO).
