#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: handler body for QGVAR(registerSurrender). Maintains the capture
 * watch's registry GVAR(surrenderedUnits) and, with it, the lifetime of the
 * watch engine itself.
 *
 * FUNC(surrenderApply) runs on each unit's OWNER machine — server, headless
 * client, or a player's — so the server cannot see these state flips any other
 * way; every one of them is reported here.
 *
 * This is also where the engine is started. GVAR(captureTick) is created by the
 * first surrender and removed by the last (in the tick itself, so there is one
 * teardown path rather than one per caller). A mission in which nobody ever
 * surrenders therefore never runs a single tick of this component — the previous
 * design started an unconditional 0.5 Hz loop at mission init and ran it to the
 * end of the mission regardless, which is the pattern rtz_reverse and
 * rtz_hud already abandoned.
 *
 * The enable setting is checked HERE rather than at init, which is what makes it
 * a live switch: turning the feature off stops new prisoners being admitted, and
 * the engine winds itself down as the units already in the list stand down.
 *
 * Arguments:
 * 0: Unit whose state changed <OBJECT>
 * 1: True if it just surrendered, false if it stood down <BOOLEAN>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, true] call rtz_captive_fnc_registerSurrender
 *
 * Public: No
 */

params ["_unit", "_surrender"];

if (!_surrender) exitWith {
    // find/deleteAt rather than `- [_unit]`: subtraction allocates a replacement
    // array on every stand-down, and deleteAt on a missing element would be a
    // silent -1 index, so the guard is not optional.
    private _index = GVAR(surrenderedUnits) find _unit;
    if (_index > -1) then {
        GVAR(surrenderedUnits) deleteAt _index;
    };
};

if !(GVAR(enabled)) exitWith {};

GVAR(surrenderedUnits) pushBackUnique _unit;

// First prisoner on the list — raise the engine. The tick takes itself down when
// the list empties again.
if (GVAR(pfh) < 0) then {
    GVAR(pfh) = [FUNC(captureTick), CAPTURE_INTERVAL] call CBA_fnc_addPerFrameHandler;
};
