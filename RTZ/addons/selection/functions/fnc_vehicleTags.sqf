#include "script_component.hpp"
/*
 * Author: Maxim
 * Minimalist floating status tag above each selected vehicle while Zeus is
 * open — one discrete text line (e.g. "Hunter HMG · 45 km/h · CREW 3/4 ·
 * FUEL 62 · LOW FUEL") — the vehicle counterpart of the infantry head tags
 * (FUNC(unitTags)). Fed by the same live server packets the vehicle overlay
 * cards use (GVAR(selVehicleIds) from FUNC(selectionInfo)'s poll,
 * GVAR(selVehicleData) from FUNC(vehicleDataStream)). Runs independently of
 * FUNC(vehicleOverlay) — either display can be enabled without the other.
 *
 * The line is assembled by FUNC(buildVtagEntry) from the fields enabled in CBA
 * settings (name, speed, crew/seats, fuel, hull, fly height, ammo, commander,
 * LAMBS task, tactic) and drawn in a static colour. Only the trailing status
 * word gets its own colour: the warning flags (LOW FUEL amber, DAMAGED red)
 * always show regardless of the status field setting, rendered as a second
 * drawIcon3D split at a measured text-width boundary from the rest of the line
 * (FUNC(textWidth) — same screen-space trick as the unit tags). Tags fade out
 * approaching GVAR(vtagMaxDistance) from the camera.
 *
 * Visibility toggles at runtime via the shared "Draw Tags" ZEN context menu
 * entry (FUNC(tagsContext)) — one entry drives this system and the unit tags
 * together, through FUNC(toggleTags). Unlike the infantry stream, the vehicle
 * stream is not consumer-gated — the poll reports selected vehicles whenever
 * the set changes — so hiding tags only stops the draw, not the gather (the
 * overlay cards consume the same packets).
 *
 * Per-frame cost: tag text/colour is cached per vehicle (GVAR(vtagCache)) and
 * only rebuilt after a fresh server push or a vtag* setting change, so a frame
 * does two hashmap lookups + one drawIcon3D per selected vehicle.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it).
 *   Needs FUNC(selectionInfo) running (Selection Info setting ON) for the
 *   selection poll AND FUNC(vehicleDataStream) running for the data stream
 *   (started automatically alongside this system — see XEH_postInit) — both
 *   must be enabled. Ordered after FUNC(vehicleDataStream) so its
 *   QGVAR(selVehicleData) handler (which fills the hashmap) runs before this
 *   system's cache-invalidation handler.
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableVehicleTags). Client-only; registers a Draw3D MEH + CBA
 *   handlers, no scheduled ops — `call`ed, not `spawn`ed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_selection_fnc_vehicleTags
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Runtime visibility switch (context menu). The master CBA setting gates whether
// this system exists at all; this flips it mid-mission.
GVAR(vtagsVisible) = true;

// netId → FUNC(buildVtagEntry) result, built lazily during the draw pass; wiped
// whenever the underlying data or a vtag* setting changes.
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

// ── Draw pass ────────────────────────────────────────────────────────────────
[missionNamespace, "Draw3D", {
    if (!GVAR(vtagsVisible)) exitWith {};
    if (isNull (findDisplay IDD_RSCDISPLAYCURATOR) || { isNull (getAssignedCuratorLogic player) }) exitWith {};
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
    private _curSide = side player;
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
            _entry = [_pkt] call FUNC(buildVtagEntry);
            _cache set [_x, _entry];
        };
        _entry params ["_mainText", "_rgbMain", "_statusText", "_rgbStatus", "_sep", ["_wMainSep", 0], ["_wStatus", 0]];
        if (_mainText == "" && { _statusText == "" }) then { continue };  // every field toggled off

        private _veh = objectFromNetId _x;
        if (isNull _veh || { !alive _veh }) then { continue };
        // Side re-check between server pushes (crew change can flip a
        // vehicle's effective side) — same filter the overlay cards apply.
        if (!_anySide && { !(VEH_SIDE_OK(_veh,_curSide)) }) then { continue };

        private _base = unitAimPositionVisual _veh;
        private _dist = _camPos distance _base;
        if (_dist > _maxDist) then { continue };
        // Screen-space vertical lift (see FUNC(unitTags)): along camera-up and
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
            // status word carry its own colour. Both halves meet exactly at that
            // point (same as the unit tags): the " · " separator already carries
            // the spacing, so pushing them further apart double-spaces the line.
            private _boundaryUI  = ((_wMainSep + _wStatus) / 2) - _wStatus;
            private _boundaryPos = _pos vectorAdd (_camRight vectorMultiply (_boundaryUI / _perMetre));
            // textAlign names the SIDE of the anchor the text sits on (not
            // typographic alignment): "left" ends at the anchor, "right" starts there.
            drawIcon3D ["", _rgbMain   + [_alpha], _boundaryPos, 0, 0, 0, _mainText + _sep, 2, _size, "RobotoCondensedBold", "left",  false, 0, 0];
            drawIcon3D ["", _rgbStatus + [_alpha], _boundaryPos, 0, 0, 0, _statusText,      2, _size, "RobotoCondensedBold", "right", false, 0, 0];
        };
    } forEach _ids;
}] call CBA_fnc_addBISEventHandler;
