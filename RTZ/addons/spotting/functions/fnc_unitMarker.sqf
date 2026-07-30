#include "script_component.hpp"
/*
 * Author: Maxim
 * NATO map-marker symbol classification for a group. sideIdx (0 = west,
 * 1 = east, 2 = other) indexes the client's per-side tuning tables.
 *
 * There is no engine command that yields a unit's military symbol (the MARTA /
 * Military Symbols system assigns them internally but exposes no getter), so the
 * type is classified from isKindOf + config — mirroring ACE3's
 * ace_common_fnc_getMarkerType, with extra UAV / cargo handling — then mapped to
 * the vanilla marker textures in \a3\ui_f\data\map\markers\nato\ . Those paths
 * are used directly rather than via CfgMarkers, because some CfgMarkers entries
 * (e.g. b_naval) resolve to "".
 *
 * Arguments:
 * 0: Unit — pass the GROUP LEADER so the symbol represents the whole group. May be
 *    a vehicle rather than a man (FUNC(spotCheck) anchors on a hull when the group's
 *    leader is not spottable), in which case that vehicle is classified <OBJECT>
 * 1: Headquarters/command element — forces the staff symbol <BOOL> (default: false)
 *
 * Return Value:
 * [texturePath <STRING>, colorArray <ARRAY>, sideIdx <NUMBER>]
 *
 * Example:
 * [_leader, false] call rtz_spotting_fnc_unitMarker
 *
 * Public: No
 */

params ["_unit", ["_isHQ", false]];

private _unitSide = side _unit;
private _sideIdx = switch (_unitSide) do {
    case west: { 0 };
    case east: { 1 };
    default    { 2 };   // independent / civilian → neutral (square) frame
};
private _prefix = ["b_", "o_", "n_"] select _sideIdx;
private _color = [_unitSide] call EFUNC(common,sideColor);

// Vehicle to classify by, or objNull for the on-foot symbol. objectParent, not
// vehicle: it already yields objNull on foot, whereas `vehicle` returns the unit
// and needs a `== _unit` sentinel to mean the same thing — a sentinel that cannot
// distinguish a man on foot from an argument that IS a vehicle. typeOf objNull is ""
// and objNull isKindOf is always false, so the on-foot case falls through the
// exceptions below untouched.
private _veh = objNull;
if (_unit isKindOf "CAManBase") then {
    // Vehicle the man occupies. Parachutes and non-mortar static weapons count as
    // on-foot so their crew keeps an infantry symbol.
    _veh = objectParent _unit;
    if (typeOf _veh == "Steerable_Parachute_F"
        || { _veh isKindOf "StaticWeapon" && { !(_veh isKindOf "StaticMortar") } }
    ) then { _veh = objNull };
} else {
    // Not a man. FUNC(spotCheck) anchors a group on a vehicle hull whenever the
    // group's own leader is not itself spottable (a player-led enemy squad, or a
    // UAV whose AI crew are absent from allUnits), so classify the hull directly —
    // its own objectParent is objNull, which would read as "on foot".
    _veh = _unit;
};

// Everything below the HQ and cargo tests is class-invariant, so the resolved
// suffix is cached per class in GVAR(markerSuffixCache) (created by
// FUNC(spottingSystem)) — each man/vehicle class pays its config lookups once
// per mission instead of once per spotted group per tick.
private _suffix = call {
    // A headquarters / command element takes the staff symbol outright, whatever it's in.
    if (_isHQ) exitWith { "hq" };

    // On foot (also static-weapon crew & parachutists, via _veh = objNull above).
    // Only a man reaches this — a non-man argument keeps _veh = _unit above.
    if (isNull _veh) exitWith {
        private _key = "m" + typeOf _unit;
        private _s   = GVAR(markerSuffixCache) get _key;
        if (isNil "_s") then {
            // Recon: stealthy, high-detection, or diver units (ACE getMarkerType heuristic).
            _s = ["inf", "recon"] select (getNumber (configOf _unit >> "detectSkill") > 20
                || { getNumber (configOf _unit >> "camouflage") < 1 }
                || { getText (configOf _unit >> "textsingular") == "diver" });
            GVAR(markerSuffixCache) set [_key, _s];
        };
        _s
    };

    if (((assignedVehicleRole _unit) param [0, ""]) == "cargo") exitWith { "inf" };        // passengers being transported

    private _key = "v" + typeOf _veh;
    private _s   = GVAR(markerSuffixCache) get _key;
    if (isNil "_s") then {
        _s = call {
            if (unitIsUAV _veh)                                         exitWith { "uav" };
            if (getNumber (configOf _veh >> "attendant") == 1)          exitWith { "med" };         // medical vehicle
            if (getNumber (configOf _veh >> "transportRepair") > 0
                || { getNumber (configOf _veh >> "transportFuel") > 0 }
                || { getNumber (configOf _veh >> "transportAmmo")  > 0 }) exitWith { "maint" };     // repair / fuel / ammo support
            if (_veh isKindOf "Plane")                                  exitWith { "plane" };
            if (_veh isKindOf "Air")                                    exitWith { "air" };         // helicopters / rotary
            if (_veh isKindOf "StaticMortar")                           exitWith { "mortar" };
            if (getNumber (configOf _veh >> "artilleryScanner") == 1)   exitWith { "art" };         // self-propelled artillery
            if (_veh isKindOf "Car")                                    exitWith { "motor_inf" };   // wheeled transport (incl. wheeled APCs)
            if (_veh isKindOf "Tank") exitWith {
                // Tracked: troop-carrying IFV/APC → mechanised; otherwise an MBT → armour.
                ["armor", "mech_inf"] select (getNumber (configOf _veh >> "transportSoldier") > 0)
            };
            if (_veh isKindOf "Ship")                                   exitWith { "naval" };
            "unknown"
        };
        GVAR(markerSuffixCache) set [_key, _s];
    };
    _s
};

[format ["\a3\ui_f\data\map\markers\nato\%1%2.paa", _prefix, _suffix], _color, _sideIdx]
