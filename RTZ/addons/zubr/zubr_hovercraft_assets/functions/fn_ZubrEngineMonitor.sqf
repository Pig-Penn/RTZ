#include "\x\rtz\addons\zubr\script_component.hpp"
/*
 * Author: Chair (CUP Vehicles), ported to a CBA per-frame handler by Maxim
 * Animates one Zubr's air cushion and propellers: registers it with the shared
 * monitor and starts that monitor if it is not already running.
 *
 * Reached from the `init` event handler in CfgVehicles.hpp, which is why it keeps
 * CUP's name and its CfgFunctions registration (see CfgFunctions.hpp).
 *
 * WHY THIS IS NOT CUP'S LOOP ANY MORE. CUP `spawn`s a `while {alive _vehicle} do`
 * with a `sleep 0.05` inside — one scheduled loop per hovercraft, ticking twenty
 * times a second for as long as the vehicle exists. That is the shape CLAUDE.md
 * rules out on a multi-hour operation, and it was the only `spawn`/`sleep` left in
 * the mod. Scheduled code also gets roughly 3 ms a frame in total and is resumed
 * whenever the scheduler gets back to it (docs/Knowledge Base/Gotchas.md §1), so
 * under load the animation simply stops keeping time.
 *
 * One shared unscheduled per-frame handler over a bounded registry replaces it,
 * created by the first Zubr and destroyed by the last — the same shape as
 * EFUNC(slide,slideTick) and EFUNC(airstrike,strikeTick). Idle cost is therefore
 * not "small", it is nothing: with no Zubr on the map the handler does not exist.
 *
 * The rates are per SECOND and integrated against real elapsed time, so the
 * propellers turn at the same speed on a 30 fps server and a 120 fps client. CUP's
 * per-iteration constants only held while the scheduler honoured the sleep.
 *
 * EVERY MACHINE REGISTERS; ONLY THE OWNER ANIMATES. `animateSource` needs the
 * vehicle local, and ownership moves during a mission (rtz_control's transfer, a
 * headless client rebalancing, a JIP handover) — so locality is a per-tick test,
 * not a registration-time one (docs/Knowledge Base/Gotchas.md §4).
 *
 * That is why the `init` handler in CfgVehicles.hpp no longer carries CUP's
 * `if (local (_this select 0))` guard. With it, only the machine that owned the
 * hull at creation ever held a record, and a handover stopped the animation for
 * good: the old owner's writes became silent no-ops and the new owner had nothing
 * registered to resume. A record on every machine that skips the work while it is
 * not the owner costs two cheap tests per hull per tick and survives the handover
 * in both directions.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * _vehicle call rtz_zubr_fnc_zubrEngineMonitor
 *
 * Public: No
 */

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle) exitWith {};

// Created here rather than in an XEH_preInit: this component is an asset addon
// with no CBA lifecycle files of its own (CfgFunctions is deliberate — the config
// expressions reference the built function names), and this function is the only
// reader or writer of either global.
if (isNil QGVAR(monitored)) then {
    GVAR(monitored) = [];
    GVAR(monitorPfh) = -1;
    GVAR(monitorLast) = CBA_missionTime;
};

// The init event handler can fire more than once against the same hull (a Zeus
// re-place, an XEH re-run), and two records would animate it twice as fast.
if (GVAR(monitored) findIf {(_x select ZUBR_VEHICLE) isEqualTo _vehicle} != -1) exitWith {};

GVAR(monitored) pushBack [_vehicle, 0, -1];

if (GVAR(monitorPfh) != -1) exitWith {};

GVAR(monitorLast) = CBA_missionTime;
GVAR(monitorPfh) = [{
    // Last Zubr went on the previous pass — take the loop down rather than leave
    // it spinning over an empty array for the rest of the mission.
    if (GVAR(monitored) isEqualTo []) exitWith {
        [GVAR(monitorPfh)] call CBA_fnc_removePerFrameHandler;
        GVAR(monitorPfh) = -1;
    };

    private _now = CBA_missionTime;
    // Clamped: a frame hitch or a mission-time jump would otherwise be handed to
    // the propellers as one enormous advance.
    private _delta = ((_now - GVAR(monitorLast)) max 0) min ZUBR_MAX_DELTA;
    GVAR(monitorLast) = _now;

    // Backwards, so a dropped record cannot disturb the indices not visited yet.
    for "_i" from (count GVAR(monitored)) - 1 to 0 step -1 do {
        private _record = GVAR(monitored) select _i;
        private _vehicle = _record select ZUBR_VEHICLE;

        // Death and deletion are the ONLY things that drop a record — `alive`
        // answers objNull too, so a hull deleted out from under the monitor goes
        // on the frame it goes.
        if (!alive _vehicle) then {
            GVAR(monitored) deleteAt _i;
            continue;
        };

        // Not ours to animate: every command below is argument-local. The record
        // stays so this machine picks the hull up if it later gains ownership.
        // ZUBR_ENGINE is reset so the first tick after a handover re-asserts the
        // cushion state rather than trusting a cached value the engine on THIS
        // machine was never told about.
        if (!local _vehicle) then {
            _record set [ZUBR_ENGINE, -1];
            continue;
        };

        private _on = isEngineOn _vehicle;

        // Written only on the transition. CUP re-wrote this every iteration, which
        // is an engine call per hull per tick to re-state a value that changes when
        // somebody starts the engine. animPeriod is 5 s, so the cushion still
        // inflates and deflates over its own ramp either way.
        private _want = [0, 1] select _on;
        if (_want != (_record select ZUBR_ENGINE)) then {
            _vehicle animateSource ["engineon_source", _want];
            _record set [ZUBR_ENGINE, _want];
        };

        private _rpm = ((_record select ZUBR_RPM) + (([-1, 1] select _on) * PROPELLER_SPIN * _delta)) max 0 min 1;
        _record set [ZUBR_RPM, _rpm];

        // Stopped and fully wound down: nothing left to advance. The engine holds
        // the last phase, which is a stationary propeller — exactly right.
        if (_rpm == 0) then { continue };

        // Read back from the engine rather than accumulated here, which is CUP's
        // own arithmetic and is deliberately kept: the phase this source clamps or
        // wraps to belongs to the binarised model, and a script-side counter would
        // be guessing at that range.
        //
        // CUP also read `animationPhase "debug_rpm"`, `animationPhase
        // "debug_engine"` and the engineon source back every iteration and used
        // none of them — sixty dead engine calls a second per hull.
        private _phase = _vehicle animationSourcePhase "propellers_source";
        _vehicle animateSource ["propellers_source", _phase + (PROPELLER_RATE * _rpm * _delta)];
    };
}, ZUBR_MONITOR_TICK] call CBA_fnc_addPerFrameHandler;
