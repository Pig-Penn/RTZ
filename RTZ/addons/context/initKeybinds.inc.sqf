// Open selected unit's inventory. Client-only: the gear dialog is a UI action,
// and the engine's networked inventory sync carries the item transfers even when
// the unit/container is remote. Bound to "I" by default (DIK scan code 23).
if (GVAR(enableUnitInventory) && hasInterface) then {
    [
        ["RTZ", "Real-Time Zeus"],
        "openUnitInventory",
        "Open selected unit's inventory (loot nearby crates, vehicles, bodies)",
        {
            if (isNull getAssignedCuratorLogic player) exitWith { false };
            if (isNull (findDisplay 312)) exitWith { false };
            [] call FUNC(openUnitInventory);
            true
        },
        {},
        [23, [false, false, false]]
    ] call CBA_fnc_addKeybind;
};
