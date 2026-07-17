#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(auraApply) (registered on EVERY machine in
 * XEH_postInit): applies or releases the command-aura effects on one group.
 * allowFleeing needs group locality, so FUNC(monitorAuras) targets the event
 * at the group and CBA routes it to the owner — server, HC, or a player
 * leading AI. The local guard covers ownership transfers mid-flight.
 *
 * Effects (extend HERE as the aura grows properties):
 * - allowFleeing 0 while inside. There is no getter to restore from on
 *   release, so the leader's final courage skill is inverted instead —
 *   allowFleeing's scale runs opposite to the skill's (0 = fearless,
 *   1 = flees instantly). Brave groups leave the zone brave; an
 *   approximation of the engine default, not a readback.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Hold — true applies the aura effects, false releases them <BOOLEAN>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_group, true] call rtz_officer_fnc_auraApply
 *
 * Public: No
 */

params ["_group", "_hold"];

if (isNull _group || {!local _group}) exitWith {};

if (_hold) then {
    _group allowFleeing 0;
} else {
    private _leader = leader _group;
    if (isNull _leader) exitWith {};

    _group allowFleeing (1 - (_leader skillFinal "courage"));
};
