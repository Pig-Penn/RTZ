#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: opens a placement session for the Zeus selection, or commits
 * an open one. One key for both halves is the gesture that makes the mode quick
 * to use — tap, arrange, tap — and it is the same one rtz_path is built around.
 *
 * Tapping twice with nothing dragged in between reproduces exactly what the
 * one-shot teleport this mode replaces did: the ghosts seed in formation at the
 * cursor and commit there. The session only costs a keystroke when it is not
 * used, and buys per-unit placement when it is.
 *
 * Returns whether it consumed the press, so a key this handler declines to act
 * on still reaches whatever would normally receive it (rtz_orders, rtz_path and
 * rtz_slide do the same).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * call rtz_place_fnc_togglePlacement
 *
 * Public: No
 */

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

// Second press commits. Escape is the path that closes without moving anything
// (FUNC(handleInput)), and so is Zeus being closed (FUNC(placeTick)).
if (GVAR(placing)) exitWith {
    [true] call FUNC(endPlacement);
    true
};

// A 3D-view gesture, so it declines over the Zeus map rather than half-working
// there. Everything the session is made of needs the 3D view: ghosts are
// positioned by a ray from the curator camera, the renderer that resolves which
// one the cursor is over is skipped by rtz_core while the map covers the view,
// and screenToWorld under an open map reports a point in a scene nobody can see.
//
// This IS a change from the order it replaces, which resolved its cursor through
// ZEN's getPosFromScreen and so also worked from the map. Declining is the honest
// version of losing that: the key passes through instead of seeding a squad's
// worth of ghosts somewhere the curator cannot look at them. Map-view placement
// would mean a second draw surface and a second cursor path, the way rtz_path
// carries one — worth doing, but not by pretending this already does it.
if (visibleMap) exitWith {false};

// Cooldown, checked BEFORE opening rather than at commit. The one-shot order
// this replaces could only report it at the moment of the teleport, which was
// also the only moment it existed; a session that opened, let a curator arrange
// a whole squad, and only then refused would be worse than useless. A stored
// timestamp read once per press — no per-frame cost.
private _readyAt = GVAR(readyAt);
if (CBA_missionTime < _readyAt) exitWith {
    [LSTRING(MsgCooldown), ceil (_readyAt - CBA_missionTime)] call zen_common_fnc_showMessage;
    true
};

call FUNC(beginPlacement)
