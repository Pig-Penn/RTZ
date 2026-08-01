#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: pulls the selected groups (and the vehicles they are
 * riding in) back onto this curator's machine, restoring the locality a
 * freshly-placed Zeus unit gets. The cure for post-rejoin units that are still
 * fully editable but visibly sluggish — see FUNC(canTakeOwnership) for why the
 * two states come apart.
 *
 * Groups and vehicles already local here are dropped rather than sent, so
 * re-running the action on a healthy squad is a no-op. Groups holding a player
 * are excluded entirely: they belong to that player's machine and moving them
 * is never correct.
 *
 * setOwner / setGroupOwner are server-only commands and the client ID has to be
 * resolved with `owner`, which is likewise server-only — so the client sends
 * itself as an object and the server does both lookups.
 *
 * Arguments:
 * 0: Selection objects <ARRAY>
 * 1: Hovered entity <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects, _hoveredEntity] call rtz_control_fnc_takeOwnership
 *
 * Public: No
 */

params ["_objects", "_hoveredEntity"];

if (isNull getAssignedCuratorLogic player) exitWith {};

private _grps = ([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads)) select {
    units _x findIf {isPlayer _x} == -1
};
if (_grps isEqualTo []) exitWith {};

private _grpsToMove = [];
private _vehsToMove = [];

{
    if (!local _x) then {_grpsToMove pushBackUnique _x};

    // A vehicle's locality is tracked independently of its crew's group, so a
    // squad can arrive here while the truck it is sitting in stays behind.
    {
        private _veh = objectParent _x;
        if (!isNull _veh && {!local _veh}) then {_vehsToMove pushBackUnique _veh};
    } forEach units _x;
} forEach _grps;

if (_grpsToMove isEqualTo [] && {_vehsToMove isEqualTo []}) exitWith {};

[QGVAR(takeOwnership), [player, _grpsToMove, _vehsToMove]] call CBA_fnc_serverEvent;

// Count hulls as well as brains: a squad already local here can still be
// riding in a truck that is not, and reporting a bare "Ownership Transferred"
// for a three-vehicle convoy read as if only one thing had moved.
[LLSTRING(MsgOwnershipTransferred), (count _grpsToMove) max (count _vehsToMove)] call EFUNC(common,showCountMessage);
