#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the trench being drawn: one marker per grid cell it would occupy, green
 * when the line can be dug and red with the reason when it cannot.
 *
 * Registered on rtz_core's shared frame loop rather than on a Draw3D handler of its
 * own, and unregistered by FUNC(endAiming). A session left registered is a renderer
 * on that loop for the rest of the mission.
 *
 * Markers, not a line, because the cells ARE the feature: the curator is choosing
 * heightmap vertices whether he knows it or not, and showing him the snapped cells
 * is what makes a drag that looks diagonal but comes out axis-aligned legible
 * before he commits rather than after.
 *
 * Arguments:
 * 0: Frame context <ARRAY> — see the CTX_* indices in rtz_core's contract
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctx] call rtz_dig_fnc_drawAim
 *
 * Public: No
 */

params ["_ctx"];

if (GVAR(aiming) isEqualTo []) exitWith {};

GVAR(aiming) params ["", "_start", "_end", "_plan", "", "", "_planAt"];

// Nothing pressed yet — there is no line to draw.
if (_start isEqualTo []) exitWith {};

private _now = _ctx select CTX_NOW;

// Re-planned on PLAN_INTERVAL, never per frame: FUNC(planTrench) runs
// nearestObjects, nearestTerrainObjects and a surfaceType lookup for three points
// of every cell. rtz_airstrike caches its own validity check the same way.
//
// The label is composed HERE too, inside the same throttle. `format` on a path that
// runs every frame is exactly what this mod's hour-long sessions cannot afford, and
// there is no reason to rebuild a string that only changes when the plan does.
if (_now >= _planAt) then {
    _plan = [_start, _end] call FUNC(planTrench);

    private _label = if (_plan select 0) then {
        format ["%1  x%2", LLSTRING(HintDig), count (_plan select 2)]
    } else {
        _plan select 1
    };

    _plan pushBack _label;

    GVAR(aiming) set [AIM_PLAN, _plan];
    GVAR(aiming) set [AIM_PLANAT, _now + PLAN_INTERVAL];
};

// First frame after the press, before the first plan has been made.
if (_plan isEqualTo []) exitWith {};

_plan params ["_valid", "", "_cells", "", ["_label", ""]];

// Refused: mark both ends rather than the cells, because there are no cells. The
// reason rides on the end the cursor is at, where the curator is already looking.
if (!_valid) exitWith {
    drawIcon3D [ICON_DIG, COLOR_INVALID, ASLToAGL _start, MARKER_SIZE, MARKER_SIZE, 0, "", 1, HINT_TEXT_SIZE, "RobotoCondensed"];
    drawIcon3D [ICON_DIG, COLOR_INVALID, ASLToAGL _end, MARKER_SIZE, MARKER_SIZE, 0, _label, 1, HINT_TEXT_SIZE, "RobotoCondensed"];
};

private _last = (count _cells) - 1;

// The label rides on the far end's marker only, so a long trench does not print it
// once per cell — and it goes through the same drawIcon3D as the marker rather than
// a second text-only call.
{
    private _centre = _x select CELL_CENTRE;

    drawIcon3D [
        ICON_DIG, COLOR_DIG, [_centre select 0, _centre select 1, 0],
        MARKER_SIZE, MARKER_SIZE, 0,
        ["", _label] select (_forEachIndex == _last),
        1, HINT_TEXT_SIZE, "RobotoCondensed"
    ];
} forEach _cells;
