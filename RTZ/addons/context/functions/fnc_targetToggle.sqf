#include "script_component.hpp"
/*
 * rtz_fnc_targetToggle
 *
 * Context-menu statement: master on/off switch for the engagement-target
 * overlay. While ON, FUNC(targetDisplay)'s Draw3D handler tracks the curator's
 * CURRENT SELECTION — selecting units draws their targets, deselecting drops
 * them — until this is clicked again to switch OFF.
 *
 * The state is PER-CLIENT (each Zeus curates their own overlay); the server is
 * told which units to poll via QGVAR(tgtWatch) so it only ever polls / sends
 * data somebody is actually looking at.
 */

GVAR(tgtEnabled) = !GVAR(tgtEnabled);

if (!GVAR(tgtEnabled)) then {
    GVAR(tgtSelection) = [];
    GVAR(tgtWatchedUnits) = createHashMap;
    GVAR(tgtDisplay) = [];
    [QGVAR(tgtWatch), [player, []]] call CBA_fnc_serverEvent;
};
// While ON, nothing to subscribe here: the Draw3D selection sync sees the
// (reset) cached selection differ from the live one and subscribes next frame.

[["Targets hidden", "Targets shown"] select GVAR(tgtEnabled)] call zen_common_fnc_showMessage;
