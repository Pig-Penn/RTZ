#include "script_component.hpp"
/*
 * Author: Maxim
 * Start the floating status tag above each selected vehicle: cache state,
 * invalidation handler, and registration of FUNC(drawVehicleTags) with the
 * shared frame loop.
 *
 * The tag is one discrete text line (e.g. "Hunter HMG · 45 km/h · CREW 3/4 ·
 * FUEL 62 · LOW FUEL") — the vehicle counterpart of the infantry head tags
 * (FUNC(unitTags)). Fed by the same live server packets the vehicle cards use
 * (GVAR(selVehicles) from FUNC(selectionPoll), GVAR(vehicleData) from the
 * STREAM_VEH feed). Runs independently of FUNC(vehicleOverlay) — either display
 * can be enabled without the other.
 *
 * The line is assembled by FUNC(buildVtagEntry) from the fields enabled in CBA
 * settings (name, speed, crew/seats, fuel, hull, fly height, ammo, commander,
 * LAMBS task, tactic) and drawn in a static colour. Only the trailing status word
 * gets its own colour: the warning flags (LOW FUEL amber, DAMAGED red) always
 * show regardless of the status field setting, rendered as a second drawIcon3D
 * split at a measured text-width boundary from the rest of the line
 * (FUNC(textWidth) — same screen-space trick as the unit tags). Tags fade out
 * approaching GVAR(vtagMaxDistance) from the camera.
 *
 * Visibility toggles at runtime via the shared "Draw Tags" ZEN context menu entry
 * (FUNC(tagsContext)) — one entry drives this system and the unit tags together,
 * through FUNC(toggleTags). Unlike the infantry feed, the vehicle feed is not
 * consumer-gated — FUNC(selectionPoll) reports selected vehicles whenever the set
 * changes — so hiding tags only stops the draw, not the gather (the cards consume
 * the same packets).
 *
 * Per-frame cost: tag text/colour is cached per vehicle (GVAR(vehicleTagsCache))
 * and only rebuilt after a fresh server push or a vtag* setting change, so a
 * frame does two hashmap lookups + one drawIcon3D per selected vehicle.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it).
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableVehicleTags). Client-only; registers a CBA handler and a
 *   renderer, no scheduled ops — `call`ed, not `spawn`ed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_vehicleTags
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Runtime visibility switch (context menu). The master CBA setting gates whether
// this system exists at all; this flips it mid-mission.
GVAR(vehicleTagsVisible) = true;

// netId → FUNC(buildVtagEntry) result, built lazily during the draw pass; wiped
// whenever the underlying data or a vtag* setting changes. The data-change half
// is flagged by FUNC(streamClient) as each STREAM_VEH snapshot lands.
GVAR(vehicleTagsCache) = createHashMap;
GVAR(vehicleTagsDirty) = true;

// Invalidate when a vtag setting changes mid-mission, so field toggles apply
// live. Flipping the master setting also syncs the runtime switch: OFF hides the
// tags immediately instead of waiting for a restart.
["CBA_SettingChanged", {
    params ["_name", "_value"];
    private _lname = toLower _name;
    if ((_lname find toLower QGVAR(vtag)) == 0) then { GVAR(vehicleTagsDirty) = true };
    if (_lname == toLower QGVAR(enableVehicleTags)) then {
        GVAR(vehicleTagsVisible) = _value;
        call FUNC(applyTagVisibility);
    };
}] call CBA_fnc_addEventHandler;

call FUNC(applyTagVisibility);
