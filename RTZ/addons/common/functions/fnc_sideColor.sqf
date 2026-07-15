#include "script_component.hpp"
/*
 * Author: Maxim
 * Canonical RTZ side palette (alpha 1). One source of truth for every marker /
 * indicator colour, shared by the spotting system and the remote-control
 * indicator; callers wanting a different alpha rebuild the array from the RGB.
 *
 * The leader palette is the brighter "own-group" set used for NCOs — units
 * whose class display name contains "leader" (see FUNC(classInfo)) — so
 * leadership reads at a glance.
 *
 * Arguments:
 * 0: Unit's side <SIDE>
 * 1: Use the brighter NCO/leader palette <BOOL> (default: false)
 *
 * Return Value:
 * Color <ARRAY> — [r, g, b, 1]
 *
 * Example:
 * [west, true] call rtz_common_fnc_sideColor
 *
 * Public: No
 */

params ["_side", ["_isLeader", false]];

if (_isLeader) exitWith {
    switch (_side) do {
        case west:        { [0.00, 0.45, 1.00, 1.00] };
        case east:        { [0.80, 0.35, 0.00, 1.00] };
        case independent: { [0.34, 0.75, 0.00, 1.00] };
        default           { [0.70, 0.00, 0.75, 1.00] };
    }
};

switch (_side) do {
    case west:        { [0.00, 0.30, 0.60, 1.00] };
    case east:        { [0.50, 0.00, 0.00, 1.00] };
    case independent: { [0.00, 0.50, 0.00, 1.00] };
    // Civilian/unknown: purple (Arma convention), the darker sibling of the
    // leader palette's default — previously duplicated independent's green,
    // making civilian and independent markers indistinguishable
    default           { [0.40, 0.00, 0.50, 1.00] };
}
