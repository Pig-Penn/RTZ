# Airstrike Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A ZEN context action that orders one selected plane to fly a scripted attack run against a curator-drawn point and bearing, delivering a weapon chosen from its own pylon loadout.

**Architecture:** A new self-contained `addons/airstrike/` component, split by locality. The aiming half (context submenu, modal press-drag-release session, `RENDER_WORLD` renderer) is entirely client-local; the execution half runs where the aircraft is local, driven by one shared per-frame handler over a bounded registry with a single teardown owner. Ingress is flown by bounded turn-rate steering; the terminal run is ZEN's CAS-module `setVelocityTransformation` rail with an invisible laser target for the release.

**Tech Stack:** SQF, CBA extended event handlers and settings, ZEN context menu, HEMTT for build/validation. Arma 3.

**Spec:** [docs/superpowers/specs/2026-08-22-airstrike-design.md](../../docs/superpowers/specs/2026-08-22-airstrike-design.md)

## Global Constraints

- **`hemtt check` must pass at the end of every task.** A Stop hook runs it and blocks on failure.
- **CBA/ACE3 macro family only** — `GVAR`/`QGVAR`/`EGVAR`, `FUNC`/`EFUNC`, `LLSTRING`/`CSTRING`, `PREP`. Never hand-roll a `rtz_airstrike_*` identifier.
- **One function per `fnc_*.sqf`**, each registered in `XEH_PREP.hpp`, each carrying the standard header comment (Author / description / Arguments / Return Value / Example / Public).
- **All user-facing text goes through `stringtable.xml`.** No hardcoded strings. `hemtt check` reports unused keys, so add keys in the task that uses them.
- **`GVAR(enabled)` is `CHECKBOX`, default `false`, Global scope.** Non-negotiable — see Task 1.
- **Never call `addMissionEventHandler ["Draw3D", …]`.** Register on `rtz_core` and unregister when done.
- **To stop a `forEach` early use `break`, tested at the TOP of the loop body.** `exitWith` there is a `continue`, not a break (`docs/Knowledge Base/Gotchas.md` §2). Prefer `findIf` for a pure existence test.
- **Per-tick discipline:** every `waitUntilAndExecute` takes a timeout, every long-lived HashMap is bounded, and `format`/`str` never appear on a path that runs per entity per tick.
- **ZEN `_objects` convention: use the WRAPPED form** — `[ARR_2(_position,_objects)] call FUNC(x)` paired with `params ["_position", "_objects"]`. Mixing conventions fails silently.

## Deviations from the spec

Four, all discovered while writing this plan. Each is a correction, not a scope change.

1. **`fnc_strikeAircraft` is added** — a 14th function the spec did not list. It resolves and validates the selection down to one aircraft, and has three callers (`canStrike`, `strikeActions`, `orderStrike`). Three callers is exactly the "real external callers" test; without it the same eight-line gate is written three times and drifts.
2. **`flyInHeight` cannot be restored.** The engine has no getter for it, so the spec's "restore `flyInHeight`" is impossible as written. Egress instead *sets* a sane value derived from the altitude the aircraft ends at — which is what Wargame does, for the same reason.
3. **`disableAI` is applied to the DRIVER, not the vehicle.** ZEN's module calls `_plane disableAI "MOVE"`, but `disableAI` is a unit command and `slide` sets the house precedent of capturing the driver at order time and restoring that specific unit.
4. **Three record fields were added** to the spec's layout: `STRIKE_CRUISE` (derived once per strike rather than per tick), `STRIKE_PROGRESS` (the fire-progress term the rail's aim raise needs) and `STRIKE_FIRE_END`.

---

### Task 1: Component scaffold and weapon classification

**Files:**
- Create: `addons/airstrike/$PBOPREFIX$`
- Create: `addons/airstrike/config.cpp`
- Create: `addons/airstrike/script_component.hpp`
- Create: `addons/airstrike/CfgEventHandlers.hpp`
- Create: `addons/airstrike/XEH_PREP.hpp`
- Create: `addons/airstrike/XEH_preStart.sqf`
- Create: `addons/airstrike/XEH_preInit.sqf`
- Create: `addons/airstrike/XEH_postInit.sqf`
- Create: `addons/airstrike/initSettings.inc.sqf`
- Create: `addons/airstrike/stringtable.xml`
- Create: `addons/airstrike/functions/script_component.hpp`
- Create: `addons/airstrike/functions/fnc_strikeWeapons.sqf`

**Interfaces:**
- Consumes: nothing.
- Produces: `FUNC(strikeWeapons)` — `[_vehicle] call FUNC(strikeWeapons)` returns `[[_weapon, _turretPath, _type, _ammo], …]` where `_weapon` is STRING, `_turretPath` is ARRAY, `_type` is one of `TYPE_GUN`/`TYPE_ROCKET`/`TYPE_MISSILE`/`TYPE_BOMB` (NUMBER), `_ammo` is NUMBER. Also the whole constant vocabulary in `script_component.hpp` and the globals set in `XEH_preInit.sqf`.

- [ ] **Step 1: Create `$PBOPREFIX$`** (no trailing newline)

```
x\rtz\addons\airstrike
```

- [ ] **Step 2: Create `config.cpp`**

```cpp
#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "zen_common", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
```

`CfgContext.hpp` is deliberately not included yet — it arrives in Task 2 with the actions it declares.

- [ ] **Step 3: Create `script_component.hpp`** — the whole constant vocabulary, so no later task has to add a define in a file it is otherwise not touching

```cpp
#define COMPONENT airstrike
#define COMPONENT_BEAUTIFIED Airstrike
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_AIRSTRIKE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_AIRSTRIKE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_AIRSTRIKE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// The aim session's target ring and approach arrow draw through rtz_core's ONE
// Draw3D handler, so this component needs that contract (RENDER_WORLD, CTX_*).
#include "\x\rtz\addons\core\script_macros_core.hpp"

// ── What kind of ordnance ────────────────────────────────────────────────────
// Decided ONCE per weapon by FUNC(strikeWeapons) and carried in the menu row,
// because it selects the release range, the aim offset and the shot cap. Stored
// as a number rather than the raw BIS_fnc_itemType string so nothing downstream
// does string comparison on a per-tick path.
#define TYPE_GUN     0
#define TYPE_ROCKET  1
#define TYPE_MISSILE 2
#define TYPE_BOMB    3

// Slant range at which each type releases (meters), indexed by TYPE_*. A bomb
// wants a long, high release and a gun run wants a short one — which is the whole
// reason the weapon is chosen BEFORE the bearing is drawn rather than after.
#define RELEASE_RANGE [700, 900, 1500, 1200]

// Vertical fudge added to the aim point, indexed by TYPE_*. A guided missile aimed
// at a point on the deck noses into the dirt short of it; every other type wants
// the aim point where it was drawn. ZEN's CAS module applies the same 20 m to its
// missile type and nothing to the rest.
#define AIM_OFFSET [0, 0, 20, 0]

// ── Run-in geometry ──────────────────────────────────────────────────────────
// Wargame's plane figures (jac_fnc_tacticalAirSupport).
#define RUN_IN_DISTANCE   1500   // m from the aim point back to the run-in start
#define RUN_IN_ALTITUDE    750   // m above terrain at the run-in start
#define RUN_IN_CAPTURE     150   // m — close enough to drop onto the rail
#define HEADING_TOLERANCE   15   // deg — aligned enough to drop onto the rail
#define EGRESS_DISTANCE   4000   // m beyond the aim point
#define FLY_HEIGHT_MIN     150   // m — floor for the flyInHeight handed back on egress

// ── Ingress steering ─────────────────────────────────────────────────────────
// This replaces Wargame's precomputed parabolic approach paths entirely. A target
// behind the aircraft produces a reversal because the rotation simply takes
// longer — there is no turnaround case to detect and no path to build.
#define TURN_RATE           12   // deg/s cap. 12 is a 30-second full circle:
                                 // chosen for readable Zeus-scale movement rather
                                 // than for realism. The most likely constant to
                                 // need retuning after in-game test 2.
#define BANK_MAX            60   // deg of roll at full turn rate
#define CLIMB_MAX           30   // deg of pitch during ingress, so a run-in start
                                 // far above the aircraft does not stand it on its tail
#define MAX_DELTA          0.5   // s — a frame hitch or a mission-time jump must not
                                 // be handed to the steering as one enormous turn

// Cruise is derived from the aircraft's OWN config maxSpeed, not a flat figure:
// a Buzzard and a Caesar BTT have no business flying the same rail. CRUISE_COEF is
// Wargame's ATTACK-RUN fraction (maxSpeedOG * 0.5), not its lower approach one — at
// 0.25 a light propeller aircraft comes out at a walking pace and only the floor
// rescues it, which would make the floor rather than the aircraft decide its speed.
#define CRUISE_COEF        0.5
#define CRUISE_MIN          40   // m/s floor

// ── Firing ───────────────────────────────────────────────────────────────────
// ZEN CAS module figures, except MAX_SHOTS which is Wargame's.
#define FIRE_DURATION        3   // s the firing window stays open
#define FIRE_DELAY         0.1   // s between fireAtTarget calls
#define AIM_RAISE           12   // m the aim point rises across the firing window,
                                 // which walks the burst instead of stacking every
                                 // round on one spot
#define MAX_SHOTS           26   // capped to 1 instead when weaponLockSystem != 0

// ── Deadlines ────────────────────────────────────────────────────────────────
// Every phase is bounded and the whole strike is bounded. A wedged strike must not
// be able to hold the per-frame handler for the rest of a multi-hour operation.
#define INGRESS_TIMEOUT    120
#define RUN_TIMEOUT         40
#define EGRESS_TIMEOUT      15
#define STRIKE_TIMEOUT     180
#define CHECK_INTERVAL    0.25   // s — throttle for the abort conditions

// ── Aim session ──────────────────────────────────────────────────────────────
#define MIN_AIM_DRAG        25   // m of world drag below which the bearing falls back
                                 // to the aircraft's current heading, so the gesture
                                 // degrades gracefully to a plain click
#define AIM_RING_RADIUS     40   // m — radius of the drawn target ring
#define AIM_RING_SEGMENTS   24
#define AIM_ARROW_LENGTH   400   // m — how far the drawn approach arrow extends

#define HINT_DURATION        4
#define HINT_ARROW         300   // m — length of the confirmation hint's approach line

#define ICON_STRIKE   "\a3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa"
#define COLOR_STRIKE  [0.9, 0.5, 0.1, 1]
#define COLOR_INVALID [0.9, 0.2, 0.2, 1]

// ── Phases ───────────────────────────────────────────────────────────────────
// Three, not four: FIRING is a flag inside the run rather than a phase of its own,
// because the rail has to keep driving the aircraft while it shoots. Splitting them
// would leave two things owning the hull's velocity at once.
#define PHASE_INGRESS 0
#define PHASE_RUN     1
#define PHASE_EGRESS  2

// ── Layout of a strike record in GVAR(active) ────────────────────────────────
// One entry per aircraft striking on THIS machine. Written by FUNC(executeStrike),
// driven by FUNC(strikeTick), torn down by FUNC(endStrike) and by nothing else.
//
// DRIVER is the load-bearing one: the unit whose AI this strike actually disabled,
// remembered so teardown restores THAT unit rather than whoever occupies the seat
// when it ends. Same reasoning as rtz_slide's MANEUVER_DRIVER.
#define STRIKE_PLANE     0
#define STRIKE_DRIVER    1
#define STRIKE_AIM       2   // aim point, ASL
#define STRIKE_BEARING   3   // direction of FLIGHT, degrees
#define STRIKE_WEAPON    4   // [weapon, turretPath, type]
#define STRIKE_PHASE     5
#define STRIKE_START     6   // run-in start point, ASL
#define STRIKE_RESTORE   7   // [moveAI, targetAI, autoTargetAI, behaviour, combatMode]
#define STRIKE_RAIL      8   // [origin, velocity, vectorDir, vectorUp, t0, duration]
#define STRIKE_LASER     9   // objNull until the firing window opens
#define STRIKE_SHOTS    10
#define STRIKE_NEXTFIRE 11
#define STRIKE_PHASE_AT 12   // deadline for the CURRENT phase
#define STRIKE_DEADLINE 13   // hard deadline for the whole strike
#define STRIKE_CHECK    14   // next throttled-condition time
#define STRIKE_CRUISE   15   // m/s, derived once at order time
#define STRIKE_PROGRESS 16   // 0..1 fire progress, drives the rail's aim raise
#define STRIKE_FIRE_END 17   // absolute time the firing window closes
```

