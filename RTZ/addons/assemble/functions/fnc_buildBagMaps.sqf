#include "script_component.hpp"
/*
 * Author: Maxim
 * Reads the vanilla assemble config once and caches it in both directions, so
 * nothing on the context-menu path ever touches configFile again.
 *
 * Vanilla static weapons split into backpacks. The weapon bag has an assembleInfo
 * with primary = 1, an assembleTo naming the vehicle to build, and a base[] list of
 * the support/tripod bags that must also be present. The tripod bag is one of those
 * base[] entries. Single bag weapons such as the Mk6 mortar have an empty base and
 * need no assistant. base is normally base[] = {..} but some configs use a bare
 * string, so both forms are normalized here - once, at load - rather than at every
 * lookup. Config reference: CfgVehicles >> <bag> >> assembleInfo (BI wiki,
 * CfgVehicles Config Reference - assembleTo / primary / base[]).
 *
 * Two maps come out of the single CfgVehicles pass:
 *   GVAR(bagInfo)         forward:  a carried bag -> what it builds and what it needs
 *   GVAR(disassembleMap)  reverse:  a built weapon -> the bags it packs back into
 * so any weapon RTZ can assemble it can also disassemble. bagInfo deliberately holds
 * EVERY bag with an assembleInfo, not just the primaries: FUNC(findAssembleSets)
 * tolerates modded configs that invert the reference (the support bag's base[]
 * naming the weapon bag) and needs the support bag's own base[] to spot that.
 *
 * Called from XEH_preInit on machines with an interface, which seeds both maps empty
 * first. Only the ordering curator's client reads them (the context-menu condition
 * and the two collectors), so a dedicated server or headless client skips the scan
 * entirely - the errand handlers that run there never consult them.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_assemble_fnc_buildBagMaps
 *
 * Public: No
 */

private _bagInfo = createHashMap;
private _disassembleMap = createHashMap;

{
    private _assembleInfo = _x >> "assembleInfo";
    private _bag = configName _x;

    // Normalize base[] here so every later lookup is a plain array read
    private _cfgBase = _assembleInfo >> "base";
    private _baseBags = (if (isText _cfgBase) then {[getText _cfgBase]} else {getArray _cfgBase}) - [""];

    private _primary = getNumber (_assembleInfo >> "primary") == 1;
    private _assembleTo = getText (_assembleInfo >> "assembleTo");

    // A primary bag that names no real vehicle can't be built, so it stays out of
    // the reverse map - but it is still kept in bagInfo, where only its base[]
    // matters (a support bag pointing back at it)
    if (!_primary || {_assembleTo == ""} || {!isClass (configFile >> "CfgVehicles" >> _assembleTo)}) then {
        _assembleTo = "";
    } else {
        _disassembleMap set [toLowerANSI _assembleTo, [_bag, _baseBags]];
    };

    _bagInfo set [toLowerANSI _bag, [_assembleTo, _baseBags]];
} forEach ("isClass (_x >> 'assembleInfo')" configClasses (configFile >> "CfgVehicles"));

GVAR(bagInfo) = _bagInfo;
GVAR(disassembleMap) = _disassembleMap;
