#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a supply vehicle has anything worth aiming at: one friendly vehicle
 * inside GVAR(serviceRadius) that needs a service this truck can perform. Drives
 * the visibility of the ZEN context entry through FUNC(canResupply), and nothing
 * else.
 *
 * This was FUNC(findTargets), which returned the whole serviceable list because the
 * order was a blanket radius sweep and needed it. FUNC(orderResupply) is a picker
 * now — the curator names the target, and FUNC(findServiceTarget) resolves it from
 * the cursor — so its only remaining caller asked for a list of at most one entry
 * purely to test it against []. It is an existence test, so it is written as one:
 * findIf short-circuits natively, which also retired MAX_SERVICE_TARGETS, the cap
 * that existed to stop a sweep of a company motor pool.
 *
 * Whether a target needs anything is one number from FUNC(serviceDeficit), which
 * measures only the services this truck offers and applies the per-service
 * thresholds. It is the last test in the chain deliberately: the ammo term walks
 * every turret's magazines, and this runs every time ZEN rebuilds the context menu.
 *
 * SIDE is checked, judged from the crewed GROUP rather than from `side` on the hull
 * — the same test VEH_SIDE_OK and FUNC(serviceProviders) make. A crewless wreck a
 * curator wants patched up has no meaningful side and must stay serviceable, while
 * a manned hostile one must not: curators here are usually on OPPOSING sides, so a
 * truck cheerfully rearming an enemy tank twenty metres away is a live case rather
 * than a theoretical one.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Supply Capabilities <ARRAY> — [canRepair, canRefuel, canRearm]
 *
 * Return Value:
 * Has Work <BOOL>
 *
 * Example:
 * [_truck, [true, false, false]] call rtz_supply_fnc_hasServiceWork
 *
 * Public: No
 */

params ["_supply", "_capabilities"];

private _supplyGroup = group _supply;
private _checkSide   = !isNull _supplyGroup;
private _supplySide  = side _supplyGroup;

// No `alive` test below: nearEntities defaults to aliveOnly, so the dead are already
// gone by the time this filter sees the list.
(_supply nearEntities [VEHICLE_TYPES, GVAR(serviceRadius)]) findIf {
    _x isNotEqualTo _supply
    && {
        !_checkSide
        || { isNull (group _x) }
        || { _supplySide getFriend (side (group _x)) >= FRIENDLY_THRESHOLD }
    }
    && { ([_x, _capabilities] call FUNC(serviceDeficit)) > 0 }
} != -1