- [ ] **Step 4: Create `CfgEventHandlers.hpp`**

```cpp
class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_postInit));
    };
};
```

- [ ] **Step 5: Create `XEH_PREP.hpp`**

```cpp
PREP(strikeWeapons);
```

- [ ] **Step 6: Create `XEH_preStart.sqf`**

```sqf
#include "script_component.hpp"

#include "XEH_PREP.hpp"
```

- [ ] **Step 7: Create `XEH_preInit.sqf`**

```sqf
#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Initialised HERE rather than behind CBA_settingsInitialized: FUNC(canStrike)
// reads it from a ZEN context CONDITION, which is evaluated on every context-menu
// open from the first frame the curator display exists. A nil read there is
// "Undefined variable" spam in the RPT on every right-click.
GVAR(enabled) = false;

// Config-derived weapon classification, memoised per vehicle CLASS. Bounded by the
// number of aircraft classes the mission actually uses, which is a handful.
GVAR(weaponCache) = createHashMap;

// One record per aircraft striking on THIS machine, and the id of the shared
// per-frame handler driving them. -1 means the handler does not exist, which is the
// state between strikes: idle cost is nothing, not merely small.
GVAR(active) = [];
GVAR(pfh) = -1;

// Wall clock of the previous tick, so the steering can work in real time rather
// than in frames.
GVAR(lastTick) = 0;

// The aim session in progress on THIS client, [] when there is none.
GVAR(aiming) = [];

#include "initSettings.inc.sqf"

ADDON = true;
```

- [ ] **Step 8: Create `XEH_postInit.sqf`** (handlers arrive in Task 4)

```sqf
#include "script_component.hpp"

// CBA event handlers for strike execution are registered here from Task 4.
```

- [ ] **Step 9: Create `initSettings.inc.sqf`**

```sqf
private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// GLOBAL, not client-local. The two halves of this component run on DIFFERENT
// machines — the aim session on the curator's client, FUNC(executeStrike) wherever
// the aircraft is local. If the two disagreed, a curator whose client has the
// feature on could send QGVAR(execute) to a machine that never expected to receive
// it. rtz_path carries this exact hazard for its commit event and resolves it the
// same way.
//
// Default OFF. This is a new, opt-in system that takes an aircraft off its AI and
// flies it on rails; no mission should acquire that merely by upgrading the mod.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;
```

- [ ] **Step 10: Create `stringtable.xml`**

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project name="RTZ">
    <Package name="Airstrike">
        <Key ID="STR_RTZ_Airstrike_DisplayName">
            <English>Airstrike</English>
        </Key>
        <Key ID="STR_RTZ_Airstrike_Enabled">
            <English>Enable Airstrike</English>
        </Key>
        <Key ID="STR_RTZ_Airstrike_Enabled_Description">
            <English>Allows curators to order a selected plane to fly a scripted attack run against a chosen position. The aircraft is flown on rails for the duration of the run and is returned to AI control afterwards.</English>
        </Key>
    </Package>
</Project>
```

- [ ] **Step 11: Create `functions/script_component.hpp`**

```cpp
#include "\x\rtz\addons\airstrike\script_component.hpp"
```

- [ ] **Step 12: Create `functions/fnc_strikeWeapons.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Lists the weapons on one aircraft usable for a ground strike, each with the
 * ordnance type that decides its release range and its live ammo count.
 *
 * Split in two on purpose. WHICH weapons a vehicle carries and WHAT they are is
 * config-derived and identical for every aircraft of that class, so it is memoised
 * in GVAR(weaponCache) and paid for once per class per mission. How much ammo is
 * left is not, and is read fresh on every call.
 *
 * A pylon loadout changed at runtime with setPylonLoadout is the one case the class
 * cache gets wrong. It is still cached against the class, because the alternative is
 * a full config walk per aircraft on every context-menu open — paid on the curator's
 * client while he waits for the menu to appear — and the failure mode is a wrong
 * weapon NAME rather than a wrong ammo count or a strike that misbehaves.
 *
 * Arguments:
 * 0: Aircraft <OBJECT>
 *
 * Return Value:
 * Usable weapons as [weapon, turretPath, type, ammo] <ARRAY>
 *
 * Example:
 * private _weapons = [cursorObject] call rtz_airstrike_fnc_strikeWeapons
 *
 * Public: No
 */

params ["_vehicle"];

private _class = typeOf _vehicle;
private _classified = GVAR(weaponCache) get _class;

