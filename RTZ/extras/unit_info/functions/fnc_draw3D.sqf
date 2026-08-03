#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws a health bar and info text above each tracked unit. Called every frame.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_unit_info_fnc_draw3D
 *
 * Public: No
 */

private _camPosASL = AGLToASL positionCameraToWorld [0, 0, 0];
private _maxDistanceSqr = GVAR(maxDistance) * GVAR(maxDistance);
private _scale = GVAR(scale);
private _textSize = TEXT_SIZE * _scale;
private _uiScale = getResolution select 5;
private _textOffsetY = TEXT_OFFSET_Y * _scale * _uiScale;
private _ammoOffsetY = AMMO_OFFSET_Y * _scale * _uiScale;
private _prune = false;

{
    private _unit = _x;

    if (isNull _unit) then {
        _prune = true;
        continue;
    };

    private _alive = alive _unit;

    if (!_alive && {GVAR(removeOnDeath)}) then {
        _unit setVariable [QGVAR(tracked), nil];
        _unit setVariable [QGVAR(data), nil];
        _prune = true;
        continue;
    };

    private _posASL = getPosASLVisual _unit;
    private _distanceSqr = _posASL vectorDistanceSqr _camPosASL;
    if (_distanceSqr > _maxDistanceSqr) then {continue};

    (_unit getVariable QGVAR(data)) params ["_height", "_name", "_sideColor"];

    private _posAGL = ASLToAGL _posASL;
    _posAGL set [2, (_posAGL select 2) + _height];

    private _health = ([0, 1 - damage _unit] select _alive) max 0;
    private _unconscious = _alive && {lifeState _unit == "INCAPACITATED"};

    // Health bar background, fill is drawn on top and shrinks towards the center
    drawIcon3D [BAR_TEXTURE, COLOR_BACKGROUND, _posAGL, BAR_WIDTH * _scale, BAR_HEIGHT * _scale, 0, "", 0];

    if (_health > 0) then {
        private _barColor = if (_unconscious) then {
            COLOR_BAR_UNCONSCIOUS
        } else {
            // Green to yellow to red gradient
            [linearConversion [0.5, 1, _health, 1, 0, true], linearConversion [0, 0.5, _health, 0, 1, true], 0, BAR_ALPHA]
        };

        drawIcon3D [BAR_TEXTURE, _barColor, _posAGL, BAR_WIDTH * _scale * _health, BAR_HEIGHT * _scale, 0, "", 0];
    };

    // Ammo bar below the health bar, based on the current magazine (dismounted units only)
    if (GVAR(showAmmo) && {_alive} && {isNull objectParent _unit}) then {
        private _weapon = currentWeapon _unit;

        if (_weapon isNotEqualTo "") then {
            drawIcon3D [BAR_TEXTURE, COLOR_BACKGROUND, _posAGL, BAR_WIDTH * _scale, AMMO_BAR_HEIGHT * _scale, 0, "", 0, 0, TEXT_FONT, "center", false, 0, _ammoOffsetY];

            private _magazine = currentMagazine _unit;

            if (_magazine isNotEqualTo "") then {
                private _capacity = GVAR(magazineCapacities) getOrDefaultCall [_magazine, {
                    getNumber (configFile >> "CfgMagazines" >> _magazine >> "count") max 1
                }, true];

                private _ammoFraction = ((_unit ammo _weapon) / _capacity) min 1;

                if (_ammoFraction > 0) then {
                    drawIcon3D [BAR_TEXTURE, COLOR_AMMO, _posAGL, BAR_WIDTH * _scale * _ammoFraction, AMMO_BAR_HEIGHT * _scale, 0, "", 0, 0, TEXT_FONT, "center", false, 0, _ammoOffsetY];
                };
            };
        };
    };

    // Info text above the bar
    private _parts = [];

    if (GVAR(showName)) then {_parts pushBack _name};
    if (GVAR(showGroup)) then {_parts pushBack groupId group _unit};
    if (GVAR(showHealth)) then {_parts pushBack format ["%1%2", round (_health * 100), "%"]};
    if (GVAR(showDistance)) then {_parts pushBack format ["%1m", round sqrt _distanceSqr]};

    if (GVAR(showVehicle)) then {
        private _vehicle = objectParent _unit;
        if (!isNull _vehicle) then {
            _parts pushBack getText (configOf _vehicle >> "displayName");
        };
    };

    // AI state info, empty values are skipped to keep the line short
    if (_alive) then {
        if (GVAR(showCommand)) then {
            private _command = currentCommand _unit;
            if (_command isNotEqualTo "") then {_parts pushBack _command};
        };

        if (GVAR(showUnitState)) then {_parts pushBack getUnitState _unit};

        // LAMBS Danger FSM task and tactic, group leaders only
        if ((GVAR(showTask) || {GVAR(showTactic)}) && {_unit isEqualTo leader _unit}) then {
            if (GVAR(showTask)) then {
                private _task = _unit getVariable ["lambs_main_currentTask", ""];
                if (_task isNotEqualTo "") then {_parts pushBack _task};
            };

            if (GVAR(showTactic)) then {
                private _tactic = group _unit getVariable ["lambs_main_currentTactic", ""];
                if (_tactic isNotEqualTo "") then {_parts pushBack _tactic};
            };
        };
    };

    private _textColor = switch (true) do {
        case (!_alive): {
            _parts pushBack LLSTRING(KIA);
            COLOR_TEXT_DEAD
        };
        case (_unconscious): {
            _parts pushBack LLSTRING(Unconscious);
            COLOR_TEXT_UNCONSCIOUS
        };
        case (GVAR(useSideColor)): {_sideColor};
        default {COLOR_TEXT_DEFAULT};
    };

    if (_parts isNotEqualTo []) then {
        drawIcon3D ["", _textColor, _posAGL, 1, 1, 0, _parts joinString TEXT_SEPARATOR, 2, _textSize, TEXT_FONT, "center", false, 0, _textOffsetY];
    };
} forEach GVAR(units);

// Lazily prune deleted and removed units
if (_prune) then {
    GVAR(units) = GVAR(units) select {!isNull _x && {_x getVariable [QGVAR(tracked), false]}};

    if (GVAR(units) isEqualTo []) then {
        call FUNC(stop);
    };
};
