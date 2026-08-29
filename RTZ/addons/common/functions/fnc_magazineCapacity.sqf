#include "script_component.hpp"
/*
 * Author: Maxim
 * The configured round count of a magazine class — what "full" means for it —
 * cached for the whole mission. Invariant per class, so each magazine pays the
 * config lookup exactly once per machine.
 *
 * There is no command that reads a vehicle's ammo ratio back, so every caller
 * that wants one compares the loaded magazines against their configured size.
 * That made this the same lookup, behind the same lazily-filled HashMap, in four
 * places: rtz_control (FUNC(needsReload)), rtz_supply (FUNC(ammoRatio)),
 * rtz_hud (FUNC(gatherUnitInfo)) and rtz_loot (FUNC(weaponScore)) — three of
 * them carrying their own cache global, and control's header already noting it
 * was "the same test, and the same cache pattern, as EFUNC(supply,ammoRatio)".
 * One rule written down four times is the bug shape this codebase keeps finding:
 * a refinement to what counts as full (a modded magazine whose `count` is absent
 * or zero, say) would otherwise land in one copy and not the others.
 *
 * Same shape as FUNC(classInfo), and shared for the same reason.
 *
 * The cache GVAR(magazineCapacities) is created in XEH_preInit so it exists on
 * every machine before any caller runs — these callers span the curator clients
 * that open a context menu and the server that runs the gather and service
 * loops, and rtz_hud's copy was created behind an isServer gate that this one
 * deliberately does not carry.
 *
 * Arguments:
 * 0: Magazine class <STRING>
 *
 * Return Value:
 * Full round count, 0 for a class with no count entry <NUMBER>
 *
 * Example:
 * private _cap = ["30Rnd_65x39_caseless_mag"] call rtz_common_fnc_magazineCapacity
 *
 * Public: No
 */

params ["_magazine"];

GVAR(magazineCapacities) getOrDefaultCall [_magazine, {
    getNumber (configFile >> "CfgMagazines" >> _magazine >> "count")
}, true]
