// Zeus keybind handlers — RTS-style orders issued without opening a context
// menu first. Each guards itself with CHECK_CURATOR_INPUT and returns whether
// it consumed the press. FUNC(keepGearAnimation) and FUNC(playGearAnim) are the
// exceptions: helpers FUNC(openUnitInventory) leans on, not handlers of their own.
PREP(curatorMapTeleport);
PREP(flyHeight);
PREP(keepGearAnimation);
PREP(openUnitInventory);
PREP(playGearAnim);
PREP(switchStance);
PREP(teleportToCursor);
PREP(toggleCombatMode);
