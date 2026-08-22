#include "script_component.hpp"
/*
 * Author: Maxim
 * Lists the weapons on one aircraft usable for a ground strike, each with the
 * ordnance type that decides its release range and its live ammo count.
 *
 * Split in two on purpose. WHICH weapons a vehicle carries and WHAT they are is
 * config-derived and identical for every aircraft of that class, so it is memoised
 * in GVAR(weaponCache) and paid for once per class per mission. How much ammo is
 * left is not, and is read fresh on every call.
 *
 * A pylon loadout changed at runtime with setPylonLoadout is the one case the class
 * cache gets wrong. It is still cached against the class, because the alternative is
 * a full config walk per aircraft on every context-menu open — paid on the curator's
 * client while he waits for the menu to appear — and the failure mode is a wrong
 * weapon NAME rather than a wrong ammo count or a strike that misbehaves.
 *
 * Arguments:
 * 0: Aircraft <OBJECT>
 *
 * Return Value:
 * Usable weapons as [weapon, turretPath, type, ammo] <ARRAY>
 *
 * Example:
 * private _weapons = [cursorObject] call rtz_airstrike_fnc_strikeWeapons
 *
 * Public: No
 */

params ["_vehicle"];

private _class = typeOf _vehicle;
private _classified = GVAR(weaponCache) get _class;

if (isNil "_classified") then {
    _classified = [];

    // [-1] is the PILOT's own weapons and is NOT part of allTurrets — which is
    // where a plane's cannon and pylons almost always live. Omitting it is the
    // difference between this returning a jet's whole loadout and returning
    // nothing at all.
    {
        private _turretPath = _x;

        {
            private _weapon = _x;

            private _type = switch (toLower ((_weapon call BIS_fnc_itemType) select 1)) do {
                case "bomblauncher": {TYPE_BOMB};
                case "missilelauncher": {TYPE_MISSILE};
                case "rocketlauncher": {TYPE_ROCKET};
                case "machinegun";
                case "cannon": {TYPE_GUN};
                // Everything else, countermeasureslauncher included — that is
                // rtz_smoke's subject, not this one.
                default {-1};
            };

            if (_type != -1) then {
                // The air-to-air test is on the MAGAZINES: aiAmmoUsageFlags 256
                // marks a magazine the engine treats as air-target-only. A weapon
                // whose EVERY magazine is marked so has no business being offered
                // against a ground position; one that merely HAS an AA magazine
                // alongside ground ones is a multi-role pylon and still does.
                private _magazines = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");

                private _groundCapable = _magazines findIf {
                    private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
                    getNumber (configFile >> "CfgAmmo" >> _ammo >> "aiAmmoUsageFlags") != 256
                } != -1;

                if (_groundCapable) then {
                    _classified pushBack [_weapon, _turretPath, _type];
                };
            };
        } forEach (_vehicle weaponsTurret _turretPath);
    } forEach ([[-1]] + allTurrets _vehicle);

    GVAR(weaponCache) set [_class, _classified];
};

// Ammo is live and is read now rather than cached. A dry weapon is dropped here
// rather than offered greyed out: a menu row exists to be clicked.
private _out = [];

{
    _x params ["_weapon", "_turretPath", "_type"];

    private _ammo = _vehicle ammo _weapon;

    if (_ammo > 0) then {
        _out pushBack [_weapon, _turretPath, _type, _ammo];
    };
} forEach _classified;

_out
