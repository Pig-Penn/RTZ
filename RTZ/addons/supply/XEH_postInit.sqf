#include "script_component.hpp"

// The ORDER runs on one machine — the server — because that is where the target
// claims have to live to mean anything, and because every reader the job needs
// (`damage`, `fuel`, `magazinesAllTurrets`, `getAmmoCargo`) reports correctly from
// anywhere. What it no longer does is WRITE: the three engine service actions are
// dispatched to each target's own owner (see QGVAR(service) below), so this
// machine only watches.
if (isServer) then {
    [QGVAR(resupply), {
        params ["_orders", ["_curator", objNull]];

        {
            _x params ["_supply", "_targets"];
            [_supply, _targets, _curator] call FUNC(serviceVehicles);
        } forEach _orders;
    }] call CBA_fnc_addEventHandler;
};

// The whole apply path, and the reason this component no longer owns a simulation.
// `action` / `actionNow` take a LOCAL argument: the server firing one on a vehicle
// owned by a headless client or a player is a silent no-op, the same trap that hid
// the old setFuel bug (docs/Knowledge Base/Gotchas.md, "Argument-local vs
// argument-global"). Registered on every machine and targeted at the SERVICED
// object by FUNC(serviceVehicles) — one event per target per order, not per tick,
// because the engine does the work from there and this component only watches it
// happen.
[QGVAR(service), LINKFUNC(applyService)] call CBA_fnc_addEventHandler;

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
// for. Both are gone.
//
// SRC_HULLS: the gatherer reads the servicing record off a hull, so it wants the
// curator's selection collapsed to distinct vehicles. Cadence rides the engine's
// shared overlay interval, so all three AI-state overlays stay in step and one
// admin slider retunes them together.
//
// The overlay bundle carries the renderer ONLY — no toasts, no context-menu
// labels, no idle accent. Those three describe an action a curator clicks, and
// this overlay has none: it is always on, so the engine's defaults are exactly
// right and anything filled in here would be wording nothing can ever display.
//
// The master setting slot is "" deliberately. It used to name a
// GVAR(enableSupplyDisplay) checkbox; the lines are now simply part of what this
// component does, so there is nothing to switch off and nothing to spend a
// settings row on. The engine reads that slot only from its CBA_SettingChanged
// watchdog, comparing it against the name of a setting that just changed — a name
// that is never "" — so this registers a stream the watchdog will never touch.
[
    STREAM_SUPPLY, LINKFUNC(gatherSupply), SRC_HULLS,
    QEGVAR(core,pollInterval), 2,
    ELINKFUNC(core,receiveOverlay),
    [LINKFUNC(drawSupply), ""]
] call EFUNC(core,registerStream);

// ── Always-on activation ─────────────────────────────────────────────────────
// Nothing else switches this stream on, so it is switched on here, once, and
// never switched off: no context action reaches it and the engine's watchdog
// cannot match its blank setting name.
//
// Straight-line, immediately after the registration it depends on. This was a
// FUNC(syncDisplay) call deferred to CBA_settingsInitialized, plus a second
// CBA_SettingChanged handler to bring the overlay back when an admin flipped the
// checkbox on again — both of which existed to READ that checkbox safely
// (a setting read straight from postInit races the server→client sync and reads
// nil, docs/Knowledge Base/Gotchas.md §2). With no setting to read there is no
// race to dodge: rtz_core builds every registry this touches in its preInit and
// requiredAddons orders the two, so everything is in place by the time this runs.
//
// hasInterface, because rtz_core's client registries do not exist on a dedicated
// server at all — its preInit exits before creating them.
if (hasInterface) then {
    // Reporting off: EFUNC(core,toggleOverlay) toasts the new state for a curator
    // who clicked something, and nobody clicked.
    [STREAM_SUPPLY, false] call EFUNC(core,toggleOverlay);
};
