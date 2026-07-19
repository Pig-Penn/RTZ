#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: master on/off switch for the engagement-target
 * overlay, PER-CLIENT (each Zeus curates their own). While ON, the Draw3D
 * handler in FUNC(targetDisplay) follows the curator's live selection and
 * subscribes it to the server poll via QGVAR(tgtWatch).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_overlays_fnc_targetToggle
 *
 * Public: No
 */

GVAR(tgtEnabled) = !GVAR(tgtEnabled);

// Switching off clears all client state and unsubscribes; switching on needs
// nothing — the Draw3D selection sync sees the (reset) cached selection differ
// from the live one and subscribes next frame.
if (!GVAR(tgtEnabled)) then {
    GVAR(tgtSelection) = [];
    GVAR(tgtWatchedUnits) = createHashMap;
    GVAR(tgtDisplay) = [];
    [QGVAR(tgtWatch), [player, []]] call CBA_fnc_serverEvent;
};

[[LLSTRING(MsgTargetsHidden), LLSTRING(MsgTargetsShown)] select GVAR(tgtEnabled)] call zen_common_fnc_showMessage;
