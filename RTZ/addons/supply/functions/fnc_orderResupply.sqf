#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens the resupply picker: the curator aims at one vehicle — in the 3D view or on
 * the Zeus map — and every selected supply vehicle that can do something for it
 * services it. Modelled on EFUNC(attack,orderDestroy), which picks the destroy
 * order's target the same way.
 *
 * THIS REPLACED A BLANKET SWEEP. The order used to resolve its own targets —
 * everything serviceable within GVAR(serviceRadius) of each selected truck — and
 * the curator had no say in it. Supply is finite (the engine consumes
 * getRepairCargo / getFuelCargo / getAmmoCargo as it services), so "which vehicle
 * gets the last of it" is a real decision the order did not expose. The cost of the
 * change is that a parked column is now one order per vehicle; the picker is worth
 * it on a truck that is nearly dry, and one code path is worth more than two.
 *
 * ONE CLICK, ONE VEHICLE, several trucks. FUNC(serviceProviders) returns every
 * selected truck that can help, not just the nearest, and each gets its own order —
 * which is safe because the claim slots are PER SERVICE (see FUNC(grantedServices)):
 * a repair truck and a fuel truck take disjoint slots on one tank, while two fuel
 * trucks cannot both take CLAIM_FUEL.
 *
 * THE PICKER'S PER-FRAME BUDGET is the thing to preserve here. The modifier function
 * runs every frame for as long as the pick is open, and the question it answers ends
 * in FUNC(serviceDeficit), whose ammo term walks every turret's magazines. So the
 * resolve is split: FUNC(findServiceTarget) is distance tests only and runs every
 * frame, and FUNC(serviceProviders) is cached against the resolved target and
 * refreshed at PICK_REFRESH. The CLICK re-resolves both from scratch — the cache is
 * a drawing optimisation, never the order.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_supply_fnc_orderResupply
 *
 * Public: No
 */

params ["_objects"];

if (!GVAR(enabled)) exitWith {};

private _supplies = [_objects] call FUNC(getSupplyVehicles);

// Capabilities are read from live cargo, so a truck that spent its last store
// between the menu being built and this click is no longer a supply vehicle at all.
// That is the only way this list can be empty when the condition passed, and it
// deserves its own wording — "nothing left to resupply" would blame the column.
if (_supplies isEqualTo []) exitWith {
    [LLSTRING(MsgSupplyEmpty)] call EFUNC(common,showCountMessage);
};

// Bail BEFORE installing the ring rather than letting ZEN's re-entry guard bounce
// us. selectPosition answers a second call by invoking the callback with
// _successful false, and that callback tears the ring down — which would take the
// ring belonging to the pick already running with it. An rtz_path planning session
// blocks too, though it holds no flag (EFUNC(common,pickerActive)).
if (call EFUNC(common,pickerActive)) exitWith {};

// The same key the ZEN context entry relabelled itself with, so the cursor names
// the exact action the menu promised: "Refuel" for a lone fuel truck, "Resupply"
// for a mixed selection. Resolved ONCE — the modifier below must stay cheap.
private _label = ([_supplies] call FUNC(serviceLabel)) select 0;

// ── Service-radius ring ──────────────────────────────────────────────────────
// Baked once: the radius is a setting and cannot change mid-pick, so a frame costs
// one vectorAdd per segment and no trigonometry. RING_SEGMENTS + 1 points, the last
// equal to the first, so FUNC(drawRing3D) closes the ring without a wrap index.
private _radius  = GVAR(serviceRadius);
private _offsets = [];

for "_i" from 0 to RING_SEGMENTS do {
    private _angle = _i * 360 / RING_SEGMENTS;
    _offsets pushBack [_radius * sin _angle, _radius * cos _angle, 0.5];
};

GVAR(ringOffsets) = _offsets;
GVAR(ringTrucks)  = _supplies;

// Registered with rtz_core's shared frame loop rather than a Draw3D handler of our
// own, and unregistered on every exit path below — which is what makes the ring
// cost literally nothing outside a picker session.
[QGVAR(ring3D), LINKFUNC(drawRing3D), RENDER_WORLD, 40] call EFUNC(core,registerRenderer);

// The map control is re-resolved here and again at teardown rather than stored: a
// CONTROL cannot be serialized, and one left in the mission namespace trips an
// engine warning when the mission state is saved.
private _mapCtrl = (findDisplay IDD_RSCDISPLAYCURATOR) displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP;