if (isNil "_classified") then {
    _classified = [];

    // [-1] is the PILOT's own weapons and is NOT part of allTurrets — which is
    // where a plane's cannon and pylons almost always live. Omitting it is the
    // difference between this returning a jet's whole loadout and returning
    // nothing at all.
    {
        private _turretPath = _x;

        {
            private _weapon = _x;

            private _type = switch (toLower ((_weapon call BIS_fnc_itemType) select 1)) do {
                case "bomblauncher": {TYPE_BOMB};
                case "missilelauncher": {TYPE_MISSILE};
                case "rocketlauncher": {TYPE_ROCKET};
                case "machinegun";
                case "cannon": {TYPE_GUN};
                // Everything else, countermeasureslauncher included — that is
                // rtz_smoke's subject, not this one.
                default {-1};
            };

            if (_type != -1) then {
                // The air-to-air test is on the MAGAZINES: aiAmmoUsageFlags 256
                // marks a magazine the engine treats as air-target-only. A weapon
                // whose EVERY magazine is marked so has no business being offered
                // against a ground position; one that merely HAS an AA magazine
                // alongside ground ones is a multi-role pylon and still does.
                private _magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");

                private _groundCapable = _magazines findIf {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    getNumber (configFile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags") != 256
                } != -1;

                if (_groundCapable) then {
                    _classified pushBack [_weapon, _turretPath, _type];
                };
            };
        } forEach (_vehicle weaponsTurret _turretPath);
    } forEach ([[-1]] + allTurrets _vehicle);

    GVAR(weaponCache) set [_class, _classified];
};

// Ammo is live and is read now rather than cached. A dry weapon is dropped here
// rather than offered greyed out: a menu row exists to be clicked.
private _out = [];

{
    _x params ["_weapon", "_turretPath", "_type"];

    private _ammo = _vehicle ammo _weapon;

    if (_ammo > 0) then {
        _out pushBack [_weapon, _turretPath, _type, _ammo];
    };
} forEach _classified;

_out
```

- [ ] **Step 13: Verify the build**

Run: `hemtt check`
Expected: PASS, with `rtz_airstrike` in the built component list and no stringtable warnings.

- [ ] **Step 14: Verify in game**

Launch `.hemtt/missions/test.Altis`. Place a `B_Plane_CAS_01_F` (A-164 Wipeout) in the air, open the debug console and run:

```sqf
copyToClipboard str ([cursorObject] call rtz_airstrike_fnc_strikeWeapons);
```

Expected: a non-empty array containing the Wipeout's cannon and its pylon weapons, each as `[weapon, turretPath, type, ammo]`. Confirm the 30 mm cannon comes back as `TYPE_GUN` (0) and that no countermeasure launcher appears.

- [ ] **Step 15: Commit**

```bash
git add addons/airstrike
git commit -m "feat(airstrike): scaffold component and weapon classification"
```

---

### Task 2: Context menu and the order

**Files:**
- Create: `addons/airstrike/CfgContext.hpp`
- Create: `addons/airstrike/functions/fnc_strikeAircraft.sqf`
- Create: `addons/airstrike/functions/fnc_canStrike.sqf`
- Create: `addons/airstrike/functions/fnc_strikeActions.sqf`
- Create: `addons/airstrike/functions/fnc_orderStrike.sqf`
- Modify: `addons/airstrike/config.cpp` (add the `CfgContext.hpp` include)
- Modify: `addons/airstrike/XEH_PREP.hpp`
- Modify: `addons/airstrike/stringtable.xml`

**Interfaces:**
- Consumes: `FUNC(strikeWeapons)` from Task 1.
- Produces:
  - `FUNC(strikeAircraft)` — `[_objects] call FUNC(strikeAircraft)` returns OBJECT (the one valid aircraft) or `objNull`.
  - `FUNC(orderStrike)` — `[_aim, _objects, _args, _bearing] call FUNC(orderStrike)` where `_aim` is position ASL, `_args` is `[_vehicle, _weapon, _turretPath, _type]` and `_bearing` is NUMBER (degrees, direction of flight; `-1` means "use the aircraft's current heading"). Returns nothing. Fires `QGVAR(execute)` with `[_vehicle, _aim, _bearing, [_weapon, _turretPath, _type]]`.

This task deliberately wires the menu straight to `FUNC(orderStrike)` using the context-menu click position as the aim point. That is a working click-to-target order, not a stub — Task 3 only changes *who calls* `orderStrike`, never `orderStrike` itself.

- [ ] **Step 1: Create `functions/fnc_strikeAircraft.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a curator selection to the single aircraft an airstrike can be ordered
 * on, or objNull if the selection is not one this order can serve.
 *
 * One function rather than the same gate written at three call sites — the context
 * condition, the submenu builder and the order itself all ask exactly this question,
 * and three copies of it would drift.
 *
 * The selection is normalized through EFUNC(common,collectVehicles) so that clicking
 * a crewman orders the aircraft he is riding in, matching every other RTZ vehicle
 * order.
 *
 * Arguments:
 * 0: Selected objects <ARRAY>
 *
 * Return Value:
 * The aircraft, or objNull <OBJECT>
 *
 * Example:
 * private _plane = [_objects] call rtz_airstrike_fnc_strikeAircraft
 *
 * Public: No
 */

params ["_objects"];

private _vehicles = [_objects] call EFUNC(common,collectVehicles);

// EXACTLY one. Two aircraft is not a selection this order can serve, and picking one
// of them silently is worse than showing no button at all: the curator would watch
// the wrong jet roll in and have no way to tell why.
if (count _vehicles != 1) exitWith {objNull};

private _vehicle = _vehicles select 0;

// Planes only in v1. Helicopters are rejected HERE rather than half-supported
// downstream, because their flight profile is genuinely different and a heli flown
// on the plane rail looks broken rather than merely wrong.
if !(_vehicle isKindOf "Plane") exitWith {objNull};
if (!alive _vehicle) exitWith {objNull};

// On the deck there is no run-in to fly.
if (isTouchingGround _vehicle) exitWith {objNull};

private _driver = driver _vehicle;
if (isNull _driver) exitWith {objNull};
if (!alive _driver) exitWith {objNull};
if (isPlayer _driver) exitWith {objNull};

if (([_vehicle] call FUNC(strikeWeapons)) isEqualTo []) exitWith {objNull};

_vehicle
```

- [ ] **Step 2: Create `functions/fnc_canStrike.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Condition for the root airstrike context action: whether the current selection is
 * one AI-flown, airborne plane holding at least one usable ground-attack weapon.
 *
 * Arguments:
 * 0: Context position ASL <ARRAY> (unused; ZEN's context signature)
 * 1: Selected objects <ARRAY>
 *
 * Return Value:
 * The order can be given <BOOL>
 *
 * Example:
 * private _ok = [_position, _objects] call rtz_airstrike_fnc_canStrike
 *
 * Public: No
 */

params ["", "_objects"];

if (!GVAR(enabled)) exitWith {false};

!isNull ([_objects] call FUNC(strikeAircraft))
```

- [ ] **Step 3: Create `functions/fnc_strikeActions.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds one context menu child action per weapon the selected aircraft can strike
 * a ground position with, labelled with its display name and how many rounds it has
 * left. The parent action hides itself automatically when no children are returned.
 *
 * The count is informational, not an order size: one strike is one pass, and how
 * much of a pylon that pass spends depends on the weapon's shot cap.
 *
 * Arguments:
 * 0: Context position ASL <ARRAY>
 * 1: Selected objects <ARRAY>
 *
 * Return Value:
 * Child actions <ARRAY>
 *
 * Example:
 * private _children = [_position, _objects] call rtz_airstrike_fnc_strikeActions
 *
 * Public: No
 */

params ["_position", "_objects"];

if (!GVAR(enabled)) exitWith {[]};

private _vehicle = [_objects] call FUNC(strikeAircraft);
if (isNull _vehicle) exitWith {[]};

// Bearing -1 means "come in the way you are already pointing". Task 3 replaces this
// statement with the drag session, which supplies a real bearing.
private _statement = {[_position, _objects, _args, -1] call FUNC(orderStrike)};

([_vehicle] call FUNC(strikeWeapons)) apply {
    _x params ["_weapon", "_turretPath", "_type", "_ammo"];

    private _config = configFile >> "CfgWeapons" >> _weapon;

    [
        _weapon,
        format [LLSTRING(WeaponLabel), getText (_config >> "displayName"), _ammo],
        getText (_config >> "picture"),
        _statement,
        {true},
        [_vehicle, _weapon, _turretPath, _type]
    ]
}
```

- [ ] **Step 4: Create `functions/fnc_orderStrike.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Validates an airstrike order and sends it to the machine that owns the aircraft,
 * then draws the curator his confirmation.
 *
 * The gate here is the SAME one FUNC(canStrike) ran, deliberately re-run rather than
 * trusted. Several seconds pass while a curator draws a bearing, and the aircraft can
 * die, land, run dry or change hands inside that window — the context menu's verdict
 * is a snapshot from before the gesture started.
 *
 * Arguments:
 * 0: Aim point ASL <ARRAY>
 * 1: Selected objects <ARRAY>
 * 2: Weapon row as [vehicle, weapon, turretPath, type] <ARRAY>
 * 3: Bearing — direction of FLIGHT in degrees, or -1 for the aircraft's current
 *    heading <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_aim, _objects, _args, 270] call rtz_airstrike_fnc_orderStrike
 *
 * Public: No
 */

params ["_aim", "_objects", "_args", ["_bearing", -1]];
_args params ["_vehicle", "_weapon", "_turretPath", "_type"];

private _current = [_objects] call FUNC(strikeAircraft);

if (_current isNotEqualTo _vehicle) exitWith {
    [LSTRING(StrikeUnavailable)] call zen_common_fnc_showMessage;
};

if (_vehicle ammo _weapon <= 0) exitWith {
    [LSTRING(NoOrdnance)] call zen_common_fnc_showMessage;
};

// A click with no meaningful drag means "come in the way you are already pointing",
// which keeps the gesture usable as a plain click.
if (_bearing < 0) then {_bearing = getDir _vehicle};

[
    QGVAR(execute),
    [_vehicle, _aim, _bearing, [_weapon, _turretPath, _type]],
    _vehicle
] call CBA_fnc_targetEvent;

// Where it will hit, and which way the run comes in. The line runs from BEHIND the
// aim point along the bearing, so it reads as an approach rather than a departure.
private _from = _aim vectorAdd [-(sin _bearing) * HINT_ARROW, -(cos _bearing) * HINT_ARROW, 0];

[
    [
        ["ICON", [ASLToAGL _aim, ICON_STRIKE, COLOR_STRIKE, 1]],
        ["LINE", [ASLToAGL _from, ASLToAGL _aim, COLOR_STRIKE]]
    ],
    HINT_DURATION
] call zen_common_fnc_drawHint;
```

- [ ] **Step 5: Create `CfgContext.hpp`**

```cpp
class zen_context_menu_actions {
    class GVAR(strike) {
        displayName = CSTRING(ActionAirstrike);
        icon = ICON_STRIKE;
        insertChildren = QUOTE([ARR_2(_position,_objects)] call FUNC(strikeActions));
        condition = QUOTE([ARR_2(_position,_objects)] call FUNC(canStrike));
        priority = 44;
    };
};
```

- [ ] **Step 6: Add the include to `config.cpp`**

Change the trailing include block from:

```cpp
#include "CfgEventHandlers.hpp"
```

to:

```cpp
#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
```

- [ ] **Step 7: Update `XEH_PREP.hpp`**

```cpp
PREP(canStrike);
PREP(orderStrike);
PREP(strikeActions);
PREP(strikeAircraft);
PREP(strikeWeapons);
```

- [ ] **Step 8: Add the stringtable keys**

Insert inside the existing `<Package name="Airstrike">`:

```xml
        <Key ID="STR_RTZ_Airstrike_ActionAirstrike">
            <English>Airstrike</English>
        </Key>
        <Key ID="STR_RTZ_Airstrike_WeaponLabel">
            <English>%1 (%2)</English>
        </Key>
        <Key ID="STR_RTZ_Airstrike_StrikeUnavailable">
            <English>Aircraft can no longer strike</English>
        </Key>
        <Key ID="STR_RTZ_Airstrike_NoOrdnance">
            <English>No ordnance remaining</English>
        </Key>
```

- [ ] **Step 9: Verify the build**

Run: `hemtt check`
Expected: PASS with no unused-key warnings.

- [ ] **Step 10: Verify in game**

In `.hemtt/missions/test.Altis`, with **`Enable Airstrike` switched ON in CBA settings** (it defaults off):

1. Place an A-164 Wipeout in the air with an AI pilot. Right-click it as Zeus.
2. Expected: an **Airstrike** entry appears. Hovering it lists the aircraft's real weapons with ammo counts.
3. Click a weapon. Expected: an orange target icon and an approach line are drawn at the clicked position for 4 seconds. Nothing flies yet — execution arrives in Task 4.
4. Turn the setting OFF and right-click again. Expected: **no Airstrike entry at all.**
5. Select two planes. Expected: no entry.
6. Select a plane parked on a runway. Expected: no entry.

- [ ] **Step 11: Commit**

```bash
git add addons/airstrike
git commit -m "feat(airstrike): context menu, weapon submenu and order dispatch"
```

---

### Task 3: The drag aim session

**Files:**
- Create: `addons/airstrike/functions/fnc_beginAiming.sqf`
- Create: `addons/airstrike/functions/fnc_handleAimInput.sqf`
- Create: `addons/airstrike/functions/fnc_drawAim.sqf`
- Create: `addons/airstrike/functions/fnc_endAiming.sqf`
- Modify: `addons/airstrike/functions/fnc_strikeActions.sqf` (statement now opens the session)
- Modify: `addons/airstrike/XEH_PREP.hpp`
- Modify: `addons/airstrike/stringtable.xml`

**Interfaces:**
- Consumes: `FUNC(strikeAircraft)`, `FUNC(orderStrike)` from Task 2.
- Produces: `FUNC(beginAiming)` — `[_position, _objects, _args] call FUNC(beginAiming)`, same first three arguments as the Task 2 statement. `GVAR(aiming)` holds `[_objects, _args, _aim, _bearing, _handlers, _armed]` while a session is open and `[]` otherwise.

- [ ] **Step 1: Create `functions/fnc_beginAiming.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens the modal aim session for one airstrike: the curator presses on the target,
 * drags in the direction he wants the aircraft to fly, and releases.
 *
 * Entirely client-local. Nothing is broadcast and nothing is authoritative until the
 * mouse comes up — the curator owns the selection and the cursor, so there is no
 * reason for the server to hear about a strike being aimed.
 *
 * zen_common_fnc_selectPosition is not used because it is click-only: a bearing needs
 * a gesture with a start and an end, and it is the bearing that decides which ridge
 * the aircraft comes over and which way the ordnance walks.
 *
 * Arguments:
 * 0: Context position ASL <ARRAY> (unused; ZEN's context signature)
 * 1: Selected objects <ARRAY>
 * 2: Weapon row as [vehicle, weapon, turretPath, type] <ARRAY>
 *
 * Return Value:
 * A session was opened <BOOL>
 *
 * Example:
 * [_position, _objects, _args] call rtz_airstrike_fnc_beginAiming
 *
 * Public: No
 */

params ["", "_objects", "_args"];

private _display = findDisplay IDD_RSCDISPLAYCURATOR;
if (isNull _display) exitWith {false};

// Never two at once. A second session would install a second set of handlers on the
// same display and only one of them would ever be removed.
if (GVAR(aiming) isNotEqualTo []) then {
    call FUNC(endAiming);
};

// _armed is the "ignore the frame we started on" guard. This session is opened by
// CLICKING a context-menu entry, so without it the very click that picked the weapon
// arrives at MouseButtonDown and latches the aim point instantly. rtz_path needs no
// such guard because it is opened by a keybind, and CBA keybinds cannot be bound to a
// mouse button; EFUNC(common,placementPreview) needs exactly this one.
GVAR(aiming) = [_objects, _args, [], -1, [], false];

private _handlers = [_display] call FUNC(handleAimInput);
GVAR(aiming) set [4, _handlers];

[QGVAR(aim), LINKFUNC(drawAim), RENDER_WORLD, 60] call EFUNC(core,registerRenderer);

true
```

- [ ] **Step 2: Create `functions/fnc_handleAimInput.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Installs the curator-display handlers the aim session listens on, and hands back
 * their ids so FUNC(endAiming) can remove precisely these and leave ZEN's own
 * handlers on the same display alone.
 *
 * Consuming a press is the exception. The gesture's own three events are swallowed so
 * the Zeus display underneath does not also act on them; everything else passes
 * through.
 *
 * Arguments:
 * 0: Curator display <DISPLAY>
 *
 * Return Value:
 * Installed handlers as [[eventType, id], ...] <ARRAY>
 *
 * Example:
 * private _handlers = [_display] call rtz_airstrike_fnc_handleAimInput
 *
 * Public: No
 */

params ["_display"];

private _handlers = [];

_handlers pushBack ["MouseButtonDown", _display displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button"];

    if (GVAR(aiming) isEqualTo []) exitWith {false};

    // Right button cancels.
    if (_button == 1) exitWith {
        call FUNC(endAiming);
        true
    };

    if (_button != 0) exitWith {false};

    // The click that opened this session is still in flight. Arm on it and swallow
    // it, so the weapon pick cannot double as the target pick.
    if !(GVAR(aiming) select 5) exitWith {
        GVAR(aiming) set [5, true];
        true
    };

    // Intersections OFF: the strike should land on the terrain the cursor is over,
    // not on the roof of whatever building happens to be under it.
    GVAR(aiming) set [2, [nil, 0] call zen_common_fnc_getPosFromScreen];
    GVAR(aiming) set [3, -1];

    true
}]];

