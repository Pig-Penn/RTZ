#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds one vehicle's cached tag entry for FUNC(drawVehicleTags) from its server
 * packet (layout: FUNC(gatherVehicleInfo)). Called lazily during the draw pass,
 * once per vehicle per cache generation — the cache is wiped on every fresh
 * server push or vtag* setting change, so this never runs per frame in the
 * steady state.
 *
 * Locality-bound fields (LAMBS task/tactic) arrive as "" when the crew is not
 * server-local, so they drop out naturally. tacticText and statusText are
 * coloured separately from mainText: the tactic in COL_TACTIC, which is what
 * identifies it now that it carries no "TAC " prefix, and the status so LOW FUEL
 * / DAMAGED can be amber/red without recolouring the whole line. The measured
 * text widths ride along so the per-frame draw only reads them back — see
 * FUNC(textWidth).
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
 *   0 mainSep (main line + its leading separator)         1 mainRGB
 *   2 tacticSep (bare tactic word, no separator)          3 tacticRGB
 *   4 statusSep (status word + its leading separator)     5 statusRGB
 *   6 mainSepWidth  7 tacticSepWidth  8 statusWidth  9 hasContent
 *   10 bars ([[centreUI, fill], ...], one per armed turret; [] for none)
 *
 * Layout matches FUNC(buildTagEntry)'s leading fields — both are composed by
 * FUNC(tagEntryTail) and drawn by FUNC(drawTagLine). The vehicle line ORDERS
 * them differently, tactic · status · main rather than tactic · main · status
 * (_statusFirst): LOW FUEL, DAMAGED or the LAMBS task sits beside the tactic
 * instead of trailing a field line whose length swings with speed, crew, fuel
 * and hull. FUNC(drawVehicleTags) passes the chunks to FUNC(drawTagLine) in that
 * order; the separators here are composed to match.
 *
 * Example:
 * [_packet] call rtz_hud_fnc_buildVtagEntry
 *
 * Public: No
 */

params ["_pkt"];

