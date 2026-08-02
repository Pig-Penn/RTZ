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
// This addon owns a STREAM on rtz_overlays' engine; the engine owns no supply
// code. Registration is a write into the two registries it builds in its own
// postInit, which is why rtz_overlays is in requiredAddons — that is what orders
// the two postInits.
//
// The guards mirror the engine's own halves exactly: it only builds the draw
// registry where there is an interface and only the gather registry on the
// server, so a dedicated server has no GVAR(drawFncs) to write into and a
// client has no GVAR(gatherFncs).
if (hasInterface) then {
    EGVAR(overlays,drawFncs) set [STREAM_SUPPLY, LINKFUNC(drawSupply)];

    // Lets the engine's CBA_SettingChanged watchdog shut this overlay down if its
    // master switch is turned off mid-mission, the same as its own two. Lowercased
    // because that watchdog cannot rely on the case a setting was registered with.
    EGVAR(overlays,streamSettings) set [STREAM_SUPPLY, toLower QGVAR(enableSupplyDisplay)];
};

if (isServer) then {
    EGVAR(overlays,gatherFncs) set [STREAM_SUPPLY, LINKFUNC(gatherSupply)];
};
