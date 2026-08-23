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
| [fnc_findCountermeasureWeapons.sqf](addons/smoke/functions/fnc_findCountermeasureWeapons.sqf) | `_firstOnly` |

The other two were worse, because the loop did not merely cost too much — it returned the
**wrong answer**. Both walked `lineIntersectsSurfaces`, whose hits come back sorted by distance
from the *begin* position, looking for the first mostly-flat surface. `exitWith` let the loop run
on, so each later hit overwrote the result and the **last** surface won instead of the first:

| Site | Symptom |
|---|---|
| [fnc_teleportToCursor.sqf](addons/orders/functions/fnc_teleportToCursor.sqf) | Trace runs downward from 200 m up, so "first" means highest. Units teleported onto a multi-storey building landed on its ground floor, and units aimed at a bridge landed underneath it |
| [fnc_placementPreview.sqf](addons/common/functions/fnc_placementPreview.sqf) | Trace runs outward from the curator camera, so "first" means nearest. The placement ghost snapped through the roof under the cursor down to the ground below it |

### `params` with the same name twice silently discards the first argument

```sqf
params ["_path", "_path"];   // BAD - the SECOND binding wins; argument 0 is lost
```

No error, no warning: the function simply runs on the wrong data. It shipped in
`fnc_splicePath`, whose caller compounded it by shadowing the engine's answer
(`params ["_agent", "_path"]` immediately followed by `private _path = _agent getVariable ...`)
and then passing `[_path, _path]`. The result was that `rtz_path`'s
route-around-obstacles feature handed an 11-element *path record* to a function
expecting a list of positions, threw twice per blocked drag, and **had never once
worked** — while every reader of the code saw a plausible-looking argument list.

Two habits kill this: give the engine's answer and your own state visibly
different names (`_calculated` vs `_record`, never both `_path`), and treat a
shadowing `private` immediately after `params` as a smell rather than a shortcut.

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

### `getOrDefaultCall` passes `[key, hashMap]` as `_this`, not the key

The default-value code runs with `_this` set to an **array** — the key is `_this select 0`.
Treating `_this` as the key itself is the trap:

```sqf
_cap = GVAR(magCapCache) getOrDefaultCall [_mag, {
    getNumber (configFile >> "CfgMagazines" >> _this >> "count")     // BAD - Type Array, expected String
}, true];

_cap = GVAR(magCapCache) getOrDefaultCall [_mag, {
    getNumber (configFile >> "CfgMagazines" >> _mag >> "count")      // GOOD - close over the key
}, true];
```

