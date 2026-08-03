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
#define CTX_CAMPOS   0
#define CTX_CAMRIGHT 1
#define CTX_CAMUP    2
#define CTX_MOUSE    3
#define CTX_NOW      4
#define CTX_VIEWDIST 5
#define CTX_DISPLAY  6

// Caps on how much of a Zeus selection the stream engine will carry, applied by
// the client poll, re-applied by the server gather, and respected by every
// renderer — one definition keeps all three in lockstep. The DISPLAYS enforce
// them too (rtz_hud's card stack), which is why they are part of the public
// contract rather than private to the engine.
#define SEL_MAX_UNITS 24
#define SEL_MAX_VEHICLES 8

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
#define SRC_UNITS 0
#define SRC_VEHS  1
#define SRC_HULLS 2
