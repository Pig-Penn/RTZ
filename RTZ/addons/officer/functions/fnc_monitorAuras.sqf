#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER lifecycle loop for officer command auras: one low-rate CBA
 * perFrameHandler (AURA_INTERVAL) shared by every aura. Each pass:
 *
 * 1. Prunes auras whose officer died or was deleted, clearing his public
 *    GVAR(auraActive) flag so client menus recover.
 * 2. Builds the union of groups currently inside ANY aura. The zone is
 *    derived live from each officer's position — that is what makes the aura
 *    follow him for free. Only groups of the officer's own side count, and a
 *    group is inside while any member — on foot or crewing a vehicle — is
 *    within the radius. Group granularity is the engine's, not a choice:
 *    fleeing is a group behaviour and allowFleeing on a unit affects its
 *    whole group anyway.
 * 3. Diffs that union against the previous pass (GVAR(auraHeld)): groups that
 *    entered get the aura effects applied, groups that left get them
 *    released — each via QGVAR(auraApply) targeted at the group, so the
 *    command runs on the group's owner (server, HC, or a player leading AI).
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
    // Idle cost is one count per pass
    if (count GVAR(auras) == 0 && {GVAR(auraHeld) isEqualTo []}) exitWith {};

    private _inside = [];
    private _gone = [];

    {
        private _officer = objectFromNetId _x;

        if (isNull _officer || {!alive _officer}) then {
            if (!isNull _officer) then {SETPVAR(_officer,GVAR(auraActive),nil)};
            _gone pushBack _x;
            continue;
        };

        private _side = side group _officer;

        // Vehicle classes included because nearEntities does not return mounted
        // units as CAManBase — crews inside the zone must count too
        {
            private _units = if (_x isKindOf "CAManBase") then {[_x]} else {crew _x};

            {
                if (alive _x && {side group _x == _side}) then {
                    _inside pushBackUnique (group _x);
                };
            } forEach _units;
        } forEach (_officer nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], _y]);
    } forEach GVAR(auras);

    {GVAR(auras) deleteAt _x} forEach _gone;

    // Entered since last pass — apply effects once (see header on the diff trade-off)
    {
        if !(_x in GVAR(auraHeld)) then {
            [QGVAR(auraApply), [_x, true], _x] call CBA_fnc_targetEvent;
        };
    } forEach _inside;

    // Left since last pass — a wiped-out group is null and has nothing to release
    {
        if (!isNull _x && {!(_x in _inside)}) then {
            [QGVAR(auraApply), [_x, false], _x] call CBA_fnc_targetEvent;
        };
    } forEach GVAR(auraHeld);

    GVAR(auraHeld) = _inside;
}, AURA_INTERVAL, []] call CBA_fnc_addPerFrameHandler;
