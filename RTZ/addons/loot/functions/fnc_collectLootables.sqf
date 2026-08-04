#include "script_component.hpp"
/*
 * Author: Maxim
 * Finds everything worth walking to around a unit: dead bodies still carrying gear,
 * dropped-weapon holders, supply crates, and unmanned vehicles with cargo.
 *
 * Two narrow lookups instead of one broad one. `nearSupplies` is the engine's own
 * "containers holding something" query and answers for crates, weapon holders and
 * vehicles in a single spatial pass. That replaces a nearestObjects sweep over
 * ["ThingX", "WeaponHolder", "WeaponHolderSimulated", "AllVehicles"] which paid for
 * three overlapping type filters and then dragged in every LIVING soldier in radius
 * purely to throw them away again. nearSupplies still returns live units, so they are
 * filtered here too - ACE's CSW reloading does the same with the same call.
 *
 * Corpses come from a SECOND, deliberately narrow spatial query over CAManBase alone.
 * This used to walk `allDeadMen` and filter by distance, on the reasoning that the
 * engine maintains that array for free. It does - but the array is every corpse in the
 * mission and it only ever grows, while this function is reached from the context-menu
 * CONDITION (FUNC(canLoot)), which runs on every right-click, once PER GROUP, and the
 * memo below is keyed on position so no two groups share an entry. Four hours in, an
 * eight-group selection meant eight walks over a four-figure array on the frame the
 * menu opened. A CAManBase query drags in the living soldiers the note above warns
 * about, but that is a handful inside the radius against an unbounded list outside it,
 * and `!alive` is the cheapest test in the predicate. Unsorted - nothing here reads the
 * order, and sorting is the expensive half of nearestObjects.
 *
 * The two lists can overlap (whether nearSupplies counts a corpse as a container is
 * not worth depending on either way), so the merge is pushBackUnique.
 *
 * Results are MEMOIZED for SCAN_CACHE_TTL. The context menu condition re-scans on
 * every right-click and the server re-scans when the order actually lands, so the
 * same sweep was being paid for repeatedly; at half a second a curator cannot outrun
 * the memo and nothing can go stale enough to matter. Client and server keep their
 * own caches, which is right - each is memoizing its own repeats.
 *
 * The source is an OBJECT rather than a position because nearSupplies is a unary
 * command on one, and every caller has the group leader to hand anyway.
 *
 * This is the CHEAP filter - "is there anything in this thing at all". Whether a
 * PARTICULAR unit can improve from a particular target is FUNC(lootPlan)'s question,
 * and a far more expensive one. Keeping the two apart is what lets the context menu
 * stay responsive while the dispatcher still refuses to march anyone to a target he
 * has no use for.
 *
 * Not lootable: living men, manned or destroyed vehicles, bodies inside vehicles
 * (AI can't path to them), curator-hidden objects, and anything already emptied.
 *
 * Arguments:
 * 0: Source <OBJECT> - center of the search, normally a group leader
 * 1: Radius <NUMBER> - search radius in meters (default: 50)
 *
 * Return Value:
 * Lootable objects, unordered <ARRAY of OBJECT>
 *
 * Example:
 * private _lootables = [leader _group, 50] call rtz_loot_fnc_collectLootables;
 *
 * Public: No
 */

params ["_source", ["_radius", 50]];

if (isNull _source) exitWith {[]};

private _position = getPosATL _source;

// Rounded to the meter: a stationary squad re-uses its own entry across repeated
// right-clicks, a moving one correctly misses. `str` over a small array is one
// command and gives a stable key without a format pass
private _key = str [round (_position select 0), round (_position select 1), _radius];
private _cached = GVAR(scanCache) get _key;

// One test at function scope rather than an exitWith nested inside the isNil check -
// exitWith only ever leaves the scope it is written in, so a nested one would fall
// straight through to the scan below and the memo would never actually be returned
if (!isNil "_cached" && {CBA_missionTime - (_cached select 0) < SCAN_CACHE_TTL}) exitWith {
    _cached select 1
};

// Everything in the map is stale by definition once it is this big, so a wholesale
// reset is cheaper and simpler than evicting entry by entry
if (count GVAR(scanCache) > SCAN_CACHE_MAX) then {
    GVAR(scanCache) = createHashMap;
};

private _lootables = [];

{
    private _object = _x;

    // The cargo reads come last and cheapest-first: `weaponCargo` and friends return
    // the flat class list, where the `get`-prefixed variants build a second array of
    // counts nobody here looks at
    private _lootable = !isObjectHidden _object
        && {alive _object}
        && {!(_object isKindOf "CAManBase")}
        && {(crew _object) findIf {alive _x} == -1}
        && {
            weaponCargo _object isNotEqualTo []
            || {magazineCargo _object isNotEqualTo []}
            || {itemCargo _object isNotEqualTo []}
            || {backpackCargo _object isNotEqualTo []}
        };

    if (_lootable) then {
        _lootables pushBackUnique _object;
    };
} forEach (_source nearSupplies _radius);

{
    private _body = _x;

    // !alive leads: it is the cheapest test and rejects the living men the
    // CAManBase query necessarily includes. distance2D is kept behind it because
    // nearestObjects culls on a sphere, so it would otherwise admit a body on a
    // rooftop that is outside the flat radius the rest of the errand assumes.
    private _lootable = !alive _body
        && {_body distance2D _position < _radius}
        && {!isObjectHidden _body}
        && {isNull objectParent _body}
        && {
            weapons _body isNotEqualTo []
            || {magazines _body isNotEqualTo []}
            || {items _body isNotEqualTo []}
            || {backpack _body isNotEqualTo ""}
            || {vest _body isNotEqualTo ""}
            || {headgear _body isNotEqualTo ""}
        };

    if (_lootable) then {
        _lootables pushBackUnique _body;
    };
} forEach nearestObjects [_position, ["CAManBase"], _radius, false];

GVAR(scanCache) set [_key, [CBA_missionTime, _lootables]];

_lootables
