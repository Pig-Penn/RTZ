# Repair and shared job lifecycle audit

## Plan and scope

Trace shared job cancellation, resource ownership and server/client boundaries;
fix demonstrated failures in repair and its shared infrastructure; validate with
HEMTT and provide engine regressions. Preserve the existing path fixes and the
user's deleted `~test.altis/mission.sqm`. This is a focused pass, not a claim that
every component has been exhaustively audited.

## Findings and changes

1. **Remote engineers lose their repair job.** `approach` wrote its order token
   locally, while the repair server compared its own copy against the token sent
   by the worker. The server could read zero and discard a valid remote worker.
   Broadcast the token once per order. No per-frame broadcast is added.
2. **Deleted job owners skip cleanup.** `progressJob` treated the missing object
   variable as evidence of a replacement. Handle null owners as cancellation and
   invoke their end callback with `false` after removing the PFH.
3. **Deleted repair targets lose their worker lists.** Keep the shared worker
   array in the job arguments as well as the vehicle. Compact it in place, so
   later arrivals and refreshed tokens remain visible to both the tick and end
   callback even after the vehicle disappears.
4. **Delayed repair completion cancels newer errands.** Carry each worker's token
   through the release event and check it on the owning machine immediately before
   clearing animation and errand state. This also protects the early teardown
   route after vehicle destruction, which bypasses the usual worker filtering.
5. **Target loss during arrival leaves engineers working forever.** If a repair
   registration reaches the server after its target dies or is deleted, send the
   same token-guarded release rather than silently rejecting it.

Engine semantics were checked against Bohemia's documentation:
[getVariable](https://community.bistudio.com/wiki/getVariable) returns the default
for a null namespace, and [deleteVehicle](https://community.bistudio.com/wiki/deleteVehicle)
documents that deleted objects become null on the following frame.

## Validation

Baseline and post-change `hemtt check` passed: 42 configs, 442 SQF files and 28
stringtables. `hemtt build` passed and produced 29 PBOs; `git diff --check`
reported no whitespace errors. Engine gameplay and multiplayer tests have not
been run, including the new integration script below.

The test mission includes `rtz_job_lifecycle.sqf`. Run on the server with:

```sqf
[] execVM "rtz_job_lifecycle.sqf"
```

It creates disposable objects and workers, exercises the production job runner and
repair functions, deletes its fixtures and reports failures to the RPT/chat. It
checks deletion cleanup, replacement isolation, normal completion, stale/current
release tokens, later worker arrivals and rejected registration.

Multiplayer checks still required with a host and second curator:

- Order repairs using engineers owned by each machine. Both should contribute,
  finish, clear their working pose and rejoin their groups.
- Re-task a working engineer to a mine or loot errand, then destroy/delete the old
  repair target. Old cleanup must not cancel the new errand.
- Delete a target during the approach-to-registration network hop. Its engineer
  should leave the repair pose instead of waiting indefinitely.
- Join a second engineer after at least one repair tick, then delete the target.
  Both workers should be released.
- Transfer ownership during an errand and repeat orders. Token replication and
  machine-local animation state still require engine verification under transfer.

Existing distributed HUD/spotting gaps remain documented in
`2026-09-12-code-audit.md`; this pass does not implement that larger protocol change.
