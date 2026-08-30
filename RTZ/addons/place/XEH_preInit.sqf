#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// ── Placement session state (curator's client only) ──────────────────────────
// Declared OUTSIDE the recompile block so a live recompile swaps the functions
// without stranding an open session — its display event handlers would never be
// removed, its ghost models and Logic helpers would never be deleted, and the
// mode could never be exited. Same rule, and the same reason, as rtz_path.

// Ghosts being arranged right now, one record per unit (layout in
// script_component.hpp). Empty except while GVAR(placing) is true.
GVAR(ghosts) = [];
GVAR(placing) = false;

// Index into GVAR(ghosts) of the ghost being dragged, and of the one the cursor
// is merely over. -1 is "none" for both. GVAR(hovered) is set by the renderer,
// which already holds the camera basis and the mouse position from rtz_core's
// frame context, so the hit test is paid once per frame there rather than
// recomputed on every click.
GVAR(grabbed) = -1;
GVAR(hovered) = -1;

// [[eventType, id], ...] for the curator-display handlers the session installs,
// so FUNC(endPlacement) can remove precisely those and leave ZEN's alone.
GVAR(inputEHs) = [];

// -1 is the "no handler exists" sentinel, matching CBA's own handle convention.
// Created on entering the session and destroyed on leaving it, which is what
// makes the mode cost exactly nothing while it is closed.
GVAR(placePfh) = -1;

// Cooldown timestamp, carried over from the one-shot teleport this mode
// replaces. Machine-local and checked only on the key press, so it costs nothing
// per frame. Armed by FUNC(commitPlacement) only when something actually moved,
// so an opened-and-cancelled session is free.
GVAR(readyAt) = 0;

#include "initSettings.inc.sqf"
#include "initKeybinds.inc.sqf"

ADDON = true;
