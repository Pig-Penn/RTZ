#include "script_component.hpp"
/*
 * rtz_fnc_lootNearbyContext
 *
 * Registers the "Loot Nearby" action in the Real-Time Zeus context menu
 * (category RTZ_RealTimeZeus): orders every selected AI squad to sweep nearby
 * lootables — dead bodies, dropped weapons, crates, unmanned vehicles — and
 * optimize their loadout: fill gaps (missing primary/launcher, backpack,
 * ammo) and swap up better gear (higher-rank weapon, higher chest armor
 * vest, armored headgear) even if the slot isn't empty.
 *
 * The entry only shows when the selection resolves to at least one group with
 * a dismounted AI unit AND something lootable sits within GVAR(lootRadius) of
 * a selected group's leader. FUNC(collectLootables) is called with a limit of
 * 1 so the per-menu-open cost stops at the first hit.
 *
 * The sweep itself (doMove / take actions / loadout transfers) must run where
 * the units are local (the server, for AI in Zeus PvP), so the whole selection
 * is batched into a single QGVAR(lootNearbyApply) server event (registered in
 * XEH_postInit).
 *
 * Loading: called by XEH_postInit (hasInterface) when the loot-nearby system is on.
 */

// Groups from the selection that have at least one dismounted AI unit able to
// walk over and loot. Shared by the condition and the statement.
private _collectGroups = {
    params ["_objects", "_hoveredEntity"];
    ([_objects + [_hoveredEntity]] call FUNC(collectSquads)) select {
        (units _x) findIf { !isPlayer _x && {isNull objectParent _x} } != -1
    }
};

private _action = [
    "RTZ_LootNearby",
    "Loot Nearby",
    "\a3\ui_f\data\igui\cfg\actions\gear_ca.paa",
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
        params ["", "_objects", "", "", "", "_hoveredEntity", "_args"];
        private _grps = [_objects, _hoveredEntity] call (_args select 0);
        if (_grps isEqualTo []) exitWith {};

        [QGVAR(lootNearbyApply), [_grps]] call CBA_fnc_serverEvent;

        private _msg = "Looting";
        if (count _grps > 1) then { _msg = format ["%1  x%2", _msg, count _grps]; };
        [_msg] call zen_common_fnc_showMessage;
    },
    {
        params ["", "_objects", "", "", "", "_hoveredEntity", "_args"];
        private _grps = [_objects, _hoveredEntity] call (_args select 0);
        // Show only when something lootable is near a selected squad; limit 1
        // + findIf keep the scan early-exit cheap on every menu open.
        _grps findIf {
            ([getPosATL leader _x, GVAR(lootRadius), 1] call FUNC(collectLootables)) isNotEqualTo []
        } != -1
    },
    [_collectGroups]
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_RealTimeZeus"], 2] call zen_context_menu_fnc_addAction;
