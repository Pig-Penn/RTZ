#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(takeOwnership) (server only). Transfers the requested
 * groups and vehicles to the requesting curator's machine.
 *
 * setOwner, setGroupOwner and `owner` are all server-only, which is why the
 * client sends its player object and the ID is resolved here rather than
 * travelling over the wire — a stale ID from a client that reconnected between
 * send and receive would hand the units to whoever inherited that slot.
 *
 * Hulls move before brains: transferring the vehicle first means the group's AI
 * arrives on a machine that already owns the hull it is driving, instead of
 * briefly steering a vehicle that is still simulated elsewhere.
 *
 * Arguments:
 * 0: Requesting player <OBJECT>
 * 1: Groups to transfer <ARRAY>
 * 2: Vehicles to transfer <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_client, _groups, _vehicles] call rtz_control_fnc_takeOwnershipApply
 *
 * Public: No
 */

params ["_client", "_grps", "_vehs"];

if (isNull _client) exitWith {};

private _id = owner _client;
if (_id <= 0) exitWith {};

{
    // A vehicle carrying a player stays where it is — its occupant's machine
    // has the authoritative say over what he is riding in.
    if (
        !isNull _x
        && {owner _x != _id}
        && {crew _x findIf {isPlayer _x} == -1}
    ) then {
        _x setOwner _id;
    };
} forEach _vehs;

{
    if (
        !isNull _x
        && {groupOwner _x != _id}
        && {units _x findIf {isPlayer _x} == -1}
    ) then {
        _x setGroupOwner _id;
    };
} forEach _grps;