_pkt params [
    "_vNet", "_dName", "_speedKmh", "_fuelPct", "_healthPct",
    "_crewCnt", "_ecNet", "_flags", "_task", "_tactic",
    ["_seatCnt", -1], ["_flyHeight", -1], ["_selAmmo", -1], ["_ammoBars", []]
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
// slot — a crew count adds nothing a player doesn't already see. The lookup is
// inside the setting guard: it resolves an object from a netId purely to answer
// a question nobody asked when the crew field is switched off.
// A full crew (aboard == seats) is the expected state and adds nothing a
// player doesn't already see — only surface the field short of full crew.
// Unknown seat counts (-1: a pre-seat-count server build) can't be judged
// full, so those still show the bare aboard count.
if (GVAR(vtagShowCrew) && { _crewCnt < _seatCnt || _seatCnt < 0 } && { !((objectFromNetId _vNet) isKindOf "StaticWeapon") }) then {
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
// Kept OUT of _segs: drawn as its own chunk in COL_TACTIC, and that colour is
// what marks it as the tactic — it spends no line width on a "TAC " prefix. A
// tactic mapped to "" (LAMBS' "None") drops the chunk entirely.
private _tacText = "";
if (GVAR(vtagShowTactic) && { _tactic != "" }) then {
    _tacText = _labels getOrDefault [_tactic, _tactic];
};

// Status: warning flags always surface; the LAMBS task only when enabled.
// Kept out of _segs — it's rendered as its own coloured drawIcon3D so Flee /
// DAMAGED / LOW FUEL can be red/amber without recolouring the line.
private _status = switch (true) do {
    case (_flags isNotEqualTo []): {
        ((_flags apply { _labels getOrDefault [_x, _x] }) select { _x != "" }) joinString " · "
    };
    case (GVAR(vtagShowStatus)): { _labels getOrDefault [_task, _task] };   // "" without LAMBS
    default                      { "" };
};

private _col = COL_NORMAL;
// Worst condition wins: a routed crew or a wrecked hull is red, low fuel amber,
// and a LAMBS task name stays the same colour as the rest of the line. Flee is
// red here for the same reason it is on an infantry tag (FUNC(buildTagEntry)) —
// it is the same engine state, reported through the same flag, and a crew that
// has broken reads identically whether it is on foot or in a hull.
private _statusCol = switch (true) do {
    case (FLAG_FLEEING in _flags):  { COL_BAD };
    case (FLAG_DAMAGED in _flags):  { COL_BAD };
    case (FLAG_LOW_FUEL in _flags): { COL_WARN };
    // Reached only when _flags is EMPTY — the three cases above cover every
    // token FUNC(gatherVehicleInfo) can push — which is exactly when the LAMBS
    // task is what the status word shows. A crew that reports itself routed
    // reads the same red as one the engine flagged: the flag is server-local
    // only, so on a Headless Client crew the task is the only route there is.
    case (_task in TASKS_FLEEING):  { COL_BAD };
    default                         { _col };
};

// Composed line and its exact on-screen widths for the coloured splits in the
// draw pass, measured once per cache build (size changes dirty the cache through
// the vtag* prefix in the settings watcher, so these stay in step with
// GVAR(vtagSize)). Shared with the unit tags — see FUNC(tagEntryTail), which is
// also what stopped this path rebuilding the composed line every frame.
private _tagSize = GVAR(vtagSize);
// _status comes back OUT as well as in: the tail drops it when it merely repeats
// the tactic (FUNC(tagEntryTail)), and adds the leading separator the vehicle
// order leaves it to carry, so the entry has to ship the string the widths were
// measured against, not the one passed in.
([_segs, _tacText, _status, _tagSize, true] call FUNC(tagEntryTail))
    params ["_mainSep", "_tacticSep", "_statusSep", "_wMainSep", "_wTacticSep", "_wStatus"];

// Ammunition gauges, right of the text: one per armed turret, so an IFV reads its
// main gun and its commander MG side by side rather than collapsing both into the
// one selected-weapon count the text field shows. Placed by the same running
// cursor FUNC(buildTagEntry) walks its icon chain with, and with the same
// constants, so the two tag families put their bars in the same place relative to
// their text. A turret with no capacity (index 13 is [] off the owning machine)
// has no denominator and so no gauge, rather than an arbitrary fill; the count is
// capped because a many-turreted hull would otherwise run its bars off the end of
// the line. Clamped for the chambered round that puts a magazine one over.
private _bars = [];
if (GVAR(vtagShowAmmoBar) && { _ammoBars isNotEqualTo [] }) then {
    private _barW   = _tagSize * BAR_FOOT;
    private _gap    = _tagSize * ICON_GAP;
    private _cursor = ((_wMainSep + _wTacticSep + _wStatus) / 2) + (_tagSize * ICON_TEXT_GAP);
    {
        // Tested at the TOP: exitWith in a forEach body is a continue, not a
        // break (docs/Knowledge Base/Gotchas.md §2).
        if (count _bars >= BAR_MAX_VEH) then { break };
        _x params ["_rounds", "_cap"];
        if (_cap > 0 && { _rounds >= 0 }) then {
            _bars pushBack [_cursor + (_barW / 2), (_rounds / _cap) min 1];
            _cursor = _cursor + _barW + _gap;
        };
    } forEach _ammoBars;
};

// Precomputed "anything to draw at all", matching FUNC(buildTagEntry): the draw
// pass reads this one boolean instead of unpacking the whole entry to work it out
// per vehicle per frame. _mainSep / _tacticSep are empty exactly when their own
// chunk is.
private _hasContent = _mainSep != "" || { _tacticSep != "" } || { _statusSep != "" }
    || { _bars isNotEqualTo [] };

[
    _mainSep, _col select [0, 3],
    _tacticSep, (COL_TACTIC) select [0, 3],
    _statusSep, _statusCol select [0, 3],
    _wMainSep, _wTacticSep, _wStatus, _hasContent,
    _bars
]
