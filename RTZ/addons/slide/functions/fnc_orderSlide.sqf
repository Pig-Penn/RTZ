#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: orders the Zeus-selected AI-driven land vehicles to drive
 * straight to the cursor — forward if the cursor is ahead of them, backward if
 * it is behind. Vehicles only travel in a straight line, so the cursor does not
 * name the destination directly: each vehicle's destination is the point on its
 * own fore-and-aft axis that the cursor position is abeam of. Select three
 * vehicles facing three ways and each drives along its own line, some forward
 * and some back, from the one keystroke.
 *
 * Which direction an order is, is therefore never chosen by the curator; it is
 * read off the sign of that projection, per vehicle. Only the dead zone abeam of
 * a vehicle — where neither direction has a straight-line answer — is rejected,
 * marked with a red destination icon on the vehicle it applies to.
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
 * vehicle gets its own targeted event (see FUNC(slideTo)).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * call rtz_slide_fnc_orderSlide
 *
 * Public: No
 */

// Zeus open, and not typing in ZEN's search box
CHECK_CURATOR_INPUT;

private _vehicles = ([SELECTED_OBJECTS] call EFUNC(common,collectVehicles)) select {
    [_x] call FUNC(canSlide)
};
if (_vehicles isEqualTo []) exitWith {false};

// Cursor → world position (AGL; only x/y are used). Intersections are off on
// purpose: the drive ends on the ground the vehicle is already standing on, so
// pointing through a wall or a treetop should still name the terrain beyond it.
(ASLToAGL ([nil, false] call zen_common_fnc_getPosFromScreen)) params ["_cursorX", "_cursorY"];

// Fallback matches the registered setting default (initSettings.inc.sqf) so a
// read before CBA_settingsInitialized behaves like the configured one
private _maxDistance = GETGVAR(maxDistance,50);

private _ordered = 0;

{
    private _vehicle = _x;
    private _origin = getPos _vehicle;

    // Fore-and-aft axis: the vehicle's facing flattened onto the ground plane. A
    // vehicle standing exactly on its nose or roof has no horizontal facing left
    // — vectorNormalized answers a zero vector rather than failing — so it has
    // no line to drive along, and the zero projection below drops it into the
    // rejection branch for free.
    (vectorDir _vehicle) params ["_dirX", "_dirY"];
    private _axis = vectorNormalized [_dirX, _dirY, 0];
    _axis params ["_axisX", "_axisY"];

    // How far ahead the cursor is: its projection onto that axis. Positive is in
    // front of the vehicle, negative behind it.
    private _distance = (_cursorX - (_origin select 0)) * _axisX + (_cursorY - (_origin select 1)) * _axisY;

    if (abs _distance < MIN_DISTANCE) then {
        // Cursor is abeam of this vehicle, or so close to it that the maneuver
        // would be over before it started
        [[["ICON", [_vehicle, ICON_MOVE, COLOR_INVALID]]], HINT_DURATION, _vehicle] call zen_common_fnc_drawHint;
        continue;
    };

    // Everything downstream — the record, the tick, the teardown — works on a
    // direction of TRAVEL and a speed, and never asks again which of the two
    // this was. Backing up is that axis flipped and the slower speed; that is
    // the entire difference between the two orders.
    private _speed = FORWARD_SPEED_MS;
    if (_distance < 0) then {
        _axis = [-_axisX, -_axisY, 0];
        _distance = -_distance;
        _speed = REVERSE_SPEED_MS;
    };

    private _destination = _origin vectorAdd (_axis vectorMultiply (_distance min _maxDistance));
    _destination set [2, 0];

    [QGVAR(slide), [_vehicle, _axis, _destination, _speed], _vehicle] call CBA_fnc_targetEvent;
    _ordered = _ordered + 1;

    [[
        ["ICON", [_destination, ICON_MOVE]],
        ["LINE", [_vehicle, _destination]]
    ], HINT_DURATION, _vehicle] call zen_common_fnc_drawHint;
} forEach _vehicles;

// Success reports with a count, so the curator can see the order landed on the
// whole selection and not just the vehicle he was pointing at. A partial reject
// is already legible as the red icons drawn above, so only a wholly rejected
// order — every selected vehicle abeam of the cursor — explains itself in words.
if (_ordered > 0) then {
    [LLSTRING(MsgDriving), _ordered] call EFUNC(common,showCountMessage);
} else {
    [LLSTRING(MsgAbeam)] call EFUNC(common,showCountMessage);
};

true
