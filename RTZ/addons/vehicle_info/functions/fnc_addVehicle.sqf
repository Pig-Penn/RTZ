#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts tracking a vehicle and caches its static draw data.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle] call rtz_vehicle_info_fnc_addVehicle
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle || {_vehicle getVariable [QGVAR(tracked), false]}) exitWith {};

// Cache values that are static or expensive to compute every frame
private _height = ((boundingBoxReal _vehicle) select 1 select 2) + HEIGHT_OFFSET;
private _name = getText (configOf _vehicle >> "displayName");
private _totalSeats = count fullCrew [_vehicle, "", true];
private _hasFuel = getNumber (configOf _vehicle >> "fuelCapacity") > 0;

// First armed turret, drivers first so driver-controlled weapons win ([] if unarmed)
private _turrets = [[-1]] + allTurrets [_vehicle, false];
private _turretIndex = _turrets findIf {(_vehicle weaponsTurret _x) isNotEqualTo []};
private _turretPath = if (_turretIndex == -1) then {[]} else {_turrets select _turretIndex};

// Group the critical hitpoint indices by damage tag, damage is read per frame via getHitIndex
private _engine = [];
private _fuelTank = [];
private _gun = [];
private _tracks = [];
private _wheels = [];

{
    private _hitPoint = toLowerANSI _x;

    switch (true) do {
        case ("engine" in _hitPoint): {_engine pushBack _forEachIndex};
        case ("fuel" in _hitPoint): {_fuelTank pushBack _forEachIndex};
        case ("gun" in _hitPoint);
        case ("turret" in _hitPoint): {_gun pushBack _forEachIndex};
        case ("track" in _hitPoint): {_tracks pushBack _forEachIndex};
        case ("wheel" in _hitPoint): {_wheels pushBack _forEachIndex};
    };
} forEach ((getAllHitPointsDamage _vehicle) param [0, []]);

private _hitPointGroups = [
    [LLSTRING(TagEngine), _engine],
    [LLSTRING(TagFuel), _fuelTank],
    [LLSTRING(TagGun), _gun],
    [LLSTRING(TagTracks), _tracks],
    [LLSTRING(TagWheels), _wheels]
] select {(_x select 1) isNotEqualTo []};

_vehicle setVariable [QGVAR(tracked), true];
_vehicle setVariable [QGVAR(data), [_height, _name, _totalSeats, _hasFuel, _turretPath, _hitPointGroups]];

GVAR(vehicles) pushBack _vehicle;

call FUNC(start);
