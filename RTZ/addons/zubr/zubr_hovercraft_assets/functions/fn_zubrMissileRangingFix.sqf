

/*
	Author: Chair

	Description:
	Workaround fix for MLRS manual ranging through weapon firemodes.

	Parameter(s):
		0: OBJECT - vehicle
		1: STRING - firemode
		2: OBJECT - projectile
		3: STRING - type of projectile that should be adjusted

	Returns:
		BOOL - success

	Example:
		[_vehicle,_firemode,_missile,"MissileBase"] call CUP_fnc_zubrMissileRangingFix
*/

params ["_vehicle", "_firemode", "_missile", "_type"];

if !(local _missile) exitWith {false};
if !(_missile isKindOf _type) exitWith {false};

//zeroed according to missile thrust
private _factor3000 = 0.78;
private _factor2000 = 0.57;
private _factor1000 = 0.33;

sleep 1.1; //small pause to wait for the rocket booster to run out
private _missilespeed = velocity _missile;

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
