#include "script_component.hpp"
/*
 * rtz_fnc_unitMarker
 *
 * Returns [texturePath, colorArray, sideIdx] for the NATO map-marker symbol of a
 * group. sideIdx (0 = west, 1 = east, 2 = other) indexes the client's per-side
 * tuning tables.
 *
 * There is no engine command that yields a unit's military symbol (the MARTA /
 * Military Symbols system assigns them internally but exposes no getter), so the
 * type is classified from isKindOf + config — mirroring ACE3's
 * ace_common_fnc_getMarkerType, with extra UAV / cargo handling — then mapped to
 * the vanilla marker textures in \a3\ui_f\data\map\markers\nato\ . Those paths
 * are used directly rather than via CfgMarkers, because some CfgMarkers entries
 * (e.g. b_naval) resolve to "".
 *
 * Arguments:
 *   0: Unit — pass the GROUP LEADER so the symbol represents the whole group <OBJECT>
 *   1: Headquarters/command element — forces the staff symbol <BOOL> (default false)
 *
 * Return: [texturePath <STRING>, colorArray <ARRAY>, sideIdx <NUMBER>]
 */

params ["_unit", ["_isHQ", false]];

private _unitSide = side _unit;
private _sideIdx = switch (_unitSide) do {
    case west: { 0 };
    case east: { 1 };
    default    { 2 };   // independent / civilian → neutral (square) frame
};
private _prefix = ["b_", "o_", "n_"] select _sideIdx;
private _color = [_unitSide] call EFUNC(common,sideColor);

// Vehicle the unit occupies, or objNull on foot. Parachutes and non-mortar
// static weapons count as on-foot so their crew keeps an infantry symbol.
private _veh = vehicle _unit;
if (_veh == _unit
    || { typeOf _veh == "Steerable_Parachute_F" }
    || { _veh isKindOf "StaticWeapon" && { !(_veh isKindOf "StaticMortar") } }
) then { _veh = objNull };

// A headquarters / command element takes the staff symbol outright, whatever it's in.
private _suffix = if (_isHQ) then { "hq" } else { call {
    // On foot (also static-weapon crew & parachutists, via _veh = objNull above).
    if (isNull _veh) exitWith {
        if !(_unit isKindOf "CAManBase") then { "unknown" } else {
            // Recon: stealthy, high-detection, or diver units (ACE getMarkerType heuristic).
            ["inf", "recon"] select (getNumber (configOf _unit >> "detectSkill") > 20
                || { getNumber (configOf _unit >> "camouflage") < 1 }
                || { getText (configOf _unit >> "textsingular") == "diver" })
        }
    };
    if (((assignedVehicleRole _unit) param [0, ""]) == "cargo") exitWith { "inf" };        // passengers being transported
    if (unitIsUAV _veh)                                         exitWith { "uav" };
    if (getNumber (configOf _veh >> "attendant") == 1)          exitWith { "med" };         // medical vehicle
    if (getNumber (configOf _veh >> "transportRepair") > 0
        || { getNumber (configOf _veh >> "transportFuel") > 0 }
        || { getNumber (configOf _veh >> "transportAmmo")  > 0 }) exitWith { "maint" };     // repair / fuel / ammo support
    if (_veh isKindOf "Plane")                                  exitWith { "plane" };
    if (_veh isKindOf "Air")                                    exitWith { "air" };         // helicopters / rotary
    if (_veh isKindOf "StaticMortar")                           exitWith { "mortar" };
    if (getNumber (configOf _veh >> "artilleryScanner") == 1)   exitWith { "art" };         // self-propelled artillery
    if (_veh isKindOf "Car")                                    exitWith { "motor_inf" };   // wheeled transport (incl. wheeled APCs)
    if (_veh isKindOf "Tank") exitWith {
        // Tracked: troop-carrying IFV/APC → mechanised; otherwise an MBT → armour.
        ["armor", "mech_inf"] select (getNumber (configOf _veh >> "transportSoldier") > 0)
    };
    if (_veh isKindOf "Ship")                                   exitWith { "naval" };
    "unknown"
} };

[format ["\a3\ui_f\data\map\markers\nato\%1%2.paa", _prefix, _suffix], _color, _sideIdx]
