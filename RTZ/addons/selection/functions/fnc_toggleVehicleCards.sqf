#include "script_component.hpp"
/*
 * Author: Maxim
 * Toggles the vehicle overlay cards (FUNC(vehicleOverlay)) between full and
 * minimized — minimized collapses every card to its accent strip + title bar.
 * Driven by the "Vehicle Cards" ZEN context menu entry registered in
 * FUNC(vehicleOverlay).
 *
 * Setting the dirty flag is what actually applies it: the overlay only relays
 * out its cards when a fresh packet arrives or the selected id set changes, so
 * without it the switch would not take effect until the next server push.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_selection_fnc_toggleVehicleCards
 *
 * Public: No
 */

GVAR(vehCardsMini) = !GVAR(vehCardsMini);
GVAR(vehDataDirty) = true;
