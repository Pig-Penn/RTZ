#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: flips the surrendered state of every unit in the
 * selection. Reads the current state from the FIRST unit and applies the inverse
 * uniformly to all of them, so a mixed selection follows the label the curator
 * just clicked (FUNC(surrenderActionModifier) reads the same first unit).
 *
 * That "one state for everyone" rule is also why FUNC(surrenderApply) refuses a
 * flip to the state a unit is already in: without it, every unit in a mixed
 * selection that was ALREADY surrendered would have its lock clock re-stamped
 * and its pose restarted each time the curator toggled the rest of the group.
 *
 * A stand-down is refused for units still inside the lock window
 * (GVAR(standDownLockTime) seconds after surrendering) — surrender is a
 * commitment. Checked here for the toast, and again authoritatively in
 * FUNC(surrenderApply) where the unit is local.
 *
 * setCaptive / disableAI / the hands-up animation must run where the unit is
 * local, so each unit's QGVAR(surrenderApply) event is TARGETED AT THE UNIT —
 * CBA runs it on the unit's owner (server, headless client, or a player's
 * machine for AI in his group; the handler is registered on every machine in
 * XEH_postInit). The handler also broadcasts the per-unit state variable so
 * every client's modifier reads the correct label.
 *
 * Arguments:
 * 0: Objects from a ZEN action's selection + hovered entity <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_captive_fnc_surrenderToggle
 *
 * Public: No
 */

params ["_objects"];

private _units = [_objects] call FUNC(collectSurrenderUnits);
if (_units isEqualTo []) exitWith {
    [LLSTRING(MsgNoUnitsSelected)] call zen_common_fnc_showMessage;
};

private _surrender = !((_units select 0) getVariable [QGVAR(surrendered), false]);

// Standing down: drop everything still inside its lock window, tracking the
// SHORTEST remaining time as we go. The refusal toast should tell the curator
// when he can try again, which is when the first of them frees up — the old
// version reported whichever unit happened to sort first, an arbitrary and
// usually pessimistic number.
private _soonest = 1e9;
if (!_surrender) then {
    private _lockTime = GVAR(standDownLockTime);
    _units = _units select {
        private _remaining = _lockTime - (CBA_missionTime - (_x getVariable [QGVAR(surrenderTime), -1e9]));
        if (_remaining > 0) then {_soonest = _soonest min _remaining};
        _remaining <= 0
    };
};

// Only the lock filter can empty the list at this point — an empty selection
// already returned above — so this is unambiguously the locked case.
if (_units isEqualTo []) exitWith {
    [LLSTRING(MsgStandDownLocked), ceil _soonest] call zen_common_fnc_showMessage;
};

{
    [QGVAR(surrenderApply), [_x, _surrender], _x] call CBA_fnc_targetEvent;
} forEach _units;

// Through the shared helper rather than a hand-rolled "%1  x%2": it appends the
// count only when it is worth showing, and passes the finished text as a format
// ARGUMENT so a translation containing a literal "%" is not re-scanned as a
// placeholder by showMessage's own format pass.
[[LLSTRING(MsgStandingDown), LLSTRING(MsgSurrendering)] select _surrender, count _units] call EFUNC(common,showCountMessage);
