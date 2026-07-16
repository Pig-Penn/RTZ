#include "script_component.hpp"
/*
 * rtz_fnc_vehicleTags
 *
 * Minimalist floating status tag above each selected vehicle while Zeus is
 * open — one discrete text line (e.g. "Hunter HMG · 45 km/h · CREW 3/4 ·
 * FUEL 62 · LOW FUEL") — the vehicle counterpart of the infantry head tags
 * (rtz_fnc_unitTags). Fed by the same live server packets the vehicle overlay
 * cards use (GVAR(selVehicleIds) / GVAR(selVehicleData), maintained by
 * rtz_fnc_selectionInfo's poll and rtz_fnc_vehicleDataStream's server gather).
 * Runs independently of rtz_fnc_vehicleOverlay — either display can be enabled
 * without the other.
 *
 * The line is assembled from the fields enabled in CBA settings (name, speed,
 * crew/seats, fuel, hull, fly height, ammo, commander, LAMBS task, tactic) and drawn
 * in a static colour — side-tinted when GVAR(vtagSideColors) is set, the
 * normal tag colour otherwise. Only the trailing status word gets its own
 * colour: the warning flags (LOW FUEL amber, DAMAGED red) always show
 * regardless of the status field setting, rendered as a second drawIcon3D
 * split at a measured text-width boundary from the rest of the line
 * (FUNC(textWidth) — same screen-space trick as the unit tags). Tags fade
 * out approaching GVAR(vtagMaxDistance) from the camera.
 *
 * Visibility toggles at runtime via the shared "Draw Tags" ZEN context menu
 * entry (rtz_fnc_tagsContext), which drives this system's
 * GVAR(fnc_toggleVehTags) alongside the unit tags' toggle. Unlike the
 * infantry stream, the vehicle stream is not consumer-gated — the poll
 * reports selected vehicles whenever the set changes — so hiding tags only
 * stops the draw, not the gather (the overlay cards consume the same
 * packets).
 *
 * Per-frame cost: tag text/colour is cached per vehicle (GVAR(vtagCache)) and
 * only rebuilt after a fresh server push or a vtag* setting change, so a frame
 * does two hashmap lookups + one drawIcon3D per selected vehicle.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it).
 *   Needs rtz_fnc_selectionInfo running (Selection Info setting ON) for the
 *   selection poll AND rtz_fnc_vehicleDataStream running for the data stream
 *   (started automatically alongside this system — see XEH_postInit) — both
 *   must be enabled. Ordered after FUNC(vehicleDataStream) so its
 *   QGVAR(selVehicleData) handler (which fills the hashmap) runs before this
 *   system's cache-invalidation handler.
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableVehicleTags). Client-only; registers a Draw3D MEH + CBA
 *   handlers, no scheduled ops — `call`ed, not `spawn`ed.
 */

if (!hasInterface) exitWith {};

// Extra breathing room (each side of the split point, UI-x = size × this) between
// the main line and the status word (LAMBS task / LOW FUEL / DAMAGED) so the
// status text isn't cramped against the rest of the tag — the vehicle analogue
// of the unit tags' ICON_TEXT_GAP.
#define STATUS_GAP 0.25

// Runtime visibility switch (context menu). The master CBA setting gates
// whether this system exists at all; this flips it mid-mission.
GVAR(vtagsVisible) = true;

// netId → [mainText, [r,g,b], statusText, [r,g,b], sep, wMainSep, wStatus]
// (widths measured at cache-build time, see FUNC(textWidth)) built lazily
// during the draw pass; wiped whenever the underlying data or a vtag* setting
// changes.
GVAR(vtagCache)      = createHashMap;
GVAR(vtagCacheDirty) = true;

// Invalidate on every fresh server push (second handler on the same CBA event
// the overlay cards consume — both run inside one dispatch, before the next
// draw)…
[QGVAR(selVehicleData), { GVAR(vtagCacheDirty) = true }] call CBA_fnc_addEventHandler;

// …and when a vtag setting changes mid-mission, so field toggles apply live.
// Flipping the master setting also syncs the runtime switch: OFF hides tags
// immediately instead of waiting for a restart.
["CBA_SettingChanged", {
    params ["_name", "_value"];
    private _lname = toLower _name;
    if ((_lname find toLower QGVAR(vtag)) == 0) then { GVAR(vtagCacheDirty) = true };
    if (_lname == toLower QGVAR(enableVehicleTags)) then { GVAR(vtagsVisible) = _value };
}] call CBA_fnc_addEventHandler;

