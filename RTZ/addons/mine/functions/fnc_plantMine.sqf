#include "script_component.hpp"
/*
 * Author: Maxim
 * Makes the unit plant a mine at its current position using the "Put" weapon.
 * Consumes the magazine and creates a mine known to the unit's side. Must be
 * executed where the unit is local.
 *
 * The unit is halted and the plant is held back until the "PutDown" animation has
 * had PUT_DELAY to play out. Firing on the same frame the animation starts — what
 * this used to do — made the mine pop into existence while the layer was still
 * standing upright, and left it planted wherever he happened to be mid-stride
 * rather than on the spot he was sent to.
 *
 * The completion hook runs after the plant, so callers can release the unit from
 * its errand without cutting the animation short. If the curator re-tasks the
 * layer inside that window the plant is abandoned and the hook is NOT run — the
 * new order owns him by then, and releasing him back into formation on top of it
 * would cancel it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Magazine <STRING>
 * 2: On Done <CODE> — run with [_unit] once the plant has resolved (default {})
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, "ATMine_Range_Mag", {_this call fnc_release}] call rtz_mine_fnc_plantMine
 *
 * Public: No
 */

params ["_unit", "_magazine", ["_onDone", {}]];

private _muzzle = GVAR(muzzles) getOrDefault [toLowerANSI _magazine, ""];

if (_muzzle isEqualTo "") exitWith {
    [_unit] call _onDone;
};

// Settle on the spot before kneeling — approach resolves within a couple of
// meters, by which point the layer may still be walking
doStop _unit;

_unit playActionNow "PutDown";
_unit selectWeapon _muzzle;

[{
    params ["_unit", "_muzzle", "_magazine", "_onDone", "_token"];

    // Re-tasked mid-animation: the new order owns the layer, so drop the plant
    // rather than firing it off and then walking him back into formation
    if (([_unit] call EFUNC(common,errandToken)) != _token) exitWith {};

    if (!alive _unit) exitWith {
        [_unit] call _onDone;
    };

    // Re-checked here rather than by the caller: the layer has been holding the
    // magazine through the whole animation and could have been disarmed since
    if (_magazine in magazines _unit) then {
        _unit fire [_muzzle, _muzzle, _magazine];
    };

    // Reset the "Put" weapon so further mines can be placed, then get a real
    // weapon back in his hands. Falling through to the handgun matters for
    // engineers and crewmen, who often carry no primary at all and would
    // otherwise be left holding the invisible "Put" muzzle
    _unit setWeaponReloadingTime [_unit, _muzzle, 0];

    private _weapon = primaryWeapon _unit;

    if (_weapon isEqualTo "") then {
        _weapon = handgunWeapon _unit;
    };

    if (_weapon isNotEqualTo "") then {
        _unit selectWeapon _weapon;
    };

    [_unit] call _onDone;
}, [_unit, _muzzle, _magazine, _onDone, [_unit] call EFUNC(common,errandToken)], PUT_DELAY] call CBA_fnc_waitAndExecute;
