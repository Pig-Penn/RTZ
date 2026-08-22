#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the static weapons, or assembled drones, that can be
 * packed back into backpacks. Reverse of FUNC(collectAssembleSets): a selected
 * weapon contributes itself, a selected crewman contributes his mount, everything
 * else is discarded - which is exactly EFUNC(common,collectVehicles)' contract.
 *
 * Membership in GVAR(disassembleMap) is the only class filter (a class is in the map
 * exactly when it assembles from a bag) - class tree checks like isKindOf "UAV"
 * would miss the quadcopter family, which inherits from Helicopter_Base_H rather
 * than the legacy UAV class.
 *
 * A manned static needs its gunner: he performs the pack and receives the weapon
 * bag. A drone does not - its "gunner" is throwaway AI crew and the lightweight UAV
 * path returns the bag to the tagged operator instead - so it only has to be crewed,
 * which also keeps Disassemble from silently vanishing on drones whose crew fills no
 * gunner turret.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * Disassemble Sets <ARRAY of ARRAY> - one [weapon <OBJECT>, gunner <OBJECT>, weapon
 * bag <STRING>, support bags <ARRAY of STRING>] per weapon; the gunner is objNull
 * for a drone. [] when nothing selected can be disassembled.
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_collectDisassembleSets
 *
 * Public: No
 */

params ["_objects"];

private _sets = [];

{
    private _info = GVAR(disassembleMap) getOrDefault [toLowerANSI typeOf _x, []];

    // Skip one already being packed, so the context action can't offer an order
    // FUNC(disassembleWeapon)'s double-order guard would only drop. The claim is a
    // CBA_missionTime deadline rather than a flag (see FUNC(disassembleWeapon)), so
    // one stranded by a re-tasked assistant lapses back into the menu on its own
    if (_info isNotEqualTo [] && {alive _x} && {CBA_missionTime >= (_x getVariable [QGVAR(packing), 0])}) then {
        _info params ["_weaponBag", "_baseBags"];

        if (unitIsUAV _x) then {
            if (crew _x isNotEqualTo []) then {
                _sets pushBack [_x, objNull, _weaponBag, _baseBags];
            };
        } else {
            private _gunner = gunner _x;

            if (!isNull _gunner) then {
                _sets pushBack [_x, _gunner, _weaponBag, _baseBags];
            };
        };
    };
} forEach ([_objects] call EFUNC(common,collectVehicles));

_sets
