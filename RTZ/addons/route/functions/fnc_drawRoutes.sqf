#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for an open planning session: one drag handle per route,
 * the traced line behind it, and the cut marker when the cursor is over a point
 * with the modifier held.
 *
 * Registered with EFUNC(core,registerRenderer), so it shares the one camera
 * basis and the one mouse query the frame loop builds for every RTZ display, and
 * is skipped outright while the Zeus map covers the 3D view — FUNC(drawRoutesMap)
 * takes over there.
 *
 * This pass also RESOLVES the hover, because it is the only place that already
 * holds both a world position and the cursor. The input handlers read what it
 * decides. Nearest wins rather than first-in-the-list wins: two handles
 * overlapping on screen should hand the grab to the one actually under the
 * cursor, not to whichever route happened to be seeded first.
 *
 * The line is decimated to a per-route budget that falls off with camera
 * distance, which is what keeps a curator with a platoon's worth of long routes
 * from issuing thousands of drawLine3D calls a frame. Wargame's equivalent
 * switches stride at three hardcoded point counts through four interacting index
 * variables, duplicated verbatim in its map renderer.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in core's script_macros_core.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctx] call rtz_route_fnc_drawRoutes
 *
 * Public: No
 */

params ["_ctx"];

private _routes = GVAR(routes);
if (_routes isEqualTo []) exitWith {
    GVAR(hovered) = objNull;
    GVAR(hoveredPoint) = [];
};

private _camPos   = _ctx select CTX_CAMPOS;
private _mouse    = _ctx select CTX_MOUSE;
private _viewDist = _ctx select CTX_VIEWDIST;

// drawIcon3D's angle is a SCREEN rotation, so a world heading has to be taken
// relative to where the camera is looking for the arrow to point the right way.
// Read once per frame, not once per handle.
private _camDir = getDir curatorCamera;

private _grabbed = GVAR(grabbed);
// Cutting is the only thing that needs per-point picking, so the whole per-point
// hit test is gated on the modifier being held.
private _cutting = GVAR(mods) select 1;

// Nearest-wins accumulators. The radii double as the initial "best" values, so a
// candidate has to beat the threshold to be considered at all.
private _hovered = objNull;
private _hoverBest = HANDLE_HIT_R2;
private _hoveredPoint = [];
private _pointBest = POINT_HIT_R2;