if (!isNull _mapCtrl) then {
    GVAR(ringMapEH) = _mapCtrl ctrlAddEventHandler ["Draw", {_this call FUNC(drawRingMap)}];
};

// Mutated in place by the modifier every frame: [target, providers, computedAt].
// Handed to selectPosition as part of its args, so it lives exactly as long as the
// pick does and no GVAR is needed to hold it.
private _cache = [objNull, [], -1];

private _modifierFunction = {
    params ["_supplies", "_position", "_args", "_visuals"];
    _args params ["_label", "_cache"];

    private _target = [_position, _supplies] call FUNC(findServiceTarget);

    if (isNull _target) exitWith {
        _visuals set [0, LSTRING(NoTarget)];
        _visuals set [3, COLOR_INVALID];
    };

    _cache params ["_cached", "_providers", "_computedAt"];

    // Recomputed when the vehicle under the cursor CHANGES, or when the cached
    // answer has gone stale. Sweeping across a column therefore costs one magazine
    // walk per vehicle crossed, and resting on one costs 1 / PICK_REFRESH a second
    // rather than one per frame.
    if (_target isNotEqualTo _cached || {CBA_missionTime - _computedAt > PICK_REFRESH}) then {
        _providers = [_target, _supplies] call FUNC(serviceProviders);

        _cache set [0, _target];
        _cache set [1, _providers];
        _cache set [2, CBA_missionTime];
    };

    // A full vehicle parked beside a loaded truck is otherwise indistinguishable
    // from bare ground, which is the one failure a curator cannot explain to
    // himself. Out-of-range gets no wording of its own — the ring draws it.
    if (_providers isEqualTo []) exitWith {
        _visuals set [0, LSTRING(NothingNeeded)];
        _visuals set [3, COLOR_NEUTRAL];
    };

    _visuals set [0, _label];
    _visuals set [3, COLOR_VALID];
};

// _supplies goes in as selectPosition's objects, so ZEN draws its own line from
// EVERY participating truck to the cursor for free — which is what shows the
// curator that a two-truck selection means two trucks working.
[_supplies, {
    params ["_confirmed", "_supplies", "_position"];

    // ── Teardown, on every path ──────────────────────────────────────────────
    // This callback is the one place the pick can end: confirm, ESCAPE, the pause
    // menu, the Zeus display closing, and a selected truck being deleted all arrive
    // here. Done before the confirm test so no exit can strand the handlers.
    [QGVAR(ring3D), RENDER_WORLD] call EFUNC(core,unregisterRenderer);

    GVAR(ringTrucks)  = [];
    GVAR(ringOffsets) = [];

    if (GVAR(ringMapEH) != -1) then {
        // controlNull when the display has already closed, which is one of the ways
        // we get here — the handler died with the control, so there is nothing to
        // detach and the id is simply dropped.
        private _mapCtrl = (findDisplay IDD_RSCDISPLAYCURATOR) displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP;

        if (!isNull _mapCtrl) then {
            _mapCtrl ctrlRemoveEventHandler ["Draw", GVAR(ringMapEH)];
        };

        GVAR(ringMapEH) = -1;
    };

    if (!_confirmed) exitWith {};

    // Re-resolved, NOT read out of the modifier's cache: that cache exists to keep
    // the cursor cheap and may be up to PICK_REFRESH stale. The click is the order.
    private _target = [_position, _supplies] call FUNC(findServiceTarget);

    private _providers = [];
    if (!isNull _target) then {
        _providers = [_target, _supplies] call FUNC(serviceProviders);
    };

    // The cursor said this was clickable at most a frame ago, so reaching here means
    // the state changed underneath the pick — a truck that just ran dry, a target
    // another curator's order claimed first. Say so rather than swallowing the click.
    if (_providers isEqualTo []) exitWith {
        [LLSTRING(MsgNothingToService)] call EFUNC(common,showCountMessage);
    };

    // player is the ordering curator (this runs on their client) — threaded through
    // so FUNC(endService) can report back to whoever actually gave the order.
    [QGVAR(resupply), [_providers apply {[_x, _target]}, player]] call CBA_fnc_serverEvent;

    // No count suffix: one click services one VEHICLE however many trucks turned up
    // to do it, and "Resupplying x2" would read as two vehicles serviced.
    [LLSTRING(MsgResupplying)] call EFUNC(common,showCountMessage);
}, [_label, _cache], _label, nil, nil, nil, _modifierFunction] call zen_common_fnc_selectPosition;