_handlers pushBack ["MouseMoving", _display displayAddEventHandler ["MouseMoving", {
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    private _aim = GVAR(aiming) select 2;
    if (_aim isEqualTo []) exitWith {false};

    private _cursor = [nil, 0] call zen_common_fnc_getPosFromScreen;

    // Below MIN_AIM_DRAG the gesture has not said anything yet, so the bearing stays
    // unset and the order falls back to the aircraft's current heading. That is what
    // makes a plain click a valid order rather than an accident.
    if (_aim distance2D _cursor < MIN_AIM_DRAG) exitWith {
        GVAR(aiming) set [3, -1];
        false
    };

    GVAR(aiming) set [3, _aim getDir _cursor];

    false
}]];

_handlers pushBack ["MouseButtonUp", _display displayAddEventHandler ["MouseButtonUp", {
    params ["", "_button"];

    if (_button != 0) exitWith {false};
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    GVAR(aiming) params ["_objects", "_args", "_aim", "_bearing"];

    // Released without ever having pressed on a target — nothing was aimed.
    if (_aim isEqualTo []) exitWith {false};

    call FUNC(endAiming);

    [_aim, _objects, _args, _bearing] call FUNC(orderStrike);

    true
}]];

_handlers pushBack ["KeyDown", _display displayAddEventHandler ["KeyDown", {
    params ["", "_key"];

    if (_key != DIK_ESCAPE) exitWith {false};
    if (GVAR(aiming) isEqualTo []) exitWith {false};

    call FUNC(endAiming);

    true
}]];

_handlers
```

`DIK_ESCAPE` is CBA's standard key macro (`1`); it is available through `script_macros.hpp`. If `hemtt check` reports it undefined, substitute the literal `1` and comment it.

- [ ] **Step 3: Create `functions/fnc_drawAim.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the aim session: a ring on the target and an arrow through it pointing the
 * way the aircraft will fly.
 *
 * Registered on rtz_core's shared frame loop rather than on a Draw3D handler of its
 * own, and unregistered by FUNC(endAiming). A session left registered is a renderer
 * on that loop for the rest of the mission.
 *
 * Arguments:
 * 0: Frame context <ARRAY> - see the CTX_* indices in rtz_core's contract
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctx] call rtz_airstrike_fnc_drawAim
 *
 * Public: No
 */

params ["_ctx"];

if (GVAR(aiming) isEqualTo []) exitWith {};

GVAR(aiming) params ["_objects", "_args", "_aim", "_bearing"];

// Nothing pressed yet — there is no target to draw a ring around.
if (_aim isEqualTo []) exitWith {};

_args params ["_vehicle"];

// Tinted invalid the moment the order would be refused, so the curator sees a dead
// gesture before he releases rather than a message after.
private _valid = alive _vehicle
    && {!isNull ([_objects] call FUNC(strikeAircraft))}
    && {_vehicle ammo (_args select 1) > 0};

private _color = [COLOR_INVALID, COLOR_STRIKE] select _valid;

private _centre = ASLToAGL _aim;

// The ring is built from AIM_RING_SEGMENTS straight segments. Cheap, and this only
// runs while a session is open.
private _step = 360 / AIM_RING_SEGMENTS;
private _previous = _centre vectorAdd [0, AIM_RING_RADIUS, 0];

for "_i" from 1 to AIM_RING_SEGMENTS do {
    private _angle = _i * _step;
    private _point = _centre vectorAdd [(sin _angle) * AIM_RING_RADIUS, (cos _angle) * AIM_RING_RADIUS, 0];

    drawLine3D [_previous, _point, _color];
    _previous = _point;
};

// A bearing of -1 means the drag has not said anything yet, so the arrow shows what
// the order would actually use: the aircraft's current heading.
private _shown = if (_bearing < 0) then {getDir _vehicle} else {_bearing};

private _from = _centre vectorAdd [-(sin _shown) * AIM_ARROW_LENGTH, -(cos _shown) * AIM_ARROW_LENGTH, 0];

drawLine3D [_from, _centre, _color];
drawIcon3D [ICON_STRIKE, _color, _centre, 0.8, 0.8, 0];
```

- [ ] **Step 4: Create `functions/fnc_endAiming.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Closes the aim session. The single exit path: commit, right-click, Escape and the
 * curator display closing under the session all route through here.
 *
 * That concentration is the point. A session leaves two pieces of state behind it —
 * four handlers on the curator display and one renderer on rtz_core's shared frame
 * loop — and both outlive the session, for the rest of the mission, if any single
 * exit forgets them.
 *
 * The handler ids removed are the ones FUNC(handleAimInput) reported, never
 * displayRemoveAllEventHandlers: ZEN has its own handlers on the same display and
 * they must survive this.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_airstrike_fnc_endAiming
 *
 * Public: No
 */

