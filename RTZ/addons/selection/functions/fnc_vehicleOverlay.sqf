#include "script_component.hpp"
/*
 * rtz_fnc_vehicleOverlay
 *
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
 * context menu entry — same toggle pattern as the unit tags (rtz_fnc_unitTags).
 *
 * rtz_fnc_selectionInfo's poll tracks which vehicles are selected and sets
 * GVAR(selVehicleIds). The actual per-vehicle data (netId → packet) is fed by
 * rtz_fnc_vehicleDataStream — split into its own function so rtz_fnc_vehicleTags
 * can consume the same stream without this overlay being enabled. This script
 * only renders the bottom-right cards from whatever that stream has gathered.
 *
 * Cards are pooled controls groups on the Zeus display; layout and text are
 * only rebuilt when a fresh server packet arrives or the selected id set
 * changes (~3 Hz worst case). Per-frame work is the world link lines plus a
 * couple of array compares.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it);
 *   LAMBS optional (task/tactic lines blank without it). Needs
 *   rtz_fnc_vehicleDataStream running for its data (started automatically
 *   alongside this system — see XEH_postInit).
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableVehicleOverlay). Registers a client Draw3D handler; contains no
 *   scheduled ops, so it is `call`ed, not `spawn`ed.
 */

// ── Card geometry (absolute UI units) and shared card colours ────────────────
#define CARD_W    0.225
#define ACCENT_W  0.0045
#define TITLE_H   0.0320
#define PAD_X     0.0080
#define BAR_H     0.0165
#define BAR_GAP   0.0045
#define CARD_GAP  0.0100
#define CARD_BG   [0, 0, 0, 0.65]
#define BAR_BG    [1, 1, 1, 0.10]

