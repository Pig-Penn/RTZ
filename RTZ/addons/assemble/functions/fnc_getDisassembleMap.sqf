#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds (once) and returns the reverse of the vanilla assemble config: a map from a
 * static weapon class to the backpacks it disassembles back into. This is the same
 * data FUNC(findAssembleSet) reads forward (a weapon bag's assembleInfo: primary = 1,
 * assembleTo = <static>, base[] = <support bags>), so any weapon RTZ can assemble it
 * can also disassemble.
 *
 * The scan walks every CfgVehicles class once and caches the result in
 * GVAR(disassembleMap), every later call is a HashMap hand-back with no config work.
 * Only machines that open the Zeus context menu ever build it, and only on the first
 * right-click of a static weapon.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Disassemble Map <HASHMAP> - toLower(static class) -> [weapon bag <STRING>,
 * support bags <ARRAY of STRING>]. The support bag list is empty for single bag
 * weapons such as the Mk6 mortar.
 *
 * Example:
 * call rtz_assemble_fnc_getDisassembleMap
 *
 * Public: No
 */

if (!isNil {GVAR(disassembleMap)}) exitWith {GVAR(disassembleMap)};

private _map = createHashMap;

{
    private _assembleInfo = _x >> "assembleInfo";

    if (getNumber (_assembleInfo >> "primary") == 1) then {
        private _staticClass = getText (_assembleInfo >> "assembleTo");

        if (_staticClass != "" && {isClass (configFile >> "CfgVehicles" >> _staticClass)}) then {
            _map set [toLower _staticClass, [configName _x, [configName _x] call FUNC(getBaseBags)]];
        };
    };
} forEach ("isClass (_x >> 'assembleInfo')" configClasses (configFile >> "CfgVehicles"));

GVAR(disassembleMap) = _map;

_map