{
    _x params ["_unit", "_hull", "_points", "_color", "_kind", "_head", "_dir", "_label", "_alt"];

    private _handlePos = (ASLToAGL _head) vectorAdd [0, 0, HANDLE_LIFT];
    private _dist = _camPos distance _handlePos;

    // Past view distance every colour below fades to nothing, so there is
    // nothing to draw and nothing to pick
    if (_dist >= _viewDist) then {continue};

    private _active = _grabbed isEqualTo _unit;

    // Handle pick. Skipped for the handle already being dragged — it is locked
    // to the cursor, so it would win every frame and the curator could never
    // hand the grab to anything else.
    private _handleScreen = worldToScreen _handlePos;
    if (!_active && {_handleScreen isNotEqualTo []}) then {
        private _dx = (_handleScreen select 0) - (_mouse select 0);
        private _dy = (_handleScreen select 1) - (_mouse select 1);
        private _r2 = (_dx * _dx) + (_dy * _dy);
        if (_r2 < _hoverBest) then {
            _hoverBest = _r2;
            _hovered = _unit;
        };
    };

    private _emphasised = _active || {GVAR(hovered) isEqualTo _unit};
    private _alpha = [ALPHA_IDLE, ALPHA_ACTIVE] select _emphasised;
    private _size = [HANDLE_SIZE, HANDLE_SIZE_HOVER] select _emphasised;

    // Rebuilt per route per frame rather than mutating the stored colour in
    // place: the record's colour is the route's identity and must survive being
    // hovered.
    private _drawColor = [_color select 0, _color select 1, _color select 2, _alpha];

    drawIcon3D [
        ICON_HANDLE, _drawColor, _handlePos,
        _size, _size, _dir - _camDir,
        "", 0, TEXT_SIZE, ROUTE_FONT, "center", false, 0, 0
    ];

    // The label sits under the handle and only while it is close enough to read.
    // Pre-resolved at session start — no str, no config lookup, per frame.
    if (_dist < LABEL_MAX_DIST) then {
        drawIcon3D [
            "", _drawColor, _handlePos vectorAdd [0, 0, -0.9],
            0, 0, 0, _label, 1, TEXT_SIZE, ROUTE_FONT, "center", false, 0, 0
        ];
    };

    // An aircraft handle floating in the sky says nothing about where it is over
    // the ground, so it gets a stalk down to the terrain and its height in
    // metres. In AGL a zero height IS the ground at that point, which is the
    // whole reason the handle is converted out of ASL before it is drawn.
    if (_kind == KIND_AIR) then {
        private _ground = [_handlePos select 0, _handlePos select 1, 0];
        drawLine3D [_handlePos, _ground, _drawColor, 2];
        drawIcon3D [
            ICON_POINT, _drawColor, _ground,
            POINT_SIZE, POINT_SIZE, 0,
            "", 0, TEXT_SIZE, ROUTE_FONT, "center", false, 0, 0
        ];
        // Pre-formatted by FUNC(appendPoint) — no str, no round, per frame
        drawIcon3D [
            "", _drawColor, _handlePos vectorAdd [0, 0, 1.1],
            0, 0, 0, _alt, 1, TEXT_SIZE, ROUTE_FONT, "center", false, 0, 0
        ];
    };

    private _count = count _points;
    if (_count == 0) then {continue};

    // Where the line starts: the subject itself, not the first drawn point
    private _lift = [0, 0, LINE_LIFT];
    private _prev = (ASLToAGL getPosASL _hull) vectorAdd _lift;

    private _originSize = POINT_SIZE * ORIGIN_SIZE_SCALE;
    drawIcon3D [
        ICON_POINT, _drawColor, _prev,
        _originSize, _originSize, 0,
        "", 0, TEXT_SIZE, ROUTE_FONT, "center", false, 0, 0
    ];

    // Budget falls off with distance; one divide per route, no tables
    private _budget = DRAW_BUDGET;
    if (_dist > DRAW_NEAR) then {
        _budget = ((DRAW_BUDGET * DRAW_NEAR) / _dist) max DRAW_MIN;
    };
    private _stride = (ceil (_count / _budget)) max 1;

    private _last = _count - 1;
    private _drawn = 0;

    for "_i" from 0 to _last step _stride do {
        private _p = (ASLToAGL (_points select _i)) vectorAdd _lift;

        drawLine3D [_prev, _p, _drawColor, LINE_WIDTH];

        if (_drawn % DOT_EVERY == 0) then {
            drawIcon3D [
                ICON_POINT, _drawColor, _p,
                POINT_SIZE, POINT_SIZE, 0,
                "", 0, TEXT_SIZE, ROUTE_FONT, "center", false, 0, 0
            ];
        };

        // Cut pick. Records the INDEX as well as the position, so FUNC(cutRoute)
        // truncates without having to search the point list for a float match —
        // which is what Wargame does, with findIf over an isEqualTo on positions.
        if (_cutting) then {
            private _scr = worldToScreen _p;
            if (_scr isNotEqualTo []) then {
                private _dx = (_scr select 0) - (_mouse select 0);
                private _dy = (_scr select 1) - (_mouse select 1);
                private _r2 = (_dx * _dx) + (_dy * _dy);
                if (_r2 < _pointBest) then {
                    _pointBest = _r2;
                    _hoveredPoint = [_unit, _i, _p];
                };
            };
        };

        _prev = _p;
        _drawn = _drawn + 1;
    };

    // Decimation can step past the true end; close the line so the drawn route
    // always reaches the handle the curator is holding
    if (_last % _stride != 0) then {
        drawLine3D [_prev, (ASLToAGL (_points select _last)) vectorAdd _lift, _drawColor, LINE_WIDTH];
    };
} forEach _routes;

// Marker on the point that a click would cut back to
if (_hoveredPoint isNotEqualTo []) then {
    drawIcon3D [
        ICON_CUT, COLOR_CUT, _hoveredPoint select 2,
        HANDLE_SIZE, HANDLE_SIZE, 0,
        "", 0, TEXT_SIZE, ROUTE_FONT, "center", false, 0, 0
    ];
};

GVAR(hovered) = _hovered;
GVAR(hoveredPoint) = _hoveredPoint;
