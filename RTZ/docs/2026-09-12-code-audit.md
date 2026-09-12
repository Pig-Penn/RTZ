# Code audit and implementation plan

Scope: inspect deeper correctness and lifecycle failures in the current working
tree. The user reports no obvious symptoms. Existing missile/grenade and mission
edits belong to the user and are preserved. The documented deployment is a listen
server with curator-owned AI, no headless clients, and long PvP sessions.

## First implementation pass: path execution

1. Replace the flight waypoint overshoot test with a bounded segment-distance
   test. Currently, any waypoint behind the current velocity vector counts as
   visited, even if the hull has never approached it. A return bend can therefore
   consume distant future points. Extract the geometric predicate for direct
   regression coverage, including overshoot, hairpins and vertical paths.
2. Distinguish successful completion from cancellation in follow teardown.
   Timeout, destruction, player takeover, driver replacement and locality loss
   currently reach the same final-altitude/landing code as successful arrival.
   Only arrival should issue those commands. Re-tasking must release the old
   executor's resources without executing its arrival actions.
3. Preserve MOVE/ANIM state when entering and leaving puppet movement, clean up
   locally installed event handlers where they were installed, and prevent
   movement writes after locality loss or player takeover. Verify restoration
   routing against the engine and existing RTZ ownership patterns.
4. Run HEMTT check/build. Provide executable in-engine regression scenarios and
   distinguish static validation from gameplay tests actually run.

## Follow-up: distributed observation

The following are code-confirmed gaps, not measured performance conclusions:

- `core/fnc_streamServer.sqf` runs gatherers exclusively on the server.
  `hud/fnc_gatherUnitInfo.sqf` supplies unknown AI fields for non-local units;
  `gatherDestination` and `gatherTarget` return empty arrays outright. Thus a
  remote curator's spawned AI lacks data that the host's AI can provide.
- `spotting/fnc_collectSides.sqf` admits only server-local spotter representatives
  and `fnc_spottingSystem.sqf` installs its fire-blink detector only on the server.
  Remote curator-owned AI needs an owner-side observation/reporting path.

Plan: retain the server's curator entitlement checks, selection caps and snapshot
diffs, while declaring each stream's execution-locality resolver alongside its
gatherer. Batch requests by owning machine; register workers on all machines.
Correlate replies with subscription generations and bound pending requests so
selection changes, disconnects and ownership transfers cannot revive stale data.
Keep supply gathering server-local because its job records live there. Spotting
needs a separate owner-side knowledge report merged by side on the server; merely
removing `local` filters would substitute unreliable reads for missing data.

Validation must include a host and a second curator, units created by each,
ownership transfer while selected, unsubscribe/reselect with delayed replies,
and disconnect/reconnect. Profile with `RTZ_perf` before and after under comparable
loads. No speedup is claimed without those measurements.

## Implementation and validation

The first path pass is implemented:

- `advanceFlightPath` checks the swept segment in three dimensions, keeps
  waypoint order through return bends, and carries unconsumed movement across
  the per-tick work cap.
- `endFollow` now accepts completion and replacement flags. Aborted scripted
  flights hold their current height rather than adopting the final point's
  altitude. Landing and hover-stop actions require successful completion and
  the same living AI pilot still controlling a local hull.
- Replacement paths release the previous executor's speed cap. They also clear
  targeting left by a combat pause, without issuing the old arrival actions.
- Puppet entry captures MOVE/ANIM; local cleanup restores those values. Local
  event handlers are removed even after ownership loss. Animation callbacks
  and the movement tick stop writing after locality loss or player takeover.
- `startFollow` checks the actual driver and path kind again after the network
  hop, so a stale order cannot start on the previous driver.

Checks run: `hemtt check`, `hemtt build` (29 PBOs), and 18 geometry regression
cases against the production SQF function in SQF-VM v2026.04.03-ed9f5f5. No Arma
gameplay or multiplayer test was run. SQF-VM is a geometry test runner here, not
evidence for engine AI, physics, animation or network behavior.

To repeat the geometry tests with a standalone SQF-VM executable:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/tests/test-path-geometry.ps1 -SqfVm C:/path/to/sqfvm.exe
```

The script executes the actual production function body and reads MAX_SKIP from
its header. It creates a temporary test script and removes it afterward. The
execution-policy option applies only to this PowerShell process. Alternatively,
in the HEMTT test mission's debug console:

```sqf
rtz_path_fnc_advanceFlightPath call compile preprocessFileLineNumbers "rtz_path_geometry.sqf"
```

### In-game checks still required

Use disposable units in the test mission, with path planning enabled temporarily.

1. Fly a wide hairpin with later points behind the aircraft and an altitude
   change on the return leg. Check that every leg is followed in order; also
   check a straight high-speed route and a looping patrol.
2. Draw a helicopter route ending at ground level. Allow one run to finish and
   verify landing. During another run, expire its follow record's end time while
   it is still airborne: it should release at its current height, not land at
   the unvisited endpoint. Repeat after pilot death and player takeover; neither
   case should receive a new landing or zero-velocity command from RTZ.
3. Start an AI-executed aircraft/boat route, switch scripted flight on, and issue
   a replacement route. After that route ends, verify the previous AI speed cap
   no longer constrains normal movement. Re-task during the settle interval too.
4. For a disposable infantry unit, keep PATH enabled and vary its initial MOVE
   and ANIM flags. Start/finish a puppet path and trigger a combat pause. Check
   that both flags return to their initial values. End a path during engagement
   and verify its forced target/watch is cleared.
5. Transfer a pathed unit and hull between host and second client, then back.
   Confirm the old owner stops movement/animation writes and removes its event
   handlers; inspect AI flags and speed limits on both owners. This pass does
   not add cross-owner restoration messages: whether those machine-local states
   need additional restoration on transfer/reacquisition remains an engine test,
   not a conclusion inferred from a successful lint run.
6. Change drivers between sending and receiving a path order. The previous
   driver should not receive a new executor. Check infantry, land vehicles,
   aircraft and boats after the common entry-point validation change.

Keep path planning off by default after testing, as requested in the existing
performance notes. Existing missile/grenade work and `mission.sqm` were not edited.

## Sources checked

- [Bohemia: expectedDestination](https://community.bistudio.com/wiki/expectedDestination)
- [Bohemia: Multiplayer Scripting](https://community.bistudio.com/wiki/Multiplayer_Scripting)
- [CBA: targetEvent implementation](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/fnc_targetEvent.sqf)
- [CBA: ownerEvent implementation](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/fnc_ownerEvent.sqf)
- [SQF-VM runtime](https://github.com/SQFvm/runtime)

The local `CLAUDE.md`, architecture and knowledge-base files were used as project
guidance. Their claims about engine behavior are hypotheses to check, not a
substitute for source inspection or in-engine tests.
