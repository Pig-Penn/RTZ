

/*
	Author: Chair

	Description:
	Workaround fix for MLRS manual ranging through weapon firemodes.

	Parameter(s):
		0: OBJECT - vehicle
		1: STRING - firemode
		2: OBJECT - projectile
		4: STRING - type of projectile that should be adjusted

	Returns:
		BOOL - success
		
	Example:
		[_vehicle,_firemode,_missile,"MissileBase"] call CUP_fnc_zubrMissileRangingFix
*/


private ["_vehicle","_firemode","_missile","_type"];

_vehicle = _this select 0;
_firemode = _this select 1;
_missile = _this select 2; if !(local _missile) exitWith {false};
_type = _this select 3; if !(_missile isKindOf _type) exitWith {false};

private ["_missilespeed","_factor3000","_factor2000","_factor1000"];
//zeroed according to missile thrust
_factor3000 = 0.78;
_factor2000 = 0.57;
_factor1000 = 0.33;

sleep 1.1; //small pause to wait for the rocket booster to run out
_missilespeed = velocity _missile;

if (_firemode == "fire_4000") exitWith {false}; //missile is zeroed to fall at this range by default, no adjustment required

if (_firemode == "fire_3000") then
{
	_missile setVelocity 
	[
		(_missilespeed select 0) * _factor3000,
		(_missilespeed select 1) * _factor3000,
		(_missilespeed select 2) * _factor3000
	];
};
if (_firemode == "fire_2000") then
{
	_missile setVelocity 
	[
		(_missilespeed select 0) * _factor2000,
		(_missilespeed select 1) * _factor2000,
		(_missilespeed select 2) * _factor2000
	];
};
if (_firemode == "fire_1000") then
{
	_missile setVelocity 
	[
		(_missilespeed select 0) * _factor1000,
		(_missilespeed select 1) * _factor1000,
		(_missilespeed select 2) * _factor1000
	];
};

true
