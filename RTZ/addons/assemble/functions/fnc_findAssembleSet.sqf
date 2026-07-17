#include "script_component.hpp"
/*
 * Author: Maxim
 * Inspects one group for a disassembled static weapon its members carry as
 * backpacks and returns the pieces needed to reassemble it.
 *
 * Vanilla static weapons split into two backpacks. The weapon bag (carried by the
 * gunner) has an assembleInfo with primary = 1, an assembleTo naming the static
 * vehicle to build, and a base[] list of the support/tripod bags that must also be
 * present. The tripod bag (carried by the assistant) is one of those base[] entries.
 * Single bag weapons such as the Mk6 mortar have an empty base and need no
 * assistant. Some modded configs invert the reference, the support bag's base[]
 * naming the weapon bag, so the assistant match checks both directions (the same
 * tolerance as LAMBS' deploy).
 *
 * Carriers must be on foot: assembling from inside a vehicle would teleport the
 * gunner out onto a static spawned next to (or inside) the vehicle.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * Assemble Set <ARRAY> - [gunner <OBJECT>, static class <STRING>, assistant
 * <OBJECT>], or [] when the group carries no complete set. The assistant is objNull
 * when no second bag is required.
 *
 * Example:
 * [group _unit] call rtz_assemble_fnc_findAssembleSet
 *
 * Public: No
 */

params ["_group"];

if (isNull _group) exitWith {[]};

private _units = units _group;

// The member carrying the primary (weapon) bag
private _gunnerIndex = _units findIf {
    isNull objectParent _x && {backpack _x != ""} && {
        private _assembleInfo = configFile >> "CfgVehicles" >> backpack _x >> "assembleInfo";
        isClass _assembleInfo && {getNumber (_assembleInfo >> "primary") == 1} && {
            private _staticClass = getText (_assembleInfo >> "assembleTo");
            _staticClass != "" && {isClass (configFile >> "CfgVehicles" >> _staticClass)}
        }
    }
};
if (_gunnerIndex == -1) exitWith {[]};

private _gunner = _units select _gunnerIndex;
private _gunnerBag = backpack _gunner;
private _staticClass = getText (configFile >> "CfgVehicles" >> _gunnerBag >> "assembleInfo" >> "assembleTo");
private _requiredBags = [_gunnerBag] call FUNC(getBaseBags);

// Single bag weapon, the gunner assembles alone
if (_requiredBags isEqualTo []) exitWith {[_gunner, _staticClass, objNull]};

// An assistant carrying one of the required support bags, also on foot
private _assistantIndex = _units findIf {
    _x != _gunner && {isNull objectParent _x} && {backpack _x != ""} && {
        (backpack _x) in _requiredBags || {_gunnerBag in ([backpack _x] call FUNC(getBaseBags))}
    }
};
if (_assistantIndex == -1) exitWith {[]};

[_gunner, _staticClass, _units select _assistantIndex]