if (GVAR(aiming) isEqualTo []) exitWith {};

private _handlers = GVAR(aiming) select 4;

// Cleared BEFORE the handlers are removed, so a handler that fires during removal
// sees a closed session rather than a half-torn-down one.
GVAR(aiming) = [];

private _display = findDisplay IDD_RSCDISPLAYCURATOR;

if (!isNull _display) then {
    {
        _x params ["_type", "_id"];
        _display displayRemoveEventHandler [_type, _id];
    } forEach _handlers;
};

[QGVAR(aim)] call EFUNC(core,unregisterRenderer);
```

- [ ] **Step 5: Point the menu at the session**

In `functions/fnc_strikeActions.sqf`, replace:

```sqf
// Bearing -1 means "come in the way you are already pointing". Task 3 replaces this
// statement with the drag session, which supplies a real bearing.
private _statement = {[_position, _objects, _args, -1] call FUNC(orderStrike)};
```

with:

```sqf
// Picking a weapon opens the aim session; the session issues the order once the
// curator has drawn a target and a bearing.
private _statement = {[_position, _objects, _args] call FUNC(beginAiming)};
```

- [ ] **Step 6: Update `XEH_PREP.hpp`**

```cpp
PREP(beginAiming);
PREP(canStrike);
PREP(drawAim);
PREP(endAiming);
PREP(handleAimInput);
PREP(orderStrike);
PREP(strikeActions);
PREP(strikeAircraft);
PREP(strikeWeapons);
```

- [ ] **Step 7: Verify the build**

Run: `hemtt check`
Expected: PASS.

- [ ] **Step 8: Verify in game**

With the setting ON, an airborne AI Wipeout selected:

1. Right-click → Airstrike → pick a weapon. Expected: the menu closes and **nothing is latched yet** — the arming guard swallowed the opening click.
2. Press and hold LMB over a target. Expected: a ring appears there with an arrow through it on the aircraft's current heading.
3. Drag away from the ring. Expected: the arrow swings to follow the drag once past ~25 m; under that it stays on the aircraft's heading.
4. Release. Expected: the confirmation hint from Task 2 appears on the drawn bearing.
5. Repeat, but press Escape mid-drag. Expected: everything disappears. Then run `str (missionNamespace getVariable ["rtz_core_worldRenderers", []])` in the debug console and confirm no `rtz_airstrike_aim` entry remains.
6. Repeat, but close the Zeus display mid-drag, then reopen it. Expected: no leftover ring, no stuck handlers, and the same renderer check comes back clean.

Item 6 is the one to watch: if the display closes without `endAiming` running, the renderer leaks. If it does, add a `zen_common_fnc_onCuratorClosed` or `Unload` hook that calls `FUNC(endAiming)`, and note it.

- [ ] **Step 9: Commit**

```bash
git add addons/airstrike
git commit -m "feat(airstrike): press-drag-release aim session with target ring and bearing arrow"
```

---

### Task 4: Execution transport, teardown and ingress

**Files:**
- Create: `addons/airstrike/functions/fnc_executeStrike.sqf`
- Create: `addons/airstrike/functions/fnc_endStrike.sqf`
- Create: `addons/airstrike/functions/fnc_steerToward.sqf`
- Create: `addons/airstrike/functions/fnc_strikeTick.sqf`
- Modify: `addons/airstrike/XEH_postInit.sqf`
- Modify: `addons/airstrike/XEH_PREP.hpp`

**Interfaces:**
- Consumes: the `QGVAR(execute)` payload `[_vehicle, _aim, _bearing, [_weapon, _turretPath, _type]]` from Task 2.
- Produces:
  - `FUNC(executeStrike)` — receiver, returns nothing.
  - `FUNC(endStrike)` — `[_record, _reroute] call FUNC(endStrike)`, `_reroute` BOOL defaulting `true`. Does **not** remove the record from `GVAR(active)`; the caller does.
  - `FUNC(steerToward)` — `[_vehicle, _destinationASL, _cruise, _delta] call FUNC(steerToward)`, returns nothing.
  - `FUNC(strikeTick)` — CBA per-frame handler, no arguments.

At the end of this task a strike flies its ingress and then ends. The rail arrives in Task 5.

- [ ] **Step 1: Create `functions/fnc_steerToward.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Flies one aircraft one step toward a point, turning no faster than TURN_RATE.
 *
 * This is the whole of the ingress geometry, and it is what replaces Wargame's
 * precomputed approach paths. A target BEHIND the aircraft needs no special case: the
 * yaw error is simply large, so the rotation takes more ticks and the aircraft comes
 * around in an arc. Wargame spends a parabolic path builder, a semicircle turnaround
 * case and fifty interpolated splice points on the same problem.
 *
 * Heading is read from vectorDir rather than getDir, because this function SETS the
 * direction vector every tick and getDir would round-trip it through the engine's yaw
 * and discard the pitch the climb needs.
 *
 * Arguments:
 * 0: Aircraft <OBJECT>
 * 1: Destination ASL <ARRAY>
 * 2: Cruise speed, m/s <NUMBER>
 * 3: Seconds since the previous tick <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, _start, _cruise, _delta] call rtz_airstrike_fnc_steerToward
 *
 * Public: No
 */

params ["_vehicle", "_destination", "_cruise", "_delta"];

private _current = vectorDir _vehicle;
private _desired = (getPosASL _vehicle) vectorFromTo _destination;

private _currentYaw = (_current select 0) atan2 (_current select 1);
private _desiredYaw = (_desired select 0) atan2 (_desired select 1);

// Wrapped into (-180, 180] so a target ten degrees to the left is a ten-degree turn
// rather than a three-hundred-and-fifty-degree one. Without the wrap the aircraft
// takes the long way round roughly half the time.
private _error = ((_desiredYaw - _currentYaw + 540) % 360) - 180;

private _maxTurn = TURN_RATE * _delta;
private _turn = (_error max (-_maxTurn)) min _maxTurn;
private _yaw = _currentYaw + _turn;

// Pitch is chased toward the destination and clamped, so a run-in start well above
// the aircraft does not stand it on its tail.
private _pitch = (asin ((_desired select 2) max -1 min 1)) max (-CLIMB_MAX) min CLIMB_MAX;

private _dir = [
    (sin _yaw) * (cos _pitch),
    (cos _yaw) * (cos _pitch),
    sin _pitch
];

_vehicle setVectorDir _dir;

// Bank in proportion to how hard it is ACTUALLY turning, so the model leans into the
// arc instead of sliding around it flat. Guarded against a zero-length tick, which
// happens on the first frame after a hitch.
private _bank = if (_maxTurn > 0) then {-(BANK_MAX * (_turn / _maxTurn))} else {0};

[_vehicle, _pitch, _bank] call BIS_fnc_setPitchBank;

_vehicle setVelocity (_dir vectorMultiply _cruise);
```

- [ ] **Step 2: Create `functions/fnc_executeStrike.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Receives an airstrike order on the machine that owns the aircraft, captures what
 * the strike is about to override, and registers the record the tick will drive.
 *
 * Arguments:
 * 0: Aircraft <OBJECT>
 * 1: Aim point ASL <ARRAY>
 * 2: Bearing, direction of flight in degrees <NUMBER>
 * 3: Weapon as [weapon, turretPath, type] <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, _aim, 270, ["Bomb_04_Plane_CAS_01_F", [-1], 3]] call rtz_airstrike_fnc_executeStrike
 *
 * Public: No
 */

params ["_vehicle", "_aim", "_bearing", "_weaponData"];

// The setting is GLOBAL, so this machine holds its own copy and is entitled to refuse.
// The condition on the curator's client is a UI gate, not an authorization: a curator
// whose client has the feature on must not be able to fly an aircraft on a machine
// where it is off.
if (!GVAR(enabled)) exitWith {};

if (!local _vehicle) exitWith {};
if (!alive _vehicle) exitWith {};

private _driver = driver _vehicle;
if (isNull _driver || {!alive _driver} || {isPlayer _driver}) exitWith {};

// A re-order REPLACES, it never stacks. Without this a curator who re-tasks the same
// jet three times gets three records driving one hull, each fighting the others for
// its velocity — the same shape as the watch stacking EFUNC(attack,addWaypoint)
// carries a comment about.
private _existing = GVAR(active) findIf {(_x select STRIKE_PLANE) isEqualTo _vehicle};

if (_existing != -1) then {
    [GVAR(active) select _existing] call FUNC(endStrike);
    GVAR(active) deleteAt _existing;
};

// Captured BEFORE anything is forced, so teardown restores the state the aircraft
// actually had rather than the state this strike put it in. Restoring blanket-enabled
// AI would switch on features some other RTZ order had deliberately disabled.
private _restore = [
    _driver checkAIFeature "MOVE",
    _driver checkAIFeature "TARGET",
    _driver checkAIFeature "AUTOTARGET",
    behaviour _driver,
    combatMode (group _driver)
];

_driver disableAI "MOVE";
_driver disableAI "TARGET";
_driver disableAI "AUTOTARGET";
_driver setBehaviour "CARELESS";
(group _driver) setCombatMode "BLUE";

private _start = _aim getPos [RUN_IN_DISTANCE, _bearing + 180];
_start set [2, (getTerrainHeightASL _start) + RUN_IN_ALTITUDE];

// Derived ONCE, here, rather than re-read from config on every tick.
private _cruise = ((getNumber (configOf _vehicle >> "maxSpeed") * CRUISE_COEF) / 3.6) max CRUISE_MIN;

private _now = CBA_missionTime;

