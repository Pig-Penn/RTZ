# SQF & Arma 3 Gotchas

Traps that bite repeatedly when working on RTZ. Each entry is the trap, the fix, and *why* —
several are bugs this repo actually shipped and had to hunt down.

> Rule of thumb: when a command misbehaves, open its Biki page and read the **Multiplayer**
> box (`Arguments: Local/Global`, `Effect: Local/Global`) and the **Problems/Notes** section
> before assuming your logic is wrong. Most "random" Arma bugs are locality or scheduler bugs.

---

## 1. Scheduler & execution environment

### `sleep` / `waitUntil` are illegal in the unscheduled environment

```sqf
// BAD - inside an event handler, PFH, or XEH
sleep 3;
_unit setDamage 0;
```

The engine **ignores the suspension and throws `Suspending not allowed in this context`**.
Execution does not pause — the next line runs immediately, so the code "works" but with none
of the intended delay. Use the CBA equivalents, which are unscheduled-safe:

```sqf
[{
    params ["_unit"];
    _unit setDamage 0;
}, [_unit], 3] call CBA_fnc_waitAndExecute;          // replaces sleep
[{ _cond }, { _code }, _args] call CBA_fnc_waitUntilAndExecute;  // replaces waitUntil
```

**Everything in this codebase is unscheduled**: CBA Extended Event Handlers (`XEH_preInit`,
`XEH_postInit`), all event handlers, every `CBA_fnc_addPerFrameHandler` body, anything reached
by `call` from those, and anything sent via `remoteExecCall`. Only `spawn` / `execVM` /
`remoteExec` create a scheduled scope. `canSuspend` returns whether suspension is legal in the
current scope if you ever need to branch on it.

### Scheduled code gets ~3 ms per frame and can be starved

