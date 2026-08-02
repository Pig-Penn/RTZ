#include "script_component.hpp"
/*
 * Author: Maxim
 * Start the native-styled stat card shown in the bottom-right corner for each
 * vehicle the curator has selected: theme state, the ZEN minimize toggle, and
 * registration of the two renderers this display needs.
 *
 * Each card matches the vanilla Zeus / ZEN interface language:
 *   — title bar tinted with the player's profile UI theme colour (the same source
 *     ZEN window title bars read), vehicle name in PuristaMedium
 *   — side-coloured accent strip down the card's left edge
 *   — dark body with icon rows: speed, crew/seats, magazines, commander,
 *     LAMBS task · tactic, and amber warnings (LOW FUEL / DAMAGED)
 *   — FUEL and HULL readout bars, colour-stepped white/green → amber → red
 * A faint side-coloured world line links each card to its vehicle.
 *
 * TWO renderers, because the card and its link line want different frames:
 *   FUNC(drawVehicleCards) is RENDER_UI — the cards are controls on the curator
 *     display and stay visible OVER the Zeus map, so they must keep updating
 *     while it is open, and must tear their pool down when Zeus closes.
 *   FUNC(drawVehicleLinks) is RENDER_WORLD — the link lines are drawLine3D into
 *     the 3D scene, which the Zeus map covers. Drawing them with the map up
 *     produced nothing at all, so the world pass skips them.
 * Registering the UI half first is deliberate: it publishes the renderable set
 * (GVAR(vehicleRenderList)) that the link pass reuses, so the packet/alive/side
 * filter runs once per frame rather than once per renderer.
 *
 * Cards minimize to accent strip + title bar (and back) at runtime via a ZEN
 * context menu entry — FUNC(toggleVehicleCards), the same toggle pattern the tags
 * use.
 *
 * FUNC(selectionPoll) tracks which vehicles are selected and sets
 * GVAR(selVehicles); the per-vehicle packets (netId → packet) arrive on the
 * STREAM_VEH feed into GVAR(vehicleData), shared with FUNC(vehicleTags) so either
 * display can run without the other. Card creation, body markup and per-card
 * layout live in FUNC(vehicleCardCreate) / FUNC(vehicleCardBody) /
 * FUNC(vehicleCardLayout).
 *
 * Cards are pooled control groups on the Zeus display; layout and text are only
 * rebuilt when a fresh server packet arrives or the selected id set changes
 * (~3 Hz worst case). Per-frame work is the world link lines plus a couple of
 * array compares.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it); LAMBS
 *   optional (task/tactic lines blank without it).
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableVehicleOverlay). Registers two renderers and a context action; no
 *   scheduled ops, so it is `call`ed, not `spawn`ed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_vehicleOverlay
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Runtime minimize switch (context menu, registered below): true collapses every
// card to its accent strip + title bar. The master CBA setting gates whether this
// system exists at all; FUNC(toggleVehicleCards) flips presentation mid-mission.
GVAR(vehCardsMini) = false;

// Renderable vehicles this frame, as [packet, vehicle]. Published by the UI
// renderer and consumed by the link renderer that runs after it in the same
// frame, so the packet/alive/side filter is paid for once.
GVAR(vehicleRenderList) = [];

// The player's profile menu tint — the exact source ZEN reads for its window
// title bars (GUI_BCG_RGB_*), so the cards inherit whatever UI colour the player
// runs. Alpha floored: a near-transparent user theme would wash the title bar out
// over bright terrain.
GVAR(vehThemeColor) = [
    profileNamespace getVariable ["GUI_BCG_RGB_R", 0.13],
    profileNamespace getVariable ["GUI_BCG_RGB_G", 0.54],
    profileNamespace getVariable ["GUI_BCG_RGB_B", 0.21],
    (profileNamespace getVariable ["GUI_BCG_RGB_A", 0.8]) max 0.7
];

[QGVAR(vehicleCards), LINKFUNC(drawVehicleCards), RENDER_UI,    10] call FUNC(registerRenderer);
[QGVAR(vehicleLinks), LINKFUNC(drawVehicleLinks), RENDER_WORLD, 10] call FUNC(registerRenderer);

// ── ZEN context menu toggle (label/tint mirror the current state) ────────────
// Under the shared RTZ_Overlays submenu alongside "Draw Tags" — this used to be
// registered at the context menu ROOT, which put a display toggle among the order
// actions instead of with the other overlays.
private _action = [
    "RTZ_MinimizeVehCards",
    LLSTRING(ActionVehCardsFull),
    ["\a3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa", [1, 1, 1, 1]],
    { call FUNC(toggleVehicleCards) },
    { true },
    [],
    {},
    {
        params ["_action"];
        if (GVAR(vehCardsMini)) then {
            _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionVehCardsMin)];
            _action set [ACTION_INDEX_ICONCOLOR, [0.60, 0.60, 0.60, 1]];
        } else {
            _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionVehCardsFull)];
            _action set [ACTION_INDEX_ICONCOLOR, [0.40, 1.00, 0.40, 1]];
        };
    }
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Overlays"], 3] call zen_context_menu_fnc_addAction;
