#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu condition for the "Take Ownership" action: true when the
 * selection holds a group (or a vehicle it is riding in) that is NOT local to
 * this client.
 *
 * Zeus places objects local to the curator who placed them. When that curator
 * disconnects the engine hands everything he owned to the server, and rejoining
 * gives him a new client ID — so his pre-disconnect units stay server-simulated
 * while anything he places now is client-simulated. The old ones then feel
 * sluggish next to the new ones: they run at the (usually CPU-bound) server's
 * simulation rate, every order costs a network round trip, and their AI skill
 * coefficients come from the server's difficulty settings rather than his.
 * Editability is a separate list and survives the rejoin untouched, which is
 * why the units still look perfectly controllable.
 *
 * Groups holding a player are never offered — they belong to that player's
 * machine by definition and setGroupOwner must not move them.
 *
 * Arguments:
 * 0: Selection objects <ARRAY>
 * 1: Hovered entity <OBJECT>
 *
 * Return Value:
 * Selection has a transferable non-local group <BOOL>
 *
 * Example:
 * [_objects, _hoveredEntity] call rtz_control_fnc_canTakeOwnership
 *
 * Public: No
 */

params ["_objects", "_hoveredEntity"];

if (isNull getAssignedCuratorLogic player) exitWith { false };

private _grps = [_objects + [_hoveredEntity]] call EFUNC(common,collectSquads);
if (_grps isEqualTo []) exitWith { false };

_grps findIf {
    private _grp = _x;
    units _grp findIf {isPlayer _x} == -1
    && {
        !local _grp
        // objectParent is objNull for a man on foot, so this is the same test
        // as `vehicle _x isNotEqualTo _x` without evaluating `vehicle` twice.
        || {units _grp findIf {!isNull objectParent _x && {!local objectParent _x}} != -1}
    }
} != -1
