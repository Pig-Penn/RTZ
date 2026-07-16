# Incoming-grenade warning icon (ZEN curator-ordered throws)

## Context

ZEN's "Throw Grenade" context action (`zen_context_actions_fnc_selectThrowPos` →
`zen_ai_fnc_throwGrenade`) lets a curator pick AI units and a ground position, and
those units walk through an aim-and-throw sequence at that spot. In a multi-curator
(PvP) Real-Time Zeus session, an opposing curator can order this at a position near
units you currently have selected, and right now there is no warning — the first
sign is the explosion. The ask is a cheap visual marker (a dot / low-cost icon) that
appears when this specifically happens near your current selection, so you get a
heads-up without any heavy rendering.

Scope, as agreed:
- Only mark grenades from **ZEN's curator-ordered throw action** — not organic AI
  combat grenade tosses in a firefight.
- Only show the marker to a curator when the throw lands **near that curator's own
  current selection** (not a global broadcast to every curator regardless of
  relevance).

## Detection approach

ZEN's `fnc_throwGrenade.sqf` (`ZEN/addons/ai/functions/fnc_throwGrenade.sqf`) makes
the unit throw via a real `"UseMagazine"` action after `doTarget`-ing a helper object
it spawns at the aim point (`createVehicle ["CBA_B_InvisibleTargetVehicle", ...]`).
The same helper class is also used by ZEN's "Suppressive Fire" action
(`fnc_suppressiveFire.sqf`), so the helper class alone doesn't disambiguate — but
combined with weapon type it does:

- Register `["CAManBase", "FiredMan", {...}, true, []] call CBA_fnc_addClassEventHandler;`
  (same technique already used for the fire-blink handler in
  `fnc_spottingSystem.sqf:114`, params confirmed against ACE3's grenade/weaponselect
  fired-EH usage: `_unit, _weapon, _muzzle, _mode, _ammo, _magazine, _projectile`).
- Filter `_weapon == "Throw"` (the pseudo-weapon for all hand-thrown items —
  excludes suppressive-fire's rifle/MG shots entirely).
- Filter `(target _unit) isKindOf "CBA_B_InvisibleTargetVehicle"` — true only while
  the unit is still aiming at ZEN's helper (set by `doTarget` in `fnc_throwGrenade`,
  and not cleared until cleanup ~1.5s later, well after the throw fires). Organic
  combat throws never set this, so they're excluded.
- `_projectile` from the EH is the live grenade object — used directly for position
  tracking, no need to hunt for it separately.

This only fires where the throwing unit is **local**, same accepted limitation as
the existing fire-blink handler (registered server-side only, in the `isServer`
half of the file) — a remote-controlled unit's throw would be missed. Normal AI
(what this ZEN action targets) is server-local, so this covers the real case.

## Distribution + display approach

No per-curator watcher registry is needed (unlike `fnc_destinationDisplay.sqf`'s
`GVAR(destWatchers)` pattern) — proximity-to-selection can be evaluated **entirely
client-side** using the native `curatorSelected` command (already exposed via the
`SELECTED_OBJECTS` macro in `script_macros.hpp`), so there's nothing for the server
to track per curator.

- Server: on a confirmed detection, `[QGVAR(grenadeThreatDetected), [_projectile]] call CBA_fnc_globalEvent;`
  (single lightweight event per throw; negligible frequency).
- Client (`hasInterface` block): event handler pushes `[_projectile, CBA_missionTime]`
  into `GVAR(grenadeThreats)`.
- Client: one `addMissionEventHandler ["Draw3D", ...]` (mirrors `fnc_mineSpotting.sqf`'s
  renderer) that, only while the Zeus interface is open (`findDisplay 312`) and the
  curator has a non-empty selection:
  - Prunes entries where `isNull _projectile` or age exceeds a failsafe max lifetime
    (grenades normally self-delete shortly after detonating; the failsafe just
    guards against a dud never going null).
  - For each remaining entry, finds the nearest distance from `getPosASL _projectile`
    to any object in `SELECTED_OBJECTS`; only draws if within
    `GVAR(grenadeWarnRadius)`.
  - Draws a single `drawIcon3D` at the live grenade position, alpha-faded by camera
    distance exactly like the mine icon (`MAX_DRAW_DIST` linearConversion). Reuse
    the existing hazard-icon look (`\A3\Ui_F_Curator\Data\CfgMarkers\minefield_ca.paa`)
    tinted orange (`[1, 0.5, 0, alpha]`) to read as "incoming" and stay visually
    distinct from the red mine icon. No pulsing/animation — matches the "as cheap as
    possible" ask.

## Files

- **New:** `Real-Time Zeus/addons/spotting/functions/fnc_grenadeWarning.sqf` — the
  whole feature (client display block + server detection block, single
  self-guarding file, same shape as `fnc_mineSpotting.sqf` / `fnc_spottingSystem.sqf`).
- **Edit:** `Real-Time Zeus/addons/spotting/XEH_PREP.hpp` — add `PREP(grenadeWarning);`.
- **Edit:** `Real-Time Zeus/addons/spotting/XEH_postInit.sqf` — inside the existing
  `CBA_settingsInitialized` handler, add
  `if (GVAR(enableGrenadeWarning)) then { [] spawn FUNC(grenadeWarning); };`
  alongside the other gated systems.
- **Edit:** `Real-Time Zeus/addons/spotting/initSettings.inc.sqf` — add two CBA
  settings under the existing `["Real-Time Zeus", "Detection"]` category:
  - `QGVAR(enableGrenadeWarning)` (CHECKBOX, default true) — master toggle.
  - `QGVAR(grenadeWarnRadius)` (SLIDER, 5–100, default 40) — metres from the
    curator's selection within which an incoming throw is marked.

No new addon dependencies — everything used (`CBA_fnc_addClassEventHandler`,
`CBA_fnc_globalEvent`, `curatorSelected`/`SELECTED_OBJECTS`, `drawIcon3D`,
`addMissionEventHandler ["Draw3D", ...]`) is already used elsewhere in `rtz_spotting`
or `rtz_common`.

## Verification

1. `hemtt build` (or the `/deploy` skill) to rebuild `rtz_spotting.pbo` and copy it
   into `@Real-Time Zeus/addons/`.
2. Load in Arma with a test mission that has two curator slots. As curator A, select
   a squad and note its position. As curator B, use ZEN's "Throw Grenade" context
   action targeting a spot within ~40 m of curator A's selected squad.
3. As curator A, confirm the orange marker appears at the live grenade's position
   and fades/disappears once it detonates (or the projectile is deleted).
4. As curator A, repeat with the throw target far outside the radius — confirm no
   marker appears.
5. Trigger an ordinary AI-vs-AI firefight where AI throw grenades organically —
   confirm no marker appears (the detection should be scoped to ZEN's ordered
   throws only).
6. Use the `/rpt` skill to confirm no script errors, and check the
   `[RTZ] spotting postInit —` build-stamp line to confirm the deployed PBO isn't
   stale.
