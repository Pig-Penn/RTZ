#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: the enemy-proximity capture engine — one shared CBA per-frame handler
 * at CAPTURE_INTERVAL walking GVAR(surrenderedUnits), raised by the first
 * surrender (FUNC(registerSurrender)) and taken down here by the last. Idle cost
 * is not "one cheap check per tick", it is nothing: between surrenders the
 * handler does not exist.
 *
 * A surrendered unit with a live, conscious ENEMY man inside GVAR(captureRadius)
 * is handed to FUNC(captureUnit).
 *
 * Three things the shape of this loop buys, all of which the previous version
 * paid for and did not get:
 *
 *  - ONE array, walked backwards. Pruning the dead, scanning, and removing the
 *    captured used to be a filtering `select` (new array), a `+` copy to iterate
 *    safely (second array), and a `- [_unit]` inside captureUnit (third) — every
 *    tick, for as long as anyone was surrendered. Iterating in reverse means an
 *    entry can be deleted in place without disturbing the indices still to come.
 *  - findIf, not select, for the captor scan. The first enemy inside the radius
 *    takes the prisoner, so there is no reason to finish classifying the rest of
 *    the crowd — and a crowd is exactly the situation where this runs.
 *  - The hostile SIDES resolved once per prisoner instead of a getFriend call per
 *    nearby man.
 *
 * Side is read from the GROUP throughout, never from `side _unit`: setCaptive
 * flips a unit's side to civilian, so both the prisoner's own side and a fellow
 * surrendered candidate's would lie about their real allegiance. Only men on
 * foot capture — nearEntities returns the vehicle rather than its crew for
 * mounted units, so a tank rolling past takes no prisoners; the crew has to get
 * out.
 *
 * Arguments:
 * None (CBA per-frame handler)
 *
 * Return Value:
 * None
 *
 * Example:
 * [rtz_captive_fnc_captureTick, CAPTURE_INTERVAL] call CBA_fnc_addPerFrameHandler
 *
 * Public: No
 */

// Last prisoner gone on the previous pass — take the loop down rather than leave
// it spinning over an empty array for the rest of the mission.
if (GVAR(surrenderedUnits) isEqualTo []) exitWith {
    [GVAR(pfh)] call CBA_fnc_removePerFrameHandler;
    GVAR(pfh) = -1;
};

private _radius = GVAR(captureRadius);

// Hostile-side sets memoised for the duration of THIS pass, keyed by the
// prisoner's side. getFriend is a relation between two sides, not a property of
// a unit, so every prisoner of a given side resolves the identical list — it was
// being rebuilt (a fresh `select` allocation over MAN_SIDES) once per prisoner
// per tick. A mass surrender is exactly when this loop is longest, and there are
// only ever a handful of distinct sides.
private _hostileBySide = createHashMap;

for "_i" from (count GVAR(surrenderedUnits)) - 1 to 0 step -1 do {
    private _unit = GVAR(surrenderedUnits) select _i;

    // Prune in the same pass as the scan: dead or deleted (alive answers objNull
    // too), stood down while the register event was still in flight, or already
    // taken by an earlier tick.
    if (
        !alive _unit
        || {!(_unit getVariable [QGVAR(surrendered), false])}
        || {_unit getVariable [QGVAR(captured), false]}
    ) then {
        GVAR(surrenderedUnits) deleteAt _i;
        continue;
    };

    private _unitSide = side group _unit;
    // Keyed on the SIDE OBJECT, not `str side`. Side is a legal HashMap key (Gotchas §3
    // lists it alongside Number/Bool/Array/String/Namespace/NaN/Code/Config entry), and
    // the string form was one throwaway allocation per prisoner per tick — the
    // per-entity-per-tick `str` CLAUDE.md rules out on a mission running for hours.
    // EFUNC(spotting,collectSides) was rewritten for exactly this and its header carries
    // the full reasoning; this was the last copy of the old shape.
    private _hostileSides = _hostileBySide getOrDefaultCall [_unitSide, {
        MAN_SIDES select {_x getFriend _unitSide < HOSTILE_THRESHOLD}
    }, true];

    private _nearby = _unit nearEntities [["CAManBase"], _radius];
    private _index = _nearby findIf {
        alive _x
        && {lifeState _x isNotEqualTo "INCAPACITATED"}
        // A fellow prisoner takes nobody captive — and this is also what stops
        // the unit matching itself, since nearEntities includes the caller.
        && {!(_x getVariable [QGVAR(surrendered), false])}
        && {(side group _x) in _hostileSides}
    };

    if (_index < 0) then {continue};

    // Removed here rather than inside captureUnit so the registry is only ever
    // mutated by the loop that owns it.
    GVAR(surrenderedUnits) deleteAt _i;
    [_unit, _nearby select _index] call FUNC(captureUnit);
};
