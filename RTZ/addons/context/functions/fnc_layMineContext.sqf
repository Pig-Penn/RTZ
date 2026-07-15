#include "script_component.hpp"
/*
 * rtz_fnc_layMineContext
 *
 * Registers the "Lay Mine Here" action in the Real-Time Zeus context menu
 * (category RTZ_RealTimeZeus). The entry shows only when the selection or
 * hovered entity resolves to at least one mine-carrying man
 * (FUNC(collectMineLayers)). Clicking it queues the cursor's world position
 * (ZEN's _position) for the carrier nearest that spot; the unit walks there and
 * plants a mine.
 *
 * The carrier is chosen client-side (positions are networked) but the walk +
 * createMine must run where the AI is local (the server, in Zeus PvP), so the
 * unit + position are dispatched there via QGVAR(layMine) (registered in
 * XEH_postInit). Rapid-clicking several spots queues them for the same nearest
 * carrier, laying a line/field.
 *
 * Loading: called by XEH_postInit (hasInterface) when the lay-mine system is on.
 */

private _action = [
    "RTZ_LayMine",
    "Lay Mine Here",
    ["\A3\Ui_F_Curator\Data\CfgMarkers\minefield_ca.paa", [1, 0.55, 0.15, 1]],
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
        params ["", "_objects", "", "", "", "_hoveredEntity"];

        private _cands = [_objects + [_hoveredEntity]] call FUNC(collectMineLayers);
        if (_cands isEqualTo []) exitWith {};

        // Enter an interactive placement picker (icon-only — a buried mine has no
        // silhouette worth ghosting). On confirm, the carrier nearest the chosen
        // spot walks there and plants; ESC cancels with no order sent.
        [
            "",
            {
                params ["_confirmed", "_pos", "", "_cands"];
                if (!_confirmed) exitWith {};

                // Nearest carrier to the picked spot responds (intuitive RTS behaviour).
                private _unit = _cands select 0;
                {
                    if (_x distance _pos < _unit distance _pos) then { _unit = _x; };
                } forEach _cands;

                [QGVAR(layMine), [_unit, _pos, player]] call CBA_fnc_serverEvent;
                ["Laying mine"] call zen_common_fnc_showMessage;
            },
            _cands,
            "\A3\Ui_F_Curator\Data\CfgMarkers\minefield_ca.paa",
            [1, 0.55, 0.15, 1]
        ] call EFUNC(common,placementPreview);
    },
    {
        params ["", "_objects", "", "", "", "_hoveredEntity"];
        ([_objects + [_hoveredEntity]] call FUNC(collectMineLayers)) isNotEqualTo []
    }
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_RealTimeZeus"], 2] call zen_context_menu_fnc_addAction;
