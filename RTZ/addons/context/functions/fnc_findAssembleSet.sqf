#include "script_component.hpp"
/*
 * rtz_fnc_findAssembleSet
 *
 * Inspects one group for a disassembled static weapon that its members are
 * carrying as backpacks, and returns the pieces needed to reassemble it.
 *
 * Vanilla static weapons split into two backpacks. The "weapon" bag (carried by
 * the gunner) has an assembleInfo with primary = 1, an assembleTo naming the
 * static vehicle to build, and a base[] list of the support/tripod bags that
 * must also be present. The "tripod" bag (carried by the assistant) is one of
 * those base[] entries. Single-bag weapons (e.g. the Mk6 mortar) have an empty
 * base and need no assistant. Some modded configs invert the reference — the
 * support bag's base[] names the weapon bag — so the assistant match checks both
 * directions (same tolerance as LAMBS' deploy).
 *
 * Config reference: CfgVehicles >> <bag> >> assembleInfo (BI wiki, CfgVehicles
 * Config Reference — assembleTo / primary / base[] / dissasembleTo[]).
 *
 * Parameters:
 *   0: Group — the group to inspect
 * Returns: [_gunner, _staticClass, _assistant] if a full set is carried,
 *          otherwise []. _assistant is objNull when no second bag is required.
 */

params ["_grp"];
if (isNull _grp) exitWith { [] };

private _units = units _grp;

// Find the member carrying the primary (weapon) bag. Carriers must be ON FOOT:
// assembling from inside a vehicle would teleport the gunner out onto a static
// spawned next to (or inside) the vehicle.
private _gunnerIdx = _units findIf {
    isNull objectParent _x && {backpack _x != ""} && {
        private _ai = configFile >> "CfgVehicles" >> backpack _x >> "assembleInfo";
        isClass _ai && {getNumber (_ai >> "primary") == 1} && {
            private _to = getText (_ai >> "assembleTo");
            _to != "" && {isClass (configFile >> "CfgVehicles" >> _to)}
        }
    }
};
if (_gunnerIdx == -1) exitWith { [] };

private _gunner = _units select _gunnerIdx;
private _gunnerBag = backpack _gunner;
private _staticClass = getText (configFile >> "CfgVehicles" >> _gunnerBag >> "assembleInfo" >> "assembleTo");
private _reqBags = [_gunnerBag] call FUNC(assembleBaseBags);

// Single-bag weapon — gunner alone can assemble.
if (_reqBags isEqualTo []) exitWith { [_gunner, _staticClass, objNull] };

// Find an assistant carrying one of the required support bags (also on foot).
private _asstIdx = _units findIf {
    _x != _gunner && {isNull objectParent _x} && {backpack _x != ""} && {
        (backpack _x) in _reqBags || {_gunnerBag in ([backpack _x] call FUNC(assembleBaseBags))}
    }
};
if (_asstIdx == -1) exitWith { [] };

[_gunner, _staticClass, _units select _asstIdx]
