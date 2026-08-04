#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// ── Planning state (curator's client only) ───────────────────────────────────
// Declared outside the recompile block so a live recompile swaps the functions
// without stranding an open planning session — its display event handlers would
// never be removed and the mode could never be exited.
//
// Paths being planned right now, one record per entity (layout in
// script_component.hpp). Empty except while GVAR(planning) is true.
GVAR(paths) = [];
GVAR(planning) = false;

// The handle the curator is dragging, and the one the cursor is merely over.
// Both are set by the renderer (which already has the camera basis and the mouse
// position from rtz_core's frame context) and read by the input handlers.
GVAR(grabbed) = objNull;
GVAR(hovered) = objNull;

// [unit, pointIndex, drawPosition] of the path point the cursor would cut back
// to, or [] when there is none. The INDEX is carried, not just the position, so
// the cut is a truncation at a known offset rather than a search of the point
// list for a matching float triple.
GVAR(hoveredPoint) = [];

// -1 is the "no handler exists" sentinel, matching CBA's own handle convention.
// Both are created on entering planning mode and destroyed on leaving it, which
// is what makes the mode cost exactly nothing while it is closed.
GVAR(planPfh) = -1;
GVAR(mapEH) = -1;

// [[eventType, id], ...] for the curator-display handlers the mode installs, so
// FUNC(endPlanning) can remove precisely those and leave ZEN's alone.
GVAR(inputEHs) = [];

// Units this session actually put a hold on. Recorded rather than re-derived
// from the setting on the way out — an admin toggling the setting mid-session
// would otherwise leave the selection stopped with nothing left to release it.
GVAR(held) = [];

// Live [shift, ctrl, alt] state, refreshed from the parameters of the key and
// mouse events this mode already receives. Scoped to the mode rather than kept
// as three mission-wide globals the way Wargame does it.
GVAR(mods) = [false, false, false];

// Path colours, assigned by index so two paths drawn in the same session are
// never the same colour and a given path keeps its colour for the session.
// Hand-picked rather than generated: these are read against grass, sand, snow
// and tarmac, and Wargame's `while {random 1.1}` picker — which can spin up to
// 600 times looking for an unused colour — regularly lands on near-black or on
// two neighbouring greens.
GVAR(palette) = [
    [0.30, 0.69, 1.00, 1],  // sky blue
    [1.00, 0.60, 0.10, 1],  // amber
    [0.45, 0.90, 0.35, 1],  // spring green
    [1.00, 0.35, 0.55, 1],  // rose
    [0.70, 0.55, 1.00, 1],  // violet
    [1.00, 0.90, 0.25, 1],  // yellow
    [0.20, 0.85, 0.80, 1],  // teal
    [1.00, 0.45, 0.20, 1],  // vermilion
    [0.60, 0.80, 0.20, 1],  // olive
    [0.90, 0.50, 0.90, 1],  // orchid
    [0.40, 0.60, 0.95, 1],  // indigo
    [0.85, 0.75, 0.55, 1]   // sand
];

// Per-kind drawing rules, indexed by KIND_* (layout in script_component.hpp).
// Built once here rather than recomputed per appended point, which is what
// Wargame does — the same twenty-odd assignments, inline, on every sample of the
// cursor.
//
//    [spacing, maxPoints, maxClimb, maxIncline, clearHeight, lodNear, lodFar, smoothSteps, commitSpacing, formationGap]
GVAR(profiles) = [
    // KIND_INFANTRY — 3 m sampling. Fine enough that the drawn line and the walked
    // line are the same shape, coarse enough that the AI navigating each leg has
    // something to navigate. Climb is one storey: stairs and embankments yes,
    // rooftops no.
    [3, 400, 2, 0.9, 0.45, "GEOM", "VIEW", 2, 20, 12],

    // KIND_LAND — 8 m sampling, and a NONE/FIRE geometry pair so the line test
    // ignores the thin clutter (bushes, fences, signs) a vehicle simply drives
    // through, while still stopping at walls and buildings.
    [8, 400, 6, 0.9, 0.65, "NONE", "FIRE", 3, 40, 30],

    // KIND_AIR — no climb or incline limit: altitude is drawn deliberately, and a
    // helicopter may legitimately go straight up. Wide sampling because a
    // 7.5 km flight plan is an ordinary one.
    [25, 300, 1e11, 1, 0.25, "GEOM", "VIEW", 6, 80, 90],

    // KIND_BOAT — climb is capped hard because a boat path that gains height has
    // left the water, which is the failure this catches when a curator traces
    // across a headland.
    [12, 300, 2, 1, 0.25, "GEOM", "VIEW", 6, 60, 45]
];

// ── Execution state (the machine each pathed unit is local to) ───────────────
// Paths being followed right now, one record per unit (layout in
// script_component.hpp). Declared outside the recompile block so a live
// recompile swaps the functions without stranding paths already running — their
// units would never be handed back to their groups.
//
// The per-frame handler that drives them is created with the first path and
// destroyed with the last (FUNC(startFollow), FUNC(followTick)); -1 is the
// "no handler exists" sentinel, matching CBA's own handle convention.
GVAR(active) = [];
GVAR(pfh) = -1;

#include "initSettings.inc.sqf"
#include "initKeybinds.inc.sqf"

ADDON = true;
