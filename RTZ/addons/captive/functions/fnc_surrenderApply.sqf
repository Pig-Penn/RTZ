#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(surrenderApply) (registered on EVERY machine in
 * XEH_postInit; senders target the event at the unit, so it runs where the unit
 * is local — required by setCaptive / disableAI / playMoveNow). Forces one unit
 * into, or restores it out of, a scripted surrender: captive (ignored as a
 * target), AI targeting/movement/animation disabled, and the vanilla hands-up
 * pose. disableAI "ANIM" holds the pose without a per-frame watcher, so this is
 * a one-shot state change and the feature costs nothing while active.
 *
 * Authoritative guards — the client-side toggle filters too, but this is where
 * the unit is local, so it has the last word:
 *  - Players are refused outright; the event lands on the unit's own machine, so
 *    running this on a human would seize his controls.
 *  - A captured prisoner can never be toggled. Capture is permanent.
 *  - A stand-down inside the lock window is refused.
 *  - A flip to the state the unit is already in is refused. Not a redundancy
 *    check: FUNC(surrenderToggle) resolves a mixed selection to ONE target
 *    state, so without this an already-surrendered unit would have its lock
 *    clock re-stamped and its pose restarted every time the curator toggled the
 *    rest of the group. (ACE's own setSurrendered guards the same case.)
 *
 * The FORCE path exists for one caller: the "Local" handler in XEH_postInit
 * re-applying a surrender on a machine that just gained the unit. disableAI is
 * stored per machine and does not travel with locality, so that re-apply is
 * mandatory — and it necessarily asks for the state the unit is already in,
 * which is exactly what the guards above reject.
 *
 * Arguments:
 * 0: Unit to toggle <OBJECT>
 * 1: True to surrender, false to restore normal AI behaviour <BOOLEAN>
 * 2: Force — re-apply a state the unit is already in, without re-stamping the
 *    lock clock <BOOLEAN> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, true] call rtz_captive_fnc_surrenderApply
 *
 * Public: No
 */

params ["_unit", "_surrender", ["_force", false]];

if (isNull _unit || {!alive _unit} || {isPlayer _unit}) exitWith {};

// The forced re-apply has to be able to reach a captured prisoner: he is still
// surrendered, and he is exactly the unit that must not be allowed to stand back
// up after an ownership change.
if (!_force && {_unit getVariable [QGVAR(captured), false]}) exitWith {};

if (!_force && {(_unit getVariable [QGVAR(surrendered), false]) isEqualTo _surrender}) exitWith {};

if (
    !_surrender
    && {CBA_missionTime - (_unit getVariable [QGVAR(surrenderTime), -1e9]) < GVAR(standDownLockTime)}
) exitWith {};

// Broadcast so every client's action modifier reads the right label, and so the
// state survives to whichever machine gains the unit next.
SETPVAR(_unit,GVAR(surrendered),_surrender);

if (_surrender) then {
    // Stamp the lock clock only when the surrender BEGINS. CBA_missionTime is
    // synced across machines, so the window means the same thing everywhere —
    // but re-stamping on the forced path would silently extend a curator's lock
    // every time a headless client rebalanced.
    if (!_force) then {
        SETPVAR(_unit,GVAR(surrenderTime),CBA_missionTime);
    };

    _unit setCaptive true;
    _unit disableAI "MOVE";
    _unit disableAI "TARGET";
    _unit disableAI "AUTOTARGET";
    _unit disableAI "ANIM";
    _unit setUnitPos "UP";

    // LAMBS' danger FSM already bails on `!checkAIFeature "MOVE"` — but that
    // reads the engine flag set just above, which is machine-local. The public
    // variable LAMBS honours alongside it travels with the unit, closing the
    // window between an ownership change and the "Local" re-apply. Inert when
    // LAMBS is not loaded.
    _unit setVariable ["lambs_danger_disableAI", true, true];

    // The pose is global, so a re-apply after an ownership change normally finds
    // it intact; replaying it unconditionally would make every locality change
    // visibly twitch. Testing the state instead of the reason covers both
    // callers in one line — a fresh surrender is never already in it, and a
    // re-apply only pays when the new owner's AI has knocked the unit out of it.
    if (animationState _unit != ANIM_SURRENDER_STATE) then {
        _unit playMoveNow ANIM_SURRENDER_ENTER;
    };
} else {
    SETPVAR(_unit,GVAR(surrenderTime),nil);

    _unit setCaptive false;
    _unit enableAI "MOVE";
    _unit enableAI "TARGET";
    _unit enableAI "AUTOTARGET";
    // ANIM first, then the animation reset — the unit cannot leave the pose
    // while its animation changes are still blocked.
    _unit enableAI "ANIM";
    _unit setUnitPos "AUTO";
    _unit switchMove "";

    _unit setVariable ["lambs_danger_disableAI", nil, true];
};

// Keep the server's capture watch registry in sync. This handler runs on the
// unit's owner machine, which is not necessarily the server — and the forced
// re-apply is skipped, because a locality change is not a state flip and would
// otherwise re-admit a captured prisoner to the watch list.
if (!_force) then {
    [QGVAR(registerSurrender), [_unit, _surrender]] call CBA_fnc_serverEvent;
};
