#include "script_component.hpp"
/*
 * Author: Maxim
 * Starts whichever of this component's two systems their master setting has
 * switched on, at most once each per machine. The one entry point behind both
 * CBA_settingsInitialized and CBA_SettingChanged, so a setting turned on
 * mid-mission brings its system up instead of doing nothing until a restart.
 *
 * Both settings used to gate a bare `call` inside the settings-initialized
 * handler, which meant the value was sampled EXACTLY ONCE, a frame after
 * postInit. Neither is forced or restart-only, so an admin enabling spotting
 * mid-mission got no detection loop, no client stores, no renderers and nothing
 * in the log — the switch simply had no effect for the rest of the operation.
 *
 * The started flags are what make re-entry safe, and they are not optional.
 * Neither FUNC(spottingSystem) nor FUNC(remoteControlIndicator) is idempotent:
 * between them they add a CAManBase class event handler, several CBA event
 * handlers, two per-frame handlers and a set of renderer registrations, none of
 * which replace a previous copy. Running either twice would double every
 * detection pass and every network send it produces, which is markedly worse
 * than the bug this function exists to fix.
 *
 * Deliberately NOT symmetric — there is no "stop". Turning a setting back off
 * mid-mission leaves the system running until the next mission, because tearing
 * these down means unpicking class event handlers and a JIP-visible store, and
 * ZEN offers no re-add for what the teardown would remove. Same one-way
 * behaviour rtz_common documents for its context-menu clean-up.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_spotting_fnc_startSystems
 *
 * Public: No
 */

// GETGVAR throughout, never a bare read. The started flags simply do not exist
// until the first run. The two SETTINGS should always be readable by the time
// either caller fires, but a bare read costs a whole aborted scope if that is
// ever wrong — `if (nil) then` is a type error that kills the rest of the script,
// not just the branch — and this function's job is to be re-runnable from a
// handler that fires at times neither of us chose. A false default is the right
// failure: it declines to start now, and the next CBA_SettingChanged or the
// settings-initialized call starts it once the value is genuinely there.
if (GETGVAR(enableSpottingSystem,false) && {!(GETGVAR(spottingStarted,false))}) then {
    GVAR(spottingStarted) = true;
    call FUNC(spottingSystem);
};

if (GETGVAR(enableRemoteControlIndicator,false) && {!(GETGVAR(rcStarted,false))}) then {
    GVAR(rcStarted) = true;
    call FUNC(remoteControlIndicator);
};
