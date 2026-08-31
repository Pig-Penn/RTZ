fnc_enter = {
    params ["_vehicle", "_driver"];

    if (!alive _vehicle) exitWith {};
    if (isNull _driver || !alive _driver) exitWith {};

    _driver disableAI "AUTOCOMBAT";
};

fnc_lock = {
    params ["_vehicle", "_target", "_driver", "_gunner"];

    if (!alive _vehicle || !alive _target) exitWith {};
    if (isNull _driver || !alive _driver) exitWith {};

    _driver reveal [_target, 4];
    if (!isNull _gunner && { alive _gunner }) then { _gunner reveal [_target, 4] };

    private _shooter = if (!isNull _gunner && { alive _gunner }) then { _gunner } else { _driver };
    _shooter doWatch _target;
    _shooter doTarget _target;
};

fnc_weapon = {
    params ["_vehicle", "_target", "_distance"];

    private _weapon = "";
    private _allWeapons = (weapons _vehicle) + (_vehicle weaponsTurret [0]) + (_vehicle weaponsTurret [-1]);
    _allWeapons = _allWeapons arrayIntersect _allWeapons;

    {
        private _name = toLower getText (configFile >> "CfgWeapons" >> _x >> "displayName");
        private _className = toLower _x;

        if ("bomb" in _name || { "gbu" in _name } || { "mk82" in _name } || { "fab" in _name } || { "jdam" in _name } || { "paveway" in _name } || { "bomb" in _className }) then {
            _weapon = _x;
        };
    } forEach _allWeapons;

    [_weapon]
};

fnc_pursuit = {
    params ["_vehicle", "_target", "_driver"];

    if (!alive _vehicle || !alive _target) exitWith {};
    if (isNull _driver || !alive _driver) exitWith {};

    private _targetPosition = getPosASL _target;
    private _targetVelocity = velocity _target;
    private _distance = _vehicle distance _target;
    private _closingTime = (_distance / (speed _vehicle max 200)) min 4;
    private _interceptPosition = _targetPosition vectorAdd (_targetVelocity vectorMultiply _closingTime);

    _driver doMove _interceptPosition;
};

fnc_fire = {
    params ["_vehicle", "_target", "_driver", "_gunner", "_weapon"];

    if (!alive _vehicle || !alive _target) exitWith { false };
    if (isNull _driver || !alive _driver) exitWith { false };

    _driver reveal [_target, 4];

    private _shooter = if (!isNull _gunner && {alive _gunner}) then {_gunner} else {_driver};
    _shooter doTarget _target;
    _shooter doWatch _target;

    private _turretPath = if (!isNull _gunner && { alive _gunner }) then { [0] } else { [-1] };
    if (_weapon in (_vehicle weaponsTurret _turretPath)) then {
        _vehicle selectWeaponTurret [_weapon, _turretPath];
    } else {
        _vehicle selectWeapon _weapon;
    };

    _shooter doFire _target;
    _vehicle fireAtTarget [_target, _weapon];
};

fnc_combat = {
    private _vehicle = westJet;
    private _target = eastTank;
    private _driver = driver _vehicle;
    private _gunner = gunner _vehicle;

    [_vehicle, _driver] call fnc_enter;
    [_vehicle, _target, _driver, _gunner] call fnc_lock;

    private _distance = _vehicle distance _target;
    private _targetPosition = getPos _target;
    private _relativeDirection = _vehicle getRelDir _target;

    private _weaponData = [_vehicle, _target, _distance] call fnc_weapon;
    _weaponData params ["_weapon"];

    if (!(_relativeDirection < 30 || _relativeDirection > 330)) exitWith { [_vehicle, _target, _driver] call fnc_pursuit };

    [_vehicle, _target, _driver, _gunner, _weapon] call fnc_fire;
};
