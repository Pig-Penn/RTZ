#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT: add the "Medical Zone" module to the Zeus module menu (ZEN custom-modules
 * framework). Called once per client from XEH_postInit, only when the casualty
 * system is enabled — no zone module if casualties are off.
 *
 * Registration is local, so this runs on every hasInterface machine (the ZEN
 * framework requires it on each client to appear in that curator's menu). The
 * module's placement callback is FUNC(placeMedicalZone).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_casualty_fnc_registerMedicalZone
 *
 * Public: No
 */

[
    localize ELSTRING(main,DisplayName),
    LLSTRING(ModuleMedicalZone),
    LINKFUNC(placeMedicalZone),
    ICON_LOAD
] call zen_custom_modules_fnc_register;
