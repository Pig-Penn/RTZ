#include "script_component.hpp"
/*
 * Author: Maxim
 * Stops the incoming-missile markers and drops the tracks. Called when the curator
 * display closes.
 *
 * The map Draw handler needs no removal — it lives on a control of the display that
 * has just been destroyed — but its stored id DOES have to be dropped, or the next
 * curator display would be handed a stale handle from the last one and skip
 * re-attaching.
 *
 * GVAR(tracked) is cleared rather than left to age out: every record in it names a
 * projectile that will be long gone by the time this curator opens Zeus again, and
 * nothing off the display reads the list.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_missile_fnc_stop
 *
 * Public: No
 */

// Unregister from rtz_core's frame loop. The loop gates on the curator display
// itself, so leaving it registered would draw nothing — but an unregistered renderer
// is not called at all, and with every renderer gone the loop skips building its
// camera basis outright.
[QGVAR(missiles3D), RENDER_WORLD] call EFUNC(core,unregisterRenderer);

GVAR(mapEH) = -1;
GVAR(tracked) = [];
