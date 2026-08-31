#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts the incoming-missile markers: the 3D renderer and the Zeus map Draw
 * handler. Called when the curator display opens, and again whenever the marker
 * setting is toggled mid-mission (see XEH_postInit).
 *
 * Both pieces ride one setting, and each is registered only while it is on and
 * torn down again when it goes off — rather than registering them and testing the
 * setting inside handlers that then run every frame for nothing. With the markers
 * off the overlay costs exactly zero, and neither draw pass has to know the
 * setting exists.
 *
 * The two are still separate registrations rather than one, because they hang off
 * different things: the 3D pass rides rtz_core's frame loop, the map pass a Draw
 * handler on a control of the curator display.
 *
 * Reporting is not gated here. GVAR(enabled) already stops it at the source
 * (FUNC(detectIncoming)), and a curator with the markers off still wants the tracks
 * to be there when they turn them back on mid-flight.
 *
 * Arguments:
 * 0: Curator Display <DISPLAY> — omitted on a setting-change refresh
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call rtz_missile_fnc_start
 *
 * Public: No
 */

params [["_display", displayNull]];

private _markers = GVAR(markers);

// Registration with rtz_core's shared frame loop, not a Draw3D handler of our own.
// Priority 45 sits above rtz_spotting's contact chevrons (41) and below rtz_mine's
// markers (60): a missile in flight is the more urgent of the three.
if (_markers) then {
    [QGVAR(missiles3D), ELINKFUNC(missile,draw3D), RENDER_WORLD, 45] call EFUNC(core,registerRenderer);
} else {
    [QGVAR(missiles3D), RENDER_WORLD] call EFUNC(core,unregisterRenderer);
};

// Re-resolved from the curator display on every call rather than cached in a GVAR:
// a CONTROL cannot be serialized, and the engine warns about — and drops — any such
// handle left in the mission namespace when the mission state is saved.
if (isNull _display) then {
    _display = findDisplay IDD_RSCDISPLAYCURATOR;
};

private _mapCtrl = _display displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP;

if (isNull _mapCtrl) exitWith {};

// Added and removed by id rather than cleared wholesale — ctrlRemoveAllEventHandlers
// would take ZEN's own Draw handlers on the same map with it
if (_markers) then {
    if (GVAR(mapEH) == -1) then {
        GVAR(mapEH) = _mapCtrl ctrlAddEventHandler ["Draw", {_this call FUNC(drawMap)}];
    };
} else {
    if (GVAR(mapEH) != -1) then {
        _mapCtrl ctrlRemoveEventHandler ["Draw", GVAR(mapEH)];
        GVAR(mapEH) = -1;
    };
};
