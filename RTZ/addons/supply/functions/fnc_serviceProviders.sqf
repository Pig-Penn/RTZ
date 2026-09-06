#include "script_component.hpp"
/*
 * Author: Maxim
 * Which of the selected supply vehicles can actually do something for one target:
 * in range, side-compatible, and carrying at least one service that the target
 * needs and that no other truck currently holds.
 *
 * EVERY provider services the target, not just the nearest. A repair truck and a
 * fuel truck selected together and aimed at one damaged, empty tank both work it,
 * each taking the claim slots it can fill — see FUNC(grantedServices). Two fuel
 * trucks aimed at the same tank produce ONE order, because the second finds
 * CLAIM_FUEL taken and has nothing left to grant.
 *
 * THE EXPENSIVE HALF of the picker. FUNC(serviceDeficit) walks every turret's
 * magazines for the ammo term, so this must not run per frame: FUNC(orderResupply)
 * caches the result against the resolved target and refreshes it at PICK_REFRESH.
 * The cheap half — which vehicle is under the cursor at all — is
 * FUNC(findServiceTarget).
 *
 * SIDE is judged from the crewed GROUP on both ends, the same test
 * FUNC(hasServiceWork) and VEH_SIDE_OK make: a crewless hull a curator wants
 * patched up has no meaningful side and stays serviceable, while a manned hostile
 * one must not be. Curators here are usually on OPPOSING sides, so this is a live
 * case rather than a theoretical one.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Supply Vehicles <ARRAY>
 *
 * Return Value:
 * Supply Vehicles That Can Service It <ARRAY of OBJECT>
 *
 * Example:
 * [_tank, _supplies] call rtz_supply_fnc_serviceProviders
 *
 * Public: No
 */

params ["_target", "_supplies"];

if (isNull _target || {!alive _target}) exitWith { [] };

private _radius      = GVAR(serviceRadius);
private _targetGroup = group _target;

_supplies select {
    private _supply = _x;

    // Ordered cheapest first: identity and distance before the group lookups, and
    // both of those before the magazine walk at the bottom.
    _supply isNotEqualTo _target
    && { alive _supply }
    && { _target distance _supply <= _radius }
    && {
        private _supplyGroup = group _supply;

        isNull _supplyGroup
        || { isNull _targetGroup }
        || { side _supplyGroup getFriend (side _targetGroup) >= FRIENDLY_THRESHOLD }
    }
    && {
        private _granted = [_target, _supply, [_supply] call FUNC(supplyCapabilities)] call FUNC(grantedServices);

        true in _granted
        && { ([_target, _granted] call FUNC(serviceDeficit)) > 0 }
    }
}
