#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds the structured-text markup for one vehicle stat card's body, for
 * FUNC(vehicleCardLayout): a speed · crew/seats · magazines icon row, the
 * commander, the LAMBS task · tactic line, and an amber warning line. Name, fuel
 * and hull live in the title bar and the readout bars, not here.
 *
 * <img> elements are top-level siblings of <t>, never nested inside <t>.
 *
 * LAMBS task/tactic strings and the RTZ FLAG_* warning tokens go through
 * GVAR(tagLabels) (FUNC(loadTagLabels)) exactly as the tags do, so one rename
 * there changes the card and the tag together — cards used to render the raw
 * strings, and the same task read differently in the two places.
 *
 * Arguments:
 * 0: Vehicle packet <ARRAY> (layout: FUNC(gatherVehicleInfo))
 *
 * Return Value:
 * Structured text markup <STRING>
 *
 * Example:
 * [_packet] call rtz_hud_fnc_vehicleCardBody
 *
 * Public: No
 */

params ["_pkt"];

_pkt params [
    "", "", "", "_speedKmh", "", "",
    "_crewCnt", "_ecNet", "_flags", "_task", "_tactic", ["_ammoCnt", 0],
    ["_seatCnt", -1]
];

private _labels = GVAR(tagLabels);
private _s = " shadow='1' shadowColor='#000000'";
private _crewStr = if (_seatCnt > 0) then { format ["%1/%2", _crewCnt, _seatCnt] } else { str _crewCnt };

private _t = "<img image='" + ICON_MOVE + "' size='0.80' color='" + HEX_DIM + "'/>"
    + "<t font='RobotoCondensed' size='0.85' color='" + HEX_BODY + "'" + _s + "> " + (format [LLSTRING(VtagFieldSpeed), _speedKmh]) + "   </t>"
    + "<img image='\a3\ui_f\data\igui\cfg\commandbar\imagedriver_ca.paa' size='0.80' color='" + HEX_DIM + "'/>"
    + "<t font='RobotoCondensed' size='0.85' color='" + HEX_BODY + "'" + _s + "> " + _crewStr + "   </t>"
    + "<img image='" + ICON_ATTACK + "' size='0.80' color='" + HEX_DIM + "'/>"
    + "<t font='RobotoCondensed' size='0.85' color='" + HEX_BODY + "'" + _s + "> " + str _ammoCnt + "</t>";

if (_ecNet != "") then {
    private _ec = objectFromNetId _ecNet;
    // alive check: `name` returns garbage for dead units, so a commander killed
    // between server pushes drops the line.
    if (!isNull _ec && { alive _ec }) then {
        _t = _t + "<br/><t font='RobotoCondensed' size='0.80' color='" + HEX_DIM + "'" + _s + ">" + LLSTRING(CardCommander) + "  </t>"
            + "<t font='RobotoCondensed' size='0.80' color='" + HEX_BODY + "'" + _s + ">" + name _ec + "</t>";
    };
};

// Same remap the tags apply, and the same rule: a label deliberately mapped to
// "" (LAMBS' "None") drops out instead of leaving a dangling separator.
private _ai = ([_task, _tactic] apply { _labels getOrDefault [_x, _x] }) select { _x != "" };
if (_ai isNotEqualTo []) then {
    _t = _t + "<br/><t font='RobotoCondensed' size='0.80' color='" + HEX_TASK + "'" + _s + ">" + (_ai joinString " · ") + "</t>";
};

private _warnings = (_flags apply { _labels getOrDefault [_x, _x] }) select { _x != "" };
if (_warnings isNotEqualTo []) then {
    _t = _t + "<br/><img image='\a3\ui_f\data\igui\cfg\simpletasks\types\intel_ca.paa' size='0.75' color='" + HEX_WARN + "'/>"
        + "<t font='RobotoCondensed' size='0.80' color='" + HEX_WARN + "'" + _s + "> " + (_warnings joinString "  ") + "</t>";
};

_t
