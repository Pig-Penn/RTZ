#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens the fire mission: the curator picks the target with the cursor — in the 3D
 * view or on the Zeus map — a ZEN target module is created there, and ZEN's Artillery
 * Fire Mission dialog then opens with that target already selected.
 *
 * This replaces ZEN's own FireArtillery context entry, which rtz_common's Clean
 * Context Menu removes. That entry picked the position the same way but then fired a
 * hardcoded four rounds at zero spread from a magazine chosen out of a submenu
 * (zen_context_actions_fnc_selectArtilleryPos); ZEN's dialog has the spread, gun
 * count, ammo and round count, but is only reachable by dragging a module out of the
 * Zeus tree and either typing a grid by hand or having planted a target first. This
 * joins the two halves.
 *
 * A TARGET MODULE, not a grid string. The dialog's other targeting mode takes a grid,
 * which ZEN resolves through CBA_fnc_mapGridToPos with the centring flag set
 * (zen_common_fnc_fireArtillery:36) — so a 6-digit grid would move the aim point to
 * the middle of its 100 m square. The target logic carries the clicked position
 * exactly, and survives the mission as a named target the curator can fire at again.
 *
 * ZEN's picker is used as-is rather than reimplemented — this needs a single click,
 * not the press-drag-release gesture that made EFUNC(airstrike,beginAiming) and
 * EFUNC(dig,beginAiming) roll their own. That also means the
 * zen_common_selectPositionActive contract is ZEN's problem here, not ours: it sets,
 * tests and clears the flag itself, and its re-entry guard answers a second call by
 * invoking the callback with _successful false rather than opening a second session.
 *
 * WHAT IS LEANED ON IN ZEN (all named in script_component.hpp):
 *
 * 1. Creating a zen_modules_moduleCreateTarget is the only way into the list the
 *    dialog's target combo reads — zen_position_logics_fnc_add keys the list on the
 *    logic's own typeOf. FUNC(createTarget) is what keeps that from also opening
 *    ZEN's naming dialog; see CfgVehicles.hpp.
 * 2. The dialog reads its initial field values from the zen_modules_saved namespace
 *    (zen_modules_fnc_gui_fireMission:23) and writes them back on confirm (its line
 *    146). Seeding the mode and target index there is what pre-selects the target,
 *    and is why no ZEN control IDC is referenced.
 * 3. The display resolves its logic from BIS_fnc_initCuratorAttributes_target — the
 *    same global zen_attributes_fnc_bi_showCuratorAttributes:45 sets before its own
 *    createDialog. BIS_fnc_showCuratorAttributes is not called directly because it
 *    bails when BIS_fnc_curatorAttributes returns [] for the logic.
 * 4. gui_fireMission DELETES that logic on its third line, before every one of its
 *    early exits, so nothing here has to clean it up — and must not try. The TARGET
 *    logic is a different object and is not deleted; FUNC(guiFireMission) owns it.
 *
 * Arguments:
 * 0: Selected objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_battery_fnc_selectFireMission
 *
 * Public: No
 */

params ["_objects"];

private _guns = [_objects] call FUNC(fireMissionGuns);
if (_guns isEqualTo []) exitWith {};

// The ANCHOR decides which guns actually fire. gui_fireMission does not take a gun
// list: it rebuilds one as `_anchor nearObjects [typeOf _anchor, 100]` filtered to
// crewed guns, so guns further out are dropped however they were selected, and
// unselected guns of the same type nearby are pulled in. Prefer the gun under the
// cursor — it is the one the curator right-clicked to get here — and fall back to
// the first of the selection when the cursor is over ground or over something else.
curatorMouseOver params ["", ["_hovered", objNull]];
private _anchor = [_guns select 0, _hovered] select (_hovered in _guns);

// Resolved ONCE, not per frame: the modifier below runs every frame for as long as
// the picker is open, and getArtilleryAmmo walks each gun's magazines. Empty for a
// pure-VLS selection, which inRangeOfArtillery cannot answer for — the modifier then
// reports no verdict instead of a false one, and ZEN's dialog does the range check
// on confirm either way.
private _magazine = (getArtilleryAmmo _guns) param [0, ""];