// ─────────────────────────────────────────────────────────────────────────────
// CLIENT — vehicle data receipt and bottom-right card rendering
// ─────────────────────────────────────────────────────────────────────────────
if (hasInterface) then {

    // Runtime minimize switch (context menu, registered below): true
    // collapses every card to its accent strip + title bar. The master CBA
    // setting gates whether this system exists at all; this flips presentation
    // mid-mission. Dirty flag forces a relayout on the next draw.
    GVAR(vehCardsMini) = false;
    GVAR(fnc_toggleVehMini) = {
        GVAR(vehCardsMini) = !GVAR(vehCardsMini);
        GVAR(vehDataDirty) = true;
    };

    // The player's profile menu tint — the exact source ZEN reads for its
    // window title bars (GUI_BCG_RGB_*), so the cards inherit whatever UI
    // colour the player runs. Alpha floored: a near-transparent user theme
    // would wash the title bar out over bright terrain.
    GVAR(vehThemeColor) = [
        profileNamespace getVariable ["GUI_BCG_RGB_R", 0.13],
        profileNamespace getVariable ["GUI_BCG_RGB_G", 0.54],
        profileNamespace getVariable ["GUI_BCG_RGB_B", 0.21],
        (profileNamespace getVariable ["GUI_BCG_RGB_A", 0.8]) max 0.7
    ];

    [missionNamespace, "Draw3D", {

        private _disp = findDisplay 312;

        // Zeus closed or curator lost — the controls died with the display;
        // just drop our references. Once only: while Zeus stays closed this
        // handler must not keep rewriting uiNamespace every frame.
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

        // Nothing selected (also guards nil before selectionInfo initialises).
        // Cards are hidden once on the transition; idle frames after that skip
        // the pool sweep entirely.
        if (isNil QGVAR(selVehicleIds) || { GVAR(selVehicleIds) isEqualTo [] }) exitWith {
            if ((GETUVAR(GVAR(veh_lastIds),[])) isNotEqualTo []) then {
                { (_x select 0) ctrlShow false } forEach _pool;
                uiNamespace setVariable [QGVAR(veh_lastIds), []];
            };
        };

        private _ids = GVAR(selVehicleIds) select [0, SEL_MAX_VEHICLES];
        // A virtual Zeus (VirtualMan_F) is the game master, not a PvP officer —
        // exempt from the own-side render filter (mirrors the selection poll
        // and the server gather).
        private _anySide = player isKindOf "VirtualMan_F";

        // Renderable set this frame: packet arrived, vehicle alive, side OK.
        private _list = [];
        {
            private _pkt = GVAR(selVehicleData) getOrDefault [_x, []];
            if (_pkt isEqualTo []) then { continue };
            private _veh = objectFromNetId _x;
            if (isNull _veh || { !alive _veh }) then { continue };
            if (!_anySide && { side (group _veh) != side player }) then { continue };
            _list pushBack [_x, _pkt, _veh];
        } forEach _ids;

        // ---- world link lines (re-drawn every frame, card → commander) ----
        {
            _x params ["", "_pkt", "_veh"];
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

        // ── inline helpers (SQF dynamic scoping: callable from this scope) ──

        // Create one pooled card bundle on the current Zeus display:
        // [group, bg, accent, titleBg, title, body,
        //  fuelBg, fuelFill, fuelLbl, hullBg, hullFill, hullLbl]
        private _fnc_makeCard = {
            params ["_disp"];
            private _grp = _disp ctrlCreate ["RscControlsGroupNoScrollbars", -1];
            _grp ctrlEnable false;

            private _fnc_child = {
                params ["_disp", "_grp", "_class"];
                private _c = _disp ctrlCreate [_class, -1, _grp];
                _c ctrlEnable false;
                _c
            };

            private _bg = [_disp, _grp, "RscText"] call _fnc_child;
            _bg ctrlSetBackgroundColor CARD_BG;
            private _accent  = [_disp, _grp, "RscText"] call _fnc_child;
            private _titleBg = [_disp, _grp, "RscText"] call _fnc_child;
            _titleBg ctrlSetBackgroundColor GVAR(vehThemeColor);
            private _title = [_disp, _grp, "RscText"] call _fnc_child;
            _title ctrlSetFont "PuristaMedium";
            _title ctrlSetFontHeight 0.0235;
            _title ctrlSetTextColor [1, 1, 1, 1];
            private _body = [_disp, _grp, "RscStructuredText"] call _fnc_child;

            private _bars = [];
            for "_i" from 0 to 1 do {
                private _barBg = [_disp, _grp, "RscText"] call _fnc_child;
                _barBg ctrlSetBackgroundColor BAR_BG;
                private _fill = [_disp, _grp, "RscText"] call _fnc_child;
                private _lbl  = [_disp, _grp, "RscText"] call _fnc_child;
                _lbl ctrlSetFont "RobotoCondensedBold";
                _lbl ctrlSetFontHeight 0.0130;
                _lbl ctrlSetTextColor [0.95, 0.97, 1.00, 0.95];
                _bars append [_barBg, _fill, _lbl];
            };

            [_grp, _bg, _accent, _titleBg, _title, _body] + _bars
        };

        // Body markup: speed · crew/seats · magazines row, commander, LAMBS
        // task · tactic, amber warnings. Name / fuel / hull live in the title
        // bar and bars, not here. <img> elements are top-level siblings of
        // <t>, never nested inside <t>.
        private _fnc_bodyText = {
            params ["_pkt"];
            _pkt params [
                "", "", "", "_speedKmh", "", "",
                "_crewCnt", "_ecNet", "_flags", "", "_task", "_tactic",
                ["_ammoCnt", 0], ["_seatCnt", -1]
            ];
            private _s = " shadow='1' shadowColor='#000000'";
            private _crewStr = if (_seatCnt > 0) then { format ["%1/%2", _crewCnt, _seatCnt] } else { str _crewCnt };

            private _t = "<img image='\a3\ui_f\data\igui\cfg\simpletasks\types\move_ca.paa' size='0.80' color='" + HEX_DIM + "'/>"
                + "<t font='RobotoCondensed' size='0.85' color='" + HEX_BODY + "'" + _s + "> " + str _speedKmh + " km/h   </t>"
                + "<img image='\a3\ui_f\data\igui\cfg\commandbar\imagedriver_ca.paa' size='0.80' color='" + HEX_DIM + "'/>"
                + "<t font='RobotoCondensed' size='0.85' color='" + HEX_BODY + "'" + _s + "> " + _crewStr + "   </t>"
                + "<img image='\a3\ui_f\data\igui\cfg\simpletasks\types\attack_ca.paa' size='0.80' color='" + HEX_DIM + "'/>"
                + "<t font='RobotoCondensed' size='0.85' color='" + HEX_BODY + "'" + _s + "> " + str _ammoCnt + "</t>";

            if (_ecNet != "") then {
                private _ec = objectFromNetId _ecNet;
                // alive check: `name` returns garbage for dead units, so a
                // commander killed between server pushes drops the line.
                if (!isNull _ec && { alive _ec }) then {
                    _t = _t + "<br/><t font='RobotoCondensed' size='0.80' color='" + HEX_DIM + "'" + _s + ">CDR  </t>"
                        + "<t font='RobotoCondensed' size='0.80' color='" + HEX_BODY + "'" + _s + ">" + name _ec + "</t>";
                };
            };

            private _ai = [_task, _tactic] select { _x != "" };
            if (_ai isNotEqualTo []) then {
                _t = _t + "<br/><t font='RobotoCondensed' size='0.80' color='" + HEX_TASK + "'" + _s + ">" + (_ai joinString " · ") + "</t>";
            };

            if (_flags isNotEqualTo []) then {
                _t = _t + "<br/><img image='\a3\ui_f\data\igui\cfg\simpletasks\types\intel_ca.paa' size='0.75' color='" + HEX_WARN + "'/>"
                    + "<t font='RobotoCondensed' size='0.80' color='" + HEX_WARN + "'" + _s + "> " + (_flags joinString "  ") + "</t>";
            };
            _t
        };

        // Lay out one labelled readout bar (bg, proportional fill, text inset).
        private _fnc_layoutBar = {
            params ["_bg", "_fill", "_lbl", "_x", "_y", "_w", "_label", "_pct", "_col"];
            _bg   ctrlSetPosition [_x, _y, _w, BAR_H];
            _fill ctrlSetPosition [_x, _y, _w * (((_pct max 0) min 100) / 100), BAR_H];
            _fill ctrlSetBackgroundColor _col;
            _lbl  ctrlSetText (_label + "  " + str _pct + "%");
            _lbl  ctrlSetPosition [_x + 0.0045, _y, _w - 0.009, BAR_H];
            { _x ctrlCommit 0 } forEach [_bg, _fill, _lbl];
        };

        // Fill one card from a packet; children are positioned relative to the
        // group. Returns the card's total height. Minimized, the card is just
        // the accent strip + title bar: body and bars are hidden and their
        // layout (incl. the ctrlTextHeight round-trip) skipped entirely.
        private _fnc_layoutCard = {
            params ["_bundle", "_pkt"];
            _bundle params ["_grp", "_bg", "_accent", "_titleBg", "_title", "_body",
                "_fuelBg", "_fuelFill", "_fuelLbl", "_hullBg", "_hullFill", "_hullLbl"];
            _pkt params ["", "_sideNum", "_dName", "", "_fuelPct", "_healthPct"];

            private _innerX = ACCENT_W + PAD_X;
            private _innerW = CARD_W - _innerX - PAD_X;
            private _mini   = GVAR(vehCardsMini);

            // Pooled controls: visibility must be re-asserted both ways, or a
            // card recycled after un-minimizing keeps its children hidden.
            { _x ctrlShow !_mini } forEach
                [_body, _fuelBg, _fuelFill, _fuelLbl, _hullBg, _hullFill, _hullLbl];

            _title ctrlSetText toUpper _dName;
            _title ctrlSetPosition [_innerX, 0, _innerW, TITLE_H];

            private _cardH = TITLE_H;
            if (!_mini) then {
                // Width must be committed before ctrlTextHeight reports the
                // wrapped height of the fresh markup.
                _body ctrlSetPosition [_innerX, TITLE_H + 0.0045, _innerW, 0.5];
                _body ctrlCommit 0;
                _body ctrlSetStructuredText parseText ([_pkt] call _fnc_bodyText);
                private _bodyH = ctrlTextHeight _body;
                _body ctrlSetPosition [_innerX, TITLE_H + 0.0045, _innerW, _bodyH];
                _body ctrlCommit 0;

                private _yBar = TITLE_H + 0.0045 + _bodyH + 0.0055;
                private _fuelCol = switch (true) do {
                    case (_fuelPct < 15): { [1.00, 0.38, 0.38, 0.90] };
                    case (_fuelPct < 40): { [1.00, 0.78, 0.30, 0.90] };
                    default               { [0.72, 0.78, 0.84, 0.90] };
                };
                [_fuelBg, _fuelFill, _fuelLbl, _innerX, _yBar, _innerW, "FUEL", _fuelPct, _fuelCol] call _fnc_layoutBar;

                private _hullCol = switch (true) do {
                    case (_healthPct < 40): { [1.00, 0.38, 0.38, 0.90] };
                    case (_healthPct < 70): { [1.00, 0.78, 0.30, 0.90] };
                    default                 { [0.55, 0.80, 0.42, 0.90] };
                };
                [_hullBg, _hullFill, _hullLbl, _innerX, _yBar + BAR_H + BAR_GAP, _innerW, "HULL", _healthPct, _hullCol] call _fnc_layoutBar;

                _cardH = _yBar + BAR_H + BAR_GAP + BAR_H + 0.0075;
            };

            _bg      ctrlSetPosition [0, 0, CARD_W, _cardH];
            _titleBg ctrlSetPosition [ACCENT_W, 0, CARD_W - ACCENT_W, TITLE_H];
            private _sideCol = SIDE_TINTS select _sideNum;
            _accent ctrlSetBackgroundColor [_sideCol#0, _sideCol#1, _sideCol#2, 0.95];
            _accent ctrlSetPosition [0, 0, ACCENT_W, _cardH];
            { _x ctrlCommit 0 } forEach [_bg, _accent, _titleBg, _title];

            _cardH
        };

        // ---- stack the cards upward from the bottom-right corner ----
        private _rightX  = safeZoneX + safeZoneW - 0.021;
        private _yCursor = safeZoneY + safeZoneH - 0.13;   // above the Zeus bottom bar
        private _yLimit  = safeZoneY + 0.28;               // below the Zeus top bar
        private _used    = 0;
        private _full    = false;   // exitWith in a forEach block only skips the
                                    // iteration, so out-of-room is a sticky flag

        {
            if (_full) then { continue };
            _x params ["", "_pkt"];
            if (_used >= count _pool) then {
                _pool pushBack ([_disp] call _fnc_makeCard);
            };
            private _bundle = _pool select _used;
            private _h = [_bundle, _pkt] call _fnc_layoutCard;
            // Out of screen room — stop; the trailing for-loop hides the rest.
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

    // ── ZEN context menu toggle (label/tint mirror the current state) ────────
    private _action = [
        "RTZ_MinimizeVehCards",
        "Vehicle Cards: FULL",
        ["\a3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa", [1, 1, 1, 1]],
        { [] call GVAR(fnc_toggleVehMini) },
        { true },
        [],
        {},
        {
            params ["_action"];
            if (GVAR(vehCardsMini)) then {
                _action set [1, "Vehicle Cards: MIN"];
                _action set [3, [0.60, 0.60, 0.60, 1]];
            } else {
                _action set [1, "Vehicle Cards: FULL"];
                _action set [3, [0.40, 1.00, 0.40, 1]];
            };
        }
    ] call zen_context_menu_fnc_createAction;

    [_action, ["RTZ_RealTimeZeus"], 7] call zen_context_menu_fnc_addAction;
};
