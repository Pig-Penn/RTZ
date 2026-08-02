#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the faint side-coloured line joining each vehicle
 * card to its vehicle's commander. Called once per frame by FUNC(frameLoop),
 * after FUNC(drawVehicleCards) has published this frame's renderable set — so
 * the packet/alive/side filter is not repeated here.
 *
 * Being a world renderer is the point: these are drawLine3D into the 3D scene,
 * which the Zeus map covers completely. The cards keep updating with the map open
 * (they are UI controls); these lines correctly stop.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in script_component.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_hud_fnc_drawVehicleLinks
 *
 * Public: No
 */

{
    _x params ["_pkt", "_veh"];
    _pkt params ["", "_sideNum", "", "", "", "", "", "_ecNet"];
    if (_ecNet == "") then { continue };

    private _ec = objectFromNetId _ecNet;
    if (isNull _ec || {!alive _ec}) then { continue };

    private _sideCol = SIDE_TINTS select _sideNum;
    drawLine3D [
        (getPosATLVisual _veh) vectorAdd [0, 0, 2.5],
        unitAimPositionVisual _ec,
        [_sideCol#0, _sideCol#1, _sideCol#2, 0.30], 2
    ];
} forEach GVAR(vehicleRenderList);
