#include "script_component.hpp"
/*
 * rtz_fnc_disassembleWeaponContext
 *
 * Registers the "Disassemble Weapon" action at the root of the Zeus context menu
 * (mirrors FUNC(assembleWeaponContext), which is also root-level). The entry
 * only shows when the selection or hovered entity resolves to at least one manned
 * static weapon that can be packed back into backpacks. Clicking it packs every
 * such weapon via FUNC(disassembleWeaponAction).
 *
 * The condition/statement are evaluated only when the context menu is opened
 * (ZEN calls them on right-click, not per frame), so this adds no running cost.
 *
 * Loading: called by XEH_postInit (hasInterface) when the assemble-weapon system is on.
 */

private _action = [
    "RTZ_DisassembleWeapon",
    "Disassemble",
    // the vanilla curator "module" cog, resolved live from CfgVehicleIcons rather than
    // hardcoding its .paa path (which lives in the engine's core bin config, not any PBO)
    [getText (configFile >> "CfgVehicleIcons" >> "iconModule"), [0.94, 0.51, 0.19, 1]],
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args];
        // the hovered entity is already included in _objects (ZEN's fnc_open pushBackUniques it).
        params ["", "_objects"];
        [_objects] call FUNC(disassembleWeaponAction);
    },
    {
        params ["", "_objects"];
        ([_objects] call FUNC(collectDisassembleSets)) isNotEqualTo []
    }
] call zen_context_menu_fnc_createAction;

[_action, [], 2] call zen_context_menu_fnc_addAction;
