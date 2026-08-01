#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(dismount) (registered on EVERY machine in
 * XEH_postInit, delivered by FUNC(setDismount) to the vehicle's OWNER).
 *
 * Lets a curator stop the AI crew/cargo of a transport from bailing out. Vital
 * for RTS-style troop movement: without it, AI dumps its infantry the instant
 * the vehicle is shot at OR immobilised, stranding a squad mid-map.
 *
 * Two engine levers are flipped together (neither affects combat mode,
 * targeting, formation or pathing — purely whether bodies leave the seat):
 *   setUnloadInCombat   [allowCargo, allowTurrets]  — bail-out when in combat
 *   allowCrewInImmobile [brokenWheels, upsideDown]  — bail-out when disabled/flipped
 * Both need the vehicle LOCAL, which is why this runs on the owner rather than
 * on the curator's client.
 *
 * The flags alone are NOT enough with LAMBS loaded: its vehicle brain
 * force-ejects APC/tank cargo by script (action ["Eject"]) without consulting
 * them, so while locked every occupant is also tagged with
 * lambs_danger_disableAI — the same lever LAMBS' own ZEN "Disable AI" action
 * sets, and the one its per-unit danger FSM exits early on. Only tags WE set
 * are cleared (tracked via the public QGVAR(dismountLambsTag) marker), so a
 * mission maker's own disableAI survives the round-trip. Public setVariable
 * because a cargo group may be owned by a different machine than the vehicle.
 * Harmless no-op when LAMBS isn't loaded.
 *
 * _allow == true  -> vanilla bail-out behaviour
 * _allow == false -> crew/cargo stay put (in combat AND when dead/flipped)
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Allow bail-out <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, false] call rtz_control_fnc_dismountApply
 *
 * Public: No
 */

params ["_veh", "_allow"];

if (isNull _veh) exitWith {};

_veh setUnloadInCombat   [_allow, _allow];       // cargo, turrets
_veh allowCrewInImmobile [!_allow, !_allow];     // brokenWheels, upsideDown

if (_allow) exitWith {
    // Release: untag only the occupants this system tagged.
    {
        if (_x getVariable [QGVAR(dismountLambsTag), false]) then {
            SETPVAR(_x,lambs_danger_disableAI,false);
            SETPVAR(_x,GVAR(dismountLambsTag),false);
        };
    } forEach (crew _veh);
};

{
    if !(_x getVariable ["lambs_danger_disableAI", false]) then {
        SETPVAR(_x,lambs_danger_disableAI,true);
        SETPVAR(_x,GVAR(dismountLambsTag),true);
    };
} forEach (crew _veh);

// Late boarders need tagging too, and a unit Zeus ejects out of a locked
// vehicle needs its AI back. Both handlers are added ONCE per vehicle per
// machine and then left in place, self-gating on the public
// QGVAR(dismountAllowed) marker — deliberately NOT removed on unlock.
//
// Event handler indices are machine-local, so storing them to remove later only
// works while the vehicle never changes owner: after a setOwner (rtz_control's
// own FUNC(takeOwnershipApply) does exactly that) the unlock lands on a machine
// holding no indices, and the handlers leak on the old one. Leaving them
// installed and inert removes the bookkeeping and the leak together — the
// marker below is local because what it guards is local.
if (_veh getVariable [QGVAR(dismountEHs), false]) exitWith {};
SETVAR(_veh,GVAR(dismountEHs),true);

_veh addEventHandler ["GetIn", {
    params ["_veh", "", "_unit"];
    if (_veh getVariable [QGVAR(dismountAllowed), true]) exitWith {};
    if (_unit getVariable ["lambs_danger_disableAI", false]) exitWith {};
    SETPVAR(_unit,lambs_danger_disableAI,true);
    SETPVAR(_unit,GVAR(dismountLambsTag),true);
}];

_veh addEventHandler ["GetOut", {
    params ["", "", "_unit"];
    if !(_unit getVariable [QGVAR(dismountLambsTag), false]) exitWith {};
    SETPVAR(_unit,lambs_danger_disableAI,false);
    SETPVAR(_unit,GVAR(dismountLambsTag),false);
}];
