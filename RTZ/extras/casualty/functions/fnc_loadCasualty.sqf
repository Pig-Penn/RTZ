#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT action handler for "Load into Medical Vehicle" (CfgContext.hpp). Resolves
 * the selection to loadable casualties and asks the server to load each one — the
 * state check and medical-vehicle search are authoritative against the server-only
 * GVAR(casualties) registry, so they run server-side via FUNC(loadCasualtyApply);
 * that handler hops the actual moveInCargo back out to the casualty's own owning
 * machine (FUNC(loadCasualtyMoveIn)), since moveInCargo is a local-effect command and
 * AI in a player-led group is local to that player's machine, not necessarily the
 * server. The ordering player rides along so the server can toast a failure ("no
 * medical vehicle in range") back to just this curator.
 *
 * Arguments:
 * 0: Objects from a ZEN action's selection + hovered entity <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_casualty_fnc_loadCasualty
 *
 * Public: No
 */

params ["_objects"];
private _cas = [_objects] call FUNC(collectCasualties);
if (_cas isEqualTo []) exitWith {};
{
    [QGVAR(loadCasualty), [_x, player]] call CBA_fnc_serverEvent;
} forEach _cas;
