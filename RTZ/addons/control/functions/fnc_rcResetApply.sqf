#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(rcReset) (registered on EVERY machine in XEH_postInit).
 * Clears the animation and look state a Zeus remote control leaves behind, so
 * the released unit drops back into a natural pose instead of holding whatever
 * the RC camera was pointed at.
 *
 * Registered unconditionally, with no hasInterface guard: FUNC(rcReset) aims a
 * targetEvent at the unit and CBA delivers it to the unit's OWNER, which for AI
 * can be a headless client or the dedicated server — the same reasoning already
 * written out for the dismount receiver in XEH_postInit.
 *
 * EVERY GUARD IS RE-CHECKED HERE, not just on the sender. There is a network hop
 * in between, and a guard that protects a command has to be evaluated where that
 * command runs — the unit can board a vehicle, go down, or die during the hop.
 *
 * Deferred one frame. ZEN's own teardown spans frames (objNull remoteControl,
 * player switchCamera, then openCuratorInterface next frame) and raises the stop
 * event synchronously in the middle of it, so a switchMove landing in that same
 * frame risks being clobbered by the engine's own transition out of control. If
 * the pose is still seen to stick in testing, escalate to a fixed
 * [..., 0.25] call CBA_fnc_waitAndExecute. The guards are re-tested inside the
 * deferred body, since a frame is long enough for all of them to change.
 *
 * doWatch / lookAt are cleared for the same reason FUNC(resetApply) clears them
 * after a LAMBS taskReset — the watch and the head/aim look are separate engine
 * channels that survive an animation reset and leave the unit staring at the old
 * point. objNull rather than [0,0,0], for the reason spelled out at
 * fnc_resetApply.sqf:83-85.
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

// Tested twice — on arrival and again a frame later, inside the deferred body —
// so a macro rather than two hand-copied blocks that can drift apart.
//
// local: filters CBA's per-machine delivery, as FUNC(resetApply) does.
// vehicle: ZEN remote controls effectiveCommander, so a VEHICLE takeover arrives
//   here as the crewman object — a switchMove on a seated unit destroys its seat
//   animation. Also covers the unit boarding something during the hop.
// INCAPACITATED: a switchMove would yank a downed unit out of its unconscious
//   animation.
// surrendered / captured: rtz_captive holds prisoners in a forced pose WITH
//   disableAI "ANIM" (its FUNC(surrenderApply)), and ZEN's canControl lets a
//   curator remote control a surrendered unit, so this is reachable. Resetting
//   there would break the pose and then leave the unit frozen in the new one,
//   because ANIM is still disabled. Read as plain object variables, which adds no
//   requiredAddons edge on rtz_captive.
#define RC_RESET_ELIGIBLE(unit) ( \
    !isNull unit \
    && {local unit} \
    && {alive unit} \
    && {vehicle unit isEqualTo unit} \
    && {lifeState unit isNotEqualTo "INCAPACITATED"} \
    && {!(unit getVariable [QEGVAR(captive,surrendered), false])} \
    && {!(unit getVariable [QEGVAR(captive,captured), false])} \
)

params ["_unit"];

if !(RC_RESET_ELIGIBLE(_unit)) exitWith {};

[{
    params ["_unit"];

    if !(RC_RESET_ELIGIBLE(_unit)) exitWith {};

    _unit switchMove "";
    _unit setUnitPos "AUTO";
    _unit doWatch objNull;
    _unit lookAt objNull;
}, [_unit]] call CBA_fnc_execNextFrame;
