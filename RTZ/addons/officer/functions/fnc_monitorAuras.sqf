#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER lifecycle loop for officer command auras: one low-rate CBA
 * perFrameHandler (AURA_INTERVAL) shared by every aura. Each pass:
 *
 * 1. Prunes auras whose officer died or was deleted, clearing his public
 *    GVAR(auraActive) flag so client menus recover and broadcasting a
 *    QGVAR(auraZone) removal so the map ring (FUNC(initCuratorDisplay)) does
 *    not linger on a dead anchor — normal toggle-off already does this in
 *    FUNC(applyAura); this is the death/delete path it can't reach. The
 *    matching JIP-stack entry goes with it, or a later joiner would replay the
 *    add and draw a ring for an aura that ended when its officer did.
 * 2. Builds the union of groups currently inside ANY aura. The zone is
 *    derived live from each officer's position — that is what makes the aura
 *    follow him for free. Only groups of the officer's own side count, and a
 *    group is inside while any member — on foot or crewing a vehicle — is
 *    within the radius. Group granularity is the engine's, not a choice:
 *    fleeing is a group behaviour and allowFleeing on a unit affects its
 *    whole group anyway.
 * 3. Diffs that union against the previous pass (GVAR(auraHeld)): groups that
 *    entered get the aura effects applied, groups that left get them
 *    released — each via QGVAR(applyAuraEffects) targeted at the group, so the
 *    command runs on the group's owner (server, HC, or a player leading AI).
 *
 * Both sides of the diff are HashMaps keyed by group netId, not arrays: the
 * membership tests run once per unit inside a zone and once per group on each
 * side of the diff, so arrays would make the whole pass quadratic in the number
 * of units under an aura — the one place in this component that scales with
 * mission size.
 *
 * The diff means effects are applied ONCE on entry, never re-asserted — if a
 * mission script fights over allowFleeing the aura does not re-win until the
 * group leaves and re-enters. Deliberate cheap-over-perfect trade for a loop
 * that runs for the whole mission.
 *
 * Overlapping auras are handled by the union: a group leaving one aura while
 * still inside another is never released.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_officer_fnc_monitorAuras
 *
 * Public: No
 */

if (!isServer) exitWith {};

[{
    // Idle cost is two counts per pass
    if (count GVAR(auras) == 0 && {count GVAR(auraHeld) == 0}) exitWith {};

    // groupNetId -> group, for every group under ANY aura this pass
    private _inside = createHashMap;
    private _gone = [];

    {
        private _officer = objectFromNetId _x;

        if (isNull _officer || {!alive _officer}) then {
            if (!isNull _officer) then {SETPVAR(_officer,GVAR(auraActive),nil)};
            _gone pushBack _x;
            [QGVAR(auraZone), ["remove", _x]] call CBA_fnc_globalEvent;
            [AURA_ZONE_JIP_ID(_x)] call CBA_fnc_removeGlobalEventJIP;
            continue;
        };

        private _side = side group _officer;

        // Vehicle classes included because nearEntities does not return mounted
        // units as CAManBase — crews inside the zone must count too
        {
            private _units = if (_x isKindOf "CAManBase") then {[_x]} else {crew _x};

            {
                if (alive _x) then {
                    // Overwriting an already-recorded group is what makes the
                    // union free — no uniqueness scan, and overlapping auras
                    // simply write the same key twice
                    private _group = group _x;
                    if (side _group == _side) then {
                        _inside set [netId _group, _group];
                    };
                };
            } forEach _units;
        } forEach (_officer nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], _y]);
    } forEach GVAR(auras);

    {GVAR(auras) deleteAt _x} forEach _gone;

    // Entered since last pass — apply effects once (see header on the diff trade-off)
    {
        if !(_x in GVAR(auraHeld)) then {
            [QGVAR(applyAuraEffects), [_y, true], _y] call CBA_fnc_targetEvent;
        };
    } forEach _inside;

    // Left since last pass — a wiped-out group is null and has nothing to release
    {
        if (!isNull _y && {!(_x in _inside)}) then {
            [QGVAR(applyAuraEffects), [_y, false], _y] call CBA_fnc_targetEvent;
        };
    } forEach GVAR(auraHeld);

    GVAR(auraHeld) = _inside;
}, AURA_INTERVAL, []] call CBA_fnc_addPerFrameHandler;