A `spawn`ed loop is suspended after roughly 3 ms and resumes whenever the scheduler gets back
to it — which, under load, can be many frames later. This is why RTZ uses
`CBA_fnc_addPerFrameHandler` everywhere ([fnc_remoteControlIndicator.sqf:20-21](addons/spotting/functions/fnc_remoteControlIndicator.sqf#L20-L21)
spells out the reasoning) rather than `spawn` + `sleep`.

### State goes stale across a suspension

Anything that yields — `sleep`, `waitUntil`, `CBA_fnc_waitAndExecute` — is a window in which
the unit can die, the vehicle can be deleted, and the player can disconnect. Re-validate after
the wait, never before it only:

```sqf
[{
    params ["_unit", "_vehicle"];
    if (!alive _unit || {isNull _vehicle}) exitWith {};   // re-check, the world moved on
    ...
}, [_unit, _vehicle], 5] call CBA_fnc_waitAndExecute;
```

### A `waitUntilAndExecute` without a timeout polls forever

`CBA_fnc_waitUntilAndExecute` re-evaluates its condition **every frame**, with no upper bound
unless you give it one. A watch whose condition may simply never come true is then a permanent
per-frame cost for the rest of the mission — and if the same watch is re-armed on each new order,
they stack rather than replace. On a multi-hour operation that accumulates.

It takes a timeout and a timeout branch; use them:

```sqf
[{ _cond }, { _onTrue }, _args, 600, { _onTimeout }] call CBA_fnc_waitUntilAndExecute;
```

Shipped in `fnc_addWaypoint`, which watched a DESTROY target for deletion with no timeout — one
per-frame condition per attack order, forever, and re-tasking a group added another.

### `while` loops in unscheduled code silently stop at 10,000 iterations

The engine caps unscheduled `while` at 10,000 iterations and quits the loop. A loop that
"mysteriously processes only part of the list" on a busy server is usually this.

---

## 2. Scopes & control flow

### `exitWith` inside `forEach` is `continue`, not `break`

`exitWith` exits **the current scope and only the current scope**. Inside a `forEach` body the
current scope is that single iteration, so it behaves as `continue`.

```sqf
{
    if (_x == _needle) exitWith { _found = true };   // skips to next element, keeps looping
} forEach _units;
```

Since Arma 3 v2.02 the fix is simply **`break`**, which works in `for`, `while` and `forEach`:

```sqf
{
    if (_x == _needle) then { _found = true; break };   // actually stops
} forEach _units;
```

**Put the test at the TOP of the loop body.** A `break` at the bottom still pays for the whole
iteration's work before it fires, which defeats the point when the loop body is the expensive part.

This shipped **five times**. The first three were "stop at the first hit" early-outs that silently
did nothing — the parameter was accepted, documented, and inert:

| Site | Dead parameter |
|---|---|
| [fnc_collectDeletables.sqf](addons/delete/functions/fnc_collectDeletables.sqf) | `_firstOnly` — and it sat *after* the crew expansion it existed to skip |
| [fnc_findTargets.sqf](addons/supply/functions/fnc_findTargets.sqf) | `_limit` — the context-menu condition swept a whole parked column to answer a boolean |
| [fnc_findCountermeasureWeapons.sqf](addons/common/functions/fnc_findCountermeasureWeapons.sqf) | `_firstOnly` |

The other two were worse, because the loop did not merely cost too much — it returned the
**wrong answer**. Both walked `lineIntersectsSurfaces`, whose hits come back sorted by distance
from the *begin* position, looking for the first mostly-flat surface. `exitWith` let the loop run
on, so each later hit overwrote the result and the **last** surface won instead of the first:

| Site | Symptom |
|---|---|
| [fnc_teleportToCursor.sqf](addons/common/functions/fnc_teleportToCursor.sqf) | Trace runs downward from 200 m up, so "first" means highest. Units teleported onto a multi-storey building landed on its ground floor, and units aimed at a bridge landed underneath it |
| [fnc_placementPreview.sqf](addons/common/functions/fnc_placementPreview.sqf) | Trace runs outward from the curator camera, so "first" means nearest. The placement ghost snapped through the roof under the cursor down to the ground below it |

The lesson generalises: an `exitWith` whose block **assigns** rather than merely reads is not just a
missed optimisation, it is a silent last-wins reducer. Grep for `exitWith` inside `forEach` before
trusting any "take the first match" loop — and note that a plain-text grep will also hit the prose
in these entries, so confirm each match is real code.

The older `scopeName` / `breakOut` route still works and is needed when you must unwind *several*
scopes at once, but **the value must ride along**: a bare `breakOut "scan"` exits with no return
value, so the function hands back `nil`. That bug shipped too, in `fnc_collectLootables` — the Loot
action's condition broke precisely when there *was* loot to take. `breakOut` also needs the scope
named on a *parent* scope; `scopeName` inside the `forEach` body would name the iteration itself.

Note that `findIf` is **not** affected by any of this — it short-circuits natively and is the right
tool for a pure existence test (see [fnc_canLoot.sqf](addons/loot/functions/fnc_canLoot.sqf)).

### `&&` and `||` only short-circuit with a code block on the right

```sqf
if (count _arr > 0 && (_arr select 0) isEqualTo _x) then {...};   // BAD: both sides evaluated
if (count _arr > 0 && {(_arr select 0) isEqualTo _x}) then {...}; // GOOD: lazy
```

With a plain Boolean on the right, **both operands are evaluated** before the operator runs, so
the guard you wrote on the left does not protect the right. Braces make the right side lazy.
This is why the codebase chains conditions as `_a && {_b} && {_c}` (see
[fnc_collectLootables.sqf:50-58](addons/loot/functions/fnc_collectLootables.sqf#L50-L58)).

### A `nil` condition aborts the whole script

`if (nil) then {...}` is a type error that kills the remainder of the running script — not just
the `if`. In `XEH_postInit` that means the rest of your init never runs, silently. This is the
failure mode behind the settings race in §4.

### `continue` does not escape a `switch do` case

`continue` applies to the enclosing loop, but a `switch do` case is its own code block —
a `continue` written inside one does not reliably reach the `forEach` around the `switch`.

```sqf
{
    private _list = switch (_source) do {
        case SRC_HULLS: {
            if !(_stream in _streams) then { continue };   // BAD - scope is the case
            _hulls
        };
    };
} forEach _streams;
```

Hoist the test out of the `switch` so `continue` sits directly in the loop body:

```sqf
{
    if (_source == SRC_HULLS && {!(_stream in _streams)}) then { continue };   // GOOD
    private _list = switch (_source) do { ... };
} forEach _streams;
```

### Nested `forEach` does **not** clobber `_x` — but alias anyway for readability

This entry used to claim the opposite, and that was wrong. `_x` and `_forEachIndex` are created in
the **called** scope, not the calling one, so an inner loop's `_x` is a different variable and is
gone the moment the inner loop ends. Nesting has been safe since Arma 2, and the same holds for the
other iteration commands that bind `_x` (`count`, `apply`, `select`, `findIf`, `configClasses`).

So this is correct, and `_x` in the `then` block is still the vehicle:

```sqf
{
    if (crew _x findIf {isPlayer _x} == -1) then { _x setOwner _id };   // outer _x intact
} forEach _vehicles;
```

**Alias regardless when the two are easy to confuse.** Not for correctness, but because a reader
should not have to hold this rule in their head to follow the code:

```sqf
{
    private _group = _x;
    { _group addVehicle _x } forEach _vehicles;   // reads unambiguously
} forEach _groups;
```

The one thing that genuinely *does* leak is a variable you set yourself inside the block — that
follows the ordinary `private` rules, not this one.

---

## 3. Variables & types

### `call` shares the caller's variable scope; `spawn` inherits nothing

`call`ed code runs in the caller's scope. Forget `private` and you overwrite the caller's
variable:

```sqf
_i = 0;   // BAD - stomps a caller's _i
private _i = 0;   // GOOD - always declare
```

Conversely, `spawn`ed code gets a **fresh** scope: local variables from the calling scope are
not visible there. Pass them through `_this`. Same for code sent via `remoteExec`.

### Arrays and hashmaps are assigned by reference

```sqf
private _b = _a;    // _b IS _a - mutating one mutates the other
private _b = +_a;   // deep copy
```

Returning an internal array from a getter hands the caller a live handle to your state. Copy
with `+` at the boundary if the caller might mutate it.

### `==` on strings is case-**in**sensitive; `isEqualTo` is case-sensitive

```sqf
"B_Soldier_F" == "b_soldier_f"          // true
"B_Soldier_F" isEqualTo "b_soldier_f"   // false
```

Config class names and `typeOf` results come back in inconsistent casing, so `==` is usually
what you want for them. But `isEqualTo` has a second trap: **it never errors on type
mismatch**, it just returns `false` (`"eleven" isEqualTo 11`). A type bug that `==` would have
surfaced as an error silently becomes a `false` branch.

### `select` out of range: sometimes `nil`, sometimes a hard error

- index **equal to** `count _arr` → returns `nil`, no error
- index **beyond** that, or **negative** → throws `Error Zero Divisor`

So off-by-one reads fail quietly and land as `nil` somewhere far from the cause. Use `param` /
`params` with defaults for anything that might be short:

```sqf
params [["_radius", 50, [0]], ["_limit", 0, [0]]];
private _mode = _args param [2, "default"];
```

### `findIf` returns `-1`, so test `!= -1`

```sqf
if (_units findIf {!alive _x} > 0) then {...};    // BAD - misses index 0
if (_units findIf {!alive _x} != -1) then {...};  // GOOD
```

And use `findIf` — not `count` — for existence tests: `{...} count _arr` evaluates the block
for **every** element with no short-circuit, while `findIf` stops at the first hit.

### `getVariable` without a default returns `nil`

```sqf
private _n = _unit getVariable QGVAR(count);            // may be nil
private _n = _unit getVariable [QGVAR(count), 0];       // always a number
```

That `nil` then propagates into arithmetic or an `if`, erroring far from the read. Always use
the two-element form.

### `isNil` vs `isNull` vs `alive`

- `isNil` — the variable was never set (undefined).
- `isNull` — the variable holds `objNull` / `grpNull` / a deleted object. Use `isNull _obj`,
  not `_obj == objNull`.
- `alive` — the object exists but may be a corpse or a wreck.

A deleted object's variable is *not* `nil`, it becomes null — so `isNil` will not catch it.
Dead units and wrecks are still non-null objects, which is why
[fnc_collectLootables.sqf:50-52](addons/loot/functions/fnc_collectLootables.sqf#L50-L52) tests
`alive` separately.

### `typeOf` vs `typeName`

`typeOf _unit` → the object's config class (`"B_Soldier_F"`). `typeName _x` → the SQF data type
(`"OBJECT"`, `"STRING"`, `"ARRAY"`). Easy to reach for the wrong one.

---

## 4. Multiplayer & locality

### AI orders only take effect where the group is local

`doMove`, `commandMove`, waypoint creation, `setSkill`, `setUnitPos`, inventory changes — these
need to run on the machine that owns the unit. Issued from a curator's client against an
AI-owned-elsewhere unit, they do nothing at all, with no error. Route them with
`CBA_fnc_targetEvent` / `remoteExec` to the owner.

### The server is *not* always where the AI is local

AI offloaded to a headless client, or AI in a player-led group, is local to that other machine.
Code that assumes "AI ⇒ server" breaks on exactly the setups that matter.
[fnc_grantCurators.sqf:10-14](addons/common/functions/fnc_grantCurators.sqf#L10-L14) documents
this case and forwards to the server with `CBA_fnc_serverEvent`.

### `remoteExec`'d code does not capture local variables

The code is transferred and run in a fresh scope on the target. Locals from the sending scope
do not exist there — pass everything through the argument array.

Also worth keeping straight:

- Targets: `0` = everyone, `2` = server, a negative ID = everyone **except** that machine.
- `remoteExec` runs the code **scheduled**; `remoteExecCall` runs it **unscheduled**. Picking
  the wrong one is how a `sleep` ends up in an unscheduled scope (§1).
- JIP only happens if you pass a JIP parameter — otherwise late joiners never see it.

### `setVariable` broadcast vs. JIP

`_obj setVariable ["x", _v, true]` broadcasts **and** persists for JIP clients.
`publicVariable` broadcasts but does **not** reach players who join later. `SETPVAR` in
[script_macros.hpp:22-23](addons/main/script_macros.hpp#L22-L23) is the public-flag helper.

### CBA settings are not ready in `postInit`

A client receives its synced setting values a frame or more *after* `postInit`. Reading one
straight away yields `nil` — and `if (nil) then` aborts the rest of the init (§2). Defending
with a default is just as wrong: it silently ignores a server-side "disabled". Gate on the
event:

```sqf
["CBA_settingsInitialized", { if (GVAR(enabled)) then { call FUNC(start) } }] call CBA_fnc_addEventHandler;
```

**There is no `CBA_fnc_runAfterSettingsInit`.** That helper is ACE3/ZEN-only
(`ace_common_fnc_` / `zen_common_fnc_`); calling the `CBA_` name is a silent `nil` no-op.
See [spotting/XEH_postInit.sqf:3-10](addons/spotting/XEH_postInit.sqf#L3-L10).

### `allPlayers` includes headless clients

It also returns virtual curators and virtual spectators, and it can be **incomplete for the
first moments of a mission**. Filter it:

```sqf
private _humans = allPlayers - entities "HeadlessClient_F";
```

### `isServer` / `isDedicated` / `hasInterface` are not interchangeable

On a **hosted** (listen) server the host machine is `isServer` *and* `hasInterface` — but not
`isDedicated`. Code written as "server = no UI" breaks there. Pick the one that matches the
actual question: who owns the logic (`isServer`) vs. who can draw (`hasInterface`).

### AI-state reads answer only where **the unit you ask about** is local

`expectedDestination`, `assignedTarget` and `targetKnowledge` return AI brain state, which
exists only on the owning machine — elsewhere they return empty or stale nonsense with no error
to warn you. The trap is testing locality on the wrong object: for a crewed vehicle the pathing
and sensor state belongs to the **crewman** (`effectiveCommander` for movement, `gunner` for
targeting), and a vehicle can be local here while its crew's group is owned elsewhere. Test
`local` on the unit you are about to query, not on the hull. See
[fnc_gatherTarget.sqf](addons/hud/functions/fnc_gatherTarget.sqf).

`expectedDestination` returns `[position, planningMode, forceReplan]` and reports `[0,0,0]` when
there is no plan. `planningMode` is one of `DoNotPlan` (not moving), `DoNotPlanFormation`,
`LEADER PLANNED`, `LEADER DIRECT`, `FORMATION PLANNED`, `VEHICLE PLANNED` — note the runtime
strings are **spaced and uppercase** where the wiki writes them camel-cased, so normalize before
matching, and do not forget `VEHICLE PLANNED`: it is what every *driving vehicle* reports.

`targetKnowledge` returns
`[knownByGroup, knownByUnit, lastSeen, lastThreat, side, positionError, position, ignoreTarget]`
— index 2 is the sighting time, 5 the error in metres, and 6 an **ASL** position needing
`ASLToAGL` before it is drawn.

---

## 5. Zeus & curator specifics

### Scripted objects are not editable by any curator

`createVehicle` does not add the object to anyone's editable set, so Zeus immediately loses
control of anything a script spawns. Register it explicitly:

```sqf
_curator addCuratorEditableObjects [[_object], _addCrew];
```

Curator modules are **server-local**, and `addCuratorEditableObjects` needs its curator
argument local — so the grant must run on the server. See
[fnc_grantCurators.sqf](addons/common/functions/fnc_grantCurators.sqf).

### Remote-control state cannot be read remotely

`remoteControlled` and `isRemoteControlling` are locality-bound: they only answer correctly on
the machine where the unit is local, i.e. the controller's own client. The server cannot trust
them. Read the `"bis_fnc_moduleRemoteControl_owner"` object variable instead — the vanilla BI
module, ACE3 and ZEN all set it with the public flag, so it is synced everywhere. Documented at
[fnc_remoteControlIndicator.sqf:11-18](addons/spotting/functions/fnc_remoteControlIndicator.sqf#L11-L18).

### `getAssignedCuratorUnit`: an `isNull` guard is not enough — use `isPlayer`

A playable Zeus slot whose AI is not disabled **leaves the body behind** when the player leaves,
so `getAssignedCuratorUnit` keeps returning a non-null, server-local, *non-player* object. Its
`owner` is `2`, so anything routed to it with `CBA_fnc_targetEvent` goes to the server: a silent
no-op on a dedicated server, but on a **listen server** the host has the receivers registered
and renders a departed curator's data as its own. `isPlayer` is the correct test, and
`isPlayer objNull` is `false` so it subsumes the null check. Full reasoning at
[fnc_spotCheck.sqf:104-112](addons/spotting/functions/fnc_spotCheck.sqf#L104-L112).

### Context-menu conditions run constantly — keep them cheap

A `condition` in `CfgContext.hpp` is evaluated as the menu builds, against the whole selection.
Anything that scans nearby objects should take a limit and bail early (the pattern
`FUNC(canLoot)` uses — pass `1` and stop at the first hit).

### A `modifierFunction` mutates a fixed-layout array — use the `ACTION_INDEX_*` macros

ZEN compiles each `CfgContext.hpp` entry into a flat array and hands it to `modifierFunction`
as `_this select 0`, to be mutated in place. The layout is set by
`zen_context_menu_fnc_compileActions`:

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| name | displayName | icon | iconColor | statement | condition | args | insertChildren | modifierFunction |

Use `ACTION_INDEX_DISPLAYNAME` / `_ICON` / `_ICONCOLOR` … from
[script_macros.hpp](addons/main/script_macros.hpp), never bare `1` / `2` / `3`.

### `localize` and double-quoted strings cannot go inside `QUOTE(...)`

`QUOTE` builds a **double-quoted** config string, so any `"` the expansion emits terminates it
early and `hemtt check` reports *"macro's result could not be parsed"*. This bites on both
`LLSTRING(x)` (expands to `localize "STR_…"`) and a `#define` holding a double-quoted literal.

Two fixes, both in [rtz_hud](addons/hud): define constants that appear inside `QUOTE`
with **single** quotes (`#define STREAM_DEST 'dest'` — valid SQF, harmless in config), and
resolve localized labels **inside** the called function from a plain id rather than passing them
through the config.

### `curatorSelected` is `[objects, groups, waypoints, markers]`

Use the `SELECTED_OBJECTS` / `SELECTED_GROUPS` macros from
[script_macros.hpp:44-45](addons/main/script_macros.hpp#L44-L45) rather than indexing by hand,
and normalize through `EFUNC(common,collectUnits)` / `collectSquads` / `collectVehicles` — a
Zeus selection can hand you vehicles when you wanted crew, or groups when you wanted units.

---

## 6. Preprocessor & CBA macros

### A trailing space after a line-continuation `\` breaks the macro

```cpp
#define THING(a,b) \
    doThing(a); \   <- invisible space here silently truncates the macro
    doOther(b)
```

The `\` must be the **last** character on the line. This produces baffling, misattributed
errors — often pointing at a completely different file.

### Macros do not expand inside string literals

`"GVAR(enabled)"` is the literal text `GVAR(enabled)`, not the expanded variable name. Use
`QUOTE()` / `QGVAR()`:

```sqf
_unit setVariable [QGVAR(state), _v];              // -> "rtz_component_state"
[QGVAR(rcDetected), _args] call CBA_fnc_globalEvent;
```

Always use `QGVAR` for event names and `setVariable` keys — hand-rolled `"rtz_..."` strings
drift out of sync with the component name the moment anything is renamed.

### `GETMVAR` / `GETGVAR` take a NAME to quote, not a variable holding one

The `GET*VAR` family wraps its first argument in `QUOTE()`, so it expects the variable's
name as literal source text. Passing a local that *holds* a name string looks right and
silently looks up the wrong thing:

```sqf
private _settingVar = QGVAR(pollInterval);           // "rtz_hud_pollInterval"
private _v = GETMVAR(_settingVar,2);                 // BAD - reads "_settingVar"
private _v = missionNamespace getVariable [_settingVar, 2];   // GOOD
```

It does not error — it returns the default forever, so a setting silently never takes
effect. Use the macro when the name is known at compile time, plain `getVariable` when it
arrives at runtime (as it does for anything registry-driven, e.g. a stream's cadence
setting in `EFUNC(hud,registerStream)`).

### Commas inside macro arguments need `ARR_N`

The preprocessor splits arguments on commas, so an array argument looks like several arguments:

```cpp
getVariable [ARR_2(QUOTE(var1),var2)]     // correct - one argument
getVariable [QUOTE(var1),var2]            // breaks when used inside another macro
```

CBA provides `ARR_2` … `ARR_N`; see the uses in
[script_macros.hpp:7-23](addons/main/script_macros.hpp#L7-L23).

### Config values that contain code need `QUOTE()`

`statement` and `condition` in `CfgContext.hpp` are strings compiled at runtime, so they must be
wrapped: `statement = QUOTE([_objects] call FUNC(orderResupply));`. Without `QUOTE`, the macros
inside never expand.

### Every user-facing string goes through the stringtable

Hardcoded text fails review and `hemtt check` validates stringtables. Use `LLSTRING` (localized
string, in SQF), `CSTRING` (the key, for configs), `LSTRING` (fully-qualified key). A missing
entry renders as the raw `STR_RTZ_...` key in-game rather than erroring — so it only shows up
when someone looks.

---

## 7. Quick reference

| Symptom | Likely cause |
|---|---|
| Delay does nothing, code runs instantly | `sleep` in unscheduled (§1) |
| Loop only processes some elements | `exitWith` acting as `continue` (§2), or the 10k unscheduled `while` cap (§1) |
| Function returns `nil` exactly when it succeeds | bare `breakOut` with no value (§2) |
| Error on the *left* guard's own condition | `&&` without `{}` on the right (§2) |
| Rest of `postInit` silently missing | `if (nil) then` on an unsynced CBA setting (§4) |
| Order works in SP / as host, not on dedicated | locality (§4) |
| Works for the host, breaks for clients | `isServer` vs `hasInterface` confusion (§4) |
| Zeus can't edit a spawned object | missing `addCuratorEditableObjects` (§5) |
| Baffling error pointing at an unrelated file | trailing space after `\` in a macro (§6) |
| Variable name appears literally in-game | macro inside a string literal, missing `QUOTE` (§6) |
| Loop skips its `continue` and runs on | `continue` inside a `switch do` case (§2) |
| A `_limit` / `_firstOnly` parameter costs exactly as much as no limit | `exitWith` used as `break` — use `break`, at the TOP of the body (§2) |
| A setting never takes effect, no error | `GETMVAR` given a variable instead of a name (§6) |
| Icons draw in first person, or behind the Zeus map | own `Draw3D` handler instead of an `EFUNC(hud,registerRenderer)` renderer (see CLAUDE.md) |
| A per-frame `waitUntilAndExecute` never stops | no timeout passed — it polls for the rest of the mission (§1) |
