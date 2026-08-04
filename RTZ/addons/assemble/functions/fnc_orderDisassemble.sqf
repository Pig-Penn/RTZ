#include "script_component.hpp"
/*
 * Author: Maxim
 * Context menu statement: packs every selected manned static weapon, or drone, back
 * into the backpacks its crew carries. Mirror of FUNC(orderAssemble), without the
 * placement preview - a pack needs no target spot.
 *
 * The deleteVehicle, moveOut and addBackpackGlobal calls must run where the weapon
 * is local - the server for Zeus AI, but a headless client or a player's machine for
 * offloaded or player-led groups - so each set is dispatched to its owner over
 * QGVAR(disassemble) (the receiver is registered on every machine in XEH_postInit).
 * The ordering curator's player rides along so the errand can toast failures back.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_orderDisassemble
 *
 * Public: No
 */

params ["_objects"];

private _sets = [_objects] call FUNC(collectDisassembleSets);

// FUNC(canDisassemble) already gated the action, this only catches a weapon lost
// between the menu opening and the click
if (_sets isEqualTo []) exitWith {};

// Targeted at the weapon (_x select 0): CBA delivers to whichever machine owns it
{
    [QGVAR(disassemble), _x + [player], _x select 0] call CBA_fnc_targetEvent;
} forEach _sets;

[LLSTRING(Disassembling), count _sets] call EFUNC(common,showCountMessage);
