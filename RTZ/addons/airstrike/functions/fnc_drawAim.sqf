#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the aim session: a ring on the target and an arrow through it pointing the
 * way the aircraft will fly.
 *
 * Registered on rtz_core's shared frame loop rather than on a Draw3D handler of its
 * own, and unregistered by FUNC(endAiming). A session left registered is a renderer
 * on that loop for the rest of the mission.
 *
 * Arguments:
 * 0: Frame context <ARRAY> - see the CTX_* indices in rtz_core's contract
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctx] call rtz_airstrike_fnc_drawAim
 *
 * Public: No
 */

params ["_ctx"];

if (GVAR(aiming) isEqualTo []) exitWith {};

GVAR(aiming) params ["_objects", "_args", "_aim", "_bearing"];

// Nothing pressed yet — there is no target to draw a ring around.
if (_aim isEqualTo []) exitWith {};

_args params ["_vehicle"];

// Tinted invalid the moment the order would be refused, so the curator sees a dead
// gesture before he releases rather than a message after.
private _valid = alive _vehicle
    && {!isNull ([_objects] call FUNC(strikeAircraft))}
    && {_vehicle ammo (_args select 1) > 0};

private _color = [COLOR_INVALID, COLOR_STRIKE] select _valid;

private _centre = ASLToAGL _aim;

// The ring is built from AIM_RING_SEGMENTS straight segments. Cheap, and this only
// runs while a session is open.
private _step = 360 / AIM_RING_SEGMENTS;
private _previous = _centre vectorAdd [0, AIM_RING_RADIUS, 0];

for "_i" from 1 to AIM_RING_SEGMENTS do {
    private _angle = _i * _step;
    private _point = _centre vectorAdd [(sin _angle) * AIM_RING_RADIUS, (cos _angle) * AIM_RING_RADIUS, 0];

    drawLine3D [_previous, _point, _color];
    _previous = _point;
};

// A bearing of -1 means the drag has not said anything yet, so the arrow shows what
// the order would actually use: the aircraft's current heading.
private _shown = if (_bearing < 0) then {getDir _vehicle} else {_bearing};

private _from = _centre vectorAdd [-(sin _shown) * AIM_ARROW_LENGTH, -(cos _shown) * AIM_ARROW_LENGTH, 0];

drawLine3D [_from, _centre, _color];
drawIcon3D [ICON_STRIKE, _color, _centre, 0.8, 0.8, 0];
