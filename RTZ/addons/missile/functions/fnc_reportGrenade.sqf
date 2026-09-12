#include "script_component.hpp"
/*
 * Author: Maxim
 * Server half: coalesces throws onto one aim point, resolves the curators that own
 * anything near where the grenade is going, and pushes one packet to each of them.
 *
 * A grenade has no target OBJECT the way an incoming missile does — ZEN's action
 * aims at a point — so ownership cannot be answered by EFUNC(common,curatorsOf),
 * which takes one object. The loop below is that function inverted: gather the
 * entities near the point once with an engine spatial query, then ask each curator
 * whether any of them is theirs. It stays here rather than becoming a curatorsNear
 * helper in rtz_common because it has exactly one caller, and rtz_common is loaded
 * by every component in the mod.
 *
 * curatorEditableObjects materialises a curator's whole editable set, so it is by
 * far the expensive part of this path — hence FUNC(claimWindow) in front of it.
 *
 * The curator who ORDERED the throw is deliberately NOT excluded. A warning is about
 * troops under a grenade, not about whose grenade it is: a curator who owns men
 * inside the blast radius of an order somebody else's squad is carrying out wants to
 * see it, and one who lands a grenade on his own men wants to see that most of all.
 * An earlier version skipped whoever owned the THROWER, which was both a different
 * question — the ordering curator is not identifiable from here — and, combined with
 * the throw position being read from the thrower rather than the aim point, the
 * reason this fanned out to nobody in the common case.
 *
 * Arguments:
 * 0: Aim position ASL — where the grenade is going, NOT where it was thrown <ARRAY>
 * 1: Thrower's side <SIDE>
 *
 * Return Value:
 * None
 *
 * Example:
 * [[3200, 6100, 12], east] call rtz_missile_fnc_reportGrenade
 *
 * Public: No
 */

params ["_pos", "_side"];

if (!GVAR(grenadeEnabled)) exitWith {};

// One ZEN order is one warning. zen_context_actions_fnc_selectThrowPos hands every
// unit in the selection the SAME aim point, so a squad ordered to throw produces one
// identical position per man — the quantization is no longer absorbing a squad's
// spread, only float noise and two curators aiming at very nearly the same spot
// inside the window.
//
// The two cell indices stay SEPARATE, in an array key. Packing them into one number
// is what the obvious `xCell * stride + yCell` does, and it quietly destroys the y
// term: SQF Numbers are 32-bit floats and the packed key lands far above the 2^24
// they represent exactly. See GRENADE_COALESCE_CELL for the full reckoning — the
// short version is that a false merge here DROPS A WARNING, so the key has to be
// exact at map scale, and an array is the only form that is.
//
// Altitude is deliberately out of the key, so two throws at the same XY on different
// floors of one building coalesce. Accepted: GVAR(grenadeRadius) covers the whole
// building either way.
private _key = [
    floor ((_pos select 0) / GRENADE_COALESCE_CELL),
    floor ((_pos select 1) / GRENADE_COALESCE_CELL)
];

if !([GVAR(recentGrenades), _key, GRENADE_WINDOW, CBA_missionTime] call FUNC(claimWindow)) exitWith {};

// One engine spatial query at the AIM POINT instead of a walk over every curator's
// editable set looking for something close. nearEntities takes an AGL position, and
// its aliveOnly parameter defaults to true — so no `select {alive _x}` is layered on
// top of it, which would be a second walk and a second array for nothing.
//
// NOT filtered on simulationEnabled: CLAUDE.md's rule is about not iterating
// sleeping units in the mod's global passes, and this is a bounded result set — a
// grenade landing on a garrison whose simulation is off is exactly the moment that
// garrison starts mattering again.
private _nearby = (ASLToAGL _pos) nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], GVAR(grenadeRadius)];

if (_nearby isEqualTo []) exitWith {};

// objNull in both object slots because the marker is STATIC at the aim point and
// tracks nothing; the aim point itself rides in the fallback slot. The SIDE rather
// than a resolved colour, so the palette lookup happens once, client-side, in
// FUNC(receiveTrack) — same payload shape as FUNC(reportIncoming) builds.
private _payload = [objNull, objNull, _side, KIND_GRENADE, _pos];

{
    // Aliased because _x means the curator out here and an entity inside the findIf
    // below. Nested forEach/findIf do NOT clobber each other (Gotchas §2), so this is
    // for the reader rather than for correctness.
    private _curator = _x;

    // isNull first, as in EFUNC(common,curatorsOf) — a dead module must never trigger
    // a curatorEditableObjects call.
    if (isNull _curator) then {continue};

    // isPlayer, not isNull: a departed Zeus leaves a non-null server-local body
    // behind, and on a listen server that body's owner is the host — so an isNull
    // test would render a departed curator's warnings on the host's screen.
    private _player = getAssignedCuratorUnit _curator;
    if (!isPlayer _player) then {continue};

    private _editable = curatorEditableObjects _curator;

    if (_nearby findIf {_x in _editable} == -1) then {continue};

    [QGVAR(track), _payload, _player] call CBA_fnc_targetEvent;
} forEach allCurators;
