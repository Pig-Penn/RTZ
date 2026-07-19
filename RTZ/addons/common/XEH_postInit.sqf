#include "script_component.hpp"

// Applies retroactively so units already on the map at mission start are
// covered too; runs for every spawned man-class unit from any source
["CAManBase", "InitPost", LINKFUNC(initMan), true, [], true] call CBA_fnc_addClassEventHandler;

// Stance orders are executed where the unit is local (setUnitPos is a
// local-effect command; FUNC(switchStance) targets each unit's own machine)
[QGVAR(switchStance), {
    params ["_unit", "_stance"];
    _unit setUnitPos _stance;
}] call CBA_fnc_addEventHandler;

// Fly-height orders are executed where the aircraft is local (flyInHeight is
// a local-effect command). The engine exposes no flyInHeight getter, so the
// ordered height is tracked in a public per-vehicle variable, seeded from the
// aircraft's current altitude on the first adjustment. Broadcast so the height
// survives locality changes (remote control) and the server-side vehicle
// overlay (rtz_selection's vehicleDataStream) can read it.
[QGVAR(adjustHeliHeight), {
    params ["_heli", "_delta"];

    private _height = ((_heli getVariable [QGVAR(flyHeight), round ((getPosATL _heli) select 2)]) + _delta) max FLY_HEIGHT_MIN;
    _heli setVariable [QGVAR(flyHeight), _height, true];
    _heli flyInHeight [_height, true];
}] call CBA_fnc_addEventHandler;

// Curator feedback toast for errands driven by FUNC(approach) (e.g. a unit that
// couldn't reach the picked spot). Fired at the ordering curator's player.
if (hasInterface) then {
    [QGVAR(approachMsg), { _this call zen_common_fnc_showMessage }] call CBA_fnc_addEventHandler;
};

// Deploy smoke screen / countermeasures. The context action is declared in
// CfgZenContext.hpp and gated by FUNC(canDeploySmoke); the weapon fire runs
// where each vehicle is local (the server for AI armor, a player's machine for
// a player-crewed vehicle), so FUNC(orderDeploySmoke) sends the selection in a
// single QGVAR(deploySmoke) event targeted at the vehicles. The receiver
// registers unconditionally on every machine (it only runs when an order was
// sent, and the setting is read live by the action condition).
[QGVAR(deploySmoke), LINKFUNC(deploySmokeApply)] call CBA_fnc_addEventHandler;

// Setting-gated context features. Deferred to CBA_settingsInitialized so each
// synced setting holds the server's value before it is read (see rtz_overlays /
// rtz_officer for the same pattern), and so ZEN's own postInit has already
// registered the actions the menu clean-up removes.
["CBA_settingsInitialized", {
    // Strip ZEN's cluttered built-in context entries (client-side only).
    if (hasInterface && {GVAR(enableCleanContextMenu)}) then {
        [] call FUNC(removeContextActions);
    };
}] call CBA_fnc_addEventHandler;
