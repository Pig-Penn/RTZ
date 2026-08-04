#include "script_component.hpp"
/*
 * Author: Maxim
 * The Zeus-map half of the planning display. Same paths, same handles, same
 * picks — drawn with the map control's own primitives, which is the only thing
 * that genuinely differs between this and FUNC(drawPaths).
 *
 * Attached to the curator map control by FUNC(beginPlanning) and detached by
 * FUNC(endPlanning), by id: clearing the control's handlers wholesale would take
 * ZEN's own Draw handlers on the same map with it.
 *
 * The two renderers are mutually exclusive — rtz_core skips every RENDER_WORLD
 * renderer while the map covers the 3D view, and this one returns immediately
 * while it does not — so both writing GVAR(hovered) and GVAR(hoveredPoint) is
 * safe, and is what lets a path be traced, picked and cut on the map exactly as
 * it is in the 3D view.
 *
 * Picks are in world metres scaled by ctrlMapScale rather than in screen units,
 * because that is the space the map hands back; the result is a constant pick
 * distance on screen at any zoom.
 *
 * Arguments:
 * 0: Map control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_map] call rtz_path_fnc_drawPathsMap
 *
 * Public: No
 */

params ["_map"];

if (!GVAR(planning)) exitWith {};

// Explicit rather than relying on a hidden control not drawing. The two
// renderers both write GVAR(hovered) and GVAR(hoveredPoint), and they are only
// safe doing that because exactly one of them runs at a time: rtz_core skips
// every RENDER_WORLD renderer while the map is up, and this returns while it is
// not. Wargame guards its map routine the same way.
if (!visibleMap) exitWith {};

private _paths = GVAR(paths);
if (_paths isEqualTo []) exitWith {
    GVAR(hovered) = objNull;
    GVAR(hoveredPoint) = [];
};

private _cursor = _map posScreenToWorld getMousePosition;

// Pick distance in metres that reads as a constant distance on screen
private _pick = MAP_HIT_SCALE * (ctrlMapScale _map);
private _pick2 = _pick * _pick;

private _grabbed = GVAR(grabbed);
private _cutting = GVAR(mods) select 1;

private _hovered = objNull;
private _hoverBest = _pick2;
private _hoveredPoint = [];
private _pointBest = _pick2;

{
    _x params ["_unit", "_hull", "_points", "_color", "_kind", "_head", "_dir", "_label", "_alt"];

    private _handlePos = ASLToAGL _head;
    private _active = _grabbed isEqualTo _unit;

    if (!_active) then {
        private _r2 = _cursor distanceSqr _handlePos;
        if (_r2 < _hoverBest) then {
            _hoverBest = _r2;
            _hovered = _unit;
        };
    };

    private _emphasised = _active || {GVAR(hovered) isEqualTo _unit};
    private _alpha = [ALPHA_IDLE, ALPHA_ACTIVE] select _emphasised;
    private _scale = [1, 1.35] select _emphasised;
    private _drawColor = [_color select 0, _color select 1, _color select 2, _alpha];

    private _size = MAP_ICON_SIZE * _scale;

    // Unlike drawIcon3D, a map icon's angle IS a world heading, so the arrow
    // takes PATH_DIR unmodified
    _map drawIcon [
        ICON_HANDLE, _drawColor, _handlePos,
        _size, _size, _dir, _label, 1, TEXT_SIZE, PATH_FONT, "center"
    ];

    // No stalk to draw on a map, but the altitude is the one thing a flight plan
    // cannot show in plan view, so it is worth a second label under the handle
    if (_kind == KIND_AIR) then {
        _map drawIcon [
            "", _drawColor, _handlePos,
            0, 0, 0, _alt, 1, TEXT_SIZE, PATH_FONT, "right"
        ];
    };

    private _count = count _points;
    if (_count == 0) then {continue};

    private _prev = ASLToAGL getPosASL _hull;

    private _originSize = MAP_POINT_SIZE * ORIGIN_SIZE_SCALE;
    _map drawIcon [
        ICON_POINT, _drawColor, _prev,
        _originSize, _originSize, 0, "", 0, TEXT_SIZE, PATH_FONT, "center"
    ];

    // No distance falloff here — the map shows the whole path at once, and
    // zoom is already accounted for by drawing in world coordinates
    private _stride = (ceil (_count / DRAW_BUDGET)) max 1;
    private _last = _count - 1;
    private _drawn = 0;

    for "_i" from 0 to _last step _stride do {
        private _p = ASLToAGL (_points select _i);

        _map drawLine [_prev, _p, _drawColor, MAP_LINE_WIDTH];

        if (_drawn % DOT_EVERY == 0) then {
            _map drawIcon [
                ICON_POINT, _drawColor, _p,
                MAP_POINT_SIZE, MAP_POINT_SIZE, 0, "", 0, TEXT_SIZE, PATH_FONT, "center"
            ];
        };

        if (_cutting) then {
            private _r2 = _cursor distanceSqr _p;
            if (_r2 < _pointBest) then {
                _pointBest = _r2;
                _hoveredPoint = [_unit, _i, _p];
            };
        };

        _prev = _p;
        _drawn = _drawn + 1;
    };

    if (_last % _stride != 0) then {
        _map drawLine [_prev, ASLToAGL (_points select _last), _drawColor, MAP_LINE_WIDTH];
    };
} forEach _paths;

if (_hoveredPoint isNotEqualTo []) then {
    _map drawIcon [
        ICON_CUT, COLOR_CUT, _hoveredPoint select 2,
        MAP_ICON_SIZE, MAP_ICON_SIZE, 0, "", 0, TEXT_SIZE, PATH_FONT, "center"
    ];
};

GVAR(hovered) = _hovered;
GVAR(hoveredPoint) = _hoveredPoint;
