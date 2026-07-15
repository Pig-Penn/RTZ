#include "script_component.hpp"
/*
 * rtz_fnc_assembleWeaponContext
 *
 * Registers the "Assemble Here" action at the root of the Zeus context menu
 * (not nested under the RTZ_RealTimeZeus submenu). The entry only shows when
 * the selection or hovered entity resolves to at least one squad carrying a complete
 * disassembled static weapon (gunner's weapon bag + assistant's tripod bag).
 * Clicking it sends every such squad to walk to the cursor's world position
 * (ZEN's _position) and raise the weapon there via FUNC(assembleWeaponAction).
 *
 * Loading: called by XEH_postInit (hasInterface) when the assemble-weapon system is on.
 */

private _action = [
    "RTZ_AssembleWeapon",
    "Assemble",
    // the vanilla curator "module" cog, resolved live from CfgVehicleIcons rather than
    // hardcoding its .paa path (which lives in the engine's core bin config, not any PBO)
    [getText (configFile >> "CfgVehicleIcons" >> "iconModule"), [0.94, 0.51, 0.19, 1]],
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args];
        // the hovered entity is already included in _objects (ZEN's fnc_open pushBackUniques it).
        params ["_position", "_objects"];
        [_objects, _position] call FUNC(assembleWeaponAction);
    },
    {
        params ["", "_objects"];
        ([_objects] call FUNC(collectAssembleSets)) isNotEqualTo []
    }
] call zen_context_menu_fnc_createAction;

[_action, [], 2] call zen_context_menu_fnc_addAction;
