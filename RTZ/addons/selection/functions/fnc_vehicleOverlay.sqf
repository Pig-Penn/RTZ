#include "script_component.hpp"
/*
 * Author: Maxim
 * Native-styled stat card in the bottom-right corner for each vehicle selected
 * by the curator, matching the vanilla Zeus / ZEN interface language:
 *   — title bar tinted with the player's profile UI theme colour (the same
 *     source ZEN window title bars read), vehicle name in PuristaMedium
 *   — side-coloured accent strip down the card's left edge
 *   — dark body with icon rows: speed, crew/seats, magazines, commander,
 *     LAMBS task · tactic, and amber warnings (LOW FUEL / DAMAGED)
 *   — FUEL and HULL readout bars, colour-stepped white/green → amber → red
 * A faint side-coloured world line links each card to its vehicle.
 *
 * Cards minimize to accent strip + title bar (and back) at runtime via a ZEN
 * context menu entry — FUNC(toggleVehicleCards), the same toggle pattern the
 * tags use.
 *
 * FUNC(selectionInfo)'s poll tracks which vehicles are selected and sets
 * GVAR(selVehicleIds). The actual per-vehicle data (netId → packet) is fed by
 * FUNC(vehicleDataStream) — split into its own function so FUNC(vehicleTags)
 * can consume the same stream without this overlay being enabled. This script
 * only renders the bottom-right cards from whatever that stream has gathered;
 * card creation, body markup and per-card layout live in
 * FUNC(vehicleCardCreate) / FUNC(vehicleCardBody) / FUNC(vehicleCardLayout).
 *
 * Cards are pooled controls groups on the Zeus display; layout and text are
 * only rebuilt when a fresh server packet arrives or the selected id set
 * changes (~3 Hz worst case). Per-frame work is the world link lines plus a
 * couple of array compares.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it);
 *   LAMBS optional (task/tactic lines blank without it). Needs
 *   FUNC(vehicleDataStream) running for its data (started automatically
 *   alongside this system — see XEH_postInit).
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableVehicleOverlay). Registers a client Draw3D handler; contains no
 *   scheduled ops, so it is `call`ed, not `spawn`ed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_selection_fnc_vehicleOverlay
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Runtime minimize switch (context menu, registered below): true collapses every
// card to its accent strip + title bar. The master CBA setting gates whether this
// system exists at all; FUNC(toggleVehicleCards) flips presentation mid-mission.
GVAR(vehCardsMini) = false;

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

[missionNamespace, "Draw3D", {

    private _disp = findDisplay IDD_RSCDISPLAYCURATOR;

    // Zeus closed or curator lost — the controls died with the display; just drop
    // our references. Once only: while Zeus stays closed this handler must not
    // keep rewriting uiNamespace every frame.
    if (isNull _disp || { isNull (getAssignedCuratorLogic player) }) exitWith {
        if ((GETUVAR(GVAR(veh_pool),[])) isNotEqualTo []) then {
            uiNamespace setVariable [QGVAR(veh_pool),    []];
            uiNamespace setVariable [QGVAR(veh_disp),    displayNull];
            uiNamespace setVariable [QGVAR(veh_lastIds), []];
        };
    };

    // Display instance changed (Zeus reopened) — flush the stale pool.
    if ((GETUVAR(GVAR(veh_disp),displayNull)) isNotEqualTo _disp) then {
        uiNamespace setVariable [QGVAR(veh_pool),    []];
        uiNamespace setVariable [QGVAR(veh_disp),    _disp];
        uiNamespace setVariable [QGVAR(veh_lastIds), []];
        GVAR(vehDataDirty) = true;
    };

    private _pool = GETUVAR(GVAR(veh_pool),[]);

    // Nothing selected (also guards nil before selectionInfo initialises). Cards
    // are hidden once on the transition; idle frames after that skip the pool
    // sweep entirely.
    if (isNil QGVAR(selVehicleIds) || { GVAR(selVehicleIds) isEqualTo [] }) exitWith {
        if ((GETUVAR(GVAR(veh_lastIds),[])) isNotEqualTo []) then {
            { (_x select 0) ctrlShow false } forEach _pool;
            uiNamespace setVariable [QGVAR(veh_lastIds), []];
        };
    };

    private _ids = GVAR(selVehicleIds) select [0, SEL_MAX_VEHICLES];
    // A virtual Zeus (VirtualMan_F) is the game master, not a PvP officer —
    // exempt from the own-side render filter (mirrors the selection poll and the
    // server gather).
    private _anySide = player isKindOf "VirtualMan_F";
    private _curSide = side player;

    // Renderable set this frame: packet arrived, vehicle alive, side OK.
    private _list = [];
    {
        private _pkt = GVAR(selVehicleData) getOrDefault [_x, []];
        if (_pkt isEqualTo []) then { continue };
        private _veh = objectFromNetId _x;
        if (isNull _veh || { !alive _veh }) then { continue };
        if (!_anySide && { !(VEH_SIDE_OK(_veh,_curSide)) }) then { continue };
        _list pushBack [_pkt, _veh];
    } forEach _ids;

    // ---- world link lines (re-drawn every frame, card → commander) ----
    {
        _x params ["_pkt", "_veh"];
        _pkt params ["", "_sideNum", "", "", "", "", "", "_ecNet"];
        if (_ecNet != "") then {
            private _ec = objectFromNetId _ecNet;
            if (!isNull _ec && { alive _ec }) then {
                private _sideCol = SIDE_TINTS select _sideNum;
                drawLine3D [
                    (getPosATLVisual _veh) vectorAdd [0, 0, 2.5],
                    unitAimPositionVisual _ec,
                    [_sideCol#0, _sideCol#1, _sideCol#2, 0.30], 2
                ];
            };
        };
    } forEach _list;

    // ---- cards: relayout only when data or the selected id set changed ----
    if (!GVAR(vehDataDirty)
        && { _ids isEqualTo (GETUVAR(GVAR(veh_lastIds),[])) }) exitWith {};
    GVAR(vehDataDirty) = false;
    uiNamespace setVariable [QGVAR(veh_lastIds), _ids];

    // ---- stack the cards upward from the bottom-right corner ----
    private _rightX  = safeZoneX + safeZoneW - 0.021;
    private _yCursor = safeZoneY + safeZoneH - 0.13;   // above the Zeus bottom bar
    private _yLimit  = safeZoneY + 0.28;               // below the Zeus top bar
    private _used    = 0;
    private _full    = false;   // exitWith in a forEach block only skips the
                                // iteration, so out-of-room is a sticky flag

    {
        if (_full) then { continue };
        _x params ["_pkt"];
        if (_used >= count _pool) then {
            _pool pushBack ([_disp] call FUNC(vehicleCardCreate));
        };
        private _bundle = _pool select _used;
        private _h = [_bundle, _pkt] call FUNC(vehicleCardLayout);
        // Out of screen room — stop. This card was laid out but never shown, and
        // _used was not advanced, so the trailing loop below hides it along with
        // the rest of the unused pool.
        if (_yCursor - _h < _yLimit) then { _full = true; continue };
        _yCursor = _yCursor - _h;
        private _grp = _bundle select 0;
        _grp ctrlSetPosition [_rightX - CARD_W, _yCursor, CARD_W, _h];
        _grp ctrlCommit 0;
        _grp ctrlShow true;
        _yCursor = _yCursor - CARD_GAP;
        _used = _used + 1;
    } forEach _list;

    for "_i" from _used to (count _pool) - 1 do {
        ((_pool select _i) select 0) ctrlShow false;
    };
    uiNamespace setVariable [QGVAR(veh_pool), _pool];

}] call CBA_fnc_addBISEventHandler;

// ── ZEN context menu toggle (label/tint mirror the current state) ────────────
// Under the shared RTZ_Overlays submenu alongside "Draw Tags" — this used to be
// registered at the context menu ROOT, which put a display toggle among the
// order actions instead of with the other overlays.
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
            _action set [1, LLSTRING(ActionVehCardsMin)];
            _action set [3, [0.60, 0.60, 0.60, 1]];
        } else {
            _action set [1, LLSTRING(ActionVehCardsFull)];
            _action set [3, [0.40, 1.00, 0.40, 1]];
        };
    }
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Overlays"], 3] call zen_context_menu_fnc_addAction;
