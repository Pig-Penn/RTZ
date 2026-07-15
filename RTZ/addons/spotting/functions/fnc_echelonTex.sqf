#include "script_component.hpp"
/*
 * rtz_fnc_echelonTex
 *
 * Echelon/size amplifier texture (group_N.paa, the same set High Command uses;
 * the scale runs 0 = fire team … 11 = army group), or "" for none. Only combat
 * infantry get a dot: on foot, riding as cargo, or — for a vehicle crew — when
 * the vehicle is actually carrying infantry in its cargo seats (sized by that
 * cargo). Pure vehicles (tanks, empty transports, etc.) get no dot. Thresholds
 * tuned for AI group sizes.
 *
 * Arguments:
 *   0: Unit (group leader) <OBJECT>
 *   1: Group member count <NUMBER>
 *
 * Return: texture path <STRING>, or "" for no amplifier
 */

params ["_unit", "_grpCount"];

private _veh = vehicle _unit;

private _count = call {
    // On foot — incl. static (non-mortar) weapon crews and parachutists, which the
    // symbol also classifies as infantry.
    if (_veh == _unit
        || { typeOf _veh == "Steerable_Parachute_F" }
        || { _veh isKindOf "StaticWeapon" && { !(_veh isKindOf "StaticMortar") } }
    ) exitWith { _grpCount };
    if (((assignedVehicleRole _unit) param [0, ""]) == "cargo") exitWith { _grpCount };   // transported as cargo
    // Vehicle crew: a dot only if the vehicle carries combat infantry in cargo.
    { alive _x && { _x isKindOf "CAManBase" } && { ((assignedVehicleRole _x) param [0, ""]) == "cargo" } } count (crew _veh)
};

// Dots scale by squads (breakpoints #defined in script_component.hpp):
//   1 squad → 1 dot, 1–2 squads → 2 dots, 2+ squads → 3 dots.
private _n = call {
    if (_count <= 1)                     exitWith { -1 };   // lone — no dot
    if (_count <= ECHELON_FIRETEAM_MAX)  exitWith {  0 };   // fire team (sub-squad)
    if (_count <= ECHELON_SQUAD_MAX)     exitWith {  1 };   // ~1 squad → 1 dot
    if (_count <= ECHELON_MULTI_SQUAD_MAX) exitWith { 2 };   // 1–2 squads → 2 dots
    3                                    // 2+ squads → 3 dots
};

if (_n < 0) then { "" } else { format ["\a3\ui_f\data\map\markers\nato\group_%1.paa", _n] }
