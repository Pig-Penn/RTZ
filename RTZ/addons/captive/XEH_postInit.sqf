#include "script_component.hpp"

// Nothing here is gated on GVAR(enabled) and nothing waits for
// CBA_settingsInitialized. Both were wrong, and wrong in the same way
// rtz_hud documents: the master switch is a live, no-restart global that
// the context condition reads on every menu open, so an admin turning the
// feature on mid-mission got a working-looking action on machines that had never
// registered any of the receivers behind it, and the order silently evaporated.
//
// Registering unconditionally costs nothing to give up. Every handler below is
// inert until something sends to it, and the capture engine does not exist until
// a unit actually surrenders — the enable check moved to the two places that can
// still refuse cheaply: the action's condition and FUNC(registerSurrender).

// The context action is client-side, but setCaptive / disableAI / playMoveNow
// only work where the unit is local. FUNC(surrenderToggle) targets the event AT
// EACH UNIT, so CBA lands it on that unit's owner — the server, a headless
// client, or a player's machine for AI in his group — which is why the handler
// has to exist on all of them rather than just on the server.
[QGVAR(surrenderApply), LINKFUNC(surrenderApply)] call CBA_fnc_addEventHandler;

// Same reason, for the capture strip-down: inventory commands belong on the
// unit's own machine, while FUNC(captureUnit) necessarily runs on the server
// (curator modules are server-local).
[QGVAR(captureApply), LINKFUNC(captureApply)] call CBA_fnc_addEventHandler;

// disableAI is stored per machine and does NOT travel with the unit — the new
// owner's AI setup wins on a locality change. setCaptive, by contrast, IS
// global and persists. That asymmetry is this component's worst failure mode:
// a surrendered unit whose ownership moves (a headless client rebalancing,
// rtz_control's transfer, an AI group joining a player) stands up and resumes
// fighting while remaining untargetable to everyone shooting back. So the state
// is re-applied on whichever machine gains the unit.
//
// A class handler rather than a per-unit one because a per-unit "Local" handler
// only exists on the machine that added it — precisely the machine that just
// lost the unit. Cost is nil in the steady state: "Local" fires on ownership
// transitions, which are rare, not on any clock.
["CAManBase", "Local", {
    params ["_unit", "_local"];
    if (!_local) exitWith {};
    if !(_unit getVariable [QGVAR(surrendered), false]) exitWith {};

    // Forced: the unit is already in the state being asked for, which the
    // idempotency guard would otherwise (correctly) refuse.
    [_unit, true, true] call FUNC(surrenderApply);
}] call CBA_fnc_addClassEventHandler;

// Capture payout toast, fired at one specific curator's player by
// FUNC(captureUnit).
if (hasInterface) then {
    [QGVAR(captureMsg), {_this call zen_common_fnc_showMessage}] call CBA_fnc_addEventHandler;
};

// FUNC(surrenderApply) runs on the unit's owner, which is not necessarily the
// server, so every state flip is reported here to keep the capture watch's
// registry authoritative.
if (isServer) then {
    [QGVAR(registerSurrender), LINKFUNC(registerSurrender)] call CBA_fnc_addEventHandler;
};
