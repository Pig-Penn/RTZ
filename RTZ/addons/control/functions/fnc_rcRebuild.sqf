#include "script_component.hpp"
/*
 * Author: Maxim
 * Rebuilds one unit released from Zeus remote control: creates a fresh unit of the same
 * type in the same group, carries the original's state across, and deletes the original.
 *
 * THIS IS THE ONLY KNOWN REMEDY, and that is not a guess. A remedy ladder was run in-game
 * against a live broken unit, cheapest candidate first: LAMBS hard taskReset (the reset
 * this component already shipped), disableAI "ALL" / enableAI "ALL", re-applying every
 * skill value, re-seating the weapon with setUnitLoadout, and a fresh group via
 * joinSilent. All five failed. Recreation is not the heavy option, it is the only option
 * — see docs/superpowers/specs/2026-08-24-rc-rebuild-design.md.
 *
 * The bug is engine-side (T179189): a unit released from remote control turns toward a
 * target and never puts its gun on it. Zeus Wargame reached the same conclusion
 * independently and says so at jac_wargameMain.sqf:2054 — "when exiting direct control,
 * create a new unit that is the exact same, in order to fix an issue with the AI aiming".
 * Its rebuild is the floor for the carry-over below: every field it copies is a field it
 * presumably lost first.
 *
 * WHAT SURVIVES FOR FREE, and why no other component has to be told this happened: CBA's
 * Extended Event Handlers re-run on createUnit, so every handler ACE3, ZEN, LAMBS and RTZ
 * register through XEH is re-attached to the replacement without help, along with their
 * init state. Only HAND-ADDED addEventHandler calls are lost.
 *
 * Across RTZ there are four of those on infantry — rtz_path's AnimDone and Hit puppet
 * handlers, and rtz_assemble's WeaponAssembled and WeaponDisassembled — and none of them
 * can be live on a unit arriving here: a puppeted or errand-running unit is not one a
 * curator is remote controlling. rtz_slide and rtz_airstrike hold units in long-lived
 * registries and are unreachable for a stronger reason still, since RC_RESET_ELIGIBLE
 * rejects anything inside a vehicle and both only ever hold crewed vehicles.
 *
 * So there is no migration contract and no notification event: this function deletes an
 * object nothing else in the mod is currently holding. If that ever stops being true —
 * if some component starts writing hand-added handlers or transient errand state to units
 * that can be remote controlled — the fix is an event raised BEFORE the capture below, so
 * listeners can release their state while the unit still exists and it is never copied
 * onto the replacement. Raising one afterwards would mean un-copying, which is worse.
 *
 * Runs where the unit is local — FUNC(rcResetApply) has already waited out the ownership
 * handover before calling this.
 *
 * Arguments:
 * 0: Released unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_control_fnc_rcRebuild
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit || {!alive _unit} || {!local _unit}) exitWith {};

private _group = group _unit;
if (isNull _group) exitWith {};

// ── Capture ──────────────────────────────────────────────────────────────────
private _type = typeOf _unit;
private _wasLeader = (leader _group) isEqualTo _unit;

private _posATL = getPosATL _unit;
private _dir = getDir _unit;
private _loadout = getUnitLoadout _unit;
private _attached = attachedObjects _unit;
private _synchronized = synchronizedObjects _unit;
private _varName = vehicleVarName _unit;

// Read locally and re-applied locally. checkAIFeature answers for THIS machine, so a
// global re-application would be asserting a state this machine never actually knew —
// and the unit is local here, which is where its AI runs.
private _featureState = RC_AI_FEATURES apply {_unit checkAIFeature _x};

// Generic, rather than a hand-maintained list of the variables RTZ happens to set today.
// This is what carries rtz_common's approach order, rtz_supply's claim, rtz_orders' fly
// height and ACE's medical state across without this function having to know any of them
// exist — and, more to the point, without a list here going stale the next time a
// component starts writing to units. Wargame's sweep, same shape
// (jac_wargameMain.sqf:1996).
private _variables = [];
{
    private _value = _unit getVariable _x;
    if (!isNil "_value") then {
        _variables pushBack [_x, _value];
    };
} forEach (allVariables _unit);

// ── Create ───────────────────────────────────────────────────────────────────
// At the map origin rather than in place, so the new unit cannot collide with the one it
// is replacing during the frames both exist. It is moved to the real position at the end,
// after the original is gone. Wargame does the same and for the same reason.
private _new = _group createUnit [_type, [0, 0, 0], [], 0, "CAN_COLLIDE"];

if (isNull _new) exitWith {
    TRACE_2("rcRebuild: createUnit FAILED, leaving the original alone",_unit,_type);
};

[{
    params ["_unit", "_new", "_group", "_wasLeader", "_posATL", "_dir", "_loadout",
        "_attached", "_synchronized", "_varName", "_featureState", "_variables"];

    if (isNull _new) exitWith {};

    // The original can die or be deleted inside the settle. The new unit is already built
    // and is the better of the two, so the rebuild finishes either way — only the reads
    // that need the original are skipped.
    private _haveOld = !isNull _unit;

    _new setUnitLoadout _loadout;
    _new setDir _dir;

    if (_haveOld) then {
        _new setRank (rank _unit);
        _new setFace (face _unit);
        _new setName (name _unit);
        _new setSuppression (getSuppression _unit);
        _new setCaptive (captive _unit);
        _new setUnitPos (unitPos _unit);
        // On the UNIT, not on its group. The replacement joins the group the original was
        // already in, so writing the group's combat mode here would either be a no-op or,
        // if the original had been given its own, quietly impose that on every other member.
        _new setCombatMode (combatMode _unit);
        _new hideObjectGlobal (isObjectHidden _unit);

        // Last of the engine writes, so a unit rebuilt at high damage is not being poked
        // with loadout and stance changes while already near death. ACE medical does not
        // read this: it keeps its own wound state in variables, which the sweep below
        // carries over separately and which is the authority wherever ACE is loaded.
        _new setDamage (damage _unit);
    };

    {
        if (_x) then {_new enableAI (RC_AI_FEATURES select _forEachIndex)}
        else {_new disableAI (RC_AI_FEATURES select _forEachIndex)};
    } forEach _featureState;

    // Public, matching Wargame. Not a preference: the engine offers no way to ask whether a
    // variable was originally set public, so the choice is between broadcasting all of them
    // and silently downgrading the ones that were. A rebuild happens a handful of times in
    // an operation, so the traffic is bounded.
    {
        _new setVariable [_x select 0, _x select 1, true];
    } forEach _variables;

    {_new synchronizeObjectsAdd [_x]} forEach _synchronized;

    // BEFORE the original is deleted, so EFUNC(common,curatorsOf) can still read who owned
    // it and per-officer ownership survives. Off-server this is a serverEvent and could in
    // principle lose the race with the delete below; grantCurators' documented fallback is
    // "all live curators", so the failure mode is a unit owned too widely rather than one
    // orphaned. Wargame grants only to the RELEASING curator and loses the rest outright.
    [_new, _unit] call EFUNC(common,grantCurators);

    if (_haveOld) then {
        deleteVehicle _unit;
    };

    [{
        params ["_new", "_group", "_wasLeader", "_posATL", "_attached", "_varName"];

        if (isNull _new) exitWith {};

        {_x attachTo [_new]} forEach _attached;

        _new setPosATL _posATL;

        // Re-asserted after the original is gone. joinSilent on the group's own units is
        // Wargame's idiom for making the engine re-seat formation slots around the
        // replacement rather than leaving a hole where the old unit stood.
        (units _group) joinSilent _group;

        if (_wasLeader) then {
            _group selectLeader _new;
        };

        if (_varName != "") then {
            _new setVehicleVarName _varName;
            missionNamespace setVariable [_varName, _new, true];
        };

        TRACE_2("rcRebuild: complete",_new,typeOf _new);
    }, [_new, _group, _wasLeader, _posATL, _attached, _varName], RC_REBUILD_SETTLE] call CBA_fnc_waitAndExecute;

}, [_unit, _new, _group, _wasLeader, _posATL, _dir, _loadout, _attached, _synchronized,
    _varName, _featureState, _variables], RC_REBUILD_SETTLE] call CBA_fnc_waitAndExecute;
