#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves the cost category of a CfgVehicles class from its inheritance.
 * Anything that is not an infantry unit, vehicle or static weapon is free.
 *
 * Arguments:
 * 0: Class name <STRING>
 *
 * Return Value:
 * Cost category index <NUMBER>
 *
 * Example:
 * ["B_Soldier_F"] call rtz_economy_fnc_categorize
 *
 * Public: No
 */

params ["_class"];

switch (true) do {
    // No officer base class exists, so match on the classname; before infantry
    case (_class isKindOf "CAManBase" && {toLower _class find "officer" != -1}): {INDEX_OFFICER};
    case (_class isKindOf "CAManBase"): {INDEX_INFANTRY}; // excludes animals, which derive from Man directly
    case (_class isKindOf "StaticWeapon"): {INDEX_STATIC};
    case (_class isKindOf "Wheeled_APC_F"): {INDEX_APC}; // before Car, wheeled APCs derive from it
    case (_class isKindOf "Tank"): {INDEX_TRACKED}; // includes tracked APCs
    case (_class isKindOf "Truck_F"): {INDEX_TRUCK}; // before Car, trucks derive from it
    case (_class isKindOf "Car"): {INDEX_CAR};
    case (_class isKindOf "ParachuteBase"): {INDEX_FREE}; // before Helicopter, parachutes derive from it
    case (_class isKindOf "Helicopter"): {INDEX_HELICOPTER};
    case (_class isKindOf "Plane"): {INDEX_PLANE};
    case (_class isKindOf "Ship"): {INDEX_BOAT};
    default {INDEX_FREE};
};
