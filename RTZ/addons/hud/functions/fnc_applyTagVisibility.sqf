#include "script_component.hpp"
/*
 * Author: Maxim
 * Sync the tag renderers' registration with their visibility flags. The flags
 * (GVAR(unitTagsVisible) / GVAR(vehicleTagsVisible)) stay the single source of
 * truth; this is what makes them take effect.
 *
 * Registration, not an early exit, is how a hidden tag system is switched off:
 * an unregistered renderer is never called, and with every renderer gone
 * FUNC(frameLoop) skips building the camera basis entirely. A system that merely
 * returned early still cost a call per frame forever.
 *
 * Each system is independently CBA-setting gated, so only one, both or neither
 * may exist at runtime — hence the isNil guards. A system that was never started
 * has no flag, and is left unregistered.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_applyTagVisibility
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

if (!isNil QGVAR(unitTagsVisible)) then {
    if (GVAR(unitTagsVisible)) then {
        [QGVAR(unitTags), LINKFUNC(drawUnitTags), RENDER_WORLD, 30] call FUNC(registerRenderer);
    } else {
        [QGVAR(unitTags), RENDER_WORLD] call FUNC(unregisterRenderer);
    };
};

if (!isNil QGVAR(vehicleTagsVisible)) then {
    if (GVAR(vehicleTagsVisible)) then {
        [QGVAR(vehicleTags), LINKFUNC(drawVehicleTags), RENDER_WORLD, 31] call FUNC(registerRenderer);
    } else {
        [QGVAR(vehicleTags), RENDER_WORLD] call FUNC(unregisterRenderer);
    };
};
