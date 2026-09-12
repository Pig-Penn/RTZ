#include "script_component.hpp"
/*
 * Author: Maxim
 * FiredMan class event handler body. Reports a grenade thrown by ZEN's
 * curator-ordered "Throw Grenade" action to the server, which decides which
 * curators are entitled to see it.
 *
 * ONLY curator-ordered throws, never the grenades AI throw of their own accord in
 * a firefight — the warning is about another curator acting on your troops, and
 * organic combat throws would drown it. ZEN sets no variable on the unit or the
 * projectile and raises no global event, so the throw has to be recognised by its
 * signature: zen_ai_fnc_throwGrenade creates a CBA_B_InvisibleTargetVehicle helper
 * at the aim point and doTargets it, and the SAME call disables the unit's TARGET
 * and AUTOTARGET so that assignment cannot be overwritten before the throw. Its
 * cleanup runs 1.5 s later — after the shot — and deletes the helper without ever
 * clearing doTarget. So at Fired time assignedTarget IS the helper, for exactly
 * the throws wanted and no others.
 *
 * ZEN's Suppressive Fire action creates the same helper class, which is why the
 * weapon test is not redundant: "Throw" excludes every rifle and MG shot outright.
 * A unit under a suppression order that throws an organic grenade would still be
 * reported — benign, since a grenade genuinely is incoming, and rare, because
 * suppression forces combat mode BLUE.
 *
 * That helper is also WHERE THE GRENADE IS GOING: zen_ai_fnc_throwGrenade does
 * `_helper setPosASL _position` with the point the curator clicked. So the one read
 * that identifies the throw also yields the aim point, and the report is built from
 * it rather than from the projectile.
 *
 * The handler is installed on every machine (a class event handler cannot be
 * removed, so it has to be), and `local _unit` picks exactly one reporter out of
 * them. Server-only registration would miss almost every real case: ZEN's
 * fnc_throwGrenade hands the work to whichever machine the unit is local on, and
 * RTZ units are local to the curator that spawned them, not to the server. That is
 * the blind spot rtz_spotting's server-only FiredMan handler documents.
 *
 * That read has a FALLBACK behind it, because whether doTarget survives the disableAI
 * in the same ZEN call is undocumented and could not be settled off the engine. See
 * the block itself for the gates; the shape to keep in mind here is that the precise
 * read stays primary and the proximity sweep only runs for a unit already proven to be
 * under a ZEN order.
 *
 * KNOWN LIMITATION — a late throw is silently missed, and the fallback does NOT fix
 * it. zen_ai_fnc_throwGrenade arms its cleanup in the SAME tick as the CBA_logic
 * "UseMagazine" action, on a 1.5 s CBA_fnc_waitAndExecute (CLEANUP_DELAY), and that
 * cleanup ends with `deleteVehicle _helper`. If the throw animation releases the
 * grenade more than 1.5 s after the action, the helper is gone by the time this
 * handler runs — and it is gone for BOTH paths alike, since a deleted object is
 * neither an assignedTarget nor a nearestObjects hit. The same cleanup also re-enables
 * TARGET, so the fallback's own gate has closed by then too. This is not fixable from
 * the Fired side at all.
 *
 * The TRACE below is how to measure how often it actually bites, and it is also how to
 * answer the doTarget question for good: build with DEBUG_ENABLED_MISSILE, order a
 * throw, and read whether the helper logged non-null. If it logged null and a warning
 * still appeared, the fallback is what carried it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Weapon <STRING>
 * 2: Muzzle <STRING>
 * 3: Mode <STRING>
 * 4: Ammo classname <STRING>
 * 5: Magazine <STRING>
 * 6: Projectile <OBJECT> — unused; the warning is anchored on ZEN's aim point, not
 *    on the grenade
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, "Throw", "HandGrenadeMuzzle", "this", "GrenadeHand", "HandGrenade", _grenade] call rtz_missile_fnc_detectGrenade
 *
 * Public: No
 */

// Deliberately in front of params, and first in the body. This handler runs on
// EVERY infantry shot on this machine for the whole mission, and "Throw" is the
// pseudo-weapon every hand-thrown item fires from — so one array index and one
// string compare is the entire cost of a shot that is not a throw. Same discipline
// as rtz_spotting's fire-blink gate, which puts its setting read above its netId.
if ((_this select 1) isNotEqualTo "Throw") exitWith {};

// The projectile is deliberately not bound: nothing downstream uses it any more. A
// grenade record tracks no object, and dropping the old `isNull _projectile` guard
// with it is an improvement — a ZEN throw whose projectile did not resolve even on
// the thrower's own machine now still warns, because the aim point is known
// independently of the grenade.
params ["_unit", "", "", "", "_ammo"];

// Locality probe, mirroring FUNC(detectIncoming)'s. Build with
// DEBUG_ENABLED_MISSILE and read the RPT to confirm the reporter is the thrower's
// owner rather than the server.
TRACE_4("throw",_unit,local _unit,_ammo,isServer);

// A bare read, deliberately. CBA writes every setting into missionNamespace
// SYNCHRONOUSLY during this component's own preInit — CBA_fnc_addSetting wraps
// cba_settings_fnc_init, which ends by raising refreshSetting, whose handler does
// the setVariable — so this is a Boolean long before any shot is fired, and the
// GETGVAR form would only add an array literal per infantry shot on the hottest
// path in the component. (The frame-later refreshAllSettings is when the SERVER's
// synced value replaces the local default; that matters to a once-at-postInit
// decision like rtz_battery's, not to a gate re-read on every event.)
if (!GVAR(grenadeEnabled)) exitWith {};
if (!local _unit) exitWith {};

