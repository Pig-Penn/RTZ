#include "script_component.hpp"

#include "XEH_PREP.hpp"

// Config scans belong here, not in XEH_preInit. preStart runs ONCE per game
// session and its results survive into every mission; preInit runs at every
// mission start. The muzzle scan below walks every "Put" magazine of every loaded
// mod, which on a heavy modset is by far the most expensive thing this component
// does — paying it per mission was pure waste. Cached in uiNamespace, which is the
// only namespace that outlives a mission (the ACE3 pattern).

// Map every placeable, self-arming mine magazine to its "Put" weapon muzzle.
// Remote detonated charges are excluded since AI cannot trigger them.
private _muzzles = createHashMap;

private _cfgPut = configFile >> "CfgWeapons" >> "Put";
private _cfgMagazines = configFile >> "CfgMagazines";
private _cfgAmmo = configFile >> "CfgAmmo";

{
    private _muzzle = _x;

    {
        private _trigger = getText (_cfgAmmo >> getText (_cfgMagazines >> _x >> "ammo") >> "mineTrigger");

        if (_trigger isNotEqualTo "" && {_trigger isNotEqualTo "RemoteTrigger"}) then {
            _muzzles set [toLowerANSI _x, _muzzle];
        };
    } forEach getArray (_cfgPut >> _muzzle >> "magazines");
} forEach getArray (_cfgPut >> "muzzles");

SETUVAR(GVAR(muzzles),_muzzles);

// Vanilla minefield marker icon, with a fallback in case the marker class is missing
private _icon = getText (configFile >> "CfgMarkers" >> "Minefield" >> "icon");

if (_icon isEqualTo "") then {
    _icon = ICON_FALLBACK;
};

SETUVAR(GVAR(icon),_icon);