// ── Tag line assembly ────────────────────────────────────────────────────────
// Builds one vehicle's cache entry (see GVAR(vtagCache) layout above) from its
// server packet (layout: rtz_fnc_vehicleDataStream's _fnc_gatherVehicle).
// Locality-bound fields (LAMBS task/tactic) arrive as "" when the crew is not
// server-local, so they drop out naturally. statusText is coloured separately
// from mainText so LOW FUEL / DAMAGED can be amber/red without recolouring the
// whole line.
GVAR(fnc_buildVtagEntry) = {
    params ["_pkt"];
    _pkt params [
        "", "_sideNum", "_dName", "_speedKmh", "_fuelPct", "_healthPct",
        "_crewCnt", "_ecNet", "_flags", "", "_task", "_tactic",
        "", ["_seatCnt", -1], ["_flyHeight", -1], ["_selAmmo", -1]
    ];

    // Display-label remap (rtz_fnc_loadTagLabels) — re-words LAMBS task/
    // tactic strings and RTZ warning flags at build time (cached).
    private _labels = GVAR(tagLabels);

    private _segs = [];
    if (GVAR(vtagShowName)) then { _segs pushBack _dName };
    if (GVAR(vtagShowSpeed) && { _speedKmh > 0 }) then {
        _segs pushBack format ["%1 km/h", _speedKmh];
    };
    if (GVAR(vtagShowCrew)) then {
        // "CREW <aboard>/<positions>"; positions can be unknown (-1: a
        // pre-seat-count server build) — degrade to the bare aboard count.
        _segs pushBack ([format ["CREW %1", _crewCnt],
            format ["CREW %1/%2", _crewCnt, _seatCnt]] select (_seatCnt > 0));
    };
    if (GVAR(vtagShowFuel) && { _fuelPct < 100 }) then {
        _segs pushBack format ["FUEL %1", _fuelPct];
    };
    if (GVAR(vtagShowHull) && { _healthPct < 100 }) then {
        _segs pushBack format ["HULL %1", _healthPct];
    };
    // Only helicopters given a fly-height keybind order carry the var (-1 otherwise).
    if (GVAR(vtagShowFlyHeight) && { _flyHeight >= 0 }) then {
        _segs pushBack format ["ALT %1", _flyHeight];
    };
    if (GVAR(vtagShowAmmo) && { _selAmmo >= 0 }) then {
        _segs pushBack format ["AMMO %1", _selAmmo];
    };
    // Dead-commander guard: `name` returns garbage for dead units, so a
    // commander killed between server pushes must drop the segment entirely.
    if (GVAR(vtagShowCommander) && { _ecNet != "" }) then {
        private _ec = objectFromNetId _ecNet;
        if (!isNull _ec && { alive _ec }) then { _segs pushBack format ["CDR %1", name _ec] };
    };
    if (GVAR(vtagShowTactic) && { _tactic != "" }) then {
        _segs pushBack format ["TAC %1", _labels getOrDefault [_tactic, _tactic]];
    };

    // Status: warning flags always surface; the LAMBS task only when enabled.
    // Kept out of _segs — it's rendered as its own coloured drawIcon3D so
    // LOW FUEL / DAMAGED can be amber/red without recolouring the line.
    private _status = switch (true) do {
        case (_flags isNotEqualTo []): { (_flags apply { _labels getOrDefault [_x, _x] }) joinString " · " };
        case (GVAR(vtagShowStatus)):   { _labels getOrDefault [_task, _task] };   // "" without LAMBS
        default                        { "" };
    };

    // Static colour — side tint when enabled, otherwise the normal tag colour.
    private _col = [COL_NORMAL, SIDE_TINTS select _sideNum] select GVAR(vtagSideColors);
    // DAMAGED beats LOW FUEL for the status colour (worst condition wins);
    // a LAMBS task name stays the same colour as the rest of the line.
    private _statusCol = switch (true) do {
        case ("DAMAGED" in _flags):  { COL_BAD };
        case ("LOW FUEL" in _flags): { COL_WARN };
        default                      { _col };
    };

    private _mainText = _segs joinString " · ";
    private _sep = ["", " · "] select (_mainText != "" && { _status != "" });

    // Exact on-screen widths for the status split in the draw pass, measured
    // once per cache build (size changes dirty the cache via the vtag* prefix
    // handler above, so these stay in step with GVAR(vtagSize)).
    private _vtagSize = GVAR(vtagSize);
    private _wMainSep = [_mainText + _sep, _vtagSize] call FUNC(textWidth);
    private _wStatus  = [_status, _vtagSize] call FUNC(textWidth);

    [_mainText, _col select [0, 3], _status, _statusCol select [0, 3], _sep, _wMainSep, _wStatus]
};

// ── Runtime toggle (shared by the context menu entry) ────────────────────────
GVAR(fnc_toggleVehTags) = {
    GVAR(vtagsVisible) = !GVAR(vtagsVisible);
    [format ["Vehicle tags %1", ["hidden", "shown"] select GVAR(vtagsVisible)]] call zen_common_fnc_showMessage;
};