GVAR(active) pushBack [
    _vehicle, _driver, _aim, _bearing, _weaponData,
    PHASE_INGRESS, _start, _restore, [], objNull,
    0, 0, _now + INGRESS_TIMEOUT, _now + STRIKE_TIMEOUT, 0,
    _cruise, 0, 0
];

// Created by the first strike, destroyed by the last. Between strikes the handler
// does not exist, so idle cost is nothing rather than merely small.
if (GVAR(pfh) == -1) then {
    GVAR(lastTick) = _now;
    GVAR(pfh) = [LINKFUNC(strikeTick), 0] call CBA_fnc_addPerFrameHandler;
};
```

- [ ] **Step 3: Create `functions/fnc_endStrike.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Tears down one airstrike, undoing everything FUNC(executeStrike) forced on the
 * aircraft and its driver.
 *
 * The single exit path. Arrival, timeout, the aircraft dying, the driver dying,
 * ownership moving, and a re-order superseding it all route through here — which is
 * the point: a strike leaves an aircraft with three AI features disabled, a CARELESS
 * behaviour and a laser target in the world, and every one of those outlives the
 * strike if any single exit forgets it.
 *
 * The driver restored is the one recorded when the strike STARTED, never
 * `driver _vehicle` re-read now. Those are different units whenever the pilot was
 * killed or swapped mid-run, and restoring the current occupant leaves the real one
 * with MOVE disabled for the rest of the mission with nothing holding a reference to
 * him.
 *
 * EVERY command below takes a LOCAL argument, so teardown only means anything on the
 * machine that owns the piece being torn down. One exit reaches here with that no
 * longer true: FUNC(strikeTick) ends a strike precisely BECAUSE `!local _vehicle`, and
 * running the restores there would be a series of silent no-ops leaving a plane
 * permanently unable to fly itself. So each half is applied where it is local and
 * targeted at its owner where it is not, and the receiving copy is told not to
 * re-route so a split pair cannot ping-pong between two owners forever. Same trap and
 * same fix as EFUNC(slide,endSlide).
 *
 * Arguments:
 * 0: Strike record <ARRAY> - layout in script_component.hpp
 * 1: Route the non-local halves to their owners <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record] call rtz_airstrike_fnc_endStrike
 *
 * Public: No
 */

params ["_record", ["_reroute", true]];
_record params ["_vehicle", "_driver"];

// The laser target is not locality-bound the way the aircraft is — whichever machine
// created it can delete it — so it is cleared before anything else and unconditionally.
private _laser = _record select STRIKE_LASER;
if (!isNull _laser) then {
    deleteVehicle _laser;
    _record set [STRIKE_LASER, objNull];
};

private _remote = [];

if (!isNull _vehicle) then {
    if (local _vehicle) then {
        if (alive _vehicle) then {
            // Hand the hull back to physics carrying the velocity it actually has, so
            // it does not stop dead in the air on the frame the rail lets go.
            _vehicle setVelocity (velocity _vehicle);

            // NOT a restore: the engine has no getter for flyInHeight, so there is
            // nothing to restore it to. This is a sane value chosen from where the
            // aircraft ended up, which is what Wargame does for the same reason.
            private _altitude = ((getPos _vehicle) select 2) max FLY_HEIGHT_MIN;
            _vehicle flyInHeight _altitude;
        };
    } else {
        _remote pushBack _vehicle;
    };
};

if (!isNull _driver) then {
    if (local _driver) then {
        (_record select STRIKE_RESTORE) params ["_move", "_target", "_autoTarget", "_behaviour", "_combatMode"];

        // Restored to what was CAPTURED, not blanket-enabled. An aircraft whose AI
        // another RTZ order had already disabled must not come back with it on.
        // Applied even to a dead driver: the flags live on the unit, not on the seat,
        // and a body that gets revived should not come back paralysed.
        if (_move) then {_driver enableAI "MOVE"} else {_driver disableAI "MOVE"};
        if (_target) then {_driver enableAI "TARGET"} else {_driver disableAI "TARGET"};
        if (_autoTarget) then {_driver enableAI "AUTOTARGET"} else {_driver disableAI "AUTOTARGET"};

        if (alive _driver && {!isPlayer _driver}) then {
            _driver setBehaviour _behaviour;
            (group _driver) setCombatMode _combatMode;
        };
    } else {
        _remote pushBackUnique _driver;
    };
};

if (!_reroute || {_remote isEqualTo []}) exitWith {};

// The whole record travels, not just the stranded half: the receiver re-runs this same
// function and picks out whatever IS local to it, so there is no second teardown
// implementation to keep in step with this one.
[QGVAR(release), [_record, false], _remote] call CBA_fnc_targetEvent;
```

- [ ] **Step 4: Create `functions/fnc_strikeTick.sqf`** (ingress only; Tasks 5 and 7 extend the `switch`)

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * The engine behind every airstrike running on this machine: one shared per-frame
 * handler walking GVAR(active), created by the first strike (FUNC(executeStrike)) and
 * removed by the last. Idle cost is therefore not "small", it is nothing — the handler
 * does not exist between strikes.
 *
 * Per-frame is spent on the two things that need it and nothing else: the steering or
 * rail push, which sets absolute velocity and visibly stutters at anything slower, and
 * the phase-transition test, which is what puts the aircraft on its rail at the right
 * point instead of a tick-length past it. Every other reason a strike ends changes on
 * human timescales and is re-checked at CHECK_INTERVAL instead — the same split
 * EFUNC(slide,slideTick) makes.
 *
 * Arguments:
 * None (CBA per-frame handler)
 *
 * Return Value:
 * None
 *
 * Example:
 * [rtz_airstrike_fnc_strikeTick, 0] call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

// Last strike finished on the previous pass — take the loop down rather than leave it
// spinning over an empty array for the rest of the mission.
if (GVAR(active) isEqualTo []) exitWith {
    [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(pfh) = -1;
};

private _now = CBA_missionTime;

// Real elapsed time, so the steering turns at TURN_RATE degrees per SECOND rather than
// per frame — otherwise the same order flies differently on a 30 fps server and a
// 120 fps client. Clamped because a frame hitch or a mission-time jump would otherwise
// be handed to the steering as one enormous turn.
private _delta = ((_now - GVAR(lastTick)) max 0) min MAX_DELTA;
GVAR(lastTick) = _now;

// Backwards, so a finished strike can be deleted without disturbing the indices of the
// records not visited yet.
for "_i" from (count GVAR(active)) - 1 to 0 step -1 do {
    private _record = GVAR(active) select _i;
    private _vehicle = _record select STRIKE_PLANE;

    // `alive` earns its place on the frame path despite being a state check: it also
    // answers objNull, so an aircraft deleted out from under the strike — rtz_delete
    // does exactly that — stops being driven on the frame it goes rather than up to
    // CHECK_INTERVAL later. `local` sits here for the same reason and is just as cheap:
    // every command in this loop is a silent no-op without it, and left in the
    // throttled block an ownership transfer meant a quarter second of driving a hull
    // this machine no longer owns, with teardown just as late.
    private _finished = !alive _vehicle
        || {!local _vehicle}
        || {_now > (_record select STRIKE_DEADLINE)}
        || {_now > (_record select STRIKE_PHASE_AT)};

    if (!_finished) then {
        switch (_record select STRIKE_PHASE) do {
            case PHASE_INGRESS: {
                private _start = _record select STRIKE_START;

                [_vehicle, _start, _record select STRIKE_CRUISE, _delta] call FUNC(steerToward);

                // BOTH tests, never either: close enough is not the same as pointed the
                // right way, and a rail entered off-axis flies a run the curator did
                // not draw.
                private _offset = ((getDir _vehicle) - (_record select STRIKE_BEARING) + 540) % 360 - 180;

                if (abs _offset < HEADING_TOLERANCE && {(getPosASL _vehicle) distance _start < RUN_IN_CAPTURE}) then {
                    // Task 5 replaces this with the hand-off onto the rail.
                    _finished = true;
                };
            };
        };
    };

    if (_finished) then {
        [_record] call FUNC(endStrike);
        GVAR(active) deleteAt _i;
    };
};
```

- [ ] **Step 5: Register the event handlers in `XEH_postInit.sqf`**

```sqf
#include "script_component.hpp"

// Sent by FUNC(orderStrike) on the curator's client, targeted at the machine that owns
// the aircraft.
[QGVAR(execute), LINKFUNC(executeStrike)] call CBA_fnc_addEventHandler;

// Sent by FUNC(endStrike) when a strike ends with its aircraft and driver on different
// machines. The receiving copy re-runs the same teardown and picks out whatever is
// local to it; _reroute is false so a split pair cannot bounce the event back and
// forth between two owners forever.
[QGVAR(release), {
    params ["_record", "_reroute"];
    [_record, _reroute] call FUNC(endStrike);
}] call CBA_fnc_addEventHandler;
```

- [ ] **Step 6: Update `XEH_PREP.hpp`** — add `PREP(endStrike);`, `PREP(executeStrike);`, `PREP(steerToward);`, `PREP(strikeTick);`, keeping the list alphabetical.

- [ ] **Step 7: Verify the build**

Run: `hemtt check`
Expected: PASS.

- [ ] **Step 8: Verify in game**

1. Order a strike on an airborne Wipeout with a target roughly ahead of it. Expected: the aircraft banks onto a course for a point 1500 m short of the target at 750 m, flies there, and then resumes normal AI flight.
2. Order a strike with the target directly **behind** the aircraft. Expected: a smooth reversal — one continuous arc, no corkscrew, no snapping. **This is the item that judges `TURN_RATE`.** If the turn is too lazy, raise it; if it snaps, lower it.
3. While the aircraft is on ingress, run `str (count rtz_airstrike_active)` in the debug console. Expected: `1`. After it finishes, expected: `0`, and `str rtz_airstrike_pfh` returns `-1`.
4. Order a second strike while the first is on ingress. Expected: `count rtz_airstrike_active` stays `1` — replaced, not stacked.
5. Shoot the aircraft down mid-ingress. Expected: the registry empties and the handler is removed.
6. After any completed ingress, confirm the aircraft flies normally: run `str [_plane checkAIFeature "MOVE", _plane checkAIFeature "AUTOTARGET"]`. Expected: `[true,true]`.

