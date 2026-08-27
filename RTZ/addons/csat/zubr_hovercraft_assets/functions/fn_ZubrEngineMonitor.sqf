

/*
	Author: Chair

	Description:
	This monitors the engine state and RPM of the hovercraft and applies animations to the air cushion and propellers.

	Parameter(s):
		0: OBJECT - vehicle

	Returns:
		/
		
	Example:
		_this call CUP_fnc_ZubrEngineMonitor
*/

#define PROPELLER_STEP  0.2
#define PROPELLER_WIND_UP_SPEED 0.01

params [
    ["_vehicle", objNull, [objNull]]
];

private _propellerRpm = 0;

while {alive _vehicle} do
{
	private _debugrpm = _vehicle animationPhase "debug_rpm";
	private _debugengine = _vehicle animationPhase "debug_engine";
	private _animengine = _vehicle animationSourcePhase "engineon_source";
	private _animpropellers = _vehicle animationSourcePhase "propellers_source";

	//check whether the engine is on or off
	if (isEngineOn _vehicle) then
	{
		_vehicle animateSource ["engineon_source",1];
		_propellerRpm = (_propellerRpm + PROPELLER_WIND_UP_SPEED) min 1;
	}
	else
	{
		_vehicle animateSource ["engineon_source",0];
		_propellerRpm = (_propellerRpm - PROPELLER_WIND_UP_SPEED) max 0;
	};

	_animPropellers = (_animPropellers + PROPELLER_STEP * _propellerRpm);
	_vehicle animateSource ["propellers_source", _animPropellers];
	sleep 0.05;
};
