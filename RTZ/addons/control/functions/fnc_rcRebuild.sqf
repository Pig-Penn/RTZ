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
 * Runs where the unit is local, and on exactly ONE machine. FUNC(rcResetApply) waits out
 * the ownership handover on every machine and the first to see the unit go local asks
 * FUNC(rcClaim) — on the server, where `owner` is authoritative — for the job. Reached as
 * the QGVAR(rcRebuildAt) receiver, never called directly across the wire.
 *
 * The tail of the rebuild is a second server hop, FUNC(rcHandover): the hide, the curator
 * grant and the delete of the original all need the server, and the grant has to be
 * ordered before the delete.
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

// Captured HERE rather than read inside the settle with the other carry-over state,
// because it is the one field that leaves this machine: FUNC(rcHandover) applies it on
// the server, and the original may already be gone by the time that hop is served.
private _hidden = isObjectHidden _unit;

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
        "_attached", "_synchronized", "_varName", "_featureState", "_variables", "_hidden"];

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
        // setName's PERSON syntax is the three-element array; the bare string form
        // is the LOCATION syntax and does nothing at all to a unit — the engine
        // leaves the replacement's randomly generated name in place, which rtz_hud's
        // vehicle tags and rtz_spotting's chevrons then display. Wargame's rebuild
        // has the same line and the same no-op. Only the last element reaches the
        // command bar, so the full name is passed there rather than a bare surname.
        // BI documents person naming as singleplayer-only; if that still holds this
        // is inert either way, but it is inert in the CORRECT shape and costs three
        // string reads a release.
        private _name = name _unit;
        private _words = _name splitString " ";
        _new setName [_name, _words param [0, _name, [""]], _name];
        _new setSuppression (getSuppression _unit);
        _new setCaptive (captive _unit);
        _new setUnitPos (unitPos _unit);
        // On the UNIT, not on its group. The replacement joins the group the original was
        // already in, so writing the group's combat mode here would either be a no-op or,
        // if the original had been given its own, quietly impose that on every other member.
        _new setCombatMode (combatMode _unit);

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

    // The hide, the curator grant and the delete of the original are ONE server-side
    // step, not three statements here — all three are server commands, and the grant
    // has to be ORDERED before the delete because it reads the original's editable-set
    // membership. FUNC(rcHandover) carries the full reasoning. This used to be a grant
    // that hopped to the server and a deleteVehicle on the next line, which lost that
    // race on the client-local path and quietly widened per-officer ownership to every
    // curator in the mission.
    [QGVAR(rcHandover), [_new, _unit, _hidden]] call CBA_fnc_serverEvent;

    [{
        params ["_new", "_group", "_wasLeader", "_posATL", "_attached", "_varName"];

        if (isNull _new) exitWith {};

        // POSITION FIRST, THEN ATTACH. `attachTo` with no offset does not snap the
        // child to the parent's origin — it keeps the child's CURRENT position
        // relative to the parent, which is why ACE3 creates an effect source at the
        // parent's position before attaching it bare (fnc_burnEffects) and why ZEN's
        // Attach To leaves objects where the curator left them. The replacement is
        // still standing at the map origin until the line below, so attaching first
        // captured an offset equal to the original's whole world position and the
        // move then applied it twice, throwing anything attached to roughly double
        // the map coordinate. Wargame's rebuild has the same ordering.
        _new setPosATL _posATL;

        {_x attachTo [_new]} forEach _attached;

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
    _varName, _featureState, _variables, _hidden], RC_REBUILD_SETTLE] call CBA_fnc_waitAndExecute;
