#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws health/fuel/ammo bars and info text above each tracked vehicle. Called every frame.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_vehicle_info_fnc_draw3D
 *
 * Public: No
 */

private _camPosASL = AGLToASL positionCameraToWorld [0, 0, 0];
private _maxDistanceSqr = GVAR(maxDistance) * GVAR(maxDistance);
private _scale = GVAR(scale);
private _textSize = TEXT_SIZE * _scale;
private _uiScale = getResolution select 5;
private _textOffsetY = TEXT_OFFSET_Y * _scale * _uiScale;
private _subBarStep = SUB_BAR_OFFSET_Y * _scale * _uiScale;
private _damageOffsetExtraY = DAMAGE_OFFSET_EXTRA_Y * _scale * _uiScale;
private _prune = false;

{
    private _vehicle = _x;

    if (isNull _vehicle) then {
        _prune = true;
        continue;
    };

    private _alive = alive _vehicle;

    if (!_alive && {GVAR(removeOnDestroyed)}) then {
        _vehicle setVariable [QGVAR(tracked), nil];
        _vehicle setVariable [QGVAR(data), nil];
        _prune = true;
        continue;
    };

    private _posASL = getPosASLVisual _vehicle;
    private _distanceSqr = _posASL vectorDistanceSqr _camPosASL;
    if (_distanceSqr > _maxDistanceSqr) then {continue};

    (_vehicle getVariable QGVAR(data)) params ["_height", "_name", "_totalSeats", "_hasFuel", "_turretPath", "_hitPointGroups"];

    private _posAGL = ASLToAGL _posASL;
    _posAGL set [2, (_posAGL select 2) + _height];

    private _health = ([0, 1 - damage _vehicle] select _alive) max 0;

    // Health bar background, fill is drawn on top and shrinks towards the center
    drawIcon3D [BAR_TEXTURE, COLOR_BACKGROUND, _posAGL, BAR_WIDTH * _scale, BAR_HEIGHT * _scale, 0, "", 0];

    if (_health > 0) then {
        // Green to yellow to red gradient
        private _barColor = [linearConversion [0.5, 1, _health, 1, 0, true], linearConversion [0, 0.5, _health, 0, 1, true], 0, BAR_ALPHA];

        drawIcon3D [BAR_TEXTURE, _barColor, _posAGL, BAR_WIDTH * _scale * _health, BAR_HEIGHT * _scale, 0, "", 0];
    };

    // Fuel and ammo bars stack below the health bar, leaving no gap when one is hidden
    private _subBarOffsetY = 0;

    if (GVAR(showFuel) && {_alive} && {_hasFuel}) then {
        _subBarOffsetY = _subBarOffsetY + _subBarStep;

        drawIcon3D [BAR_TEXTURE, COLOR_BACKGROUND, _posAGL, BAR_WIDTH * _scale, SUB_BAR_HEIGHT * _scale, 0, "", 0, 0, TEXT_FONT, "center", false, 0, _subBarOffsetY];

        private _fuel = fuel _vehicle;

        if (_fuel > 0) then {
            drawIcon3D [BAR_TEXTURE, COLOR_FUEL, _posAGL, BAR_WIDTH * _scale * _fuel, SUB_BAR_HEIGHT * _scale, 0, "", 0, 0, TEXT_FONT, "center", false, 0, _subBarOffsetY];
        };
    };

    // Ammo bar based on the current magazine of the primary armed turret
    if (GVAR(showAmmo) && {_alive} && {_turretPath isNotEqualTo []}) then {
        _subBarOffsetY = _subBarOffsetY + _subBarStep;

        drawIcon3D [BAR_TEXTURE, COLOR_BACKGROUND, _posAGL, BAR_WIDTH * _scale, SUB_BAR_HEIGHT * _scale, 0, "", 0, 0, TEXT_FONT, "center", false, 0, _subBarOffsetY];

        (weaponState [_vehicle, _turretPath]) params ["", "", "", ["_magazine", ""], ["_ammoCount", 0]];

        if (_magazine isNotEqualTo "") then {
            private _capacity = GVAR(magazineCapacities) getOrDefaultCall [_magazine, {
                getNumber (configFile >> "CfgMagazines" >> _magazine >> "count") max 1
            }, true];

            private _ammoFraction = (_ammoCount / _capacity) min 1;

            if (_ammoFraction > 0) then {
                drawIcon3D [BAR_TEXTURE, COLOR_AMMO, _posAGL, BAR_WIDTH * _scale * _ammoFraction, SUB_BAR_HEIGHT * _scale, 0, "", 0, 0, TEXT_FONT, "center", false, 0, _subBarOffsetY];
            };
        };
    };

    // Info text above the bar
    private _parts = [];

    if (GVAR(showName)) then {_parts pushBack _name};

    if (GVAR(showGroup)) then {
        private _commander = effectiveCommander _vehicle;
        if (!isNull _commander) then {_parts pushBack groupId group _commander};
    };

    if (GVAR(showHealth)) then {_parts pushBack format ["%1%2", round (_health * 100), "%"]};
    if (GVAR(showDistance)) then {_parts pushBack format ["%1m", round sqrt _distanceSqr]};

    if (_alive) then {
        if (GVAR(showCrew)) then {
            _parts pushBack format ["%1/%2", {alive _x} count crew _vehicle, _totalSeats];
        };

        if (GVAR(showSpeed)) then {
            _parts pushBack format ["%1 km/h", round speed _vehicle];
        };

        // Red tags below the bars for heavily damaged critical components
        if (GVAR(showDamage)) then {
            private _tags = [];

            {
                _x params ["_label", "_indices"];

                if (_indices findIf {(_vehicle getHitIndex _x) >= DAMAGE_TAG_THRESHOLD} != -1) then {
                    _tags pushBack _label;
                };
            } forEach _hitPointGroups;

            if (!canMove _vehicle) then {_tags pushBack LLSTRING(Immobile)};

            if (_tags isNotEqualTo []) then {
                drawIcon3D ["", COLOR_TEXT_DAMAGE, _posAGL, 1, 1, 0, _tags joinString TEXT_SEPARATOR, 2, _textSize, TEXT_FONT, "center", false, 0, _subBarOffsetY + _damageOffsetExtraY];
            };
        };
    };

    private _textColor = switch (true) do {
        case (!_alive): {
            _parts pushBack LLSTRING(Destroyed);
            COLOR_TEXT_DESTROYED
        };
        case (GVAR(useSideColor)): {
            private _commander = effectiveCommander _vehicle;

            if (isNull _commander) then {
                COLOR_TEXT_DEFAULT
            } else {
                private _side = side group _commander;

                GVAR(sideColors) getOrDefaultCall [str _side, {
                    private _color = ([_side] call BIS_fnc_sideColor) + [1];
                    _color resize 4;
                    _color
                }, true]
            }
        };
        default {COLOR_TEXT_DEFAULT};
    };

    if (_parts isNotEqualTo []) then {
        drawIcon3D ["", _textColor, _posAGL, 1, 1, 0, _parts joinString TEXT_SEPARATOR, 2, _textSize, TEXT_FONT, "center", false, 0, _textOffsetY];
    };
} forEach GVAR(vehicles);

// Lazily prune deleted and removed vehicles
if (_prune) then {
    GVAR(vehicles) = GVAR(vehicles) select {!isNull _x && {_x getVariable [QGVAR(tracked), false]}};

    if (GVAR(vehicles) isEqualTo []) then {
        call FUNC(stop);
    };
};
