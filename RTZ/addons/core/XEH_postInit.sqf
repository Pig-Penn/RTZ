#include "script_component.hpp"

// ─────────────────────────────────────────────────────────────────────────────
// The two engines, started UNCONDITIONALLY on every machine
// ─────────────────────────────────────────────────────────────────────────────
// Neither reads a setting to install itself, and both are free while nothing uses
// them: the client registers one early-exiting Draw3D handler, one snapshot
// receiver and one selection poll that does nothing without a curator display;
// the server registers one subscribe receiver and a PFH that bails on `count == 0`
// while nobody is watching.
//
// Gating an ENGINE on a setting is a trap worth spelling out, because this used to
// be done two different ways and both were wrong. The display enable* settings are
// isGlobal 0 — PER-CLIENT preferences — so a dedicated server gating the feed on
// its own copy of one means flipping "Vehicle Tags" off in a server CBA config
// blanks every client's tags with nothing in the log to explain it. And the
// selection poll was gated on rtz_hud's "Selection Info" setting, which quietly
// made an unrelated addon's overlay (rtz_supply's supply lines, which needs the
// hull slice this poll publishes) depend on a display the admin may have turned
// off. The poll is consumer-gated instead: with nothing demanding a slice it
// reports nothing and the subscription lapses, which is the same "free when idle"
// property without borrowing someone else's switch.
//
// `call`, not `spawn`: every body registers handlers and returns.
call FUNC(frameLoop);
call FUNC(streamClient);
call FUNC(streamServer);
call FUNC(selectionPoll);

// The RTZ_perf report loop, on the same terms: one PFH that costs a single
// getVariable per PERF_REPORT_INTERVAL while the flag is off, and the producers
// feeding it each gate on the flag themselves. Unconditional and NOT hasInterface-
// gated — the server produces half the samples (the detection pass, the RC scan),
// and on a listen server, which is the deployment this mod is run on, both halves
// belong in the one log.
call FUNC(perfReport);
