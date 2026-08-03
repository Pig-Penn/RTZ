#include "script_component.hpp"
/*
 * Author: Maxim
 * Sync the tag renderers' registration with their visibility flags. The flags
 * (GVAR(unitTagsVisible) / GVAR(vehicleTagsVisible)) stay the single source of
 * truth; this is what makes them take effect.
 *
 * Registration, not an early exit, is how a hidden tag system is switched off:
 * an unregistered renderer is never called, and with every renderer gone
 * EFUNC(core,frameLoop) skips building the camera basis entirely. A system that merely
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
    private _visible = GVAR(unitTagsVisible);

    if (_visible) then {
        [QGVAR(unitTags), LINKFUNC(drawUnitTags), RENDER_WORLD, 30] call EFUNC(core,registerRenderer);
    } else {
        [QGVAR(unitTags), RENDER_WORLD] call EFUNC(core,unregisterRenderer);
    };

    // Tell the engine whether anyone still wants the infantry slice streamed. The
    // engine used to read GVAR(unitTagsVisible) by name to work this out, which is
    // exactly the display knowledge that kept it welded to this component; it also
    // needed a defensive GETGVAR there, because this flag does not exist until the
    // tag system starts and a nil would have aborted the whole subscription
    // (docs/Gotchas.md §2). Declaring it from the consumer side removes both
    // problems — and this is the one place every visibility change funnels
    // through, so the demand cannot drift out of step with the renderer.
    // No `detailed`: the tags show no field that needs the expensive intel.
    [QGVAR(unitTags), _visible] call EFUNC(core,setDemand);
};

if (!isNil QGVAR(vehicleTagsVisible)) then {
    if (GVAR(vehicleTagsVisible)) then {
        [QGVAR(vehicleTags), LINKFUNC(drawVehicleTags), RENDER_WORLD, 31] call EFUNC(core,registerRenderer);
    } else {
        [QGVAR(vehicleTags), RENDER_WORLD] call EFUNC(core,unregisterRenderer);
    };
};
