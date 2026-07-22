#include "script_component.hpp"
/*
 * Author: Maxim
 * ZEN custom-module callback: drop (or remove) a medical safe-zone OWNED by the
 * placing curator. Only that curator's own casualties can be evacuated there, and
 * only that curator sees the zone marker — so it is deliberately NOT global.
 *
 * Two halves:
 *   - Visual: a client-LOCAL "rtz_medzone_*" ELLIPSE marker, visible only to the
 *     owning curator (createMarkerLocal — never propagates to other machines).
 *   - Authoritative: the zone [pos, radius, ownerCuratorNetId] is registered on the
 *     SERVER via QGVAR(zoneApply), because the delivery check (FUNC(findSafeZone),
 *     server-side) cannot read a client-local marker. Ownership is keyed by the
 *     curator logic's netId, matched against the casualty's owning curator.
 *
 * Toggle: placing the module on top of one of MY existing zones removes it. Only my
 * own zones are local markers on this machine, so the scan can only match mine.
 *
 * Runs unscheduled on the placing (curator) machine.
 *
 * Arguments:
 * 0: Module position, ASL (x,y usable directly as map coords) <ARRAY>
 * 1: Attached object, objNull if none — unused <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_pos, objNull] call rtz_casualty_fnc_placeMedicalZone
 *
 * Public: No
 */

params ["_pos"];
private _radius = GETGVAR(zoneRadius,50);

// This module is placed from the Zeus interface, so the local player is a curator;
// its logic netId is the zone's owner key. Bail defensively if somehow not a curator.
private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {
    [LSTRING(MsgCuratorOnly)] call zen_common_fnc_showMessage;
};
private _ownerId = netId _curator;
private _pos2D = [_pos select 0, _pos select 1];

// Toggle off: dropped on one of my own zones → remove it (local marker + server entry).
private _mine = allMapMarkers select {
    (_x select [0, 11]) == "rtz_medzone" &&
    { (getMarkerPos _x) distance2D _pos2D < _radius }
};
if (_mine isNotEqualTo []) exitWith {
    {
        deleteMarkerLocal _x;
        [QGVAR(zoneApply), ["remove", _x]] call CBA_fnc_serverEvent;
    } forEach _mine;
    [LSTRING(MsgZoneRemoved)] call zen_common_fnc_showMessage;
};

// clientOwner keeps the id unique across machines; the counter unique per machine.
GVAR(zoneCounter) = (GETGVAR(zoneCounter,0)) + 1;
private _id = format ["rtz_medzone_%1_%2", clientOwner, GVAR(zoneCounter)];

// Local marker — visible ONLY to this curator.
private _mkr = createMarkerLocal [_id, _pos2D];
if (_mkr isEqualTo "") exitWith {
    [LSTRING(MsgZoneCreateFailed)] call zen_common_fnc_showMessage;
};
_mkr setMarkerShapeLocal "ELLIPSE";
_mkr setMarkerBrushLocal "SolidBorder";
_mkr setMarkerSizeLocal [_radius, _radius];
_mkr setMarkerColorLocal "ColorGreen";
_mkr setMarkerAlphaLocal 0.5;
_mkr setMarkerTextLocal LLSTRING(ModuleMedicalZone);

// Register the authoritative, owner-scoped zone on the server (same id as the marker).
[QGVAR(zoneApply), ["add", _id, _pos2D, _radius, _ownerId]] call CBA_fnc_serverEvent;

[LSTRING(MsgZonePlaced), round _radius] call zen_common_fnc_showMessage;
