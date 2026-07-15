#include "script_component.hpp"
/*
 * rtz_fnc_buildDisassembleMap
 *
 * Builds (once) and returns the reverse of the vanilla assemble config: a map
 * from a static-weapon class to the backpacks it disassembles back into. This is
 * the exact same data FUNC(findAssembleSet) reads forward (a weapon bag's
 * assembleInfo: primary = 1, assembleTo = <static>, base[] = <support bags>), so
 * any weapon RTZ can assemble it can also disassemble.
 *
 * The scan walks every CfgVehicles class ONCE and caches the result in
 * GVAR(disassembleMap); every later call is a HashMap hand-back with no config
 * work. Only machines that open the Zeus context menu (hasInterface) ever build
 * it, and only on the first right-click of a static weapon.
 *
 * Returns: HashMap  toLower(staticClass) -> [_weaponBag, _baseBags]
 *          _weaponBag is the gunner's bag; _baseBags the support/tripod bag list
 *          (empty for single-bag weapons such as the Mk6 mortar).
 */

if (!isNil {GVAR(disassembleMap)}) exitWith { GVAR(disassembleMap) };

private _map = createHashMap;
{
    private _ai = _x >> "assembleInfo";
    if (getNumber (_ai >> "primary") == 1) then {
        private _to = getText (_ai >> "assembleTo");
        if (_to != "" && {isClass (configFile >> "CfgVehicles" >> _to)}) then {
            _map set [toLower _to, [configName _x, [configName _x] call FUNC(assembleBaseBags)]];
        };
    };
} forEach ("isClass (_x >> 'assembleInfo')" configClasses (configFile >> "CfgVehicles"));

GVAR(disassembleMap) = _map;
_map
