#include "script_component.hpp"
/*
 * Author: Maxim
 * Keeps a man visibly rummaging for as long as the curator has a gear display
 * open on him — the cosmetic half of FUNC(openUnitInventory).
 *
 * The engine plays the gear animation ONCE, as part of the "Gear" action, and
 * then leaves it to be overwritten: it sustains the gear pose only for the
 * PLAYER whose display is open, and an AI's own move FSM takes the motion state
 * back a second or two later and replaces it. There is no engine state saying
 * "this AI is in his gear" to hold on to, so the animation has to be re-applied.
 *
 * This function is only the WATCHER, and it runs on the curator's client because
 * the display it polls is his. It sends one QGVAR(gearAnimStart) when it first
 * confirms the display really is open and one QGVAR(gearAnimStop) when it closes;
 * everything between those two is driven on the man's own machine by an AnimDone
 * handler (see XEH_postInit and FUNC(playGearAnim)). Nothing is sent per tick,
 * which matters on a multi-hour op — the earlier shape of this function fired a
 * network event every second for as long as a curator left a loadout open.
 *
 * The start event is sent from inside the loop rather than up front, and that
 * ordering is load-bearing. CBA_fnc_targetEvent calls a LOCAL target's receiver
 * in the same statement, not over the network, so starting the animation before
 * the display exists replays playActionNow in the very frame the caller issued
 * its own `action ["Gear", _target]`. playActionNow interrupts whatever action is
 * current, which cancelled that call before the engine reached the side effect
 * that opens the dialog — the display never appeared and only the animation ran.
 * Waiting for the display to be visible makes that race impossible to lose.
 *
 * A held pose is possible — disableAI "ANIM" plus the lambs_danger_disableAI
 * flag, the way EFUNC(captive,surrenderApply) pins a prisoner, and the way ZEN's
 * ambient animation module does it — but that costs the unit its reactions for as
 * long as the curator is inside its loadout, which on a multi-hour op is a real
 * price for a cosmetic fix. Nothing here touches AI state, and the man is left
 * free to move between beats; see FUNC(playGearAnim) for why gating on whether he
 * is moving is precisely the wrong thing to do.
 *
 * LAMBS is NOT the interruption here, however much it looks like it. Its
 * lambs_danger_forceMove flag (what EFUNC(common,approach) and
 * EFUNC(repair,startRepair) use) only suppresses LAMBS' own danger-reaction
 * movement, and a man walking an ordinary move order is in no danger state at
 * all — setting it changes nothing on this path and costs a misleading "forced"
 * tag on the HUD (EFUNC(hud,gatherUnitInfo)). It was tried and reverted.
 *
 * Arguments:
 * 0: Man to animate — the unit itself, or a vehicle's crewman <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_orders_fnc_keepGearAnimation
 *
 * Public: No
 */

params ["_actor"];

// One session at a time. Opening a second man's gear while a display is still up
// would otherwise leave two watchers racing on the same display test, and the
// older one would go on animating a man the curator has already moved off — so
// the running session is ended properly, on whichever man it belonged to.
if (!isNil QGVAR(gearActor)) then {
    [GVAR(gearPfh)] call CBA_fnc_removePerFrameHandler;
    [QGVAR(gearAnimStop), [GVAR(gearActor)], GVAR(gearActor)] call CBA_fnc_targetEvent;
    GVAR(gearPfh) = nil;
    GVAR(gearActor) = nil;
};

if (!alive _actor) exitWith {};

GVAR(gearActor) = _actor;

GVAR(gearPfh) = [{
    params ["_args", "_pfhId"];
    _args params ["_actor", "_started", "_deadline"];

    private _open = !isNull (findDisplay IDD_GEAR);

    // First sight of the display. The engine opens it a frame or two AFTER the
    // action is issued, so until this fires the deadline is only a short grace
    // for it to appear; from here it becomes the long runaway cap, and the
    // display's absence starts meaning "the curator closed it" instead of "it has
    // not opened yet".
    if (_open && {!_started}) then {
        _started = true;
        _deadline = CBA_missionTime + GEAR_ANIM_MAX;
        _args set [1, _started];
        _args set [2, _deadline];

        [QGVAR(gearAnimStart), [_actor], _actor] call CBA_fnc_targetEvent;
    };

    if (!alive _actor || {_started && {!_open}} || {CBA_missionTime > _deadline}) exitWith {
        [_pfhId] call CBA_fnc_removePerFrameHandler;

        // Only if a session was actually opened. A grace that expires without the
        // display ever appearing has nothing on the man to take back off.
        if (_started) then {
            [QGVAR(gearAnimStop), [_actor], _actor] call CBA_fnc_targetEvent;
        };

        GVAR(gearPfh) = nil;
        GVAR(gearActor) = nil;
    };
}, GEAR_WATCH_INTERVAL, [_actor, false, CBA_missionTime + GEAR_ANIM_GRACE]] call CBA_fnc_addPerFrameHandler;
