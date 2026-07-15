#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

GVAR(mines) = [];
GVAR(draw) = -1;
GVAR(pfh) = -1;

// Map every placeable, self-arming mine magazine to its "Put" weapon muzzle,
// remote detonated charges are excluded since AI cannot trigger them
GVAR(muzzles) = createHashMap;

private _cfgPut = configFile >> "CfgWeapons" >> "Put";
private _cfgMagazines = configFile >> "CfgMagazines";
private _cfgAmmo = configFile >> "CfgAmmo";

{
    private _muzzle = _x;

    {
        private _trigger = getText (_cfgAmmo >> getText (_cfgMagazines >> _x >> "ammo") >> "mineTrigger");

        if (_trigger isNotEqualTo "" && {_trigger isNotEqualTo "RemoteTrigger"}) then {
            GVAR(muzzles) set [toLowerANSI _x, _muzzle];
        };
    } forEach getArray (_cfgPut >> _muzzle >> "magazines");
} forEach getArray (_cfgPut >> "muzzles");

// Vanilla minefield marker icon, with a fallback in case the marker class is missing
GVAR(icon) = getText (configFile >> "CfgMarkers" >> "Minefield" >> "icon");

if (GVAR(icon) isEqualTo "") then {
    GVAR(icon) = ICON_FALLBACK;
};

#include "initSettings.inc.sqf"

ADDON = true;
