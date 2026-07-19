#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: master on/off switch for the expected-destination
 * overlay, PER-CLIENT (each Zeus curates their own). While ON, the Draw3D
 * handler in FUNC(destinationDisplay) follows the curator's live selection
 * and subscribes it to the server poll via QGVAR(destWatch).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_overlays_fnc_destinationToggle
 *
 * Public: No
 */

GVAR(destEnabled) = !GVAR(destEnabled);

// Switching off clears all client state and unsubscribes; switching on needs
// nothing — the Draw3D selection sync sees the (reset) cached selection differ
// from the live one and subscribes next frame.
if (!GVAR(destEnabled)) then {
    GVAR(destSelection) = [];
    GVAR(destWatchedUnits) = createHashMap;
    GVAR(destDisplay) = [];
    [QGVAR(destWatch), [player, []]] call CBA_fnc_serverEvent;
};

[[LLSTRING(MsgDestinationsHidden), LLSTRING(MsgDestinationsShown)] select GVAR(destEnabled)] call zen_common_fnc_showMessage;
