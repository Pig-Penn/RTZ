#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds one vehicle's cached tag entry for FUNC(vehicleTags) from its server
 * packet (layout: FUNC(gatherVehicleInfo)). Called lazily during the draw pass,
 * once per vehicle per cache generation — the cache is wiped on every fresh
 * server push or vtag* setting change, so this never runs per frame in the
 * steady state.
 *
 * Locality-bound fields (LAMBS task/tactic) arrive as "" when the crew is not
 * server-local, so they drop out naturally. statusText is coloured separately
 * from mainText so LOW FUEL / DAMAGED can be amber/red without recolouring the
 * whole line. The measured text widths ride along so the per-frame draw only
 * reads them back — see FUNC(textWidth).
 *
 * All display text resolves here: LAMBS task/tactic strings and the RTZ FLAG_*
 * wire tokens go through GVAR(tagLabels) (FUNC(loadTagLabels)), and a token whose
 * label is deliberately blank drops its whole segment.
 *
 * Arguments:
 * 0: Vehicle packet <ARRAY>
 *
 * Return Value:
 * Cache entry <ARRAY>
 *   0 mainText  1 mainRGB  2 statusText  3 statusRGB  4 separator
 *   5 mainSepWidth  6 statusWidth
 *
 * Example:
 * [_packet] call rtz_selection_fnc_buildVtagEntry
 *
 * Public: No
 */

params ["_pkt"];

_pkt params [
    "_vNet", "", "_dName", "_speedKmh", "_fuelPct", "_healthPct",
    "_crewCnt", "_ecNet", "_flags", "_task", "_tactic", "",
    ["_seatCnt", -1], ["_flyHeight", -1], ["_selAmmo", -1]
];

// Display-label remap (FUNC(loadTagLabels)) — LAMBS strings and RTZ tokens to
// localized text, resolved at build time (cached).
private _labels = GVAR(tagLabels);

private _segs = [];
if (GVAR(vtagShowName)) then { _segs pushBack _dName };
if (GVAR(vtagShowSpeed) && { _speedKmh > 0 }) then {
    _segs pushBack format [LLSTRING(VtagFieldSpeed), _speedKmh];
};
// Static weapons (mortars, HMGs, AT launchers on tripods) have a single gunner
// slot — a crew count adds nothing a player doesn't already see.
private _isStatic = (objectFromNetId _vNet) isKindOf "StaticWeapon";
if (GVAR(vtagShowCrew) && { !_isStatic }) then {
    // "<aboard>/<positions>"; positions can be unknown (-1: a pre-seat-count
    // server build) — degrade to the bare aboard count.
    _segs pushBack ([
        format [LLSTRING(VtagFieldCrew), _crewCnt],
        format [LLSTRING(VtagFieldCrewSeats), _crewCnt, _seatCnt]
    ] select (_seatCnt > 0));
};
if (GVAR(vtagShowFuel) && { _fuelPct < 100 }) then {
    _segs pushBack format [LLSTRING(VtagFieldFuel), _fuelPct];
};
if (GVAR(vtagShowHull) && { _healthPct < 100 }) then {
    _segs pushBack format [LLSTRING(VtagFieldHull), _healthPct];
};
// Only helicopters given a fly-height keybind order carry the var (-1 otherwise).
if (GVAR(vtagShowFlyHeight) && { _flyHeight >= 0 }) then {
    _segs pushBack format [LLSTRING(VtagFieldAlt), _flyHeight];
};
if (GVAR(vtagShowAmmo) && { _selAmmo >= 0 }) then {
    _segs pushBack format [LLSTRING(VtagFieldAmmo), _selAmmo];
};
// Dead-commander guard: `name` returns garbage for dead units, so a commander
// killed between server pushes must drop the segment entirely.
if (GVAR(vtagShowCommander) && { _ecNet != "" }) then {
    private _ec = objectFromNetId _ecNet;
    if (!isNull _ec && { alive _ec }) then {
        _segs pushBack format [LLSTRING(VtagFieldCommander), name _ec];
    };
};
if (GVAR(vtagShowTactic) && { _tactic != "" }) then {
    // Remap FIRST: a tactic mapped to "" (LAMBS' "None") must drop the whole
    // segment, not render a bare "TAC ".
    private _tacLabel = _labels getOrDefault [_tactic, _tactic];
    if (_tacLabel != "") then {
        _segs pushBack format [LLSTRING(TagFieldTactic), _tacLabel];
    };
};

// Status: warning flags always surface; the LAMBS task only when enabled.
// Kept out of _segs — it's rendered as its own coloured drawIcon3D so LOW FUEL /
// DAMAGED can be amber/red without recolouring the line.
private _status = switch (true) do {
    case (_flags isNotEqualTo []): {
        ((_flags apply { _labels getOrDefault [_x, _x] }) select { _x != "" }) joinString " · "
    };
    case (GVAR(vtagShowStatus)): { _labels getOrDefault [_task, _task] };   // "" without LAMBS
    default                      { "" };
};

private _col = COL_NORMAL;
// DAMAGED beats LOW FUEL for the status colour (worst condition wins); a LAMBS
// task name stays the same colour as the rest of the line.
private _statusCol = switch (true) do {
    case (FLAG_DAMAGED in _flags):  { COL_BAD };
    case (FLAG_LOW_FUEL in _flags): { COL_WARN };
    default                         { _col };
};

private _mainText = _segs joinString " · ";
private _sep = ["", " · "] select (_mainText != "" && { _status != "" });

// Exact on-screen widths for the status split in the draw pass, measured once per
// cache build (size changes dirty the cache via the vtag* prefix handler in
// FUNC(vehicleTags), so these stay in step with GVAR(vtagSize)).
private _vtagSize = GVAR(vtagSize);
private _wMainSep = [_mainText + _sep, _vtagSize] call FUNC(textWidth);
private _wStatus  = [_status, _vtagSize] call FUNC(textWidth);

[_mainText, _col select [0, 3], _status, _statusCol select [0, 3], _sep, _wMainSep, _wStatus]
