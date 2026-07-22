#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: starts the enemy-proximity capture watch — a CBA PFH (~2 s) over
 * the surrendered-unit registry GVAR(surrenderedUnits) (fed by
 * QGVAR(registerSurrender) from surrenderApply on the units' owner machines).
 * While the list is empty each tick is a single isEqualTo check, so the
 * feature idles for free.
 *
 * A surrendered unit with a live, conscious ENEMY man inside
 * GVAR(captureRadius) is handed to FUNC(captureUnit). Side is read from the
 * GROUP — setCaptive flips `side _unit` to civilian, so both the prisoner's
 * side and a fellow surrendered candidate's side would lie; group side keeps
 * the real allegiance. Only men on foot capture (nearEntities returns the
 * vehicle, not its crew, for mounted units) — a tank rolling past does not
 * take prisoners, the crew has to dismount.
 *
 * Loading: called once from XEH_postInit (isServer, capture setting on).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_captive_fnc_captureWatch
 *
 * Public: No
 */

[{
    if (GVAR(surrenderedUnits) isEqualTo []) exitWith {};

    // Prune: dead/deleted units, and any that stood down while their owner
    // machine's register event was still in flight.
    GVAR(surrenderedUnits) = GVAR(surrenderedUnits) select {
        !isNull _x
        && {alive _x}
        && {_x getVariable [QGVAR(surrendered), false]}
        && {!(_x getVariable [QGVAR(captured), false])}
    };

    private _radius = GVAR(captureRadius);
    {
        private _unit = _x;
        private _unitSide = side group _unit;
        private _captors = (_unit nearEntities [["CAManBase"], _radius]) select {
            alive _x
            && {lifeState _x isNotEqualTo "INCAPACITATED"}
            && {!(_x getVariable [QGVAR(surrendered), false])}
            && {(side group _x) getFriend _unitSide < 0.6}
        };
        if (_captors isNotEqualTo []) then {
            [_unit, _captors select 0] call FUNC(captureUnit);
        };
    // captureUnit removes the prisoner from the registry — iterate a copy
    } forEach +GVAR(surrenderedUnits);
}, 2] call CBA_fnc_addPerFrameHandler;
