#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for EGVAR(control,resetDone), which EFUNC(control,reset) raises
 * globally with every unit it just reset. Tears down the editing area anchored
 * on any officer in that list and puts him on COOLDOWN_DURATION, so editing
 * rights cannot be re-anchored on an officer the moment he is reset.
 *
 * Same reasoning as the COMBAT/CARELESS teardown in FUNC(monitorAreas): a reset
 * is an upheaval of the officer's state — EFUNC(control,resetApply) discards his
 * group and builds a new one, and his orders and behaviour go with it — and
 * editing rights anchored on him have no business surviving that.
 *
 * CLIENT-SIDE, and reached by a global event rather than one aimed at the
 * resetting curator. GVAR(areas) is this client's own tracking map and the
 * removal has to go through this client's curator module, so every curator
 * machine has to run this against its own state; and the officer is on cooldown
 * for EVERYONE, not merely whoever reset him.
 *
 * NOT gated on GVAR(cooldownEnable), unlike the two teardowns in FUNC(setArea)
 * and FUNC(monitorAreas). That setting prices a Zeus MOVING his own editing
 * rights around; this wait is a consequence of resetting the anchor and applies
 * either way. Nothing else has to change for that to hold: the setting only ever
 * gated ARMING, never enforcement — FUNC(setArea)'s add path tests
 * FUNC(isOnCooldown) unconditionally.
 *
 * Non-officers in the list are ignored, so the sender can stay ignorant of what
 * an officer is and ship its whole reset selection (FUNC(isOfficer) is
 * class-cached, so the scan is a hashmap lookup per unit).
 *
 * Arguments:
 * 0: Units that were reset <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_units] call rtz_officer_fnc_resetCooldown
 *
 * Public: No
 */

params ["_units"];

private _removed = false;

{
    if ([_x] call FUNC(isOfficer)) then {
        // Through the remove primitive, so the teardown goes via the one place
        // that knows how to unregister an area server-side. It returns false
        // when this client held no area on him — the common case, and why the
        // cooldown is armed outside it rather than left to setArea, which arms
        // only on a successful removal and only while the setting is on.
        if ([_x, false] call FUNC(setArea)) then { _removed = true };

        GVAR(cooldowns) set [netId _x, CBA_missionTime + COOLDOWN_DURATION];
    };
} forEach _units;

// One message per reset, not per officer: a squad reset can catch several
// anchors at once, and the curator does not need telling once per area (mirrors
// the combat teardown in FUNC(monitorAreas))
if (_removed) then {
    [LSTRING(MsgAreaResetRemoved)] call zen_common_fnc_showMessage;
};
