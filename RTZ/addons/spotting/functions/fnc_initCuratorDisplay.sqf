#include "script_component.hpp"
/*
 * rtz_fnc_initCuratorDisplay
 *
 * Runs every time the Zeus curator display (RscDisplayCurator, IDD 312) is created,
 * via CBA's Extended_DisplayLoad_EventHandlers (see CfgEventHandlers.hpp) — the same
 * pattern ZEN uses. The curator display and its map control are destroyed and
 * recreated each time Zeus opens, and control event handlers die with their control,
 * so the map overlays must be re-attached per display instance. This replaces
 * the old 4 Hz `findDisplay 312` polling loops.
 *
 * Attaches two independent overlays to the curator map (control 50), each gated on
 * its own system having initialized on this machine and its own per-display guard:
 *   - spotting overlay     (GVAR(spotGroups), set up by FUNC(spottingSystem))
 *   - officer zone overlay (GVAR(officerZones), set up by FUNC(spottingSystem))
 *
 * Also called directly by FUNC(spottingSystem)'s client half if the display already
 * exists when the (settings-deferred) client half starts; the per-display guards
 * make the two paths safe to overlap.
 *
 * Arguments:
 *   0: Display — the freshly created curator display
 */

params ["_display"];

// ── Overlay the spotted GROUP icons on the Zeus interface map ─────────────────
// Control 50 is the curator map (per ZEUS WARGAME). The handler dies with its
// control when Zeus closes — no leak, and never a duplicate on a given display.
if (!isNil QGVAR(spotGroups) && {!(_display getVariable [QGVAR(spotDrawAttached), false])}) then {
    _display setVariable [QGVAR(spotDrawAttached), true];
    (_display displayCtrl 50) ctrlAddEventHandler ["Draw", {
        if (count GVAR(spotGroups) == 0) exitWith {};
        params ["_map"];
        // Echelon amplifier vertical gap above the map group icon, indexed by the
        // payload's side index (0 = BLUFOR rectangle, 1 = OPFOR diamond — peaks highest
        // so needs the most lift, 2 = independent/civilian square). Screen-space Y
        // offset (holds at any map zoom); AMP_GAPS_MAP #defined in script_component.hpp.
        private _AMP_GAPS = AMP_GAPS_MAP;
        {
            // _y = [unit, texture, colorArray, echelonTex, sideIdx, leaderNetId] —
            // GVAR(spotGroups) holds group icons only (chevrons live in spotChevrons).
            _y params ["_unit", "_texture", "_colorArray", "_echelonTex", "_sideIdx"];
            if (isNull _unit || !alive _unit) then { continue };
            private _pos = getPosVisual _unit;
            _map drawIcon [_texture, _colorArray, _pos, MAP_ICON_SIZE, MAP_ICON_SIZE, 0, "", 0, 0.03, "RobotoCondensed"];
            if (_echelonTex != "") then {
                // map drawIcon takes a WORLD pos and has no vertical offset, so the
                // amplifier would stack on the symbol. Lift it in SCREEN space (constant
                // gap at any zoom): world→screen, nudge Y up, screen→world. ctrlMapWorld-
                // ToScreen returns [] off-screen — fall back to _pos so we still draw.
                // Gap raised to sit at the same height the native High Command map shows.
                private _scr    = _map ctrlMapWorldToScreen _pos;
                private _ampPos = if (_scr isEqualTo []) then { _pos }
                    else { _map ctrlMapScreenToWorld [_scr#0, (_scr#1) - (_AMP_GAPS select _sideIdx)] };
                _map drawIcon [_echelonTex, _colorArray, _ampPos, MAP_ICON_SIZE, MAP_ICON_SIZE, 0, "", 0, 0.03, "RobotoCondensed"];
            };
        } forEach GVAR(spotGroups);
    }];
};

// ── Overlay a spotted enemy officer's editing-area zone as a hollow ring ──────
// GVAR(officerZones) is a tiny subset of GVAR(spotChevrons) — normally empty
// (most missions never enable rtz_officer's zoning, and even then most spotted
// units aren't officers with an active area) — so this is effectively free.
// One drawEllipse per entry, no fill ("" texture = outline only), radius comes
// straight off the officer's actual zone (no recompute). Toggle: GVAR(officerZonesVisible).
if (!isNil QGVAR(officerZones) && {!(_display getVariable [QGVAR(zoneDrawAttached), false])}) then {
    _display setVariable [QGVAR(zoneDrawAttached), true];
    (_display displayCtrl 50) ctrlAddEventHandler ["Draw", {
        if (!GVAR(officerZonesVisible) || { count GVAR(officerZones) == 0 }) exitWith {};
        params ["_map"];
        {
            // _y = [unit, radius]; position sampled live so the ring tracks the
            // officer between spot ticks (matches the follow behaviour of the
            // real editing area, which re-centres on the same officer).
            _y params ["_unit", "_radius"];
            if (isNull _unit || !alive _unit) then { continue };
            _map drawEllipse [getPosVisual _unit, _radius, _radius, 0, COLOR_ZONE_RING, ""];
        } forEach GVAR(officerZones);
    }];
};