- [ ] **Step 9: Commit**

```bash
git add addons/airstrike
git commit -m "feat(airstrike): execution transport, teardown contract and turn-rate ingress"
```

---

### Task 5: The attack rail

**Files:**
- Modify: `addons/airstrike/functions/fnc_strikeTick.sqf`

**Interfaces:**
- Consumes: everything from Task 4.
- Produces: `STRIKE_RAIL` is populated as `[_origin, _velocity, _vectorDir, _vectorUp, _t0, _duration]` on entry to `PHASE_RUN`; `PHASE_RUN` is reached and exited.

- [ ] **Step 1: Replace the ingress hand-off**

In `fnc_strikeTick.sqf`, replace:

```sqf
                if (abs _offset < HEADING_TOLERANCE && {(getPosASL _vehicle) distance _start < RUN_IN_CAPTURE}) then {
                    // Task 5 replaces this with the hand-off onto the rail.
                    _finished = true;
                };
```

with:

```sqf
                if (abs _offset < HEADING_TOLERANCE && {(getPosASL _vehicle) distance _start < RUN_IN_CAPTURE}) then {
                    private _origin = getPosASL _vehicle;
                    private _aim = _record select STRIKE_AIM;
                    private _cruise = _record select STRIKE_CRUISE;

                    private _dir = _origin vectorFromTo _aim;

                    // The dive angle the module uses, from the two legs of the descent
                    // rather than from a fixed number: -90 plus the angle between the
                    // horizontal run and the drop. Floored so an aim point at or above
                    // the aircraft cannot divide by zero.
                    private _horizontal = _origin distance2D _aim;
                    private _drop = (((_origin select 2) - (_aim select 2))) max 1;
                    private _pitch = -90 + atan (_horizontal / _drop);

                    _vehicle setVectorDir _dir;
                    [_vehicle, _pitch, 0] call BIS_fnc_setPitchBank;

                    // Captured ONCE. setVelocityTransformation interpolates between two
                    // fixed states, so re-deriving these every tick would move the
                    // goalposts under the interpolation and the aircraft would never
                    // arrive.
                    _record set [STRIKE_RAIL, [
                        _origin,
                        _dir vectorMultiply _cruise,
                        _dir,
                        vectorUp _vehicle,
                        _now,
                        (_origin distance _aim) / _cruise
                    ]];

                    _record set [STRIKE_PHASE, PHASE_RUN];
                    _record set [STRIKE_PHASE_AT, _now + RUN_TIMEOUT];
                };
```

- [ ] **Step 2: Add the `PHASE_RUN` case**

Immediately after the `case PHASE_INGRESS: { … };` block, inside the same `switch`:

```sqf
            case PHASE_RUN: {
                (_record select STRIKE_RAIL) params ["_origin", "_velocity", "_dir", "_up", "_t0", "_duration"];

                private _aim = _record select STRIKE_AIM;
                private _type = (_record select STRIKE_WEAPON) select 2;

                // The aim point is raised by a per-type offset plus the fire progress.
                // The offset keeps a guided missile from nosing into the dirt short of a
                // ground-level mark; the progress term is the module's own fudge, which
                // walks the burst forward instead of stacking every round on one spot.
                private _target = +_aim;
                _target set [2,
                    (_target select 2)
                    + ((AIM_OFFSET) select _type)
                    + (_record select STRIKE_PROGRESS) * AIM_RAISE
                ];

                _vehicle setVelocityTransformation [
                    _origin, _target,
                    _velocity, _velocity,
                    _dir, _dir,
                    _up, _up,
                    (_now - _t0) / _duration
                ];

                // setVelocityTransformation writes the interpolated state but leaves the
                // engine's own velocity integration to fight it on the next physics step.
                // Re-asserting the velocity it just produced is what keeps the aircraft on
                // the line; both references do exactly this and it is not redundant.
                _vehicle setVelocity (velocity _vehicle);

                // Task 6 opens the firing window here.

                if ((_now - _t0) >= _duration) then {
                    // Task 7 replaces this with the hand-off to egress.
                    _finished = true;
                };
            };
```

- [ ] **Step 3: Verify the build**

Run: `hemtt check`
Expected: PASS.

- [ ] **Step 4: Verify in game**

1. Order a strike. Expected: the aircraft flies its ingress, then noses over and **dives cleanly through the drawn aim point** along the drawn bearing, then reverts to AI flight at the bottom.
2. Draw the bearing from several different directions and confirm the dive always arrives along the line drawn, not along the shortest path from wherever the plane happened to be.
3. Watch for the aircraft "sticking" at the top of the dive. If it does, `_duration` is being computed from a stale `_origin` — confirm the rail is captured once, not per tick.

- [ ] **Step 5: Commit**

```bash
git add addons/airstrike
git commit -m "feat(airstrike): setVelocityTransformation attack rail"
```

---

### Task 6: The release

**Files:**
- Create: `addons/airstrike/functions/fnc_release.sqf`
- Modify: `addons/airstrike/functions/fnc_strikeTick.sqf`
- Modify: `addons/airstrike/XEH_PREP.hpp`

**Interfaces:**
- Consumes: the record from Task 4, `PHASE_RUN` from Task 5.
- Produces: `FUNC(release)` — `[_record, _now] call FUNC(release)` returns BOOL (`true` when the firing window is finished). Mutates `STRIKE_LASER`, `STRIKE_SHOTS`, `STRIKE_NEXTFIRE`, `STRIKE_PROGRESS`, `STRIKE_FIRE_END` in place.

- [ ] **Step 1: Create `functions/fnc_release.sqf`**

```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * Runs the firing window of one attack run: creates the mark, points the aircraft at
 * it, and pulls the trigger on a cadence until the window closes.
 *
 * The invisible laser target is the whole trick, and it is ZEN's CAS module's. The AI
 * will not engage bare coordinates — fireAtTarget needs something to aim at — but it
 * will engage a laser target sitting on them. Wargame solves the same problem the hard
 * way, by re-guiding every projectile in a FiredMan handler; that is the upgrade path
 * for accuracy, and this function is separate precisely so it can be taken without
 * touching the engine.
 *
 * Kept OUT of the rail's own case in FUNC(strikeTick) even though it runs inside the
 * run phase, because it owns five fields of the record and inlining it would make the
 * rail's case the longest thing in the component.
 *
 * Arguments:
 * 0: Strike record, mutated in place <ARRAY>
 * 1: Current mission time <NUMBER>
 *
 * Return Value:
 * The firing window is finished <BOOL>
 *
 * Example:
 * private _done = [_record, _now] call rtz_airstrike_fnc_release
 *
 * Public: No
 */

params ["_record", "_now"];

_record params ["_vehicle", "_driver", "_aim"];
(_record select STRIKE_WEAPON) params ["_weapon"];

private _laser = _record select STRIKE_LASER;

// First call for this strike: plant the mark and hand the aircraft its target.
if (isNull _laser) then {
    private _side = side (group _driver);
    private _class = ["LaserTargetE", "LaserTargetW"] select (_side getFriend west > 0.6);

    // "NONE" so it is not snapped to the terrain and is not registered as curator
    // editable — a curator who could select and delete the mark could break the strike
    // he had just ordered, without any way to see why.
    _laser = createVehicle [_class, ASLToAGL _aim, [], 0, "NONE"];
    _laser setPosASL _aim;

    _record set [STRIKE_LASER, _laser];
    _record set [STRIKE_FIRE_END, _now + FIRE_DURATION];

    // reveal/doWatch/doTarget take the EMITTER's laser target, while fireAtTarget takes
    // the emitter object itself. That asymmetry is ZEN's, and it is reproduced rather
    // than tidied because it is the combination known to work.
    _vehicle reveal (laserTarget _laser);
    _driver doWatch (laserTarget _laser);
    _driver doTarget (laserTarget _laser);
};

if (_now >= (_record select STRIKE_NEXTFIRE)) then {
    _vehicle fireAtTarget [_laser, _weapon];

    _record set [STRIKE_NEXTFIRE, _now + FIRE_DELAY];
    _record set [STRIKE_SHOTS, (_record select STRIKE_SHOTS) + 1];
};

private _fireEnd = _record select STRIKE_FIRE_END;

// Drives the rail's aim raise. Rising from 0 to 1 across the window is what walks the
// impacts forward instead of piling them on one spot.
_record set [STRIKE_PROGRESS, ((1 - ((_fireEnd - _now) / FIRE_DURATION)) max 0) min 1];

// A lock-based launcher hammered at 10 Hz empties its whole pylon into a single point,
// so guided weapons fire once and are done.
private _guided = getNumber (configFile >> "CfgWeapons" >> _weapon >> "weaponLockSystem") != 0;
private _cap = [MAX_SHOTS, 1] select _guided;

_now >= _fireEnd
    || {(_record select STRIKE_SHOTS) >= _cap}
    || {_vehicle ammo _weapon <= 0}
```

- [ ] **Step 2: Open the firing window from the rail**

In `fnc_strikeTick.sqf`, replace the line:

```sqf
                // Task 6 opens the firing window here.
```

with:

```sqf
                // The window opens on slant range, not on rail progress: a bomb wants a
                // long, high release and a gun run a short one, and the two arrive at
                // very different fractions of the same rail.
                private _range = RELEASE_RANGE select _type;

                if (!isNull (_record select STRIKE_LASER) || {(getPosASL _vehicle) distance _aim < _range}) then {
                    [_record, _now] call FUNC(release);
                };
```

The `!isNull` half keeps the window open once it has opened, so a fast aircraft that overshoots the release range inside one tick still finishes its burst.

