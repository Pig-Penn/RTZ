#include "script_component.hpp"

// The errands (doMove, createVehicle, the engine assemble/disassemble actions) must
// run where their unit is local. That is the server for ordinary Zeus AI, but AI
// offloaded to a headless client — or sitting in a player-led group — is local to
// that machine instead, so the context actions target the gunner / weapon with
// CBA_fnc_targetEvent and every machine carries a receiver.
//
// Deliberately not gated on GVAR(enabled): that setting is client-side and only
// hides the ordering curator's own actions, so gating the receiving half on some
// other machine's copy of it would leave a curator with an action whose receiver
// never existed. Nothing here costs anything until an order actually arrives.
[QGVAR(assemble), LINKFUNC(assembleWeapon)] call CBA_fnc_addEventHandler;
[QGVAR(disassemble), LINKFUNC(disassembleWeapon)] call CBA_fnc_addEventHandler;

// The Zeus grant for a freshly built weapon rides EGVAR(common,grantCurators), whose
// server-side receiver lives in rtz_common's own postInit.
//
// Feedback toasts raised by the errands go through EFUNC(common,notifyCurator),
// whose receiver is registered once in rtz_common's postInit — this component
// used to carry an identical private copy on its own event name.
