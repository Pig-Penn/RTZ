#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves the turret weapon classes on a vehicle that can be fired as
 * countermeasures. Matches two families:
 *   - Aircraft flare/chaff dispensers: CfgAmmo simulation "shotCM".
 *   - Ground-vehicle smoke dischargers: turret weapon class name containing
 *     "smoke" (e.g. vanilla "SmokeLauncher"). Their ammo is NOT classified
 *     shotCM, unlike aircraft countermeasures — confirmed empirically: ZEN's
 *     own Shift+C keybind (zen_common_fnc_deployCountermeasures), which only
 *     checks shotCM, fires correctly on aircraft but never on tanks/IFVs.
 *
 * Only magazines the vehicle currently carries with rounds left count, so an
 * emptied launcher stops offering the order.
 *
 * PERFORMANCE: the context menu condition (FUNC(canDeploySmoke)) runs this for
 * every selected vehicle on every right-click, so the config work is memoised
 * in GVAR(cmWeaponCache), keyed by "magazine|weapon". That verdict — does this
 * weapon fire this magazine, and does that magazine count as a countermeasure
 * — depends only on config, never on the vehicle instance, so it is resolved
 * once per distinct pair per machine and is a single hashmap probe forever
 * after. What remains per call is one magazinesAllTurrets query, which has to
 * stay live: it is what reports the current ammo counts.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Stop at the first weapon found (existence check for the context menu
 *    condition, FUNC(canDeploySmoke)) <BOOL> (default: false)
 *
 * Return Value:
 * Unique weapon class names, may be empty <ARRAY>
 *
 * Example:
 * [_vehicle] call rtz_common_fnc_findCountermeasureWeapons
 *
 * Public: No
 */

params ["_vehicle", ["_firstOnly", false]];

private _cache = GVAR(cmWeaponCache);
private _weapons = [];

{
    // Checked at the TOP with `break`. This was an `exitWith {}` at the bottom of
    // the body: exitWith inside a forEach unwinds only the current ITERATION, so
    // it acted as a continue (docs/Knowledge Base/Gotchas.md §2) and _firstOnly never stopped
    // anything — the existence check walked every magazine of every turret.
    if (_firstOnly && {_weapons isNotEqualTo []}) then { break };

    _x params ["_magazine", "_turretPath", "_count"];

    if (_count > 0) then {
        {
            private _key = _magazine + "|" + _x;
            private _isCM = _cache get _key;

            if (isNil "_isCM") then {
                private _ammo = getText (configFile >> "CfgMagazines" >> _magazine >> "ammo");
                _isCM = (
                    getText (configFile >> "CfgAmmo" >> _ammo >> "simulation") == "shotCM"
                    || {"smoke" in toLower _x}
                ) && {_magazine in (_x call CBA_fnc_compatibleMagazines)};

                _cache set [_key, _isCM];
            };

            if (_isCM) then {
                _weapons pushBackUnique _x;
            };
        } forEach (_vehicle weaponsTurret _turretPath);
    };
} forEach magazinesAllTurrets _vehicle;

_weapons