- [ ] **Step 3: Update `XEH_PREP.hpp`** — add `PREP(release);`, keeping the list alphabetical.

- [ ] **Step 4: Verify the build**

Run: `hemtt check`
Expected: PASS.

- [ ] **Step 5: Verify in game**

1. Wipeout, **bombs** selected, target an empty field. Expected: the aircraft dives, releases at roughly 1200 m slant, and the bombs land in the general area of the mark. Near, not precisely on — that is the documented v1 accuracy.
2. Same aircraft, **cannon** selected. Expected: a visibly later release, roughly 700 m, and a burst that walks forward rather than piling on one point.
3. Guided missile (a Blackfoot's Scalpels or a jet's GBU). Expected: exactly **one** launch, not a salvo.
4. A jet with only one bomb left. Expected: it fires once and the window closes on ammo rather than on time.
5. After any strike, run `count (allMissionObjects "LaserTargetW" + allMissionObjects "LaserTargetE")`. Expected: `0` — no orphaned mark.

- [ ] **Step 6: Commit**

```bash
git add addons/airstrike
git commit -m "feat(airstrike): laser-target release window"
```

---

### Task 7: Egress and hardening

**Files:**
- Modify: `addons/airstrike/functions/fnc_strikeTick.sqf`
- Modify: `addons/airstrike/stringtable.xml`

**Interfaces:**
- Consumes: everything above.
- Produces: `PHASE_EGRESS`; the throttled abort block.

- [ ] **Step 1: Hand off to egress**

In `fnc_strikeTick.sqf`, replace:

```sqf
                if ((_now - _t0) >= _duration) then {
                    // Task 7 replaces this with the hand-off to egress.
                    _finished = true;
                };
```

with:

```sqf
                if ((_now - _t0) >= _duration) then {
                    _record set [STRIKE_PHASE, PHASE_EGRESS];
                    _record set [STRIKE_PHASE_AT, _now + EGRESS_TIMEOUT];

                    // The aircraft is handed back to its AI HERE rather than at teardown,
                    // so the pull-off is flown by the pilot and looks like flying rather
                    // than like a scripted object being released mid-dive. Teardown still
                    // runs the same restores — they are idempotent, and teardown is also
                    // reached by paths that never get here.
                    private _egress = _aim getPos [EGRESS_DISTANCE, _record select STRIKE_BEARING];
                    _egress set [2, (getTerrainHeightASL _egress) + RUN_IN_ALTITUDE];

                    (_record select STRIKE_RESTORE) params ["_move", "", "", "_behaviour"];

                    if (_move) then {(_record select STRIKE_DRIVER) enableAI "MOVE"};

                    _vehicle flyInHeight RUN_IN_ALTITUDE;
                    _vehicle doMove (ASLToAGL _egress);
                };
```

- [ ] **Step 2: Add the `PHASE_EGRESS` case**

After the `case PHASE_RUN: { … };` block:

```sqf
            case PHASE_EGRESS: {
                // Nothing to drive: the AI has the aircraft back and is flying the
                // pull-off itself. This phase exists only to keep the record alive long
                // enough for the aircraft to get clear of its own bombs before the mark
                // is deleted, and it ends on distance or on EGRESS_TIMEOUT.
                if ((getPosASL _vehicle) distance (_record select STRIKE_AIM) > RUN_IN_DISTANCE) then {
                    _finished = true;
                };
            };
```

- [ ] **Step 3: Add the throttled abort block**

In `fnc_strikeTick.sqf`, immediately after the `switch` closes and before `if (_finished) then {`:

```sqf
    // Everything that changes on human timescales. Roughly a dozen engine calls per
    // aircraft traded from once a frame down to four times a second, on each record's
    // own stagger. Skipped entirely once something faster has already ended the strike.
    if (!_finished && {_now >= (_record select STRIKE_CHECK)}) then {
        _record set [STRIKE_CHECK, _now + CHECK_INTERVAL];

        private _driver = _record select STRIKE_DRIVER;
        (_record select STRIKE_WEAPON) params ["_weapon"];

        _finished =
            // Not "is there a driver" but "is it still HIM" — a swapped seat ends the
            // strike so teardown can restore the unit it actually disabled.
            (driver _vehicle) isNotEqualTo _driver
            || {!alive _driver}
            || {isPlayer _driver}
            // Dry BEFORE the window ever opened: there is nothing left to deliver, so
            // flying the rest of the run is theatre.
            || {(_record select STRIKE_PHASE) != PHASE_EGRESS
                && {isNull (_record select STRIKE_LASER)}
                && {_vehicle ammo _weapon <= 0}};
    };
```

- [ ] **Step 4: Add the stringtable key for the abort message** — insert inside `<Package name="Airstrike">`:

```xml
        <Key ID="STR_RTZ_Airstrike_StrikeAborted">
            <English>Airstrike aborted</English>
        </Key>
```

If nothing ends up calling `showMessage` with it, **delete the key rather than leaving it** — `hemtt check` reports unused stringtable keys and a dead key is a check failure, not a harmless leftover.

- [ ] **Step 5: Verify the build**

Run: `hemtt check`
Expected: PASS, no unused-key warnings.

- [ ] **Step 6: Run the full verification matrix from the spec**

1. Jet with bombs, target ahead — ordinary run, clean pull-off.
2. Target directly behind — clean reversal.
3. Gun run vs. bomb run — visibly different release ranges.
4. Aircraft shot down mid-run — no orphaned laser target, and `str [_wreck checkAIFeature "MOVE"]` on a surviving pilot shows the captured value restored.
5. Second strike ordered while one is running — `count rtz_airstrike_active` stays 1.
6. Escape mid-aim — no renderer left registered.
7. Aircraft with no usable ordnance, or on the ground — no action.
8. **Ownership transferred mid-strike via `rtz_control`** — the strike ends and the plane flies normally afterwards on its new owner. Verify with `str [_plane checkAIFeature "MOVE", _plane checkAIFeature "AUTOTARGET"]` **on the machine that now owns it**. This is the item most likely to break.
9. Setting OFF — no action appears, and a `QGVAR(execute)` fired by hand from the debug console is refused.

- [ ] **Step 7: Commit**

```bash
git add addons/airstrike
git commit -m "feat(airstrike): egress phase and throttled abort conditions"
```

---

### Task 8: Documentation

**Files:**
- Modify: `docs/Architecture.md`

**Interfaces:**
- Consumes: the finished component.
- Produces: nothing in code.

- [ ] **Step 1: Add the component row**

In the "Current components" table in `docs/Architecture.md`, insert a row in alphabetical position (between `assemble` and `attack`):

```markdown
| `airstrike` | Order one selected plane to fly a scripted attack run against a curator-drawn point and bearing, delivering a weapon picked from its own pylon loadout. Off by default (`GVAR(enabled)`, Global — the aim session and the executor run on different machines, so they must agree). Split by locality like `path`: the press-drag-release aim session is entirely client-local (one renderer on `core`'s frame loop, no server traffic), and only the order crosses the wire, as one targeted event.<br><br>**Fully on rails**, because the AI will not fly a coherent attack run and will not engage a bare position at all. Three phases on one shared per-frame handler over a bounded registry, created by the first strike and destroyed by the last: an ingress flown by **bounded turn-rate steering** — which replaces Wargame's precomputed parabolic approach paths entirely, since a target behind the aircraft needs no special case when the rotation is simply allowed to take longer — then ZEN's CAS-module `setVelocityTransformation` rail, then an AI-flown pull-off. The release is the module's trick: an **invisible laser target** planted on the aim point, because `fireAtTarget` needs something to aim at and the AI will not engage coordinates. Accuracy is therefore module-grade; re-guiding projectiles in a `FiredMan` handler, as Wargame does, is the upgrade path and `fnc_release` is separate so it can be taken without touching the engine.<br><br>All teardown routes through `fnc_endStrike`, which restores the AI features **captured at order time** rather than blanket-enabling them, and restores the driver captured at order time rather than whoever is in the seat when it ends. Like `slide`, it applies whichever half is local and targets `QGVAR(release)` at the owner of the other — a strike ended *because* ownership moved would otherwise restore into thin air and leave a plane permanently unable to fly itself. `flyInHeight` is the one thing NOT restored: the engine has no getter for it, so egress sets a sane value from where the aircraft ended up |
```

- [ ] **Step 2: Verify the build**

Run: `hemtt check`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add docs/Architecture.md
git commit -m "docs: describe the airstrike component in Architecture.md"
```

---

## Self-review notes

**Spec coverage.** Every section of the spec maps to a task: architecture and files → Task 1; data flow and the condition → Tasks 2-3; weapon classification → Task 1; the aim session → Task 3; the strike engine's three phases → Tasks 4-7; failure/locality/teardown → Tasks 4 and 7; settings and text → Task 1 plus per-task additions; verification → the in-game step of every task, with the spec's full matrix run in Task 7; documentation → Task 8. The spec's "known limitations" section is design commentary and needs no task.

**Type consistency.** `FUNC(strikeWeapons)` returns four-element rows `[weapon, turretPath, type, ammo]` in Task 1; `fnc_strikeActions` destructures exactly those four in Task 2 and packs the first three plus the vehicle into `_args` as `[vehicle, weapon, turretPath, type]`; `fnc_orderStrike` destructures that same four-element `_args` and sends the three-element `[weapon, turretPath, type]` as `STRIKE_WEAPON`; Tasks 5-7 read `STRIKE_WEAPON select 2` for the type and `params ["_weapon"]` for the weapon. The four shapes are distinct and each is used consistently — the one to watch when editing is that `_args` carries the vehicle and `STRIKE_WEAPON` does not.

**One thing to watch during execution:** Task 3, item 6. If the curator display can close without `endAiming` running, the renderer leaks onto `core`'s frame loop for the rest of the mission. The plan flags this as a conditional follow-up rather than pre-solving it, because whether ZEN's display teardown already fires a usable hook needs to be observed rather than guessed.
