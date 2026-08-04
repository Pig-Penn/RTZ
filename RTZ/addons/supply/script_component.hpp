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

// ── Service thresholds ───────────────────────────────────────────────────────
// Damage below this is treated as intact, so a scratched vehicle does not keep
// the action visible forever. Doubles as the COMPLETION SNAP window: setDamage
// does not store the figure it is given verbatim (the engine redistributes it
// across hit points and `damage` reads back an aggregate), so the per-tick delta
// chain drifts and a job that has applied its whole deficit still lands a little
// above zero. FUNC(endService) snaps that residue away — but only from inside
// this window, so a vehicle genuinely shot up mid-service keeps its new damage
// instead of having it erased on the last frame. rtz_repair uses the same
// snap-inside-the-threshold trick for the same reason; the two values differ
// because a supply truck servicing a parked column and an engineer working one
// wreck have different ideas of "close enough to intact".
#define REPAIR_THRESHOLD 0.02

// Fuel above this is treated as full — and, symmetrically, the snap window for
// the fuel side of FUNC(endService).
#define FUEL_THRESHOLD 0.99

// Floor (s) of the GVAR(serviceInterval) setting — the interval at which
// service progress is applied. Deliberately coarse: the loop is a single
// handler for the whole order and interpolates against the clock, so the
// interval changes write granularity, never total throughput.
#define SERVICE_TICK_MIN 0.5

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
// EFUNC(core,registerStream) call and switches it on for good (FUNC(syncDisplay)) —
// unlike rtz_hud's two overlays, this one has no context-menu toggle. That is why rtz_core is in
// requiredAddons — registration writes into registries the engine builds in its
// own postInit, and requiredAddons is what orders the two.
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

// Draw tuning, matched to the engine's other overlays so the three read as one
// system: lines start fading at FADE_NEAR and bottom out at MAX_DRAW_DIST, and
// labels only render while the cursor is within LABEL_CURSOR_RADIUS of the icon
// (GUI screen units).
#define MAX_DRAW_DIST       2500
#define FADE_NEAR           800
#define LABEL_CURSOR_RADIUS 0.05
#define LABEL_TEXT_SIZE     0.03
#define LABEL_FONT          "RobotoCondensed"
#define ICON_SIZE_SERVICE   0.7

// The overlay hangs its icon and label at the MIDPOINT of each supply line, not
// over the serviced vehicle. Anything drawn on a vehicle lands underneath Zeus's
// own unit icon — which is drawn by the engine, always on top, and cannot be
// moved — so the readout was simply invisible on exactly the vehicles it
// described. The midpoint of a line between two hulls is empty screen space by
// construction, and it also reads as belonging to the LINK rather than to the
// target. Lifted clear of the terrain so a line running across a slope does not
// bury it.
#define SERVICE_ICON_LIFT   1.5

// Progress is shown by the line itself: the stretch from the supply vehicle up to
// the progress point draws at full strength, the remainder at this fraction of
// its alpha. Gives every line an at-a-glance readout with no text at all, which
// is what makes the percentage affordable as a cursor-only detail.
#define LINE_PENDING_ALPHA  0.3
