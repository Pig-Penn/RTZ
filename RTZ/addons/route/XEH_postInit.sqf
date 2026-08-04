#include "script_component.hpp"

// The planning hold runs where the unit is local — doStop and doFollow are AI
// orders, and an AI order issued anywhere else does nothing at all, silently.
// Sent per unit with CBA_fnc_targetEvent rather than broadcast, so only the
// owning machine is asked to do anything.
[QGVAR(hold), LINKFUNC(setHold)] call CBA_fnc_addEventHandler;

// A committed route executes there for the same reason. Sent per unit by
// FUNC(commitRoutes) — Wargame broadcasts its equivalent to everyone and has
// each machine test locality and discard, so a thirty-unit plan costs every
// client in the session thirty payloads to throw away.
[QGVAR(follow), LINKFUNC(startFollow)] call CBA_fnc_addEventHandler;
