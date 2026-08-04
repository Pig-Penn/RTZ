#include "script_component.hpp"

// The sweep (doMove, the engine take/rearm actions, the loadout transfers) must run
// where the units are local - the server, for the Zeus AI this targets. Non-local
// units are skipped by FUNC(lootSquads) itself, so a single server receiver covers
// the whole selection.
//
// Deliberately not gated on GVAR(enabled): that setting is client-side and only
// hides the ordering curator's own action, so gating the receiving half on the
// server's copy of it would leave a curator with an action whose receiver never
// existed. The handler costs nothing until an order actually arrives.
if (isServer) then {
    [QGVAR(loot), LINKFUNC(lootSquads)] call CBA_fnc_addEventHandler;
};

// NOT isServer-gated, unlike the sweep above: the worn-gear strip has to run where
// the BODY is local, and a corpse owned by a headless client or by a player-led
// group is local on that machine rather than the server. See FUNC(stripWorn).
[QGVAR(strip), LINKFUNC(stripWorn)] call CBA_fnc_addEventHandler;
