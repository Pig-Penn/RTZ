#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the vehicles the Attach Flag action acts on:
 * those whose faction is in GVAR(factionFlags) and that are not already flying
 * that faction's flag.
 *
 * Single source of truth for the context action — its condition and its
 * statement both go through here, so the button cannot appear when a click
 * would do nothing, nor claim work it will not do. See rtz_control's
 * FUNC(collectDismountVehicles) for why that matters.
 *
 * Dropping vehicles that already carry the flag is what makes the action
 * self-hiding: once every resolved vehicle is flagged, this returns [] and the
 * entry stops rendering.
 *
 * NOT tested here: whether the vehicle's model actually has a flag proxy to
 * hang the texture on. Nothing in config exposes that, and ZEN's own Attach
 * Flag module offers itself on any AllVehicles for the same reason. A vehicle
 * without one stores the forced texture and shows nothing — the action then
 * hides, because the texture IS set.
 *
 * Arguments:
 * 0: Selected objects, hovered entity included <ARRAY>
 *
 * Return Value:
 * Unique vehicles missing their faction's flag <ARRAY>
 *
 * Example:
 * [_objects + [_hoveredEntity]] call rtz_flag_fnc_collectFlagVehicles
 *
 * Public: No
 */

params ["_objects"];

// Resolves a selected crewman to his vehicle, drops non-objects (a hovered
// group can arrive here) and everything that is not a vehicle, and dedupes.
private _vehicles = [_objects] call EFUNC(common,collectVehicles);

_vehicles select {
    alive _x
    && {
        private _texture = GVAR(factionFlags) getOrDefault [toLowerANSI faction _x, ""];
        // getForcedFlagTexture returns the same normalised shape the table
        // stores (lowercased, no leading backslash), so this is a plain compare.
        _texture isNotEqualTo "" && { getForcedFlagTexture _x isNotEqualTo _texture }
    }
}
