#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: orders the Zeus-selected AI-driven land vehicles to back up
 * towards the cursor. Vehicles only reverse in a straight line, so the cursor
 * does not name the destination directly — each vehicle's destination is the
 * point on its own rear axis that the cursor position is abeam of. Select three
 * vehicles facing three ways and each backs up along its own line.
 *
 * An order with the cursor in front of a vehicle has no straight-line answer and
 * is rejected, marked with a red destination icon on the vehicle it applies to.
 *
 * Travel is capped at GVAR(maxDistance) so one keystroke cannot drag a column
 * across the map. The cap shortens the destination rather than refusing the
 * order, and the hint draws the shortened endpoint — what is drawn is what was
 * ordered.
 *
 * Selection goes through EFUNC(common,collectVehicles), so clicking a crewman
 * orders the vehicle he is riding in, matching every other RTZ vehicle order.
 *
 * Locality: runs on the curator's client, which owns the selection and the
 * cursor. The maneuver itself has to run where the vehicle is local, so each
 * vehicle gets its own targeted event (see FUNC(reverseTo)).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * call rtz_reverse_fnc_orderReverse
 *
 * Public: No
 */

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

private _vehicles = ([SELECTED_OBJECTS] call EFUNC(common,collectVehicles)) select {
    [_x] call FUNC(canReverse)
};
if (_vehicles isEqualTo []) exitWith {false};

// Cursor → world position (AGL; only x/y are used). Intersections are off on
// purpose: a reverse ends on the ground the vehicle is already standing on, so
// pointing through a wall or a treetop should still name the terrain behind it.
private _pos = ASLToAGL ([nil, false] call zen_common_fnc_getPosFromScreen);

// Fallback matches the registered setting default (initSettings.inc.sqf) so a
// read before CBA_settingsInitialized behaves like the configured one
private _maxDistance = GETGVAR(maxDistance,50);

private _ordered = 0;

{
    private _vehicle = _x;
    private _origin = getPos _vehicle;

    // Rear axis: the vehicle's facing flattened onto the ground plane and
    // flipped. A vehicle standing exactly on its nose or roof has no horizontal
    // facing left to flip — vectorNormalized answers a zero vector rather than
    // failing — so it has no rear to back towards, and the zero projection below
    // drops it into the rejection branch for free.
    (vectorDir _vehicle) params ["_dirX", "_dirY"];
    private _axis = vectorNormalized [-_dirX, -_dirY, 0];

    // How far back the cursor is: its projection onto the rear axis
    private _toCursor = _pos vectorDiff _origin;
    private _distance = (_toCursor select 0) * (_axis select 0) + (_toCursor select 1) * (_axis select 1);

    if (_distance < MIN_DISTANCE) then {
        // Cursor is in front of this vehicle, or so close behind it that the
        // maneuver would be over before it started
        [[["ICON", [_vehicle, ICON_MOVE, COLOR_INVALID]]], HINT_DURATION, _vehicle] call zen_common_fnc_drawHint;
        continue;
    };

    private _destination = _origin vectorAdd (_axis vectorMultiply (_distance min _maxDistance));
    _destination set [2, 0];

    [QGVAR(reverse), [_vehicle, _axis, _destination], _vehicle] call CBA_fnc_targetEvent;
    _ordered = _ordered + 1;

    [[
        ["ICON", [_destination, ICON_MOVE]],
        ["LINE", [_vehicle, _destination]]
    ], HINT_DURATION, _vehicle] call zen_common_fnc_drawHint;
} forEach _vehicles;

// Success reports with a count, so the curator can see the order landed on the
// whole selection and not just the vehicle he was pointing at. A partial reject
// is already legible as the red icons drawn above, so only a wholly rejected
// order — every selected vehicle facing the cursor — explains itself in words.
if (_ordered > 0) then {
    [LLSTRING(MsgReversing), _ordered] call EFUNC(common,showCountMessage);
} else {
    [LLSTRING(MsgNotBehind)] call EFUNC(common,showCountMessage);
};

true
