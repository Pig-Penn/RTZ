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

// Combat mode orders are executed where the group is local (setCombatMode is
// a local-effect command). The engine exposes no reliable cross-locality
// combatMode getter, so the ordered fire discipline is tracked in a public
// per-group variable so the curator's next read (FUNC(toggleCombatMode)) is
// authoritative even when the group is local to a dedicated server / headless
// client.
[QGVAR(toggleCombatMode), {
    params ["_grp", "_mode", "_hold"];
    _grp setCombatMode _mode;
    _grp setVariable [QGVAR(holdFire), _hold, true];
}] call CBA_fnc_addEventHandler;

// Curator modules are server-local, so an errand that spawned an object on any
// other machine forwards its Zeus grant here — see FUNC(grantCurators).
if (isServer) then {
    [QGVAR(grantCurators), LINKFUNC(grantCurators)] call CBA_fnc_addEventHandler;
};

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

// Turning the clean-up on mid-mission applies immediately instead of waiting
// for a restart. The reverse is one-way: zen_context_menu_fnc_removeAction
// deletes the node out of ZEN's runtime action tree and ZEN offers no re-add
// for its own built-ins, so turning the setting back OFF only takes effect on
// the next mission start. FUNC(removeContextActions) self-guards against a
// repeated ON (ZEN logs an RPT error for an already-removed path).
if (hasInterface) then {
    ["CBA_SettingChanged", {
        params ["_name", "_value"];
        if (toLower _name != toLower QGVAR(enableCleanContextMenu)) exitWith {};
        if (_value) then {
            [] call FUNC(removeContextActions);
        };
    }] call CBA_fnc_addEventHandler;
};
