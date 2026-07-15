#include "script_component.hpp"
/*
 * rtz_fnc_findCountermeasureWeapons
 *
 * Resolves the turret weapon classes on a vehicle that can be fired as
 * countermeasures. Matches two families:
 *   - Aircraft flare/chaff dispensers: CfgAmmo simulation "shotCM".
 *   - Ground-vehicle smoke dischargers: turret weapon class name containing
 *     "smoke" (e.g. vanilla "SmokeLauncher"). Their ammo is NOT classified
 *     shotCM, unlike aircraft countermeasures — confirmed empirically: ZEN's
 *     own Shift+C keybind (zen_common_fnc_deployCountermeasures), which only
 *     checks shotCM, fires correctly on aircraft but never on tanks/IFVs.
 *
 * Parameters:
 *   0: Object — vehicle
 * Returns: Array of unique weapon class names (strings), may be empty
 */

params ["_vehicle"];

private _cfgAmmo = configFile >> "CfgAmmo";
private _cfgMagazines = configFile >> "CfgMagazines";
private _weapons = [];

{
    _x params ["_magazine", "_turretPath", "_count"];
    if (_count > 0) then {
        private _ammo = getText (_cfgMagazines >> _magazine >> "ammo");
        private _isCM = getText (_cfgAmmo >> _ammo >> "simulation") == "shotCM";
        {
            if ((_isCM || { "smoke" in toLower _x }) && { _magazine in (_x call CBA_fnc_compatibleMagazines) }) then {
                _weapons pushBackUnique _x;
            };
        } forEach (_vehicle weaponsTurret _turretPath);
    };
} forEach magazinesAllTurrets _vehicle;

_weapons
