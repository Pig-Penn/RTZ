#include "script_component.hpp"

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

// Setting-gated context features. Deferred to CBA_settingsInitialized so each
// synced setting holds the server's value before it is read (see rtz_hud /
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
