// rtz_core's public contracts: what a component must know to register a
// renderer with the frame loop or declare a stream on the stream engine.
//
// Include this from your component's script_component.hpp, AFTER main's
// script_macros.hpp:
//
//     #include "\x\rtz\addons\core\script_macros_core.hpp"
//
// and declare "rtz_core" in your CfgPatches requiredAddons. Every current
// consumer (rtz_hud, rtz_mine, rtz_spotting, rtz_supply) already does.
//
// These used to live in main's script_macros.hpp on the belief that "component
// headers are not visible to each other". They are — an absolute PBO path
// resolves any component's header from any other. ACE3 does exactly this: ten
// medical components include \z\ace\addons\medical_engine\script_macros_medical.hpp
// from their own script_component.hpp. Keeping them here means rtz_attack,
// rtz_loot and rtz_economy — which neither draw nor stream — no longer parse
// this component's private contract, and a CTX_* index can change without
// touching the one addon every other addon depends on.

// ── Frame-loop contract ──────────────────────────────────────────────────────
// RTZ draws every curator-view display from ONE Draw3D handler
// (EFUNC(core,frameLoop)); a component that wants to draw registers a renderer
// with EFUNC(core,registerRenderer) instead of adding a handler of its own.
//
//   RENDER_WORLD — draws into the 3D scene (drawIcon3D / drawLine3D). Receives
//                  the frame context array below. Skipped while the Zeus MAP is
//                  up: the map covers the 3D view, so the output is invisible
//                  and the whole pass is waste.
//   RENDER_UI    — drives controls on the curator display, which stay visible
//                  OVER the Zeus map. Receives the display, or displayNull when
//                  Zeus is closed — and is called on those frames too, so it can
//                  tear its controls down.
#define RENDER_WORLD 0
#define RENDER_UI    1

// Index into the frame context array a RENDER_WORLD renderer receives. Named so
// a renderer can `select` the one or two it needs without a `params` over all
// seven. Camera-right/up are unit vectors in WORLD space — the axes screen-space
// offsets ride, so "right of the text" holds at any camera orientation.
// CTX_VIEWDIST is floored to a positive value by the loop, so renderers may divide
// by it for their distance fade without guarding.
// The context is passed as `[_ctx] call <renderer>`, so a renderer reads it with
// `params ["_ctx"]` — see the frame loop for why the wrapping array is required.
#define CTX_CAMPOS   0
#define CTX_CAMRIGHT 1
#define CTX_CAMUP    2
#define CTX_MOUSE    3
#define CTX_NOW      4
#define CTX_VIEWDIST 5
// No CTX_DISPLAY: a RENDER_WORLD renderer never needs the display, and a
// RENDER_UI one receives it as its whole argument instead.

// Caps on how much of a Zeus selection the stream engine will carry, applied by
// the client poll, re-applied by the server gather, and respected by every
// renderer — one definition keeps all three in lockstep. The DISPLAYS enforce
// them too (rtz_hud's card stack), which is why they are part of the public
// contract rather than private to the engine.
//
// SEL_MAX_HULLS bounds the third slice. It went uncapped for a while on the
// reasoning that the overlays "report what the curator's own selection is doing"
// — but the hull slice is the one that crosses the wire as OBJECTS, and a box
// select over a base sent one entry per prop, per module, per ammo crate, on
// every selection change, then made the server run every SRC_HULLS gatherer over
// all of them. The poll now also drops anything that is not an AllVehicles, which
// costs nothing: expectedDestination, targetKnowledge and the supply record exist
// only on a man or a vehicle, so every one of those entries was already coming
// back [] from all three gatherers.
#define SEL_MAX_UNITS 24
#define SEL_MAX_VEHICLES 8
#define SEL_MAX_HULLS 32

// A vehicle's effective side is its CREW's side — but an unmanned vehicle has
// `grpNull` for a group, and `side grpNull` matches no real side, so a plain
// `side (group veh) == side curator` test silently hides every parked truck and
// unmanned static from a side-restricted curator. Crewless vehicles are treated
// as visible to everyone instead (they belong to nobody yet, and Zeus can edit
// them regardless). Shared by the client poll, the server gather and both vehicle
// render paths so all four agree on what is visible.
#define VEH_SIDE_OK(veh,curSide) (isNull (group veh) || { side (group veh) == curSide })

// Side index carried in every packet: 0 west, 1 east, 2 independent, 3 everything
// else (civilian / logic / sideEmpty). Computed on the server where the real side
// is known, then carried so the client can colour by it without a side lookup.
#define SIDE_NUM(s) (switch (s) do { case west: {0}; case east: {1}; case independent: {2}; default {3} })

// ── Stream-engine contract ───────────────────────────────────────────────────
// Which slice of a watcher's selection a stream's gatherer is fed, resolved ONCE
// per watcher per tick by EFUNC(core,streamServer) and shared by every stream
// that wants it. Passed to EFUNC(core,registerStream).
//   SRC_UNITS — selected infantry, as [object, netId, dialogOpen]; side-filtered
//               and capped client-side, re-validated server-side.
//   SRC_VEHS  — selected vehicles, same shape and treatment.
//   SRC_HULLS — the whole selection resolved to distinct hulls, as
//               [watchedEntity, hull, dialogOpen]: a crewman resolves to his
//               vehicle, which moves and fights as one. What the AI-state
//               overlays want.
//
// These double as the DEMAND vocabulary: a display declares which slices it wants
// streamed with EFUNC(core,setDemand) — [QGVAR(myDisplay), [SRC_UNITS]] — and the
// poll reports a slice only while somebody is asking for it. Reusing the same
// constants is deliberate: "which slice does this stream read" and "which slice
// does this display want" are the same question asked from the two ends.
//
// SRC_HULLS is NOT a valid demand and is ignored if passed. Hull demand is
// already expressed by an overlay being switched on — EFUNC(core,toggleOverlay)
// owns GVAR(activeStreams), and the poll gates the hull slice on it — so routing
// it through the demand registry as well would give one fact two owners and two
// chances to disagree.
#define SRC_UNITS 0
#define SRC_VEHS  1
#define SRC_HULLS 2

// ── Overlay draw contract ────────────────────────────────────────────────────
// How a world-space overlay label is drawn. Shared, not per-component: these
// describe one visual system, and the whole point of the rule is that the
// destination, target and supply-line overlays must fade and reveal IDENTICALLY
// or they stop reading as one mod.
//
// They lived as byte-identical copies in rtz_hud's and rtz_supply's own headers,
// with rtz_supply's comment saying they were "matched to the engine's other
// overlays" — which is an argument for one definition, not two that must be
// hand-synced. Both components already include this file.
//
// Overlays start fading at FADE_NEAR and bottom out at MAX_DRAW_DIST (matching
// the spotting wedge's outer cap); a label only renders while the cursor is
// within LABEL_CURSOR_RADIUS of its icon, in GUI screen units.
#define MAX_DRAW_DIST       2500
#define FADE_NEAR           800
#define LABEL_CURSOR_RADIUS 0.05
#define LABEL_TEXT_SIZE     0.03
#define LABEL_FONT          "RobotoCondensed"
