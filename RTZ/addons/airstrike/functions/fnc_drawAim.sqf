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

GVAR(aiming) params ["_objects", "_args", "_aim", "_bearing", "", "", "_valid", "_validAt"];

// Nothing pressed yet — there is no target to draw a ring around.
if (_aim isEqualTo []) exitWith {};

_args params ["_vehicle", "_weapon", "_turretPath"];

// Tinted invalid the moment the order would be refused, so the curator sees a dead
// gesture before he releases rather than a message after. Cached in GVAR(aiming)
// and refreshed on AIM_VALID_INTERVAL rather than every frame the ring is up —
// this runs the same FUNC(strikeAircraft) selection walk and FUNC(strikeWeapons)
// pylon/magazine enumeration FUNC(orderStrike) itself pays for at commit time.
//
// Matched on BOTH weapon and turret path through FUNC(strikeWeapons), never a
// bare `_vehicle ammo _weapon` read: `ammo` takes no turret path, so twin
// symmetric pylons sharing one weapon classname across two turret paths would
// borrow each other's counts, and it reports only the loaded magazine rather
// than the weapon's total. Same defect, same fix FUNC(orderStrike) already
// documents and applies — mirrored here rather than reimplemented.
private _now = _ctx select CTX_NOW;

if (_now >= _validAt) then {
    _valid = alive _vehicle
        && {!isNull ([_objects] call FUNC(strikeAircraft))}
        && {([_vehicle] call FUNC(strikeWeapons)) findIf {
            (_x select 0 isEqualTo _weapon) && {(_x select 1) isEqualTo _turretPath}
        } != -1};

    GVAR(aiming) set [6, _valid];
    GVAR(aiming) set [7, _now + AIM_VALID_INTERVAL];
};

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
