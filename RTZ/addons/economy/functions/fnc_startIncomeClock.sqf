#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Starts the income clock on a freshly opened Zeus display: the readout
 * that borrows the clock bar's mission-countdown slot to say how long until the
 * next income payout, and how big it is.
 *
 * The display and its controls are destroyed and recreated on every open, so the
 * three control references are resolved here, once, and carried in the tick's own
 * args rather than looked up per tick.
 *
 * WHY A PFH AND NOT EFUNC(core,registerRenderer). The readout changes once a
 * second and only while Zeus is open. A permanently registered RENDER_UI renderer
 * would put a findDisplay on the Draw3D handler of every client for the whole
 * mission — the per-frame, multi-hour cost CLAUDE.md rules out — to serve one
 * update a second. A display-scoped PFH that removes itself when the display goes
 * away is the shape rtz_hud's selection info already uses for the same reason.
 *
 * NOT gated on GVAR(incomeClock) here: FUNC(incomeClockTick) reads the setting
 * itself, so toggling it takes effect without backing out of Zeus, and a 1 Hz
 * handler that early-exits costs nothing. Everything else it needs to bail on
 * (economy disabled, no income, a real mission countdown) can change mid-session
 * too, and is tested there for the same reason.
 *
 * Loading: called from XEH_postInit's zen_curatorDisplayLoaded handler.
 * Client-only; registers one PFH, no scheduled ops.
 *
 * Arguments:
 * 0: The freshly created curator display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 312] call rtz_economy_fnc_startIncomeClock
 *
 * Public: No
 */

params ["_display"];

if (isNull _display) exitWith {};

// zen_curatorDisplayLoaded can fire more than once against the same display; one
// tick per display, or they would fight over the same three controls
if (_display getVariable [QGVAR(incomeClockStarted), false]) exitWith {};
_display setVariable [QGVAR(incomeClockStarted), true];

// Read once so the tint can be undone when the slot goes back to vanilla — there
// is no getter for a control's text colour, and by then ours is the only value
// the control has ever been given
private _default = getArray (configFile >> "RscText" >> "colorText");
if (count _default != 4) then { _default = [1, 1, 1, 1] };

[
    LINKFUNC(incomeClockTick),
    CLOCK_INTERVAL,
    [
        _display,
        _display displayCtrl IDC_CURATOR_CLOCK_DURATION,
        _display displayCtrl IDC_CURATOR_CLOCK_DAYTIME,
        _display displayCtrl IDC_CURATOR_CLOCK_COUNTDOWN,
        _default,
        "",  // last countdown text, so an unchanged string costs no ctrlSetText
        -1   // last full-bar state; -1 matches neither bool, so the first tick tints
    ]
] call CBA_fnc_addPerFrameHandler;
