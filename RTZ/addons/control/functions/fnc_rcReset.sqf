#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for "zen_remoteControlStopped" (registered on EVERY machine in
 * XEH_postInit, but only ever RAISED on the ex-controller's own client). Sends
 * the animation reset that unsticks a unit the curator just released — the
 * engine leaves a look-direction lock pointing wherever the RC camera was aimed,
 * and vanilla AI never clears it, so the unit keeps the pose it was let go in
 * (the "frozen aiming at the sky" case).
 *
 * DETECTION IS ZEN'S EVENT, NOT A POLL — the non-obvious part, and the one that
 * gets re-litigated. zen_remote_control_fnc_start:100 raises
 * "zen_remoteControlStopped" locally after it has already run
 * `objNull remoteControl _unit` and cleared bis_fnc_moduleRemoteControl_owner,
 * and EVERY RC entry point funnels through that function: ZEN hides the vanilla
 * ModuleRemoteControl_F (scopeCurator = 1, i.e. hidden from the module list)
 * and registers its own module in its place, the
 * Zeus double-click goes through FUNC(handleMouseDblClick), and ACE3's Zeus RC
 * is zen_compat_ace calling the same start. ZEN is a hard dependency of this
 * component already (zen_common / zen_context_menu in requiredAddons).
 *
 * That makes the server-side scan FUNC(remoteControlIndicator) runs unnecessary
 * HERE. The indicator polls because it needs EVERY unit's RC state on the SERVER
 * for OTHER curators — a question no local event answers. This needs only "the
 * controller learns their own release ended", which the event delivers on
 * exactly the machine that owns the per-client setting.
 *
 * Accepted limitation: a curator who DISCONNECTS mid-RC never fires the event,
 * so the unit is not reset. ZEN leaks the same case (its owner variable is never
 * cleared either, so the indicator icon sticks for everyone else) — pre-existing
 * and upstream. Same for a mission script driving BIS_fnc_moduleRemoteControl
 * directly.
 *
 * The unit's locality after release is not guaranteed to be this machine, so the
 * commands themselves go out as a targetEvent (see FUNC(rcResetApply)); the
 * checks here are only a cheap pre-filter so an ineligible release costs no
 * network message. GVAR(enableRcReset) is read LIVE, per curator.
 *
 * Arguments:
 * 0: Released unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_control_fnc_rcReset
 *
 * Public: No
 */

params ["_unit"];

if (!GVAR(enableRcReset)) exitWith {};

// ZEN raises the event on its !alive exit condition too, and _unit can be null
// by then. Infantry only — a vehicle takeover arrives as the crewman object,
// and the applier re-checks this after the hop.
if (isNull _unit || {!alive _unit} || {!(_unit isKindOf "CAManBase")}) exitWith {};
if (vehicle _unit isNotEqualTo _unit) exitWith {};

[QGVAR(rcReset), [_unit], _unit] call CBA_fnc_targetEvent;