private _modifierFunction = {
    params ["_guns", "_position", "_args", "_visuals"];
    _args params ["", "_magazine"];

    if (_magazine isEqualTo "") exitWith {
        _visuals set [0, LSTRING(FireMissionPickTarget)];
        _visuals set [3, COLOR_UNKNOWN_RANGE];
    };

    if (ASLToAGL _position inRangeOfArtillery [_guns, _magazine]) then {
        _visuals set [0, LSTRING(FireMissionInRange)];
        _visuals set [3, COLOR_IN_RANGE];
    } else {
        _visuals set [0, LSTRING(FireMissionOutOfRange)];
        _visuals set [3, COLOR_OUT_OF_RANGE];
    };
};

[_guns, {
    params ["_successful", "", "_position", "_args"];
    _args params ["_anchor"];

    // Covers every way the pick can end badly: ESCAPE, the pause menu, the Zeus
    // display closing, a gun being deleted mid-pick, and a picker already running.
    if (!_successful) exitWith {};
    if (isNull _anchor) exitWith {};

    // Global, not local: the guns resolve the target through the object itself
    // (zen_common_fnc_fireArtillery reads getPosASL off it), and they are local to
    // whichever machine owns them.
    //
    // createUnit on a throwaway logic group, NOT createVehicle. A module logic
    // descends from Logic, and the engine refuses those outright — "Vehicles with
    // brain cannot be created using 'createVehicle'" in the RPT, objNull returned,
    // and every step after it quietly doing nothing with a null. The group is made
    // with deleteWhenEmpty set so it collects itself once initModule has moved the
    // logic into BI's function-module group; this is ZEN's own construction in
    // zen_common_fnc_fireVLS and zen_common_fnc_createZeus. CAN_COLLIDE so the engine
    // leaves the position exactly where the curator put it.
    private _target = createGroup [sideLogic, true] createUnit [FIRE_MISSION_TARGET, ASLToAGL _position, [], 0, "CAN_COLLIDE"];

    // createGroup returns grpNull once a side is at its group cap, and createUnit on
    // it returns objNull. Say so rather than repeating the silent nothing above.
    if (isNull _target) exitWith {
        [LSTRING(MsgTargetFailed)] call zen_common_fnc_showMessage;
    };

    // Suppresses ZEN's naming dialog. Safe to set after creation even though the init
    // event handler has already fired, because initModule defers the module function
    // by a frame — see FUNC(createTarget).
    _target setVariable [QGVAR(silentTarget), true];

    // ZEN's own name format and counter, so an RTZ target is indistinguishable from
    // one planted by hand: "Target Alpha", "Target Bravo", and so on.
    //
    // Registered here and NAMED AGAIN BELOW, because add()'s name does not survive on
    // its own. zen_modules_fnc_initModule moves every module logic into one of BI's
    // function-module groups a frame after creation, and that reassignment RESETS the
    // entity's name — a target named in the creation frame reads back correctly and is
    // then blank one frame later, which is what the target combo was showing. ZEN never
    // meets this because its own naming runs from the Create Target dialog's confirm
    // callback, seconds after the join has already happened.
    //
    // add() still carries the name: its CBA_fnc_globalEventJIP entry is what names the
    // target for players who join later, and that entry is not affected by the reset.
    private _tmpGroup = group _target;
    private _name = [_target, TARGET_NAME_FORMAT] call zen_position_logics_fnc_nextName;
    [_target, _name] call zen_position_logics_fnc_add;

    // The list is server-authoritative — add() hands off with CBA_fnc_serverEvent
    // from a client and the server broadcasts the list back — so the index the dialog
    // needs does not exist yet on a dedicated server. Wait for it, bounded.
    //
    // The group test is the second half of the same wait: the name re-assert below is
    // only correct once initModule's rehome has landed, and the rehome is a SERVER
    // action while add() is a round trip, so neither one implies the other has run.
    // Group membership replicates, so the curator can see it from here.
    [{
        params ["_target", "", "", "_tmpGroup"];

        isNull _target
        || {_target in (FIRE_MISSION_TARGET call zen_position_logics_fnc_get)
            && {group _target isNotEqualTo _tmpGroup}}
    }, {
        params ["_target", "_anchor", "_name"];

        if (isNull _target || {isNull _anchor}) exitWith {};

        // The re-assert. Global rather than JIP: add() already owns the JIP entry, and
        // a second one would name the target twice for a player joining later.
        [ZEN_EVENT_SETNAME, [_target, _name]] call CBA_fnc_globalEvent;

        // Index into the SAME filtered list the dialog indexes into: initList numbers
        // its rows off zen_position_logics_fnc_get, and select() reads the value back
        // out of it, so anything else would aim at the wrong target.
        private _index = (FIRE_MISSION_TARGET call zen_position_logics_fnc_get) find _target;
        if (_index < 0) exitWith {[_target] call FUNC(discardTarget)};

        // Read-modify-write rather than a fresh tuple, so spread, gun count, ammo and
        // round count keep whatever the curator last confirmed. Copied because the
        // stored array is handed back by reference.
        private _saved = +(zen_modules_saved getVariable [ZEN_SAVED_FIREMISSION, ZEN_SAVED_DEFAULT]);
        _saved set [SAVED_INDEX_MODE, SAVED_MODE_TARGET];
        _saved set [SAVED_INDEX_TARGET, _index];
        zen_modules_saved setVariable [ZEN_SAVED_FIREMISSION, _saved];

        // Handed to FUNC(guiFireMission), which deletes it again unless the curator
        // confirms the mission. Set before the dialog opens: the display's function
        // runs inside createDialog, not after it.
        GVAR(pendingTarget) = _target;

        // LOCAL, unlike the target above: this logic never leaves the client. It
        // exists only to carry the anchor gun to gui_fireMission through attachedTo,
        // which deletes it on its third line, so making it global would broadcast a
        // create and a delete for an object no other machine ever reads. The order
        // itself leaves this machine later, as ZEN's own zen_common_fireArtillery
        // target event.
        // POSITION FIRST, THEN ATTACH — EFUNC(control,rcRebuild)'s rule, and this
        // logic is not just carrying the gun: gui_fireMission reads its POSITION off
        // it on its second line, one line before it deletes it, and that position is
        // what the target combo measures every "x.x km" from and what its Nearest and
        // Farthest modes sort by. Created at [0, 0, 0] the way the rest of ZEN creates
        // a throwaway logic, that read lands on the map's south-west corner while the
        // dialog is still opening in the same frame, and every target in the list is
        // reported tens of kilometres away from a gun standing next to it.
        //
        // Creating it AT the anchor makes the read correct whether or not the attach
        // has resolved by the time createDialog runs, so nothing here depends on when
        // the engine applies an attachment. The attach still matters and stays: it is
        // how gui_fireMission resolves the gun at all, through attachedTo.
        private _logic = FIRE_MISSION_MODULE createVehicleLocal (ASLToAGL getPosASL _anchor);
        _logic attachTo [_anchor, [0, 0, 0]];

        missionNamespace setVariable ["BIS_fnc_initCuratorAttributes_target", _logic];

        // The only path on which the module logic is this function's to clean up. A
        // dialog that opened has already deleted it — deleteVehicle on the resulting
        // null object would be a no-op, but a dialog that did NOT open leaves an
        // attached, hidden logic riding the gun for the rest of a mission measured in
        // hours, and leaves the target pending with no Unload handler coming.
        if !(createDialog FIRE_MISSION_DIALOG) then {
            GVAR(pendingTarget) = objNull;
            deleteVehicle _logic;
            [_target] call FUNC(discardTarget);
        };
    }, [_target, _anchor, _name, _tmpGroup], TARGET_REGISTER_TIMEOUT, {
        params ["_target"];

        // The registration never came back. Take the target with it rather than
        // leaving an unnamed one standing on the map.
        [_target] call FUNC(discardTarget);

        [LSTRING(MsgTargetFailed)] call zen_common_fnc_showMessage;
    }] call CBA_fnc_waitUntilAndExecute;
}, [_anchor, _magazine], nil, nil, nil, nil, _modifierFunction] call zen_common_fnc_selectPosition;