// ZEN-ordered only. See the header — this is the whole discriminator.
// assignedTarget, not `target`: the former is what doTarget/commandTarget write and
// read back, and `target` is not a command at all.
//
// Bound rather than called twice, because the helper is also where the AIM POINT
// comes from below. isKindOf on objNull is false, so a helper ZEN's cleanup already
// deleted — or one doTarget never recorded — falls through to the fallback below
// rather than reaching getPosASL objNull and putting a warning triangle on the map
// origin. When the fallback finds nothing either, the isNull gate under it is what
// drops the throw.
private _helper = assignedTarget _unit;

// Instrumentation for that limitation. Compiles to nothing without
// DEBUG_ENABLED_MISSILE, so typeOf is not paid on a live server. A throw logged here
// with a null helper is either an organic combat toss — expected, and the
// overwhelming majority — or a ZEN order whose 1.5 s cleanup beat the animation.
TRACE_3("throw helper",_unit,_helper,typeOf _helper);

// FALLBACK, and the reason it exists is an engine question nobody has written down:
// zen_ai_fnc_throwGrenade disables the unit's TARGET and AUTOTARGET in the SAME call,
// BEFORE the doTarget that assigns the helper. If that assignment does not survive the
// disable, assignedTarget is objNull for every ZEN throw and the discriminator above
// matches NOTHING — the whole half is inert, with no error in the RPT to say so. ZEN
// would never notice: its own aiming rides lookAt/doWatch and getRelDir, and it never
// reads assignedTarget back.
//
// So the helper is recovered by proximity when the precise read misses. Two cheap
// reads have to gate that, because ZEN's Suppressive Fire creates the SAME helper
// class (fnc_suppressiveFire.sqf) and would otherwise be mistaken for a throw order:
//
//   - checkAIFeature "TARGET" is the COST gate, and it is what keeps this off the hot
//     path. It is false only while one of those two ZEN actions holds the unit — both
//     disable an identical DISABLED_ABILITIES list — so an organic combat toss, which
//     is the overwhelming majority of throws and the case a firefight produces by the
//     dozen, never reaches nearestObjects at all. It answers only on the owning
//     machine, which is where `local _unit` above has already put us.
//   - zen_ai_isSuppressing is ZEN's own public flag on a unit under a SUPPRESSION
//     order — precisely the unit whose nearby helper is the wrong one to read an aim
//     point from.
//
// The candidate is then filtered by bearing, which is ZEN's own throw gate rather than
// a heuristic of ours: the magazine does not fire until the unit is facing its helper.
if !(_helper isKindOf "CBA_B_InvisibleTargetVehicle") then {
    _helper = objNull;

    if (!(_unit checkAIFeature "TARGET") && {!(_unit getVariable ["zen_ai_isSuppressing", false])}) then {
        // Sorted nearest-first, deliberately: the unsorted form is cheaper, but this
        // runs only for a unit already known to be under a ZEN order, and "the helper
        // it is aiming at" wants the nearest match rather than an arbitrary one.
        private _candidates = nearestObjects [_unit, ["CBA_B_InvisibleTargetVehicle"], THROW_HELPER_RADIUS];

        private _index = _candidates findIf {
            private _dir = _unit getRelDir _x;
            _dir <= THROW_HELPER_ARC || {_dir >= 360 - THROW_HELPER_ARC}
        };

        if (_index > -1) then {_helper = _candidates select _index};
    };
};

// isNull rather than the isKindOf above, because both branches have already
// guaranteed the class by the time control reaches here.
if (isNull _helper) exitWith {};

// Explosive only. ZEN's action offers every magazine on the Throw muzzle, so
// smoke, chemlights, IR strobes and throwable stones all reach this point, and
// none of them is the warning a curator asked for. indirectHit separates them
// cleanly: a frag has blast, the rest have none.
//
// Memoized by ammo classname — see FUNC(ammoVerdict), which is this cache and the
// guided-missile one, once.
private _explosive = [GVAR(explosiveAmmo), _ammo, {
    (getNumber (configFile >> "CfgAmmo" >> _this >> "indirectHit")) > 0
}] call FUNC(ammoVerdict);

if (!_explosive) exitWith {};

// The AIM POINT, not the projectile. zen_ai_fnc_throwGrenade does
// `_helper setPosASL _position` with the position the curator clicked, and
// zen_context_actions_fnc_selectThrowPos hands the IDENTICAL _position to every unit
// in the selection, capped at 75 m.
//
// The projectile at Fired time is still in the thrower's HAND, and sending that
// position was wrong four ways at once: the server's nearEntities scan ran around
// the thrower, so with a long throw the units actually under the grenade could sit
// outside the radius entirely; the units it did find were the throwing squad; the
// marker drew on the thrower; and the coalescing key became per-thrower-position, so
// a spread squad produced one warning per man instead of one per order. The helper
// is already resolved above, so the correct answer costs one getPosASL.
//
// The position travels with the event rather than being re-read on the server: the
// helper is deleted 1.5 s later and is not a network object on the receiving
// curator's machine anyway.
//
// `side _unit` colours the marker by who threw it, matching FUNC(detectIncoming) —
// the SIDE travels, never a resolved colour, and FUNC(receiveTrack) does the palette
// lookup on the client that will draw it.
[QGVAR(grenade), [getPosASL _helper, side _unit]] call CBA_fnc_serverEvent;
