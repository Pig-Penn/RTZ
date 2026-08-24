#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(rcReset) (registered on EVERY machine in XEH_postInit).
 * Waits out the ownership handover a Zeus remote-control release starts, then hands
 * the unit to FUNC(rcRebuild) on whichever machine ends up owning it.
 *
 * This function used to clear the released unit's animation and look state, which
 * fixed the POSE it was let go in. That was a real fix for a real symptom, and it
 * was not the important one: the unit also comes back unable to AIM (engine bug
 * T179189), and a remedy ladder run in-game established that nothing short of
 * recreating the unit clears that — including the LAMBS hard taskReset this
 * component already ships. FUNC(rcRebuild) carries the reasoning and the evidence.
 * A rebuilt unit gets the pose fix for free, since it is a new unit.
 *
 * Registered unconditionally, with no hasInterface guard: FUNC(rcReset) raises
 * this globally and the unit's owner can be a headless client or the dedicated
 * server — the same reasoning already written out for the dismount receiver in
 * XEH_postInit.
 *
 * THIS RUNS EVERYWHERE AND WAITS FOR OWNERSHIP, rather than being routed to an
 * owner by the sender. The reason is in the dispatch note in fnc_rcReset.sqf:
 * `remoteControl` parks the unit on the CONTROLLER's machine, and the handover
 * back is still in flight when ZEN raises the release event, so at dispatch time
 * NO machine can yet name the unit's next owner — the ex-controller least of
 * all, since `local` is still true there. So every machine takes the message and
 * waits out the handover; whichever one the unit lands on does the work, and the
 * rest time out having cost one `local` test per frame for RC_RESET_TIMEOUT.
 *
 * The wait replaces an execNextFrame that re-tested `local` exactly one frame
 * after the release — i.e. squarely inside the handover window, which is what
 * made the reset vanish silently. A condition is the right tool here precisely
 * because the settling time is a network round trip, not a frame count. It is
 * bounded per the per-tick rule in CLAUDE.md; on timeout it gives up in silence.
 *
 * The one-frame minimum the old code bought on purpose is still there for free,
 * and matters more now than it did: CBA evaluates a waitUntil condition no earlier
 * than the next frame, so the rebuild can never begin inside ZEN's own multi-frame
 * teardown (objNull remoteControl, player switchCamera, then openCuratorInterface
 * next frame). Deleting the unit out from under that sequence is a worse outcome
 * than the mistimed switchMove this originally guarded against.
 *
 * EVERY GUARD IS RE-CHECKED IN THE STATEMENT, not just on arrival. There is a
 * network hop and then a wait in between, and a guard that protects a command
 * has to be evaluated where and when that command runs — the unit can board a
 * vehicle, go down, or die while the handover completes.
 *
 * Arguments:
 * 0: Released unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_control_fnc_rcResetApply
 *
 * Public: No
 */

// Tested three times — on arrival, in the wait condition, and again in the
// statement once the handover has landed — so a macro rather than hand-copied
// blocks that can drift apart.
//
// Locality is deliberately NOT part of this: it is the thing being waited FOR,
// so folding it in here would make the arrival filter reject every machine that
// is about to receive the unit. It is tested separately alongside this macro.
//
// vehicle: ZEN remote controls effectiveCommander, so a VEHICLE takeover arrives
//   here as the crewman object. Crew are excluded deliberately and not as a gap —
//   T179189 does not break a remote-controlled crewman's aiming, so there is
//   nothing to rebuild, and recreating a unit into a specific seat would be real
//   work for no benefit. Also covers the unit boarding something during the wait.
// INCAPACITATED: a downed unit is mid-revive-state and must not be replaced out
//   from under whatever is treating it.
// surrendered / captured: rtz_captive holds prisoners in a forced pose WITH
//   disableAI "ANIM" (its FUNC(surrenderApply)), and ZEN's canControl lets a
//   curator remote control a surrendered unit, so this is reachable. Read as plain
//   object variables, which adds no requiredAddons edge on rtz_captive.
#define RC_RESET_ELIGIBLE(unit) ( \
    !isNull unit \
    && {alive unit} \
    && {vehicle unit isEqualTo unit} \
    && {lifeState unit isNotEqualTo "INCAPACITATED"} \
    && {!(unit getVariable [QEGVAR(captive,surrendered), false])} \
    && {!(unit getVariable [QEGVAR(captive,captured), false])} \
)

params ["_unit"];

if !(RC_RESET_ELIGIBLE(_unit)) exitWith {};

[
    // Settles on either of two outcomes: the handover landed here, or the unit
    // stopped being a valid subject at all. The second disjunct is what keeps a
    // death or a mount during the wait from spinning every machine in the
    // mission to the full timeout — the statement then sorts out which it was.
    {
        params ["_unit"];
        local _unit || {!(RC_RESET_ELIGIBLE(_unit))}
    },
    {
        params ["_unit"];

        // Only one of the two settling conditions means "act".
        if !(local _unit && {RC_RESET_ELIGIBLE(_unit)}) exitWith {};

        [_unit] call FUNC(rcRebuild);
    },
    [_unit],
    RC_RESET_TIMEOUT
] call CBA_fnc_waitUntilAndExecute;
