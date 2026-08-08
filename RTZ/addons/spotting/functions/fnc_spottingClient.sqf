#include "script_component.hpp"
/*
 * Author: Maxim
 * Client half of the spotting system: per-player icon stores, the per-frame
 * renderer registration (FUNC(drawSpots)), the CBA event receivers
 * (spotDetected / spotLost / spotAlert / blink), the Zeus map overlay attach
 * fallback, and the JIP resync request.
 *
 * No hasInterface guard here — per the ZEN guard convention this is only
 * reachable from FUNC(spottingSystem), which forks on hasInterface before
 * calling in.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_spotting_fnc_spottingClient
 *
 * Public: No
 */

// Per-player storage, split by marker kind so the per-frame draw passes and
// the Zeus map overlay iterate exactly the entries they render — no flag
// filtering per entry per frame. Sizes/positions are computed client-side
// each frame. Set by QGVAR(spotDetected); cleared by QGVAR(spotLost).
//   GVAR(spotGroups):   markerName → [unit, texture, colorArray, echelonTex, sideIdx, leaderNetId]
//   GVAR(spotChevrons): markerName → [unit, texture, colorArray, leaderNetId, displayName, unitNetId]
//     unitNetId is the spotted man's own netId, carried so FUNC(drawSpots) can test the
//     remote-control store by key without a `netId` engine call per chevron per frame.
//     It is pre-resolved server-side (FUNC(spotCheck) already holds it as the spot key's
//     unit half) and cannot drift from the object it names, so unlike the other payload
//     fields it needs no place in the change signature.
//   GVAR(officerZones): markerName → [unit, plantedCenter, radius] — the subset of
//     entries in EITHER store above whose unit is an enemy officer carrying an
//     active editing-area zone. Chevrons for the most part; a GROUP entry when the
//     officer is the man his group's icon is drawn over, since the server drops
//     that man's chevron (it would be a second marker on the same soldier) and
//     moves his zone onto the group payload rather than letting the ring die with
//     it — see FUNC(spotCheck). Center + radius come from rtz_officer's
//     RTZ_officerZoneMap, piggybacked on whichever payload carries the officer —
//     see QGVAR(spotDetected) below. Drawn as a hollow ring on the Zeus map by
//     FUNC(initCuratorDisplay), at the PLANTED center — rtz_officer areas never
//     move once placed, so the ring marks the editable ground, not the officer.
GVAR(spotGroups)   = createHashMap;
GVAR(spotChevrons) = createHashMap;
GVAR(officerZones) = createHashMap;

// markerName → time until which the icon flashes white (set by QGVAR(blink) when the
// spotted unit fires). Only wedge markers ever receive blinks.
GVAR(blinkUntil) = createHashMap;

// NOTE: GVAR(chevronsEnabled), GVAR(officerZonesVisible) and the GVAR(chevronNames)
// fallback are initialized in XEH_preInit, NOT here — this function is gated on the
// GVAR(enableSpottingSystem) setting, whereas the context action's modifierFunction
// runs unconditionally and would read them as nil with the system disabled. See the
// comment block in XEH_preInit.sqf.

// Draw 3D world icons above each spotted enemy every frame; positions are sampled
// live from the unit so icons track smoothly between the server's spot cycles.
//
// The renderer itself is FUNC(drawSpots), which reads the stores above
// through EGVAR; rtz_core owns the ONE Draw3D handler every RTZ display draws
// from, and is what calls it. This used to be a Draw3D handler of its own; with
// five other displays doing the same, each frame re-ran the Zeus test and rebuilt
// the camera basis once per handler. The frame loop resolves that once and also
// owns the curator-view gates (Zeus open, map not covering the 3D view) that the
// old handler repeated at the top of every pass.
[QGVAR(spots), LINKFUNC(drawSpots), RENDER_WORLD, 41] call EFUNC(core,registerRenderer);

// Store/update icon data for a spotted enemy. Texture, colour, echelon amplifier,
// side index, group-leader netId and display name are all pre-resolved on the server.
[QGVAR(spotDetected), {
    params ["_markerName", "_unit", "_texture", "_colorArray", "_isGroupMarker", "_echelonTex", "_sideIdx", "_ldrId", "_name", ["_zone", []], ["_unitId", ""]];

    if (_isGroupMarker) then {
        GVAR(spotGroups) set [_markerName, [_unit, _texture, _colorArray, _echelonTex, _sideIdx, _ldrId]];
    } else {
        GVAR(spotChevrons) set [_markerName, [_unit, _texture, _colorArray, _ldrId, _name, _unitId]];
    };

    // Officer zone ring, handled the same for BOTH marker kinds. It used to sit in
    // the wedge branch alone, on the reasoning that only individually-identified
    // entries carry a zone — still true, but the server now suppresses the chevron
    // of the man the group icon is drawn over (see FUNC(spotCheck)) and moves his
    // zone onto the GROUP payload, so an officer leading his own squad reaches this
    // handler through the branch above. Entries without one send [] and take the
    // deleteAt, which is a no-op on the overwhelming majority that never had a ring.
    // The zone dropping back to [] (area removed while still spotted) clears it the
    // same tick, since both signatures embed the zone and force a resend.
    if (_zone isNotEqualTo []) then {
        GVAR(officerZones) set [_markerName, [_unit, _zone select 0, _zone select 1]];
    } else {
        GVAR(officerZones) deleteAt _markerName;
    };
}] call CBA_fnc_addEventHandler;

// Remove 3D icon when the enemy is no longer spotted. Group and chevron
// marker names never collide ("s_"/"w_" key prefixes), so deleting from
// both maps is a safe single-hit.
[QGVAR(spotLost), {
    params ["_markerName"];

    GVAR(spotGroups)   deleteAt _markerName;
    GVAR(spotChevrons) deleteAt _markerName;
    GVAR(officerZones) deleteAt _markerName;
    GVAR(blinkUntil)   deleteAt _markerName;
}] call CBA_fnc_addEventHandler;

// Contact report spoken by the spotting unit — fired by the server with a CBA
// targeted event so it runs only on this curator's machine. sideChat is local:
// the line appears in this player's side channel as "<groupId>: <message>".
[QGVAR(spotAlert), {
    params ["_reporter", "_message"];

    if (isNull _reporter) exitWith {};
    _reporter sideChat _message;
}] call CBA_fnc_addEventHandler;

// Flash a wedge white for a moment — fired by the server when the spotted unit shoots.
[QGVAR(blink), {
    params ["_markerName"];

    GVAR(blinkUntil) set [_markerName, time + BLINK_DURATION];
}] call CBA_fnc_addEventHandler;

// Zeus map overlay: normally attached by FUNC(initCuratorDisplay) via the XEH
// DisplayLoad event each time the curator display is created. If Zeus is somehow
// already open when this client half starts (late settings init), attach now.
private _curatorDisplay = findDisplay IDD_RSCDISPLAYCURATOR;
if (!isNull _curatorDisplay) then {
    [_curatorDisplay] call FUNC(initCuratorDisplay);
};

// Handlers are registered — ask the server to force-resend every active spot to
// THIS player. Covers JIP/rejoin where sig-gated sends happened before this machine
// could listen, and (for a same-slot rejoin, where the player object and therefore
// every signature is unchanged) is the only thing that restores the picture at all.
// Sending `player` rather than an empty payload makes the request per-destination:
// the server holds it pending until this player actually resolves to a curator,
// instead of spending a global flag on the next tick whether or not we were a
// resolvable Zeus by then. (Harmless no-op at mission start: nothing is active yet.)
[QGVAR(spotResync), [player]] call CBA_fnc_serverEvent;
