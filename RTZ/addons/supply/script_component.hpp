#define COMPONENT supply
#define COMPONENT_BEAUTIFIED Supply
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_SUPPLY
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_SUPPLY
    #define DEBUG_SETTINGS DEBUG_SETTINGS_SUPPLY
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// ZEN action array indices (ACTION_INDEX_*) come from main/script_macros.hpp.

// RENDER_WORLD / CTX_* / SRC_HULLS — this component owns a supply-lines stream
// on rtz_core's engine and the renderer that draws it.
#include "\x\rtz\addons\core\script_macros_core.hpp"

// The icon ZEN puts on its "Vehicle Logistics" submenu folder, so this order
// reads as part of the same family in the context menu rather than borrowing
// rearm_ca.paa — which names only one of the three services this order covers.
#define ICON_RESUPPLY "\a3\ui_f\data\igui\cfg\simpleTasks\types\truck_ca.paa"

// Per-service icons, swapped in by FUNC(resupplyActionModifier) when every
// selected supply vehicle offers only one of the three — the same three
// simpleTasks/types icons ZEN's own Repair / Rearm / Refuel entries use under
// its VehicleLogistics submenu (addons/context_actions/CfgContext.hpp in the
// ZEN source), so a single-service selection reads as the exact action ZEN
// already names rather than the generic multi-service ICON_RESUPPLY above.
#define ICON_REPAIR "\a3\ui_f\data\igui\cfg\simpleTasks\types\repair_ca.paa"
#define ICON_REFUEL "\a3\ui_f\data\igui\cfg\simpleTasks\types\refuel_ca.paa"
#define ICON_REARM  "\a3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa"

// Hard cap on how many targets one order can take on, and the sweep's own early
// out. Matches SEL_MAX_UNITS in core/script_macros_core.hpp — the cap the shared
// selection poll already applies for the same reason.
#define MAX_SERVICE_TARGETS 24

// getFriend below this counts as hostile, so a supply vehicle will not service an
// enemy. Same idiom and same reading as rtz_attack's HOSTILE_THRESHOLD, phrased
// from the friendly side because this filter KEEPS what passes it.
#define FRIENDLY_THRESHOLD 0.6

// ── Service thresholds ───────────────────────────────────────────────────────
// Each is the point past which a target is treated as already full, so a
// scratched vehicle does not keep the Resupply action visible forever. They are
// applied per service inside FUNC(serviceDeficit) BEFORE the three are summed:
// without them a vehicle sitting one round below a full belt would report a
// deficit of 0.005, never close it, and keep the order offered indefinitely.
//
// These used to double as completion-SNAP windows, because the old per-tick
// setDamage/setFuel delta chain drifted and left a job that had applied its whole
// deficit a hair above zero. The engine writes the values now, so there is no
// drift and nothing to snap.
#define REPAIR_THRESHOLD 0.02
#define FUEL_THRESHOLD   0.99
#define AMMO_THRESHOLD   0.99

// How often (s) FUNC(serviceTick) OBSERVES the engine's work, and how long (s) it
// keeps watching one order before giving up on a deficit that is still not
// closing. STALL_TICKS * SERVICE_TICK is therefore the real latency on "this
// truck is dry"; SERVICE_TIMEOUT only ever fires on an order that is genuinely
// still inching along.
//
// Both were CBA sliders — GVAR(serviceInterval) and GVAR(serviceTimeout) — and
// neither described anything a curator decides. The ENGINE sets the pace of a
// service and finishes one in seconds: polling faster cannot make it finish
// sooner, and the timeout is a watchdog whose only visible effect is how long a
// pathological order lingers before it reports — lowering it would make ordinary
// orders report incomplete. They belong with STALL_TICKS and CLAIM_GRACE below,
// as monitor internals tuned once, rather than on the settings screen beside
// GVAR(serviceRadius), which is a real choice about what one order picks up.
#define SERVICE_TICK    1
#define SERVICE_TIMEOUT 60

