#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Draws the service-radius ring around each selected supply vehicle while
 * the target picker is open. Registered as a RENDER_WORLD renderer on
 * EFUNC(core,frameLoop) by FUNC(orderResupply) and unregistered again the moment
 * the pick ends — so this costs exactly nothing outside a picker session, which is
 * what registering rather than testing a flag every frame buys.
 *
 * The ring exists because the picker's boundary is otherwise invisible: a curator
 * has no way to see where GVAR(serviceRadius) — 30 m by default — ends, and
 * FUNC(findServiceTarget) reports everything past it as no target at all.
 *
 * FLAT, and centred on the truck's LIVE position. The offsets are baked once when
 * the picker opens (FUNC(orderResupply)), so a frame costs one vectorAdd and one
 * drawLine3D per segment per truck and no trigonometry at all. It follows a truck
 * that moves, but does not follow terrain: on a slope the ring cuts into the hill
 * on one side and floats on the other. Supply vehicles are parked on flat ground
 * essentially always, and sampling getTerrainHeightASL per segment per frame to fix
 * a case that does not arise is exactly the per-frame cost this mod cannot afford.
 *
 * The map half is FUNC(drawRingMap): a RENDER_WORLD renderer is skipped while the
 * Zeus map is up, by design, and the picker works on the map too.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in core's script_macros_core.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_supply_fnc_drawRing3D
 *
 * Public: No
 */

params ["_ctx"];

private _trucks = GVAR(ringTrucks);
if (_trucks isEqualTo []) exitWith {};

private _offsets = GVAR(ringOffsets);
if (_offsets isEqualTo []) exitWith {};

private _camPos = _ctx select CTX_CAMPOS;

{
    if (isNull _x || {!alive _x}) then { continue };

    // ASLToAGL, NOT getPosATLVisual: drawLine3D takes AGL, whose Z is measured from
    // the WATER SURFACE over sea while ATL measures from the seabed. Same idiom
    // FUNC(drawSupply) uses, and for the same reason — a supply boat or an
    // amphibious hull would otherwise draw its ring lifted by the water depth.
    private _centre = ASLToAGL getPosASLVisual _x;

    // Distant rings recede rather than stacking into clutter. Cut outright rather
    // than faded: unlike a supply line, a ring is a thing the curator is currently
    // aiming inside of, so there is no reading to preserve at two kilometres.
    if (_camPos distance _centre > MAX_DRAW_DIST) then { continue };

    // _offsets carries RING_SEGMENTS + 1 points, the last equal to the first, so
    // the loop closes the ring without a wrap-around index.
    for "_i" from 0 to (RING_SEGMENTS - 1) do {
        drawLine3D [
            _centre vectorAdd (_offsets select _i),
            _centre vectorAdd (_offsets select (_i + 1)),
            COLOR_RING
        ];
    };
} forEach _trucks;
