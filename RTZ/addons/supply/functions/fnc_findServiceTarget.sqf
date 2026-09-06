#include "script_component.hpp"
/*
 * Author: Maxim
 * The vehicle the curator is aiming at: the one nearest the cursor within
 * PICK_SNAP_RADIUS that is also inside GVAR(serviceRadius) of at least one of the
 * selected supply vehicles. Mirror of EFUNC(attack,findTarget), which resolves the
 * destroy order's target the same way.
 *
 * DISTANCE TESTS ONLY. This runs every frame for as long as the picker is open, so
 * it must not touch FUNC(serviceDeficit) — whose ammo term walks every turret's
 * magazines. Whether the vehicle found here needs anything is FUNC(serviceProviders)'
 * question, and that one is cached (see PICK_REFRESH).
 *
 * The out-of-radius test lives here rather than in the caller because a vehicle
 * outside every ring is not "a target that cannot be serviced" — it is not a target
 * at all, and the cursor says so. The ring already draws that boundary, which is
 * why it does not earn its own cursor wording.
 *
 * The selected supply vehicles are excluded from being targets themselves: they are
 * the ones giving, and a picker in which the givers are also candidates reads as an
 * accident. A truck that needs topping up is still serviceable — select only the
 * giver and click the receiver.
 *
 * Arguments:
 * 0: Position ASL <ARRAY>
 * 1: Supply Vehicles <ARRAY>
 *
 * Return Value:
 * Target, objNull if there is none <OBJECT>
 *
 * Example:
 * [_position, _supplies] call rtz_supply_fnc_findServiceTarget
 *
 * Public: No
 */

params ["_position", "_supplies"];

private _pos    = ASLToAGL _position;
private _radius = GVAR(serviceRadius);

private _target      = objNull;
private _minDistance = 1e10;

// No `alive` test below: nearEntities defaults to aliveOnly, so the dead are gone
// before this filter sees them. VEHICLE_TYPES is the same list FUNC(hasServiceWork)
// sweeps, so the picker and the menu condition agree on what a serviceable thing is.
{
    private _candidate = _x;

    if (_candidate in _supplies) then { continue };

    // Inside SOME selected truck's ring. Cheapest ordering: this drops everything
    // parked beyond the boundary before the distance-to-cursor comparison runs.
    if ((_supplies findIf {_candidate distance _x <= _radius}) == -1) then { continue };

    private _distance = _candidate distance2D _pos;

    if (_distance < _minDistance) then {
        _minDistance = _distance;
        _target = _candidate;
    };
} forEach (_pos nearEntities [VEHICLE_TYPES, PICK_SNAP_RADIUS]);

_target
