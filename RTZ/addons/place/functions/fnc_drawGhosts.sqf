#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the session's ghost markers, and resolves which one the cursor is over
 * while it is at it.
 *
 * The hit test lives here rather than in the click handler because this pass is
 * already walking every ghost with the camera basis and the mouse position in
 * hand from rtz_core's shared frame context. Doing it here costs one projection
 * per ghost per frame that the draw needed anyway; doing it in the handler would
 * repeat the whole walk on every press. rtz_path splits it the same way, for the
 * same reason.
 *
 * Registered by FUNC(beginPlacement) and unregistered by FUNC(endPlacement), so
 * the mode costs exactly nothing while it is closed. Skipped by rtz_core
 * whenever the Zeus map covers the 3D view, which is also why the input handlers
 * refuse to act on GVAR(hovered) while visibleMap is true — the value under it
 * would be whatever the last 3D frame left behind.
 *
 * Nothing here allocates or formats: the label and both colour variants were
 * built once at seed time and are only read. CLAUDE.md's per-entity-per-tick
 * rule, on a pass that can run for as long as a curator leaves the mode open.
 *
 * Arguments:
 * 0: Frame context (CTX_* in core's script_macros_core.hpp) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(ghosts), LINKFUNC(drawGhosts), RENDER_WORLD, RENDER_PRIORITY] call rtz_core_fnc_registerRenderer
 *
 * Public: No
 */

params ["_ctx"];

private _ghosts = GVAR(ghosts);
if (_ghosts isEqualTo []) exitWith {};

private _camPos = _ctx select CTX_CAMPOS;
private _mouse = _ctx select CTX_MOUSE;
private _viewDist = _ctx select CTX_VIEWDIST;

private _grabbed = GVAR(grabbed);

// Emphasis is drawn from LAST frame's pick while this frame's is still being
// resolved — the winner is not known until the walk finishes, and a highlight one
// frame behind the cursor is not a thing an eye can see. The alternative is a
// second pass over the same array purely to move a highlight forward by 16 ms.
private _hovered = GVAR(hovered);

private _maxDistance = GETGVAR(maxDistance,150);

// Squared, so the pick compares squared screen distances and never takes a root
private _hoverBest = HOVER_RADIUS * HOVER_RADIUS;
private _nextHovered = -1;

{
    _x params ["", "_helper", "", "_origin", "_label", "_colors", "_glyph"];

    if (isNull _helper) then {continue};

    private _posASL = getPosASL _helper;

    // Past view distance there is nothing on screen to draw and nothing to pick
    if (_camPos distance _posASL >= _viewDist) then {continue};

    private _posAGL = ASLToAGL _posASL;
    private _active = _grabbed == _forEachIndex;

    // Hover pick. Skipped for the ghost already being dragged — it is locked to
    // the cursor, so it would win every frame and the curator could never hand
    // the grab to anything else.
    if (!_active) then {
        private _screen = worldToScreen _posAGL;
        if (_screen isNotEqualTo []) then {
            private _dx = (_screen select 0) - (_mouse select 0);
            private _dy = (_screen select 1) - (_mouse select 1);
            private _r2 = (_dx * _dx) + (_dy * _dy);
            if (_r2 < _hoverBest) then {
                _hoverBest = _r2;
                _nextHovered = _forEachIndex;
            };
        };
    };

    // The range gate, shown rather than reported. A ghost dragged further from
    // its unit than the setting allows goes red HERE, so the curator sees the
    // refusal while there is still something to do about it — the one-shot order
    // this mode replaces could only mention it afterwards, once the chance to
    // fix it had gone. FUNC(commitPlacement) applies the same test.
    private _color = if ((_origin distance2D _posASL) > _maxDistance) then {
        COLOR_OUT_OF_RANGE
    } else {
        _colors select (_active || {_hovered == _forEachIndex})
    };

    // Vanilla Zeus' own marker, shared with rtz_common's placement preview. The
    // colour goes in whole: vanilla tints only its disc by side and keeps the ring
    // white, but the ALPHA here is what says idle / hovered, so splitting the two
    // would cost the state signal to buy nothing.
    [_posAGL, _color, _glyph, _label, GHOST_TEXT_SIZE] call EFUNC(common,drawZeusIcon);
} forEach _ghosts;

GVAR(hovered) = _nextHovered;
