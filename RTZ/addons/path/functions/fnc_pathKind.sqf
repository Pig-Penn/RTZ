#include "script_component.hpp"
/*
 * Author: Maxim
 * Classifies an entity for path planning, and by doing so decides whether it
 * can be pathed at all: KIND_NONE is the "no" answer, so one call filters a
 * selection and labels what survives in a single pass.
 *
 * The single definition of "pathable", shared by the places that must agree on
 * it — FUNC(beginPlanning) building the session, FUNC(commitPaths) re-checking
 * before it orders, and (after the network hop) the executor on the owning
 * machine. Same three-call-site role as rtz_reverse's FUNC(canReverse).
 *
 * Takes a HULL: a man on foot, or a vehicle. A crewman is never passed here —
 * FUNC(beginPlanning) resolves a selected crewman to his vehicle first, matching
 * every other RTZ vehicle order.
 *
 * Boats are detected by the "canFloat" config flag rather than `isKindOf "Ship"`
 * alone, so amphibious land vehicles (BTR, AAV) are still classified KIND_LAND —
 * they steer like land vehicles and setDriveOnPath works on them, which it does
 * not on a true Ship.
 *
 * Deliberately says nothing about locality: the curator's client evaluates this
 * for units it does not own, and locality is checked where the path actually
 * runs.
 *
 * One caveat that follows from that. AI feature flags do not travel with
 * ownership (Gotchas §4 — rtz_captive re-applies its own on a "Local" event), so
 * the checkAIFeature read below is only authoritative on the owning machine. A
 * curator can therefore draw a path for a unit whose PATH is disabled
 * elsewhere; FUNC(startFollow) re-runs this on the owner and declines it there,
 * so the order is dropped rather than half-applied.
 *
 * Arguments:
 * 0: Man on foot or vehicle <OBJECT>
 *
 * Return Value:
 * KIND_INFANTRY / KIND_LAND / KIND_AIR / KIND_BOAT, or KIND_NONE <NUMBER>
 *
 * Example:
 * private _kind = [_vehicle] call rtz_path_fnc_pathKind
 *
 * Public: No
 */

params ["_hull"];

if (isNull _hull || {!alive _hull} || {!canMove _hull}) exitWith {KIND_NONE};

// Whoever will receive the order: the man himself, or the vehicle's driver.
private _unit = if (_hull isKindOf "CAManBase") then {_hull} else {driver _hull};

// No driver means nothing to order; a player at the controls — including a
// curator remote-controlling the unit, which isPlayer also reports — drives
// himself and must not have a path pushed under him.
if (isNull _unit || {!alive _unit} || {isPlayer _unit}) exitWith {KIND_NONE};

// A unit whose PATH feature is off cannot navigate, so a path would be issued
// and silently ignored. LAMBS gates its own move orders the same way
// (lambs_main_fnc_doAssault), and RTZ's own planning freeze sets exactly this
// flag — so this is also what stops a second planning session being opened
// against units the first one froze.
if (!(_unit checkAIFeature "PATH")) exitWith {KIND_NONE};

if (_hull isKindOf "CAManBase") exitWith {
    // A man riding in something is pathed through his vehicle, not on his own
    if (!isNull objectParent _hull) exitWith {KIND_NONE};
    KIND_INFANTRY
};

// Statics are excluded explicitly rather than left to canMove: StaticWeapon
// inherits from LandVehicle and passes canMove, so the config hierarchy is the
// only thing keeping a mortar out of a driving path.
if (_hull isKindOf "StaticWeapon" || {_hull isKindOf "Static"} || {_hull isKindOf "Logic"}) exitWith {KIND_NONE};

if (_hull isKindOf "Air") exitWith {KIND_AIR};

// True boats only. An amphibious LandVehicle also floats, but it drives, so it
// stays KIND_LAND and keeps the engine-driven executor.
if (_hull isKindOf "Ship" && {!(_hull isKindOf "LandVehicle")}) exitWith {KIND_BOAT};

if (_hull isKindOf "LandVehicle") exitWith {KIND_LAND};

KIND_NONE
