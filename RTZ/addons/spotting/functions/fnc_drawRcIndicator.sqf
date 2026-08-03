#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the remote-control indicator: a portrait icon over
 * every unit another curator is currently puppeteering, so a rival game master's
 * direct control reads at a glance instead of looking like unusually sharp AI.
 *
 * The DATA is owned by rtz_spotting, whose server scan resolves who is
 * controlling what and pushes viewer-diffed events into GVAR(rcDisplay) — see
 * EFUNC(spotting,remoteControlIndicator) for the detection reasoning (the engine
 * has no global getter for "who is remote controlling X"). This component owns
 * only how it looks, hence the EGVAR read; the renderer is registered by that
 * function, so it only ever runs when the store exists.
 *
 * Registered with EFUNC(core,frameLoop), which resolves the Zeus test, the camera
 * position and the view distance once for every display — this pass does no
 * camera query of its own, and is skipped entirely while the Zeus map is up.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in script_component.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_hud_fnc_drawRcIndicator
 *
 * Public: No
 */

params ["_ctx"];

private _rcDisplay = EGVAR(spotting,rcDisplay);
// Empty-map test first: it is the overwhelmingly common case and the cheapest
// check.
if (count _rcDisplay == 0) exitWith {};

private _camPos   = _ctx select CTX_CAMPOS;
private _viewDist = _ctx select CTX_VIEWDIST;

// Slow colour shift (~0.5 Hz): lerps 0→RC_COLOR_SHIFT_MAX toward white so the
// icon brightens cyclically without touching alpha (distance fade stays clean).
private _shift = RC_COLOR_SHIFT_MAX * ((sin (time * RC_COLOR_SHIFT_FREQ) + 1) / 2);

{
    // _x = unitNetId (HashMap key); _y = stored display data.
    _y params ["_unit", "_colorArray"];
    if (!alive _unit) then { continue };   // alive objNull is false — covers deleted units too
    private _anchor = vehicle _unit;
    private _dist   = _camPos distance _anchor;

    // On foot: chevron recipe, head + 1 m (identical to spotting chevrons).
    // Mounted: head + 1 m sits inside the hull, so anchor to the vehicle's
    // bounding-box roof + 1 m instead.
    private _iconPos = if (isNull objectParent _unit) then {
        (_unit modelToWorldVisual (_unit selectionPosition "Head")) vectorAdd [0, 0, 1]
    } else {
        _anchor modelToWorldVisual [0, 0, ((boundingBoxReal _anchor) select 1 select 2) + 1]
    };
    // ~1/4 of the chevron size table (the portrait texture fills its full bounding
    // box whereas the thin wedge does not), as a smooth ramp.
    private _iconW = linearConversion [RC_ICON_NEAR, RC_ICON_FAR, _dist, RC_ICON_MAX_WIDTH, RC_ICON_MIN_WIDTH, true];

    // Distance fade; RGB shifted toward white on each cycle.
    private _alpha = ((_viewDist - _dist) / _viewDist) max 0;
    private _col   = [
        ((_colorArray#0) + _shift * (1 - _colorArray#0)) min 1,
        ((_colorArray#1) + _shift * (1 - _colorArray#1)) min 1,
        ((_colorArray#2) + _shift * (1 - _colorArray#2)) min 1,
        _alpha
    ];

    drawIcon3D [
        RC_TEXTURE,
        _col, _iconPos, _iconW, _iconW, 0, "", 0, 0, "RobotoCondensed", "center", false, 0, 0
    ];
} forEach _rcDisplay;
