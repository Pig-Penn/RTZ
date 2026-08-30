#include "script_component.hpp"
/*
 * Author: Maxim
 * Flies each resolved vehicle's own faction flag on it. A mixed-faction
 * selection therefore gets each vehicle its own flag, not a shared one.
 *
 * Runs entirely on the curator's client and deliberately does NOT remoteExec:
 * forceFlagTexture takes a global argument and has a global effect, so one call
 * here reaches every machine. ZEN's Attach Flag module does exactly the same.
 *
 * Re-resolves the selection through FUNC(collectFlagVehicles) rather than
 * trusting what the condition saw, so a vehicle that died or was flagged
 * between the menu opening and the click is dropped.
 *
 * Arguments:
 * 0: Selected objects, hovered entity included <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects + [_hoveredEntity]] call rtz_flag_fnc_attachFlag
 *
 * Public: No
 */

params ["_objects"];

{
    // Present by construction: collectFlagVehicles only returns vehicles whose
    // faction resolved to a texture.
    _x forceFlagTexture (GVAR(factionFlags) get (toLowerANSI faction _x));
} forEach ([_objects] call FUNC(collectFlagVehicles));
