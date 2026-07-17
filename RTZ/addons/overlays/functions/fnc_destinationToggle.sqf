#include "script_component.hpp"
/*
 * rtz_fnc_destinationToggle
 *
 * Context-menu statement: master on/off switch for the expected-destination
 * overlay. While ON, FUNC(destinationDisplay)'s Draw3D handler tracks the
 * curator's CURRENT SELECTION — selecting units draws their destinations,
 * deselecting drops them — until this is clicked again to switch OFF.
 *
 * The state is PER-CLIENT (each Zeus curates their own overlay); the server is
 * told which units to poll via QGVAR(destWatch) so it only ever polls / sends
 * data somebody is actually looking at.
 */

GVAR(destEnabled) = !GVAR(destEnabled);

if (!GVAR(destEnabled)) then {
    GVAR(destSelection) = [];
    GVAR(destWatchedUnits) = createHashMap;
    GVAR(destDisplay) = [];
    [QGVAR(destWatch), [player, []]] call CBA_fnc_serverEvent;
};
// While ON, nothing to subscribe here: the Draw3D selection sync sees the
// (reset) cached selection differ from the live one and subscribes next frame.

[["Destinations hidden", "Destinations shown"] select GVAR(destEnabled)] call zen_common_fnc_showMessage;
