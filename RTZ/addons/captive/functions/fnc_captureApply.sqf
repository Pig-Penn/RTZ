#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(captureApply) (registered on every machine in
 * XEH_postInit): strips a prisoner's armament and puts him in the bound-hands
 * pose, where he is local. Inventory and animation commands are unreliable
 * across locality, and FUNC(captureUnit) is pinned to the server by its curator
 * lookups, so both are sent to the unit rather than performed on the spot.
 *
 * Weapons first, then everything left that can be loaded into one. removeAllWeapons
 * takes the rifle, sidearm, launcher, binoculars and whatever is chambered in
 * them, but leaves the spare magazines in the prisoner's vest and uniform — and
 * grenades, which are magazines too. A prisoner who can be handed a rifle from
 * his own vest, or who still has a frag on him, is not disarmed.
 *
 * Uniform, vest and backpack are deliberately left alone: this is a disarm, not
 * a strip search, and the containers are what makes the prisoner still look like
 * the soldier he was.
 *
 * The pose then drops his hands from the surrender to bound behind his back, so
 * a curator can tell at a glance which of the men standing around have merely
 * given up and which have actually been taken. It is the only visible difference
 * between the two states: a prisoner keeps every restriction of the surrender he
 * came from, so nothing else about him changes on capture.
 *
 * Arguments:
 * 0: The captured unit <OBJECT>
 * 1: Re-route to the unit's owner if it is not local here <BOOL> (default: true;
 *    the re-routed copy passes false so a handover cannot ping-pong)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_captive_fnc_captureApply
 *
 * Public: No
 */

params ["_unit", ["_reroute", true]];

if (isNull _unit || {!alive _unit}) exitWith {};

// Every command below takes a LOCAL argument, so arriving on the wrong machine
// is not a partial failure — it is four silent no-ops that leave an armed
// prisoner and no error to say so. FUNC(captureUnit) addresses this at the
// unit's owner, but ownership can move between the send and the arrival: the
// group join it performs is one cause, and an HC rebalancing, rtz_control's
// transfer or a JIP handover are others it has no say in at all.
//
// Unlike its sibling this has no safety net to fall back on. The CAManBase
// "Local" handler in XEH_postInit re-applies FUNC(surrenderApply) on every
// ownership change — which restores the freeze, the captive flag and even the
// bound pose, since that function reads QGVAR(captured) to pick between the two
// poses — but it never re-runs the DISARM. So this is the one state flip in the
// component that has to get itself to the right machine.
//
// One hop only. The receiver of a re-route runs this same function with
// _reroute false and simply gives up if it is not local there either, which is
// the ping-pong guard EFUNC(slide,endSlide) documents needing for the same
// reason. Giving up is no worse than today's behaviour; bouncing forever is.
if (!local _unit) exitWith {
    if (_reroute) then {
        [QGVAR(captureApply), [_unit, false], _unit] call CBA_fnc_targetEvent;
    };
};

removeAllWeapons _unit;

// Deduplicated: `magazines` lists every round-count separately, and
// removeMagazines already takes every magazine of the class it is given, so the
// raw list would call it a dozen times to no effect.
private _magazines = magazines _unit;
{
    _unit removeMagazines _x;
} forEach (_magazines arrayIntersect _magazines);

// playMoveNow, not playMove: the prisoner is standing frozen in the surrender
// pose with disableAI "ANIM" set, and no ConnectTo chain leads out of it — a
// plain playMove would be queued behind a transition that never comes and the
// unit would keep his hands up. The switch is forced instead, and the state is
// static and looped, so it holds with nothing watching it.
//
// Guarded on the state rather than played unconditionally, for the same reason
// FUNC(surrenderApply) guards its own: this handler is idempotent by design, and
// re-playing a pose the unit is already holding is a visible twitch.
if (animationState _unit != ANIM_CAPTURED_STATE) then {
    _unit playMoveNow ANIM_CAPTURED_ENTER;
};
