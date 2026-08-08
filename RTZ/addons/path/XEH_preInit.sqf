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

// The grabbed handle is being ROTATED rather than dragged: the cursor sets which
// way the subject faces instead of where it goes. Armed at mouse-down only, so a
// modifier pressed part-way through a trace cannot turn it into a rotation, and
// a rotation cannot silently become a trace when the modifier is let go.
GVAR(rotating) = false;

// Metres of altitude a vertical drag on an AIRCRAFT handle has asked for and not
// yet been given a point for. Lives across frames because one frame of mouse
// travel is worth less altitude than FUNC(appendPoint) will accept, so the drag
// has to be integrated to reach the threshold at all — see FUNC(airTarget).
// Zeroed by FUNC(appendPoint) the moment it spends it.
GVAR(altDrag) = 0;

// Post-process handle for the planning tint, and the generation counter the
// modifier hint's expiry rides on. Both live out here with the rest of the
// session state for the same reason: a live recompile mid-session must not
// strand a screen effect nothing is left holding the handle to, and must not
// leave a stale timer able to blank the next session's hint.
GVAR(ppEffect) = -1;
GVAR(hintGeneration) = 0;

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

// Path colours. A colour is claimed by an ENTITY and kept on it (FUNC(colorFor)),
// so the truck that was amber in the last planning session is amber in the next
// one — which is the whole point of colouring paths at all when a curator plans
// the same company four times in an operation. That persistence is Wargame's
// idea and a good one; what is wrong with its version is the picker, a
// `while {random 1.1}` that can spin up to 600 times looking for an unused
// colour and regularly lands on near-black or on two neighbouring greens.
//
// Hand-picked instead: these are read against grass, sand, snow and tarmac, and
// FUNC(colorFor) hands out the least-used one rather than cycling by index, so
// a session of thirteen paths repeats one colour instead of restarting the whole
// order.
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
// The last two are the SAME number for two executors, and the gap between them
// is the whole content of Wargame's "one point every 0.25 m". A doMove chain
// hands each leg to the AI's own navigation, which has no use for a target a few
// metres ahead; a scripted executor walks or flies the polyline literally, and
// every point it is not given is a corner it cuts. FUNC(commitPaths) picks
// between them by which executor the settings put the subject on.
//
//    [spacing, maxPoints, maxClimb, maxIncline, clearHeight, lodNear, lodFar, smoothSteps, commitSpacing, formationGap, scriptedSpacing]
GVAR(profiles) = [
    // KIND_INFANTRY — 3 m sampling. Fine enough that the drawn line and the walked
    // line are the same shape, coarse enough that the AI navigating each leg has
    // something to navigate. Climb is one storey: stairs and embankments yes,
    // rooftops no.
    [3, 400, 2, 0.9, 0.45, "GEOM", "VIEW", 2, 20, 12, 4],

    // KIND_LAND — 8 m sampling, and a NONE/FIRE geometry pair so the line test
    // ignores the thin clutter (bushes, fences, signs) a vehicle simply drives
    // through, while still stopping at walls and buildings. The engine drives
    // this one whatever the settings say, so there is nothing finer to ask for.
    [8, 400, 6, 0.9, 0.65, "NONE", "FIRE", 3, 40, 30, 40],

    // KIND_AIR — no climb or incline limit: altitude is drawn deliberately, and a
    // helicopter may legitimately go straight up. Wide sampling because a
    // 7.5 km flight plan is an ordinary one.
    [25, 300, 1e11, 1, 0.25, "GEOM", "VIEW", 6, 80, 90, 30],

    // KIND_BOAT — climb is capped hard because a boat path that gains height has
    // left the water, which is the failure this catches when a curator traces
    // across a headland.
    [12, 300, 2, 1, 0.25, "GEOM", "VIEW", 6, 60, 45, 20]
];

// ── Tactical move tables (read where the unit is local) ─────────────────────
// Suffix of the directional movement animation to play, and the steering offset
// that goes with it, indexed by the 45-degree sector the direction of travel
// falls in RELATIVE to the direction the unit is facing. Sector 0 is straight
// ahead, and they run clockwise: f, fr, r, br, b, bl, l, fl.
//
// The offsets are Wargame's (jack_animationDirectionArr) and are carried over
// unchanged on purpose. They correct for the fact that a strafe animation
// displaces the model along the STRAFE direction while the steering routine is
// aiming the model's nose — they were arrived at by eye against the animation
// set and there is nothing to re-derive them from. That is also why they are not
// simply -45 per sector: the diagonal animations do not displace the model at a
// true 45 degrees, and the two that look wrong on paper (fr, fl) are the two
// that were tuned hardest.
//
// These are the CORRECTION only. The sector's own 45-degree term is added on top
// by FUNC(moveAnimation), which is where the two become a steering offset — read
// that before changing a number here.
GVAR(animDirections) = [
    ["f", 0], ["fr", 315], ["r", 180], ["br", 90],
    ["b", 0], ["bl", 270], ["l", 180], ["fl", 135]
];

// Resolved animation names, keyed by pace + stance + weapon + direction. The
// lookup it replaces is a config read plus an isClass per leg per unit; the map
// it fills is bounded at ANIM_CACHE_MAX because a HashMap that only grows is a
// leak on a multi-hour operation (CLAUDE.md), not because the key space is
// expected to come anywhere near it. Same shape as rtz_smoke's cmWeaponCache.
GVAR(animCache) = createHashMap;

// Door selections and their model-space positions, keyed by building CLASS —
// because that is what the answer is a property of. FUNC(openDoors) fills it;
// bounded at DOOR_CACHE_MAX for the same reason as the animation cache. Wargame
// asks the same question of the nearest BUILDING, every half second, per unit.
GVAR(doorCache) = createHashMap;

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
