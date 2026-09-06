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

// MAX_SERVICE_TARGETS used to sit here — a hard cap of 24 on how many targets one
// order could take on, matching SEL_MAX_UNITS. It existed because the old blanket
// sweep resolved its own targets and a truck parked in a company motor pool would
// otherwise produce a hundred-odd claims, a hundred-odd events and a hundred supply
// lines from one click. FUNC(orderResupply) is a PICKER now: one click carries one
// vehicle, so there is nothing left to cap.

// getFriend below this counts as hostile, so a supply vehicle will not service an
// enemy. Same idiom and same reading as rtz_attack's HOSTILE_THRESHOLD, phrased
// from the friendly side because this filter KEEPS what passes it.
#define FRIENDLY_THRESHOLD 0.6

// ── Target picker ────────────────────────────────────────────────────────────
// How far from the clicked point a vehicle may be and still count as the one the
// curator meant. Deliberately TIGHTER than rtz_attack's SEARCH_RADIUS of 20: that
// order picks out of a dispersed enemy where the nearest hostile is almost always
// the intended one, while this one aims into a parked column inside a 30 m default
// service radius, where 20 m would routinely snap onto a neighbour.
#define PICK_SNAP_RADIUS 8

// How stale the cached provider set may get before the cursor recomputes it. The
// cheap half of the resolve (FUNC(findServiceTarget), distance tests only) runs
// every frame; FUNC(serviceProviders) walks every turret's magazines through
// FUNC(serviceDeficit) and must not. Recomputed when the target under the cursor
// CHANGES or when this has elapsed — so sweeping across a column costs one walk per
// vehicle crossed, and resting on one costs four a second rather than sixty.
#define PICK_REFRESH 0.25

// Segments in the service-radius ring. The offsets are baked once when the picker
// opens (the radius cannot change mid-pick), so this is a per-frame drawLine3D
// count per selected truck and nothing else.
#define RING_SEGMENTS 32

// Cursor feedback. Three states, not two: a full vehicle parked beside a loaded
// truck is otherwise indistinguishable from bare ground, which is the one failure
// a curator cannot explain to himself. Out-of-range is deliberately NOT its own
// state — the ring already draws that boundary.
#define COLOR_VALID   [0.40, 0.80, 0.50, 1]
#define COLOR_NEUTRAL [0.75, 0.75, 0.75, 0.9]
#define COLOR_INVALID [0.50, 0.50, 0.50, 0.8]

// The ring itself, dimmer than the cursor. Matches COLOR_SUPPLY_RGB below so the
// aiming overlay and the supply lines it produces read as one system.
#define COLOR_RING [0.40, 0.80, 0.50, 0.5]

// ── Claim slots ──────────────────────────────────────────────────────────────
// The QGVAR(claim) array a serviced vehicle carries is PER SERVICE, not one lock
// for the whole target: a repair truck and a fuel truck aimed at one damaged, empty
// tank hold disjoint slots and work it together, while two fuel trucks still cannot
// both take the fuel — which is the invariant the monitor rests on, since each job
// measures progress from its own deficit snapshot and two jobs measuring the same
// service would each read the other's work as its own. The exclusive claim this
// replaced made the first case impossible: the two contended for one lock despite
// carrying nothing in common, and the loser was dropped from the order.
//
// Three slots in the order FUNC(supplyCapabilities) returns — repair, fuel, ammo —
// so a capability array and a claim array are walked with one index, which is how
// FUNC(grantedServices) and FUNC(releaseClaims) both read it. Each slot is [] when
// free, or [holder, expiresAt]; see CLAIM_GRACE below for why the expiry exists.
//
// There are deliberately no CLAIM_REPAIR / CLAIM_FUEL / CLAIM_AMMO index macros.
// Every reader walks the array in parallel with a capability array and indexes it
// with _forEachIndex, so named indices would be three constants nothing referenced —
// and a dead constant that looks tunable is exactly the kind of thing that misleads
// the next reader.

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
// running jobs against the same SERVICE on one vehicle and each reading the
// other's work as its own progress. They carry an expiry as well as being released
// explicitly so that a superseded job, a destroyed supply truck or an order that
// stopped early can never strand a service as permanently unclaimable.
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