// ── Monitor tuning ───────────────────────────────────────────────────────────
// The supply line is drawn client-side by linear interpolation between polls, and
// the payload it interpolates carries only a start time and a duration (see
// STREAM_SUPPLY below). Since the ENGINE now sets the pace and will not report
// progress, FUNC(serviceTick) measures progress from the deficit it is watching
// close and re-stamps `duration` when the client's straight line has drifted
// further than this from the truth. A re-stamp is a changed payload, so this is
// deliberately loose: too tight and the overlay's send-diff fires every poll,
// which is the one thing rtz_core's stream engine exists to avoid.
#define PROGRESS_DRIFT 0.1

// Progress gain below this does not count as progress. Guards the stall detector
// against a service that is technically inching along on floating-point noise.
#define PROGRESS_EPSILON 0.01

// Consecutive ticks with no real progress before the job gives up and tells the
// curator. This is the catch-all for "the engine action did nothing" — a dry
// supply truck is the expected cause, but a target the action silently refuses
// looks identical and must not idle out the whole timeout either.
#define STALL_TICKS 5

// Extra seconds a target's claim outlives the job that took it. Claims are what
// stop two supply vehicles — ordered separately, or by two different curators —
// running jobs with different snapshots against one vehicle and overwriting each
// other every tick. They carry an expiry rather than being released explicitly
// so that a superseded job, a destroyed supply truck or an order that stopped
// early can never strand a vehicle as permanently unserviceable.
#define CLAIM_GRACE 5

// ── Supply-lines overlay ─────────────────────────────────────────────────────
// This overlay is a CLIENT of rtz_core's stream engine, not a part of it: the
// gather/draw pair lives here, and XEH_postInit declares the whole stream in one
// EFUNC(core,registerStream) call and switches it on in the next line, for good.
// Unlike rtz_hud's two overlays it has no context-menu toggle, and — since the
// GVAR(enableSupplyDisplay) checkbox was removed — no setting either: supply
// lines are simply part of what this component does. That is why rtz_core is in
// requiredAddons — registration writes into registries the engine builds in its
// own preInit, and requiredAddons is what orders the two.
//
// This said rtz_hud, on both counts, and had done since the engine moved out of
// that component. rtz_hud is not in this addon's requiredAddons and never needed
// to be — it is a sibling consumer of the same engine, not the engine. Naming a
// display addon as the owner of shared machinery is the exact confusion the
// rtz_core split exists to prevent (see CLAUDE.md, "Nothing in core may name a
// specific display").
//
// SINGLE-quoted deliberately, matching the engine's own ids: this appears inside
// QUOTE(...) in CfgContext.hpp, and a double-quoted literal would terminate the
// config string the macro builds.
#define STREAM_SUPPLY 'sup'

// Tint of the lines themselves. There is no matching RGBA constant: the four-part
// COLOR_SUPPLY that used to sit here was the idle accent of a context-menu toggle
// this overlay no longer has, and a dead constant that looks tunable is precisely
// how a copy misleads. FUNC(drawSupply) appends its own distance-fade alpha.
#define COLOR_SUPPLY_RGB [0.40, 0.80, 0.50]

// MAX_DRAW_DIST / FADE_NEAR come from core/script_macros_core.hpp, included
// above. They used to be copied here to keep this overlay "matched to the
// engine's other overlays" — which is exactly why they belong in one place
// instead. The LABEL_* trio the engine exports alongside them is deliberately
// unused: this overlay draws lines and nothing else, no icon and no caption.
// There was a resupply glyph on the midpoint of every line, showing the exact
// percentage under the cursor, and it read as clutter across a serviced column —
// the fill below already carries the job at a glance.

// Progress is shown by the line itself: the stretch from the supply vehicle up to
// the progress point draws at full strength, the remainder at this fraction of
// its alpha. Gives every line an at-a-glance readout with no text at all, which
// is what makes the percentage affordable as a cursor-only detail.
#define LINE_PENDING_ALPHA  0.3
