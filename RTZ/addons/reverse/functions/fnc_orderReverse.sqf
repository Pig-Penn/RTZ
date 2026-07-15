#include "script_component.hpp"
/*
 * Author: Maxim
 * Orders the selected AI-driven land vehicles to reverse towards the cursor
 * position. Vehicles only back up in a straight line, so each destination is
 * the point on the vehicle's rear axis that the cursor position is abeam of.
 * Orders with the cursor in front of a vehicle are rejected with a red hint.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_reverse_fnc_orderReverse
 *
 * Public: No
 */

// Terrain position under the cursor, works in both camera and map view
private _pos = ASLToAGL ([nil, false] call zen_common_fnc_getPosFromScreen);

{
    private _vehicle = _x;
    private _driver = driver _vehicle;

    if (
        _vehicle isKindOf "LandVehicle" && {canMove _vehicle}
        && {!isNull _driver} && {alive _driver} && {!isPlayer _driver}
    ) then {
        // Rear axis of the vehicle projected onto the ground plane
        private _rear = vectorDir _vehicle vectorMultiply -1;
        _rear set [2, 0];
        _rear = vectorNormalized _rear;

        private _toCursor = _pos vectorDiff getPosATL _vehicle;
        _toCursor set [2, 0];

        // Reverse far enough to bring the cursor position abeam
        private _distance = _toCursor vectorDotProduct _rear;

        if (_distance < MIN_DISTANCE) then {
            // Cursor is not behind the vehicle
            [[
                ["ICON", [_vehicle, ICON_MOVE, COLOR_INVALID]]
            ], HINT_DURATION, _vehicle] call zen_common_fnc_drawHint;
        } else {
            private _destination = getPosATL _vehicle vectorAdd (_rear vectorMultiply _distance);
            _destination set [2, 0];

            [QGVAR(reverse), [_vehicle, _destination], _vehicle] call CBA_fnc_targetEvent;

            [[
                ["ICON", [_destination, ICON_MOVE]],
                ["LINE", [_vehicle, _destination]]
            ], HINT_DURATION, _vehicle] call zen_common_fnc_drawHint;
        };
    };
} forEach (curatorSelected select 0);
