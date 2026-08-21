#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether ordering this unit to reload would actually do anything: it holds a
 * weapon whose loaded magazine is beaten by a spare it is carrying. That is
 * exactly what the `reload` command does — swap the magazine in the weapon for
 * the best compatible one in the inventory — so a unit failing this test would
 * ignore the order, and there is no point offering it.
 *
 * Read on the CURATOR'S CLIENT, about units that are almost never local to it.
 * That is safe here and nowhere near universal — `expectedDestination` and
 * friends return stale nonsense off the owning machine (docs/Knowledge Base/Gotchas.md §4).
 * Weapon and inventory state is argument-global: ACE3's "Check Ammo"
 * interaction reads `_target ammo`, `magazinesAmmoFull _target` and
 * `currentWeapon _target` on the interacting player's machine with no locality
 * guard and no remoteExec, on targets that are routinely remote.
 *
 * MOUNTED UNITS take the vehicle branch. `currentWeapon` of a man in a turret
 * reports the turret's weapon while his `magazinesAmmoFull` still reports what
 * is in his uniform, so the infantry test below would compare a cannon against
 * rifle magazines and answer nonsense. Turret magazines are compared to their
 * configured round count instead — literally the same test as
 * EFUNC(supply,needsAmmo), and now the same code: both go through
 * EFUNC(common,magazineCapacity). A driver in an unarmed vehicle therefore
 * answers false, which is correct: nothing there can be reloaded.
 *
 * Both config reads are memoized per class for the mission, because the same
 * handful of classes recur across every unit in every selection — magazine
 * capacity in rtz_common's shared cache, a weapon's compatible magazines in
 * this component's own GVAR(weaponMagazines), which nothing else asks for.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Reloading would change something <BOOL>
 *
 * Example:
 * private _worthIt = [_unit] call rtz_control_fnc_needsReload
 *
 * Public: No
 */

params ["_unit"];

private _veh = objectParent _unit;

if (!isNull _veh) exitWith {
    (magazinesAllTurrets _veh findIf {
        _x params ["_magazine", "", "_rounds"];

        _rounds < ([_magazine] call EFUNC(common,magazineCapacity))
    }) > -1
};

private _weapon = currentWeapon _unit;
if (_weapon isEqualTo "") exitWith {false};

// Compatible magazines rather than "same class as the loaded one": a rifle fed
// a 20-round mag when it also takes 30s should still see the 30 as an upgrade.
private _compatible = GVAR(weaponMagazines) getOrDefaultCall [_weapon, {
    compatibleMagazines _weapon
}, true];
if (_compatible isEqualTo []) exitWith {false};

// Rounds in the weapon right now. `ammo` is read rather than picking the
// loaded entry out of the list below, because a unit carrying a rifle AND a
// handgun that share a magazine class has two entries flagged loaded and only
// this one answers for the weapon in his hands.
private _loaded = _unit ammo _weapon;

(magazinesAmmoFull _unit findIf {
    _x params ["_magazine", "_rounds", "_isLoaded"];

    !_isLoaded && {_rounds > _loaded} && {_magazine in _compatible}
}) > -1
