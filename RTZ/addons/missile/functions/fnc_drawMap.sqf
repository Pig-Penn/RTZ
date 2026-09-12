#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the same incoming-projectile markers on the Zeus map. Attached only while
 * GVAR(markers) is on (FUNC(start)), so there is no setting test per frame.
 *
 * The map pass exists because rtz_core skips RENDER_WORLD renderers while the map
 * covers the 3D view — without it, opening the map mid-flight would lose the
 * warning entirely.
 *
 * Arguments:
 * 0: Zeus Map Control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrlMap] call rtz_missile_fnc_drawMap
 *
 * Public: No
 */

params ["_ctrlMap"];

private _tracked = GVAR(tracked);
if (_tracked isEqualTo []) exitWith {};

[CBA_missionTime] call FUNC(pruneTracked);

private _drawLine = GVAR(drawLine);

// REC_COLOR is already [r, g, b, 1] and is a shared read-only reference — see the
// note in FUNC(draw3D). Neither `ctrl drawIcon` nor `ctrl drawLine` writes back into
// a colour argument, so it is passed straight through rather than rebuilt per record
// per frame.
{
    _x params ["_missile", "_target", "_color", "", "", "_kind", "_fallback"];

    // Three cases, as in FUNC(draw3D): the projectile, else the threatened unit,
    // else the fallback anchor — which for a grenade is the aim point, and is the
    // ONLY case it ever takes, because its marker is static and both object slots
    // are objNull for its whole life.
    private _anchor = if (!isNull _missile) then {
        getPosASLVisual _missile
    } else {
        if (isNull _target) then {_fallback} else {getPosASLVisual _target}
    };

    if (count _anchor < 3) then {continue};

    // Never for a grenade: there is no target object to draw a line to.
    if (_drawLine && {!isNull _missile} && {!isNull _target}) then {
        private _targetPos = getPosASLVisual _target;

        if (count _targetPos > 2) then {
            _ctrlMap drawLine [_anchor, _targetPos, _color, LINE_WIDTH_MAP];
        };
    };

    // Branches rather than `[A, B] select _kind`, which would allocate per record
    // per frame.
    private _icon = ICON_MISSILE;
    private _size = ICON_SIZE_MAP;

    if (_kind == KIND_GRENADE) then {
        _icon = ICON_GRENADE;
        _size = ICON_GRENADE_SIZE_MAP;
    };

    _ctrlMap drawIcon [_icon, _color, _anchor, _size, _size, 0];
} forEach _tracked;
