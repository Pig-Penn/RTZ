# Performance Audit — Open Questions

Things the codebase does not answer, raised during the performance audit
(`.claude/plans/performance-audit.md`). None of these block the mechanical Tier 1
fixes; answers would sharpen the Tier 2 changes and settle whether any Tier 3
feature removal is worth doing at all.

Answer inline under each question and the answers become part of the knowledge
base — several of them (locality topology, live setting values, typical enabled
displays) are facts every future optimisation pass will need again.

**Status:** answered, and the fixes those answers pointed at have landed. Where an
answer changed the shape of the work rather than just confirming it, a `_Done:_`
note says what was built. The three answers that mattered most, and that any future
pass should start from:

- **Listen server, no headless clients.** Server-side and client-side costs are
  ADDITIVE on the host. A "server" cost and a "client" cost are the same machine's
  frame time here.
- **Curators are usually on OPPOSING sides.** Anything inside `fnc_spotCheck`'s
  per-side loop carries a 2–4× multiplier that a single-side test mission hides
  completely.
- **Tags, supply lines and spot chevrons are always on.** Tags and supply lines are
  selection-bounded (`SEL_MAX_*`) and stay cheap; chevrons are the only display
  whose cost grows with the mission.

## Measurement

**1. Has anything been profiled?**
`diag_fps`, `diag_frameNo`, CBA's `#perf`, or a `-profiling` build. Any real
numbers beat the structural reasoning the audit is built on.

> _Answer:_ Nothing has been profiled I believe. That needs to happen.
>
> _Done:_ `RTZ_perf` now exists. Type `RTZ_perf = true;` in the debug console
> (local is enough on a listen server) and every measured path reports to the RPT
> every 10 seconds — see `EFUNC(core,perfSample)` / `EFUNC(core,perfReport)`.

**2. When the framerate drops, does it get worse because there are more UNITS in
the mission, because more CURATORS are connected, or because more of the enemy is
currently SPOTTED?**
Original wording — "does the drop track unit count, number of curators, or how
much is spotted?" — was not clear, and the honest answer is that nobody can know
without measuring. It matters because the three point at three different pieces of
code, and fixing the wrong one costs effort and changes nothing:

| If it tracks… | The cost is in | Shape |
|---|---|---|
| Unit count | `fnc_collectSides` — it walks `allUnits` and `vehicles` in full every detection tick | Server, grows with mission size whether or not anything is happening |
| Curator count / sides | `fnc_spotCheck`'s per-side loop — the whole detection pass repeats once per curator SIDE | Server, multiplies by 2–4 given opposed curators (Q8) |
| How much is spotted | `fnc_drawSpots` — one icon per spotted enemy, walked every frame | Client, and on a listen server it stacks on top of the two above |

> _Answer:_ This is now measured rather than guessed. The three are timed
> separately and report under `collectSides`, `spotCheck` and the renderer's own
> id, each with the counters that say what the mission looked like at the time
> (`units=`, `sides=`, `hostile=`, `chev=`). Whichever line moves when the
> framerate falls is the answer, and it will differ between missions.

**3. Dedicated server, listen server, or both? Headless clients in play?**
Several code paths behave differently with an HC — the `local` filter in
`fnc_collectSides` excludes HC-owned AI from the spotter pool, and
`fnc_gatherUnitInfo` returns defaults with `_isLocal` false for anything the
server does not own.

> _Answer:_ On a listen server. No headless clients.

## Settings as shipped

**4. What are the live values for `spotCheckInterval`, `core pollInterval`,
`rcCheckInterval`, `tagMaxDistance` and `captureRadius`?**
The audit reasoned from the defaults. If `spotCheckInterval` is already raised to
5 s, the detection-pass work matters much less than assumed.

> _Answer:_ They are the defaults.

**5. Which displays do curators typically leave *on*?**
Tags, selection dialog, spot chevrons, supply lines, path planning — each is
separately gated, and the mod is only as expensive as what is switched on. A
display nobody uses is not worth optimising; one everybody leaves on is worth
more than its share.

> _Answer:_ Tags, supply lines, and spot chevrons are typically always on.

**6. Is `path` actually used in operations?**
It is off by default (`GVAR(enable)`). Its puppet executor is a 10 Hz per-unit
tick with per-tick `setVectorDir` and animation resolution, which would change
the priority order if it is routinely on.

> _Answer:_ Sometimes. Keep it off by default.

## Scale detail

**7. Of the 200–500 AI, roughly how many are *hostile to a curator side* at
once?**
The "skip groups nobody knows about" change in `fnc_spotCheck` pays off in
proportion to how much of the enemy force is out of contact at any moment.

> _Answer:_ It depends. But it could be a lot.

**8. Are curators usually all on the *same* side?**
If yes, `fnc_spotCheck`'s per-side loop runs once and several costs the audit
flagged as "per curator side" are single-pass in practice.

> _Answer:_ Not at all, typically curators are going against each other.

**9. Ambient/civilian traffic on the maps in use?**
`fnc_collectSides` walks `vehicles`, which is every vehicle on the terrain —
hundreds of ambient cars on Altis, none on a barren map.

> _Answer:_ No.

## Intent

**10. Is the fire-blink used and valued, or is it decoration?**
It is the cheapest spotting feature to remove (a `FiredMan` class EH firing on
every infantry shot mod-wide, plus a per-icon-per-frame lookup), and the audit
would rather not propose removing something that earns its keep.

> _Answer:_ It is used. But add a setting to turn this off.
>
> _Done:_ `rtz_spotting_enableFireBlink`, global, default on. Gated on both sides —
> the `FiredMan` handler and the `GVAR(wedgeByUnit)` rebuild that feeds it.

**11. Is anything in `extras/` headed back into `addons/`?**
Only what HEMTT builds was audited.

> _Answer:_ One day it will be, keep it in extras for now.

**12. Do curators routinely hit `SEL_MAX_UNITS` (24) / `SEL_MAX_HULLS` (32)?**
If the truncation toast fires often, the caps may be the wrong size rather than
the code being slow — and raising them changes the cost of every stream and
renderer downstream.

> _Answer:_ I highly doubt any curator is going to select 32 vehicles at once. But, they may select 24 infantry at once, but rarely.