The code block is not a fresh scope like `spawn` (§3), so simply **closing over the outer
variable holding the key** is the clearest fix and is what the rest of the codebase does
([fnc_needsAmmo.sqf:28](addons/supply/functions/fnc_needsAmmo.sqf#L28),
[fnc_draw3D.sqf:90](extras/vehicle_info/functions/fnc_draw3D.sqf#L90)).

This shipped twice, and **only one of the two errored**:

| Site | Symptom |
|---|---|
| [fnc_gatherUnitInfo.sqf](addons/hud/functions/fnc_gatherUnitInfo.sqf) | `configFile >> _this` is a type error → *Type Array, expected String*, loud and obvious |
| [fnc_unitMarker.sqf](addons/spotting/functions/fnc_unitMarker.sqf) | `format` accepts any type, so it silently built `…\nato\[o_inf,[HashMap]].paa` — **and cached it**, so every later hit returned the broken path with no error at all |

A default block that feeds `_this` into anything stringly-typed (`format`, `+`, a marker or
texture path) fails silently and then poisons the cache. Note that `params ["_key"]` at the top
of the block also works, and is why [fnc_getCost.sqf:37](addons/economy/functions/fnc_getCost.sqf#L37)'s
`{_this call FUNC(categorize)}` is correct by accident — `categorize` opens with `params ["_class"]`,
which reads index 0.

### An Object is not a valid HashMap key — use its `netId`

HashMap keys must be one of *Number, Bool, Array, String, Namespace, NaN, Code, Side, Config
entry*. An `Object` is none of them, and every `set` / `get` / `getOrDefault*` with one throws:

```
Error Type Object, expected Number,Bool,Array,String,Namespace,Not a Number,code,Side,Config entry
```

It fails per **call**, so a per-tick memo keyed on units logs once per entity per stream per
watcher per tick — thousands of lines, and the cache it was meant to be never holds anything,
so the expensive work it guards runs every time anyway. Key on `netId _unit` instead, which is
what the rest of the codebase does ([fnc_spotCheck.sqf](addons/spotting/functions/fnc_spotCheck.sqf),
[fnc_streamServer.sqf](addons/core/functions/fnc_streamServer.sqf)). Where the entity already
travels with its netId (the selection slices do), carry that string along rather than re-deriving it.

Arrays *are* valid keys, but only if everything inside them is hashable — `[_unit, "x"]` throws
for the same reason.

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
- index **beyond** that → throws `Error Zero Divisor`

So off-by-one reads fail quietly and land as `nil` somewhere far from the cause. Use `param` /
`params` with defaults for anything that might be short:

```sqf
params [["_radius", 50, [0]], ["_limit", 0, [0]]];
private _mode = _args param [2, "default"];
```

**A NEGATIVE index is not out of range — it counts from the end**, Python-style, for both
`select` and `set`. Arma 3 **v2.12** added it (FT-T166810); before that it did throw
`Error Zero Divisor`, and this entry claimed so long after it stopped being true.

```sqf
_arr select -1    // last element
_arr select -2    // second from last
```

Safe here without a guard: `REQUIRED_VERSION` is **2.18**
([main/script_mod.hpp](addons/main/script_mod.hpp)), and CBA — which RTZ requires at ≥ 3.16.0 —
itself requires **2.20**, so the floor is well past 2.12 twice over. RTZ relies on it in nine
places ([reducePath.sqf:78](addons/path/functions/fnc_reducePath.sqf#L78),
[isPatrol.sqf:41](addons/path/functions/fnc_isPatrol.sqf#L41),
[followTick.sqf:145](addons/path/functions/fnc_followTick.sqf#L145) among them), and ACE3, CBA
and LAMBS use it throughout their own source.

The reason this correction is worth its space: the old wording invited a "fix" that would have
broken all nine working call sites at once, which is a worse outcome than the bug it warned about.
Version-dependent claims need the version written next to them — see also the `break` entry in §2,
which is only true from v2.02.

### `params` destructures `_this` — passing one array gives the callee its first element

`params` always treats `_this` as an *argument list*. So a callee written `params ["_ctx"]`
does not receive the array you passed — it receives `_this select 0`:

```sqf
private _ctx = [_camPos, _camRight, _camUp, _mouse, _now, _viewDist, _display];
_ctx call _renderer;      // WRONG — renderer's _ctx is _camPos
[_ctx] call _renderer;    // right  — renderer's _ctx is the whole context
```

This shipped in `rtz_core`'s frame loop and broke **every** `RENDER_WORLD` renderer at once.
Each one's `_ctx select CTX_CAMPOS` read a bare number instead of a position, so its first
`distance` threw *Generic error*; `_ctx select CTX_VIEWDIST` then ran off the end of the
3-element position and threw *Zero Divisor* (see the `select` entry above). Because a runtime
error **aborts the whole scope**, one throw killed the rest of that renderer's `forEach` — so
the mod drew nothing at all while the native Zeus icons underneath kept working, which made it
look like a rendering quirk rather than a total failure.

Two lessons worth more than the fix: an error's *reported line* can be the propagation point,
not the fault (the `Zero Divisor` was blamed on the line that merely read the value), and a
guard placed **after** the throwing statement can never run — instrument *before* it.

If the function header says `Arguments: 0: <thing>`, the caller owes it `[thing]`.

### Position commands return `[]`, and one fallback is not enough

`unitAimPositionVisual` returns `[]` for a vehicle with no crew aim point to resolve through —
an empty hull, or the frames between Zeus creating a crewed vehicle and its crew being moved
in. **`modelToWorldVisual` returns `[]` too** while the object's model has not resolved on this
machine, which is the same handful of frames. So the obvious fallback is `[]` exactly when it
is needed:

```sqf
private _base = unitAimPositionVisual _veh;
if (_base isEqualTo []) then {
    _base = _veh modelToWorldVisual [0, 0, (boundingBoxReal _veh) select 1 select 2];
};
private _dist = _camPos distance _base;    // BAD - still [] → Generic error in expression

private _base = unitAimPositionVisual _veh;
if (count _base < 3) then {
    private _top = ((boundingBoxReal _veh) param [1, []]) param [2, 0];
    _base = _veh modelToWorldVisual [0, 0, _top];
};
if (count _base < 3) then { continue };    // GOOD - skip the frame, it resolves on the next
```

Test `count _base < 3`, not `isEqualTo []`, so a short array is caught as well, and **re-test
after the fallback**. What an `[]` position does next decides whether you ever find out:

| Consumer | Symptom |
|---|---|
| `distance` ([fnc_drawVehicleTags.sqf](addons/hud/functions/fnc_drawVehicleTags.sqf)) | *Generic error in expression* — and the throw kills the rest of that renderer's pass for the frame |
| `vectorAdd`, then `drawIcon3D` ([fnc_drawSpots.sqf](addons/spotting/functions/fnc_drawSpots.sqf)) | `[] vectorAdd [...]` stays `[]` and the draw is a silent no-op — no error, the icon just is not there |

Both shipped from the same edit; only the `distance` one announced itself.

### `selectionPosition` is animated, not a per-class constant — never memoize it

It looks like a pure model query, and the name encourages that reading: a selection is a
named point in the model, so surely for a given class the answer is fixed for the mission.
It is not. The Biki is explicit that it returns the position **"in model space pertaining to
the current animation in render time scope"** — the head, hands and weapon points all move
*within* model space as a man leans, crouches, goes prone or turns his torso.

The proof is in CBA: [`CBA_fnc_modelHeadDir`](https://github.com/CBATeam/CBA_A3/blob/master/addons/common/fnc_modelHeadDir.sqf)
derives a unit's **live** head facing from nothing but `selectionPosition "pilot"` and
`selectionPosition "neck"`. If those were static it could only ever return one number.

```sqf
// BAD - memoized on typeOf. Every man of that class is frozen in whatever pose the
// first one of that class happened to be in when the cache was first populated.
GVAR(headOffsetCache) getOrDefaultCall [typeOf _unit, {_unit selectionPosition "Head"}, true]

// GOOD - re-read per frame. ACE3's spectator draws the same EG chevron this way.
#define HEAD_POS(obj) ((obj) modelToWorldVisual ((obj) selectionPosition "Head"))
```

The symptom is quiet, because the icon is still *near* the unit: a chevron hanging beside a
man's shoulder rather than over his head, or a metre above a prone one, drifting as he
changes stance. Nothing errors, and the icon tracks him around the map perfectly — it is
only ever wrong by the animation delta, which reads as "the icon is slightly off" rather
than "the offset is stale".

A per-**frame** engine read is the correct answer here, so the usual "hoist it to the broad
phase" instinct is the bug. Where that read is per entity per frame, pay for it with a macro
rather than a function ([script_macros.hpp](addons/main/script_macros.hpp)) — a `call` there
buys a fresh scope and a `params` destructure per entity per frame.

Memoizing on `typeOf` is still right for genuine *config* reads (`EFUNC(common,classInfo)`,
`GVAR(magazineCapacities)`); the distinction is config vs. model-state, not "engine call I
would rather not repeat".

#### …but a *label* does not want an animated anchor at all

Fixing the memo exposed the other half of the lesson. `HEAD_POS` is right for an icon that
means **"this man"** — a spot chevron, the remote-control portrait — which *should* sink
with him when he goes prone. It is wrong for a **head tag**, which means "this entity's
label", because the live head is ~1.65 m up in model space standing and ~0.3 m up prone:
tags dived about a metre and a third on the first man to hit the dirt and landed on top of
the basegame Zeus entity icon, which does not move. `GVAR(tagHeight)` could not save it —
that lift is a flat offset added to a floor that is itself moving.

```sqf
// Label over an entity: static model extent, one height through every stance.
#define MODEL_TOP(obj) (((boundingBoxReal (obj)) param [1, []]) param [2, 0])
_obj modelToWorldVisual [0, 0, MODEL_TOP(_obj)]      // EFUNC(hud,tagAnchor)
```

`boundingBoxReal` reports the **model's** extent, not the current animation's, so it is the
per-class constant `selectionPosition` was mistaken for. Note the shape of the mistake: the
memo was not wrong because caching is wrong, it was wrong because it cached an animated
value — and swapping in a genuinely static one is a different fix from re-reading the
animated one per frame. Ask which of the two you actually want *before* reaching for either.

### `ctrlTextWidth` measures a control, not the glyphs — it adds 0.008 UI-x per side

Text that will be drawn with `drawIcon3D` must be measured with **`getTextWidth`**.
`ctrlTextWidth` answers a different question — *"how wide must a **control** be to hold this
string"* — and the Biki spells out the difference: the margins are **hardcoded at 0.008 each
side**, so a `ctrlTextWidth` reading is the glyph run **plus 0.016 UI-x**. `drawIcon3D` draws
bare glyphs and has no margins at all.

```sqf
// BAD - a hidden RscText, fonted and sized to match the draw, still overstates by 0.016.
_ctrl ctrlSetFontHeight _size; _ctrl ctrlSetText _text; ctrlTextWidth _ctrl

// GOOD - the same estimate without a control's margins, and without a control.
_text getTextWidth ["RobotoCondensedBold", _size]
```

Nothing errors, and the number is *plausible* — which is what makes it expensive. It goes wrong
wherever a measured width is used as an **advance**. A tag line drawn as several separately
coloured `drawIcon3D` chunks (`EFUNC(hud,drawTagLine)`) walks its cursor by these widths, so every
chunk after the first landed 0.016 past the `" · "` baked into the end of the one before it: the
gap after each separator was visibly wider than the gap before it, and the line — centred on the
inflated total — sat 0.008 left of the entity it belonged to.

The nastiest part is that the error scales with **how many strings you measured**, not with the
line. A tag carrying main + tactic + status overshot by three margins; one carrying only a main
line, by one. `EFUNC(hud,buildTagEntry)` sizes its icon slots and its de-confliction footprint off
that same sum, so its icons drifted right by an amount that changed per tag — and no fixed
`ICON_TEXT_GAP` can be tuned against a moving error. If you ever catch yourself nudging a spacing
constant to make icons sit right, check what measured them first.

`getTextWidth` takes the font and size directly, so it also works before `findDisplay 46` exists.
That removes the "no display yet, fall back to a per-character estimate" branch a control-based
measurement needs — and with it the silently-wrong widths that branch baked into any cache entry
built too early.

### `drawIcon3D` centres its ICON on the anchor but hangs its TEXT below it

One call, two anchoring rules. The texture is drawn **centred** on the position; the string is
drawn **below** it, starting at roughly `y + height/2`. So an icon and a text label given the
*same* position do not line up — the icon rides about half a line of text high.

That is invisible until you mix the two, which is exactly what a tag row does.
[`EFUNC(hud,drawTagLine)`](addons/hud/functions/fnc_drawTagLine.sqf) draws the words as text on a
**zero-size** icon, so with `height = 0` the text simply hangs from the anchor — and every icon
and bar in the row beside it, centred on that same anchor, floated half a line above the words
it belonged to. `ICON_BASELINE` (`addons/hud/script_component.hpp`) is the nudge back down, half
the font height, applied to every item in the chain by
[`EFUNC(hud,drawUnitTags)`](addons/hud/functions/fnc_drawUnitTags.sqf) and
[`EFUNC(hud,drawTagBar)`](addons/hud/functions/fnc_drawTagBar.sqf) so they cannot drift apart.

No aspect correction on that one: the text size *is* a UI-y measure (it is what `getTextWidth`
takes as its height), unlike `BAR_HEIGHT`, which is stated in UI-x and has to be converted.

The other direction works too — parameters 13 and 14 are the **text** offset, so a negative
`offsetY` pulls the label up onto the icon instead of pushing the icon down onto the label. Pick
one and use it everywhere; the tags nudge the icons, because the text anchor is also what the
de-confliction pass measures overlaps with.

### The texture's own crop is part of its size

Two icons drawn at the same `drawIcon3D` size do not render the same size — the *sheet* is what
gets scaled, not the glyph inside it. The A3 simpletask family
(`\a3\ui_f\data\igui\cfg\simpletasks\types\*`) insets its glyphs about 12% on every side; the
flag textures do not. The map-marker flag (`\a3\ui_f\data\map\markers\military\flag_ca.paa`) is
a map *pin* — pole to both sheet edges, flag mass in the top third — so at the family's size it
came out taller than its neighbours *and* top-heavy, and no `ICON_TEXT_GAP` or `ICON_DRAW` value
fixes either, because the mismatch is in the art.

Two separate decisions come out of that. Which glyph: at ~30 px, **ink** decides whether an icon
reads or dissolves, and of the four flag textures that exist across every A3 PBO and ZEN, only
`\a3\ui_f\data\igui\cfg\actions\takeflag_ca.paa` is drawn solid (45% ink; the markers and
`returnflag_ca` are all hairline outlines at 21–28%). And what size to draw it: `takeflag` is
also edge-to-edge vertically, so `FLAG_ICON_SCALE` trims its *draw* by the crop ratio (0.875)
while its layout *slot* stays one `ICON_FOOT` like every other icon's — the chain arithmetic
keeps one kind of item to place, and the narrower glyph just sits with more air.

Both are cheap to check before you tune anything: decode the sheet, take the alpha bounding box
and the ink fraction, and compare them against the icons it will sit next to.

### A screen-space offset added to an AGL position rides the terrain

`drawIcon3D`, `drawLine3D` and `worldToScreen` all take **PositionAGL**, whose Z is measured
from the terrain *directly under the point*. `modelToWorldVisual`, `unitAimPositionVisual` and
`modelToWorld` all hand you one. So the obvious way to nudge a drawn thing sideways —

```sqf
// BAD - _agl is AGL, so this holds HEIGHT ABOVE GROUND constant and walks the
// anchor up and down the hill instead of sliding it along the screen axis.
_agl vectorAdd (_camRight vectorMultiply _metres)

// GOOD - offset in true world space, convert back only at the draw itself.
ASLToAGL ((AGLToASL _agl) vectorAdd (_camRight vectorMultiply _metres))
```

is only correct on flat ground. `_camRight` (`CTX_CAMRIGHT`) is horizontal, so the whole offset
lands in XY, and the resulting point's real altitude changes by the *terrain difference* between
where it started and where it ended up.

The scale is what makes this bite. A UI offset becomes world metres through `_perMetre`, and at
tag range that multiplier is large: a 0.1 UI-x text chunk on an entity 150 m out is roughly **20 m**
of world offset. On a hillside that is metres of elevation, so
[`EFUNC(hud,drawTagLine)`](addons/hud/functions/fnc_drawTagLine.sqf) — which walks a cursor across
*three* separately-coloured chunks — put each chunk on its own patch of ground and the tag came
apart into pieces at different heights. Flat terrain hid it completely.

It corrupts the horizontal axis too, and less obviously: an altitude change moves the anchor's
**depth** from a pitched camera, and `worldToScreen`'s X is depth-divided, so the chunk spacing
drifts as well as the height. The `_perMetre` probe itself (`worldToScreen (_pos vectorAdd
_camRight)`) is measured with the same broken step, so the scale it returns is off before anything
uses it.

Note the shape of the regression: the two-draw version this replaced anchored **both** halves at
one point, so both sampled the same terrain and moved together — the line stayed coherent while
being drawn in the wrong place. Splitting one anchor into three is what turned a shared error into
a visible tear. **Any time you offset a draw position by a camera-basis vector, do the arithmetic
in ASL.**

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

### Argument-local vs argument-global is decided per command, not per family

Commands that look like siblings do not share a locality rule, and the failure is **silent** —
no error, no log line, and any "done" toast you raise afterwards still fires. `rtz_supply`
repaired and rearmed vehicles correctly for as long as the component existed while never
refuelling the ones a headless client or a player owned, because `setDamage` and `setFuel` sit
on opposite sides of this line:

| Command | Arguments | Notes |
|---|---|---|
| `setDamage` | **Global** | Works from anywhere. ACE3 calls it bare in `fnc_doFullRepair` |
| `setFuel` | **Local** | Routed by [supply/fnc_applyFuel.sqf](addons/supply/functions/fnc_applyFuel.sqf) |
| `setVehicleAmmo` | **Local** | Routed by `QGVAR(rearm)` in [supply/XEH_postInit.sqf](addons/supply/XEH_postInit.sqf) |
| `setHit` / `setHitPointDamage` | **Local** | Unlike `setDamage` — the trap that makes this table necessary |
| `disableAI` / `enableAI` | **Local** | Also stored per machine and does **not** travel with locality (see below) |
| `setVelocity`, `setDriveOnPath` | **Local** | |
| `allowFleeing` | **Local** (group) | [officer/fnc_applyAuraEffects.sqf](addons/officer/functions/fnc_applyAuraEffects.sqf) guards on `local _group` |

**The Biki is the authority, and a browser reads it fine — but tooling cannot.**
`community.bistudio.com` returns HTTP 403 to automated fetches: WebFetch, its own MediaWiki
API, `Special:Export` and `?action=raw` alike, with or without a browser User-Agent. So the
MP box is one click away for a human and unavailable to any scripted check. Web *search*
returns Biki links but its summaries paraphrase, and one such summary asserted `setDamage` was
local — which is wrong, and acting on it would have cost a pointless refactor of a working
repair path.

Read the answer out of a mature mod's source instead, via `raw.githubusercontent.com`
(`acemod/ACE3`, `CBATeam/CBA_A3`). A command called with **no** locality guard in code that
demonstrably works in MP is arg-global; one wrapped in a `local` check or an event route is
arg-local. That is evidence rather than proof, so record which of the two you have.

### The server is *not* always where the AI is local

AI offloaded to a headless client, or AI in a player-led group, is local to that other machine.
Code that assumes "AI ⇒ server" breaks on exactly the setups that matter.
[fnc_grantCurators.sqf:10-14](addons/common/functions/fnc_grantCurators.sqf#L10-L14) documents
this case and forwards to the server with `CBA_fnc_serverEvent`.

### Locality is not established once — a long-running order must re-test it every tick

"Must run where the unit is local" in a function header describes the moment the order was
**issued**. It says nothing about the seconds or minutes that follow, and ownership moves during
them: `rtz_control`'s deliberate transfer, a headless client rebalancing, a JIP handover.

An AI order does not survive its unit changing machine. So an order issued once and then merely
*waited on* stops being obeyed the instant ownership moves, and the wait runs to its full
timeout — after which whatever message the timeout carries reports the wrong cause. This is what
[common/fnc_approach.sqf](addons/common/functions/fnc_approach.sqf) did to every errand built on
it (`assemble`, `mine`, `loot`, `repair`) until `!local _lead` was added to its watch condition.

Every long-running order in RTZ now tests ownership on its own tick:

```sqf
private _finished = !alive _unit
    || {!local _unit}          // ← ownership moved; let go cleanly
    || { /* ... */ };
```

See [path/fnc_followTick.sqf:78](addons/path/functions/fnc_followTick.sqf#L78) and
[slide/fnc_slideTick.sqf](addons/slide/functions/fnc_slideTick.sqf), which deliberately
hoists its `local` test **out** of the throttled block so a handover is noticed on the frame it
happens rather than up to `CHECK_INTERVAL` later.

Two consequences that are easy to miss:

- **Teardown runs on the wrong machine.** Noticing `!local` and *then* running the restores is
  half a fix — every restore command above is itself argument-local, so it silently no-ops on
  the machine that just lost the object. [slide/fnc_endSlide.sqf](addons/slide/functions/fnc_endSlide.sqf)
  applies whichever half is local and targets the owner for the rest.
- **Do not let a split pair ping-pong.** If teardown re-routes, and the receiver re-runs the same
  routing function, then an object whose two halves live on different machines (a player in the
  seat of an AI-owned hull) bounces the event between the two owners forever. Pass an explicit
  "apply only, do not re-route" flag on the wire — `endSlide`'s `_reroute` parameter.

Machine-local *state* has the mirror-image problem: `disableAI` does not travel, so a unit that
changes hands arrives with its AI enabled. `rtz_captive` re-applies from a `CAManBase` `"Local"`
event handler for exactly this reason — see
[captive/fnc_surrenderApply.sqf](addons/captive/functions/fnc_surrenderApply.sqf).

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
| Function runs on the wrong argument, no error | duplicate name in `params`, or a `private` shadowing it on the next line (§2) |
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
| *Type Array, expected String* inside a hashmap default block, or a cached value built from a stringified array | `_this` in `getOrDefaultCall` is `[key, hashMap]`, not the key (§3) |
| *Type Object, expected Number,Bool,Array,String,…* on a hashmap read/write, repeating at the tick rate | an Object used as a HashMap key — key on `netId` (§3) |
| *Generic error in expression* on `distance`, only for freshly Zeus-placed objects | `unitAimPositionVisual` **and** `modelToWorldVisual` both return `[]` for those frames (§3) |
| One field of a multi-part write never applies; the rest do, and the "done" toast still fires | that command is argument-**local** while its siblings are global — check the table (§4) |
| An order works, then quietly stops part-way through and only ends at its timeout | ownership moved mid-order and nothing re-tested `local` (§4) |
| A unit is released everywhere except the machine that actually holds it | teardown ran on the machine that *lost* the object — route it to the owner (§4) |
| A drawn line or icon breaks apart or drifts vertically on slopes but looks right on flat ground | a camera-basis offset was added to an **AGL** position, so it follows the terrain — offset in ASL, `ASLToAGL` at the draw (§3) |
| An event bounces between two machines forever | teardown re-routes on both ends; pass an "apply only" flag (§4) |
| A unit arrives on a new owner with its AI back on | `disableAI` is machine-local and does not travel — re-apply from a `"Local"` handler (§4) |
| A drawn text line reads lopsided — every separator has a wider gap after it than before it, and the whole line sits slightly left of its entity | widths measured with `ctrlTextWidth`, which adds 0.008 UI-x of control margin per side — measure with `getTextWidth` (§3) |
