#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens whatever door a puppet is about to walk into. Runs on the record's
 * half-second stagger, and only for a unit standing close enough to a building
 * for the question to arise.
 *
 * A puppet has no AI movement left, and opening a door is something the AI does
 * on its way through one — so without this a scripted infantry path drawn into a
 * compound ends against the first closed door, with the man walking on the spot.
 * Wargame carries the same helper for the same reason.
 *
 * What is different here is where the work happens. Which selections of a
 * building are doors is a property of the CLASS, not of the building, so it is
 * asked once per class and remembered — including the model-space position of
 * each door, so the only per-sweep cost is a modelToWorld and a distance per
 * door. Wargame runs `selectionNames` over the nearest building every half
 * second, per unit, and re-derives every door position each time.
 *
 * Doors already open are skipped rather than re-animated: `animate` on a source
 * already at its target phase is not free, and re-issuing it every half second
 * for as long as a squad files through a doorway is a door that never settles.
 *
 * Arguments:
 * 0: Man <OBJECT>
 *
 * Return Value:
 * A door was opened <BOOL>
 *
 * Example:
 * [_unit] call rtz_path_fnc_openDoors
 *
 * Public: No
 */

params ["_unit"];

private _building = nearestBuilding _unit;
if (isNull _building) exitWith {false};
if (_unit distance _building > DOOR_BUILDING_DIST) exitWith {false};

// Terrain-placed objects can answer "" to typeOf, which would collapse every
// such building onto one cache entry and open the wrong doors. The model name is
// what actually identifies the geometry, and it is unique where typeOf is not.
private _key = typeOf _building;
if (_key isEqualTo "") then {_key = (getModelInfo _building) select 0};

private _doors = GVAR(doorCache) get _key;

if (isNil "_doors") then {
    _doors = [];

    {
        // "handle" is excluded because a door handle is a selection of the door
        // and matching it would animate a source that does not exist. Wargame
        // filters the same two substrings.
        if ((_x find "door") != -1 && {(_x find "handle") == -1}) then {
            _doors pushBack [_x, _building selectionPosition [_x, "ViewGeometry", "AveragePoint"]];
        };
    } forEach (selectionNames _building);

    // Bounded, because a HashMap that only ever grows is a leak on a multi-hour
    // operation (CLAUDE.md). A mission's building classes are a fixed set, so
    // reaching the cap means something unexpected is generating keys and
    // starting over costs one sweep per class still in use.
    if (count GVAR(doorCache) >= DOOR_CACHE_MAX) then {
        GVAR(doorCache) = createHashMap;
    };

    GVAR(doorCache) set [_key, _doors];
};

if (_doors isEqualTo []) exitWith {false};

private _opened = false;

{
    _x params ["_name", "_modelPos"];

    if (_unit distance (_building modelToWorld _modelPos) > DOOR_REACH) then {continue};

    // Already open, or on its way. The phase is the authoritative answer and it
    // is one engine read, against a set of `animate` calls that are not.
    if ((_building animationPhase (_name + "_rot")) > 0.5) then {continue};

    // Three sources because building doors are modelled three ways — a hinged
    // leaf rotates, a double door slides in two halves. Animating a source a
    // model does not have is a no-op, so asking for all three is cheaper than
    // working out which kind this door is.
    _building animate [_name + "_rot", 1];
    _building animate [_name + "A_move", 1];
    _building animate [_name + "B_move", 1];

    _opened = true;
} forEach _doors;

_opened
