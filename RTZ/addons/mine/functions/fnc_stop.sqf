#include "script_component.hpp"
/*
 * Author: Maxim
 * Stops marking spotted mines and clears the mine cache. Called when the curator
 * display closes.
 *
 * The map Draw handler needs no removal — it lives on a control of the display
 * that has just been destroyed — but its stored id and control DO have to be
 * dropped, or the next curator display would be handed a stale handle from the
 * last one and skip re-attaching.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_mine_fnc_stop
 *
 * Public: No
 */

if (GVAR(pfh) != -1) then {
    [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(pfh) = -1;
};

// Unregister from rtz_hud's frame loop. The loop gates on the curator display
// itself, so leaving it registered would draw nothing — but an unregistered
// renderer is not called at all, and with every renderer gone the loop skips
// building its camera basis outright.
[QGVAR(mines3D), RENDER_WORLD] call EFUNC(hud,unregisterRenderer);

GVAR(mapCtrl) = controlNull;
GVAR(mapEH) = -1;
GVAR(mines) = [];
