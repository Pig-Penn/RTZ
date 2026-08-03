#include "script_component.hpp"

// The bulk of an order runs on ONE machine wherever the serviced vehicles are
// local. setDamage is documented arg global / eff global, so it works from here
// against a vehicle owned anywhere; setFuel is relied on for the same (it is one
// of the classic global-effect commands) but that was not re-verified against the
// wiki when this was written — if refuelling is ever seen to miss on a
// headless-client-owned vehicle, this is the line to suspect, and the fix is the
// QGVAR(rearm) pattern below.
//
// The server is picked because it owns the AI supply vehicles anyway, and because
// holding the target claims on a single machine is what makes them mean anything.
if (isServer) then {
    [QGVAR(resupply), {
        params ["_orders", ["_curator", objNull]];

        {
            _x params ["_supply", "_targets"];
            [_supply, _targets, _curator] call FUNC(serviceVehicles);
        } forEach _orders;
    }] call CBA_fnc_addEventHandler;
};

// setVehicleAmmo is the exception: its ARGUMENT is local, so the server calling
// it on a vehicle owned by a headless client or a player is a silent no-op —
// which is exactly what used to happen. Registered on every machine and targeted
// at the vehicle by FUNC(endService). One event per vehicle per completed order,
// not per tick, because ammo is a single write at the end rather than a ramp.
[QGVAR(rearm), {
    params ["_vehicle"];
    if (isNull _vehicle || {!alive _vehicle}) exitWith {};

    _vehicle setVehicleAmmo 1;
}] call CBA_fnc_addEventHandler;

// Completion report, aimed at whoever gave the order. The stringtable KEY comes
// over the wire rather than the localised text, so the toast renders in the
// receiving client's own language instead of the server's.
if (hasInterface) then {
    [QGVAR(report), {
        params ["_key", ["_count", 1]];

        [localize _key, _count] call EFUNC(common,showCountMessage);
    }] call CBA_fnc_addEventHandler;
};

// ── Supply-lines overlay registration ────────────────────────────────────────
// This addon owns a STREAM on rtz_core's engine; the engine owns no supply code.
// ONE declaration, exactly like the engine's own streams — EFUNC(core,registerStream)
// self-gates each half, so there is nothing to guard here.
//
// This used to be two blocks: a hasInterface block writing STREAM_SUPPLY into
// EGVAR(hud,streamRenderers) and EGVAR(hud,streamSettings) BY HAND, and an isServer
// block declaring the gatherer. Reaching into another addon's registries was the
// only way to complete a stream from outside it, and it still left the shared
// context-menu halves unable to name this overlay — which is why this addon
// carried FUNC(toggleSupplyOverlay) and FUNC(supplyOverlayModifier), two functions
// that duplicated the engine's own purely to supply wording it had no way to ask
// for. The labels ride the declaration now and both are gone.
//
// SRC_HULLS: the gatherer reads the servicing record off a hull, so it wants the
// curator's selection collapsed to distinct vehicles. Cadence rides the engine's
// shared overlay interval, so all three AI-state overlays stay in step and one
// admin slider retunes them together.
[
    STREAM_SUPPLY, LINKFUNC(gatherSupply), SRC_HULLS,
    QEGVAR(core,pollInterval), 2,
    ELINKFUNC(core,receiveOverlay),
    [
        LINKFUNC(drawSupply),
        QGVAR(enableSupplyDisplay),
        [LLSTRING(MsgSupplyLinesHidden), LLSTRING(MsgSupplyLinesShown)],
        [LLSTRING(ActionDrawSupplyLines), LLSTRING(ActionHideSupplyLines)],
        COLOR_SUPPLY
    ]
] call EFUNC(core,registerStream);
