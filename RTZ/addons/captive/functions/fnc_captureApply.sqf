#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(captureApply) (registered on every machine in
 * XEH_postInit): strips a prisoner's armament where he is local. Inventory
 * commands are unreliable across locality, and FUNC(captureUnit) is pinned to
 * the server by its curator lookups, so the strip is sent to the unit rather
 * than performed on the spot.
 *
 * Weapons first, then everything left that can be loaded into one. removeAllWeapons
 * takes the rifle, sidearm, launcher, binoculars and whatever is chambered in
 * them, but leaves the spare magazines in the prisoner's vest and uniform — and
 * grenades, which are magazines too. A prisoner who can be handed a rifle from
 * his own vest, or who still has a frag on him, is not disarmed.
 *
 * Uniform, vest and backpack are deliberately left alone: this is a disarm, not
 * a strip search, and the containers are what makes the prisoner still look like
 * the soldier he was.
 *
 * Arguments:
 * 0: The captured unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_captive_fnc_captureApply
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit || {!alive _unit}) exitWith {};

removeAllWeapons _unit;

// Deduplicated: `magazines` lists every round-count separately, and
// removeMagazines already takes every magazine of the class it is given, so the
// raw list would call it a dozen times to no effect.
private _magazines = magazines _unit;
{
    _unit removeMagazines _x;
} forEach (_magazines arrayIntersect _magazines);
