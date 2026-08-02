#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the vehicles parked around a supply vehicle that still need something
 * it can give. The lookup is by position rather than from the curator selection,
 * so the serviced vehicles do not have to be Zeus editable.
 *
 * The capabilities are passed in rather than looked up again, and _limit caps the
 * result: the context menu condition only needs to know whether there is ANY work
 * at all, and asking for one match turns a full sweep of a parked column into a
 * walk that stops at the first hit.
 *
 * The needs-test is ordered cheapest first — the ammo check walks every turret's
 * magazines, so it only runs for vehicles already found fully repaired and
 * fuelled, and only when this supply vehicle carries ammo in the first place.
 *
 * Range is measured the same way the mid-service drop test in FUNC(serviceTick)
 * measures it (3D, hull to hull). It used to acquire in 3D and drop in 2D, which
 * left a band where a vehicle could be too far to pick up yet too close to let go.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Capabilities, as returned by FUNC(supplyCapabilities) <ARRAY>
 * 2: Stop After This Many Matches, 0 For All <NUMBER> (default: 0)
 *
 * Return Value:
 * Serviceable Vehicles <ARRAY>
 *
 * Example:
 * [_truck, [ARR_3(true,true,false)]] call rtz_supply_fnc_findTargets
 *
 * Public: No
 */

params ["_supply", "_capabilities", ["_limit", 0]];

_capabilities params ["_canRepair", "_canRefuel", "_canRearm"];

private _targets = [];

// No `alive` test in here: nearEntities defaults to aliveOnly, so the dead are
// already gone by the time this filter sees the list.
{
    // Checked at the TOP with `break`. This was an `exitWith {}` at the bottom of
    // the body, described as "the plain forEach break idiom" — it is not one:
    // exitWith inside a forEach unwinds only the current ITERATION, making it a
    // continue (docs/Gotchas.md §2). _limit was therefore inert, and the context
    // menu condition — which asks for exactly one match — swept the whole parked
    // column, running FUNC(needsAmmo) (a walk over every turret's magazines) on
    // every vehicle in radius to answer a boolean.
    if (_limit > 0 && {count _targets >= _limit}) then { break };

    if (_x isEqualTo _supply) then { continue };

    if !(
        (_canRepair && {damage _x > REPAIR_THRESHOLD})
        || {_canRefuel && {fuel _x < FUEL_THRESHOLD}}
        || {_canRearm && {[_x] call FUNC(needsAmmo)}}
    ) then { continue };

    _targets pushBack _x;
} forEach (_supply nearEntities [VEHICLE_TYPES, GVAR(serviceRadius)]);

_targets