// ── Draw pass ────────────────────────────────────────────────────────────────
[missionNamespace, "Draw3D", {
    if (!GVAR(vtagsVisible)) exitWith {};
    if (isNull (findDisplay 312) || { isNull (getAssignedCuratorLogic player) }) exitWith {};
    if (isNil QGVAR(selVehicleIds)) exitWith {};
    private _ids = GVAR(selVehicleIds);
    if (_ids isEqualTo []) exitWith {};

    if (GVAR(vtagCacheDirty)) then {
        GVAR(vtagCache)      = createHashMap;
        GVAR(vtagCacheDirty) = false;
    };

    private _cache   = GVAR(vtagCache);
    private _data    = GVAR(selVehicleData);
    private _camPos  = positionCameraToWorld [0, 0, 0];
    private _maxDist = GVAR(vtagMaxDistance);
    private _fadeIn  = _maxDist * 0.85;
    private _size    = GVAR(vtagSize);
    private _zOff    = GVAR(vtagHeight);
    // A virtual Zeus (VirtualMan_F) is the game master, not a PvP officer —
    // exempt from the own-side render filter (mirrors the overlay cards).
    private _anySide = player isKindOf "VirtualMan_F";
    // Camera-right unit vector in world space — the axis the status split is
    // offset along so "right of the text" holds for any camera orientation.
    private _camRight = (positionCameraToWorld [1, 0, 0]) vectorDiff _camPos;
    // Camera-up unit vector — the tag's vertical lift rides this (not world +Z)
    // so it floats above the icon on screen even from a top-down camera.
    private _camUp    = (positionCameraToWorld [0, 1, 0]) vectorDiff _camPos;

    {
        private _entry = _cache get _x;
        if (isNil "_entry") then {
            private _pkt = _data get _x;
            if (isNil "_pkt") then { continue };                   // packet not arrived yet
            _entry = [_pkt] call GVAR(fnc_buildVtagEntry);
            _cache set [_x, _entry];
        };
        _entry params ["_mainText", "_rgbMain", "_statusText", "_rgbStatus", "_sep", ["_wMainSep", 0], ["_wStatus", 0]];
        if (_mainText == "" && { _statusText == "" }) then { continue };  // every field toggled off

        private _veh = objectFromNetId _x;
        if (isNull _veh || { !alive _veh }) then { continue };
        // Side re-check between server pushes (crew change can flip a
        // vehicle's effective side) — same filter the overlay cards apply.
        if (!_anySide && { side (group _veh) != side player }) then { continue };

        private _base = unitAimPositionVisual _veh;
        private _dist = _camPos distance _base;
        if (_dist > _maxDist) then { continue };
        // Screen-space vertical lift (see rtz_fnc_unitTags): along camera-up and
        // distance-scaled, so the tag clears the icon from a top-down camera too.
        private _pos = _base vectorAdd (_camUp vectorMultiply (_zOff * (1 max (_dist / 30))));
        private _alpha = linearConversion [_fadeIn, _maxDist, _dist, 0.85, 0, true];

        if (_statusText == "") then {
            drawIcon3D ["", _rgbMain + [_alpha], _pos, 0, 0, 0, _mainText, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
            continue;
        };

        // Screen-space scale (UI units per metre of camera-right at this
        // vehicle's depth) — needed to split the status word into its own
        // coloured draw. Exact for any FOV, no fov-formula guesswork.
        private _perMetre = 0;
        private _scr = worldToScreen _pos;
        private _oneRight = worldToScreen (_pos vectorAdd _camRight);
        if (_scr isNotEqualTo [] && { _oneRight isNotEqualTo [] }) then {
            _perMetre = (_oneRight select 0) - (_scr select 0);
        };

        if (_perMetre <= 1e-6) then {
            drawIcon3D ["", _rgbMain + [_alpha], _pos, 0, 0, 0, _mainText + _sep + _statusText, 2, _size, "RobotoCondensedBold", "center", false, 0, 0];
        } else {
            // Split point = centre + halfWidth(fullText) - width(statusText),
            // from the widths measured at cache-build time (FUNC(textWidth)) —
            // keeps the combined line centred on the vehicle while letting the
            // status word carry its own colour. A STATUS_GAP is opened around
            // the split point (main pulled left, status pushed right by the
            // same amount) so the status word gets breathing room instead of
            // butting against the rest of the line.
            private _boundaryUI  = ((_wMainSep + _wStatus) / 2) - _wStatus;
            private _gapUI       = _size * STATUS_GAP;
            private _mainPos   = _pos vectorAdd (_camRight vectorMultiply ((_boundaryUI - _gapUI) / _perMetre));
            private _statusPos = _pos vectorAdd (_camRight vectorMultiply ((_boundaryUI + _gapUI) / _perMetre));
            // textAlign names the SIDE of the anchor the text sits on (not
            // typographic alignment): "left" ends at the anchor, "right" starts there.
            drawIcon3D ["", _rgbMain   + [_alpha], _mainPos,   0, 0, 0, _mainText + _sep, 2, _size, "RobotoCondensedBold", "left",  false, 0, 0];
            drawIcon3D ["", _rgbStatus + [_alpha], _statusPos, 0, 0, 0, _statusText,      2, _size, "RobotoCondensedBold", "right", false, 0, 0];
        };
    } forEach _ids;
}] call CBA_fnc_addBISEventHandler;
