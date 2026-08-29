#include "script_component.hpp"
/*
 * Author: Maxim
 * Everything around a supply vehicle that it can do something for. Position
 * based, not selection based, so a curator resupplies a parked column by picking
 * the truck rather than by box-selecting the column.
 *
 * Whether a target needs anything is one number from FUNC(serviceDeficit), which
 * measures only the services this truck offers and applies the per-service
 * thresholds. It replaced three inline tests here, the last of which walked every
 * turret's magazines.
 *
 * SIDE is checked, which it never used to be — a supply truck would happily repair
 * and rearm an enemy tank parked twenty metres away, and curators here are usually
 * on OPPOSING sides, so that is a live case rather than a theoretical one. Judged
 * from the crewed GROUP rather than from `side` on the hull, the same test
 * VEH_SIDE_OK makes: a crewless wreck a curator wants patched up has no meaningful
 * side and must stay serviceable, while a manned hostile one must not.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Supply Capabilities <ARRAY> — [canRepair, canRefuel, canRearm]
 * 2: Stop After This Many <NUMBER> — 0 for MAX_SERVICE_TARGETS (default: 0)
 *
 * Return Value:
 * Serviceable Targets <ARRAY of OBJECT>
 *
 * Example:
 * [_truck, [true, false, false], 1] call rtz_supply_fnc_findTargets
 *
 * Public: No
 */

params ["_supply", "_capabilities", ["_limit", 0]];

// Never unbounded. A truck parked in a company motor pool would otherwise produce
// a hundred-odd claims, a hundred-odd events and a hundred supply lines from one
// click. Matches SEL_MAX_UNITS, the cap the selection poll already applies.
if (_limit <= 0) then { _limit = MAX_SERVICE_TARGETS };

private _supplyGroup = group _supply;
private _checkSide   = !isNull _supplyGroup;
private _supplySide  = side _supplyGroup;

private _targets = [];

// No `alive` test in here: nearEntities defaults to aliveOnly, so the dead are
// already gone by the time this filter sees the list.
{
    // Checked at the TOP with `break`. This was an `exitWith {}` at the bottom of
    // the body, described as "the plain forEach break idiom" — it is not one:
    // exitWith inside a forEach unwinds only the current ITERATION, making it a
    // continue (docs/Knowledge Base/Gotchas.md §2). _limit was therefore inert, and the context
    // menu condition — which asks for exactly one match — swept the whole parked
    // column, running the ammo walk on every vehicle in radius to answer a boolean.
    if (count _targets >= _limit) then { break };

    if (_x isEqualTo _supply) then { continue };

    private _group = group _x;
    if (_checkSide && { !isNull _group } && { _supplySide getFriend (side _group) < FRIENDLY_THRESHOLD }) then { continue };

    if (([_x, _capabilities] call FUNC(serviceDeficit)) <= 0) then { continue };

    _targets pushBack _x;
} forEach (_supply nearEntities [VEHICLE_TYPES, GVAR(serviceRadius)]);

_targets
