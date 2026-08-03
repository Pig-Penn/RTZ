#include "script_component.hpp"

// Deploy smoke screen / countermeasures. The context action is declared in
// CfgContext.hpp and gated by FUNC(canDeploySmoke); the weapon fire runs
// where each vehicle is local (the server for AI armor, a player's machine for
// a player-crewed vehicle), so FUNC(orderDeploySmoke) sends the selection in a
// single QGVAR(deploySmoke) event targeted at the vehicles. The receiver
// registers unconditionally on every machine (it only runs when an order was
// sent, and the setting is read live by the action condition).
[QGVAR(deploySmoke), LINKFUNC(deploySmokeApply)] call CBA_fnc_addEventHandler;
