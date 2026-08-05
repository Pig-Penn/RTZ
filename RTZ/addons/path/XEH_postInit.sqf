#include "script_component.hpp"

// Registered UNCONDITIONALLY, and NOT deferred to CBA_settingsInitialized.
//
// Both used to sit behind `if (!GVAR(enable)) exitWith {}` inside a
// CBA_settingsInitialized handler, which is the trap rtz_captive and rtz_control
// each document having already fixed for themselves: GVAR(enable) is a live,
// no-restart global that FUNC(togglePlanning) reads at PRESS time, so an admin
// switching path planning on mid-mission got a fully working planning session —
// drag handles, traced lines, the lot — on machines that had never registered
// either receiver behind it, and every committed path evaporated silently. The
// setting DEFAULTS TO FALSE, so turning it on mid-mission is the ordinary way to
// enable the feature, not an edge case.
//
// There is nothing to give up by registering early. An idle CBA event handler
// costs nothing, neither body runs until an order is actually sent to it, and the
// enable check stays in the one place that can still refuse cheaply — the keybind
// handler that opens the session.

// The planning hold runs where the unit is local — doStop and doFollow are AI
// orders, and an AI order issued anywhere else does nothing at all, silently.
// Sent per unit with CBA_fnc_targetEvent rather than broadcast, so only the
// owning machine is asked to do anything.
[QGVAR(hold), LINKFUNC(setHold)] call CBA_fnc_addEventHandler;

// A committed path executes there for the same reason. Sent per unit by
// FUNC(commitPaths) — Wargame broadcasts its equivalent to everyone and has
// each machine test locality and discard, so a thirty-unit plan costs every
// client in the session thirty payloads to throw away.
[QGVAR(follow), LINKFUNC(startFollow)] call CBA_fnc_addEventHandler;
