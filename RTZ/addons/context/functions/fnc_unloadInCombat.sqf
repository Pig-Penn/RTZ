#include "script_component.hpp"
/*
 * rtz_fnc_unloadInCombat
 *
 * Lets a curator stop the AI crew/cargo of a selected transport from bailing
 * out. Vital for RTS-style troop movement: without it, AI dumps its infantry
 * the instant the vehicle is shot at OR immobilised, stranding a squad mid-map.
 *
 * Two engine levers are flipped together (neither affects combat mode,
 * targeting, formation or pathing — purely whether bodies leave the seat):
 *   setUnloadInCombat  [allowCargo, allowTurrets]  — bail-out when in combat
 *   allowCrewInImmobile [brokenWheels, upsideDown] — bail-out when disabled/flipped
 * The flags alone are NOT enough with LAMBS loaded: its vehicle brain
 * force-ejects APC/tank cargo by script (action ["Eject"]) without consulting
 * them, so the apply handler also suppresses the LAMBS danger FSM for everyone
 * aboard while locked (see the handler comment below).
 *
 * Locality: the handler must run where the VEHICLE is local —
 * fnc_setUnloadInCombat routes it there via the QGVAR(applyUnloadFlags) CBA
 * target event. The chosen state is stored as a public vehicle variable
 * (GVAR(unloadInCombat)) so the toggle stays deterministic and JIP-consistent.
 *
 * Trigger it with a Zeus Enhanced right-click toggle action "Forbid/Allow Dismount" on a
 * selected/hovered vehicle (or its crew).
 *
 * Requires CBA_A3; the context action also requires Zeus Enhanced.
 * Loading: spawned from XEH_postInit once CBA settings are initialised.
 */

// ─────────────────────────────────────────────────────────────────────────────
// EVERY MACHINE (incl. dedicated server / HC) — the apply event handler.
// Registered before the interface guard because CBA_fnc_targetEvent fires it on
// the vehicle's owner, which on a dedicated server or HC has no interface.
//
// _allow == true  -> vanilla bail-out behaviour
// _allow == false -> crew/cargo stay put (in combat AND when the vehicle is dead/flipped)
// ─────────────────────────────────────────────────────────────────────────────

[QGVAR(applyUnloadFlags), {
    params ["_veh", "_allow"];
    if (isNull _veh) exitWith {};

    _veh setUnloadInCombat  [_allow, _allow];        // cargo, turrets
    _veh allowCrewInImmobile [!_allow, !_allow];     // brokenWheels, upsideDown

    // LAMBS suppression. Its per-unit danger FSM exits early when the unit
    // carries lambs_danger_disableAI (the same lever LAMBS' own ZEN "Disable
    // AI" action sets), so while locked every occupant is tagged and a GetIn
    // EH tags late boarders; GetOut / unlock untags. Only tags WE set are
    // cleared (tracked via the public QGVAR(lambsTag) marker), so a mission
    // maker's own disableAI survives the round-trip. Public setVariable
    // because a cargo group may be owned by a different machine than the
    // vehicle. Harmless no-op when LAMBS isn't loaded.
    if (_allow) then {
        {
            if (_x getVariable [QGVAR(lambsTag), false]) then {
                SETPVAR(_x,lambs_danger_disableAI,false);
                SETPVAR(_x,GVAR(lambsTag),false);
            };
        } forEach (crew _veh);

        (_veh getVariable [QGVAR(lockEHs), []]) params [["_getIn", -1], ["_getOut", -1]];
        if (_getIn  != -1) then { _veh removeEventHandler ["GetIn",  _getIn]  };
        if (_getOut != -1) then { _veh removeEventHandler ["GetOut", _getOut] };
        _veh setVariable [QGVAR(lockEHs), nil];
    } else {
        {
            if !(_x getVariable ["lambs_danger_disableAI", false]) then {
                SETPVAR(_x,lambs_danger_disableAI,true);
                SETPVAR(_x,GVAR(lambsTag),true);
            };
        } forEach (crew _veh);

        if ((_veh getVariable [QGVAR(lockEHs), []]) isEqualTo []) then {
            private _getIn = _veh addEventHandler ["GetIn", {
                params ["_veh", "", "_unit"];
                if (_veh getVariable [QGVAR(unloadInCombat), true]) exitWith {};
                if (_unit getVariable ["lambs_danger_disableAI", false]) exitWith {};
                SETPVAR(_unit,lambs_danger_disableAI,true);
                SETPVAR(_unit,GVAR(lambsTag),true);
            }];
            // Zeus can still eject a unit from a locked vehicle — restore its AI.
            private _getOut = _veh addEventHandler ["GetOut", {
                params ["", "", "_unit"];
                if !(_unit getVariable [QGVAR(lambsTag), false]) exitWith {};
                SETPVAR(_unit,lambs_danger_disableAI,false);
                SETPVAR(_unit,GVAR(lambsTag),false);
            }];
            _veh setVariable [QGVAR(lockEHs), [_getIn, _getOut]];
        };
    };
}] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

// ─────────────────────────────────────────────────────────────────────────────
// INTERFACE MACHINES — context action + keybind (curator-facing)
// The helper functions (collectVehicles, setUnloadInCombat, toggleUnloadInCombat,
// dismountActionModifier) are compiled via PREP and called here by name rather
// than defined inline; feedback toasts go through zen_common_fnc_showMessage.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Zeus Enhanced right-click context action
//
// A single toggle entry at the top of the Control submenu (RTZ_Control)
// whose label and icon tint track the hovered/selected vehicle's current
// state (ZEN's own pattern for toggle actions): amber padlock "Forbid
// Dismount" while vanilla, cyan "Allow Dismount" once locked.
// ─────────────────────────────────────────────────────────────────────────────

private _action = [
    "RTZ_ToggleDismount",
    "Forbid Dismount",                                              // default label/icon; replaced by modifier
    ["\a3\modules_f\data\iconlock_ca.paa", [1.00, 0.78, 0.22, 1]],
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
        params ["", "_objects"];
        [_objects] call FUNC(toggleUnloadInCombat);
    },
    {
        // Static weapons (HMGs, mortars, GMGs) have no dismount concept — exclude them
        // so the toggle never shows on a bare static turret selection.
        params ["", "_objects"];
        (([_objects] call EFUNC(common,collectVehicles)) findIf { !(_x isKindOf "StaticWeapon") }) != -1
    },
    [],                          // args
    {},                          // insertChildren
    FUNC(dismountActionModifier) // modifierFunction
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Control"], 0] call zen_context_menu_fnc_addAction;
