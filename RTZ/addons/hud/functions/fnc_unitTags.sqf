#include "script_component.hpp"
/*
 * Author: Maxim
 * Start the floating status tag above each selected infantry unit's head: cache
 * state, invalidation handlers, and registration of FUNC(drawUnitTags) with the
 * shared frame loop.
 *
 * The tag is one discrete text line (e.g. "Rifleman · HP 62 · FLEEING") fed by
 * the same live server packets the selection info dialog uses
 * (EGVAR(core,selUnits) / GVAR(unitData), maintained by EFUNC(core,selectionPoll) and the
 * STREAM_UNIT feed).
 *
 * The line is assembled by FUNC(buildTagEntry) from the fields enabled in CBA
 * settings (role, health, morale, suppression, magazine rounds, status, LAMBS
 * tactic, current AI command) and drawn in a static colour so urgency never
 * recolours the whole line. Only the trailing status word (DOWN / FLEEING) gets
 * its own colour (red), rendered as a second drawIcon3D split at a measured
 * text-width boundary from the rest of the line (same screen-space trick as the
 * flag icon). DOWN / FLEEING always shows regardless of the status field
 * setting. Mounted units are skipped (the vehicle tag covers their vehicle);
 * tags fade out approaching GVAR(tagMaxDistance) from the camera.
 *
 * Two optional icons ride the same screen-space placement trick, each
 * hover-expandable to its full detail (GVAR(tagShow{Flag,Threat}Icon)):
 *   — a flag icon at the right end when the unit carries status flags
 *     (HIDDEN, BUSY, PATH OFF, …);
 *   — a threat icon between the text and the flag icon — the unit's LAMBS
 *     danger cause if any, else its current attack target (danger always wins,
 *     same rule the dialog uses) — hovering reveals the full detail.
 *
 * Visibility toggles at runtime via the shared "Draw Tags" ZEN context menu
 * entry (FUNC(tagsContext)) — one entry drives this system and the vehicle tags
 * together, through FUNC(toggleTags). Hiding the tags UNREGISTERS the renderer
 * rather than merely flagging it, so hidden tags cost nothing per frame; and
 * EFUNC(core,selectionPoll) stops reporting the selection once neither the tags nor
 * the dialog want it, so they cost zero gather/network traffic too.
 *
 * Per-frame cost: tag text/colour is cached per unit (GVAR(unitTagsCache)) and
 * only rebuilt after a fresh server push or a tag* setting change, so a frame
 * does two hashmap lookups + one drawIcon3D per selected unit.
 *
 * Requirements: CBA_A3; ZEN optional (context toggle absent without it).
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on
 *   GVAR(enableUnitTags). Client-only; registers CBA handlers and a renderer,
 *   no scheduled ops — `call`ed, not `spawn`ed.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_unitTags
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Icon render size and hover pick distance (ICON_DRAW / ICON_HOVER_RADIUS) come
// from script_component.hpp, alongside the placement constants
// FUNC(buildTagEntry) measures with. The UI-x offsets that position the icons
// and split the coloured status word are measured exactly at cache-build time —
// the draw pass only reads them back.

// Runtime visibility switch (context menu). The master CBA setting gates whether
// this system exists at all; this flips it mid-mission. Read defensively by
// EFUNC(core,selectionPoll), which reports the selection to the server while it is
// true so the STREAM_UNIT feed runs.
GVAR(unitTagsVisible) = true;

// netId → FUNC(buildTagEntry) result, built lazily during the draw pass; wiped
// whenever the underlying data or a tag* setting changes. The data-change half
// is flagged by EFUNC(core,streamClient) as each STREAM_UNIT snapshot lands.
GVAR(unitTagsCache) = createHashMap;
GVAR(unitTagsDirty) = true;

// Invalidate when a tag setting changes mid-mission, so field toggles apply
// live. Flipping the master setting also syncs the runtime switch: OFF hides the
// tags (and stops the data stream) immediately instead of waiting for a restart.
["CBA_SettingChanged", {
    params ["_name", "_value"];
    private _lname = toLower _name;
    if ((_lname find toLower QGVAR(tag)) == 0) then { GVAR(unitTagsDirty) = true };
    if (_lname == toLower QGVAR(enableUnitTags)) then {
        GVAR(unitTagsVisible) = _value;
        call FUNC(applyTagVisibility);
    };
}] call CBA_fnc_addEventHandler;

call FUNC(applyTagVisibility);
