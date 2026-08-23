#include "script_component.hpp"
/*
 * Author: Maxim
 * The ONE Draw3D handler in RTZ. Every curator-view display — unit tags, vehicle
 * tags, destination and target overlays, spot icons, the remote-control
 * indicator — draws from here.
 *
 * Why one: a Draw3D handler runs every frame, and the work at the TOP of each is
 * identical. Six independently-registered handlers meant six `findDisplay`
 * + `getAssignedCuratorLogic` Zeus tests, up to five separate camera bases (each
 * of which is THREE `positionCameraToWorld` calls, for origin/right/up) and
 * several `getMousePosition` calls — every frame, to draw one picture. This
 * computes that context once and hands the same array to each renderer, so a
 * curator running every display pays for one camera query, not five.
 *
 * Two renderer classes, because "is this frame worth drawing?" has two answers:
 *
 *   RENDER_WORLD — draws into the 3D scene. Skipped entirely while the Zeus MAP
 *     is up: the map covers the 3D view, so `drawIcon3D` / `drawLine3D` output
 *     is invisible and the entire pass is waste. Only the spot renderer used to
 *     test this; the tags and overlays all ran their full draw with the map
 *     open, producing nothing.
 *
 *   RENDER_UI — drives controls on the curator display, which stay visible OVER
 *     the Zeus map. Receives the display directly (displayNull when Zeus is
 *     closed or this player is not a curator) and is responsible for its own
 *     teardown on that transition — which is exactly why it is called on
 *     Zeus-closed frames, where the world pass exits.
 *
 * The registry is populated by FUNC(registerRenderer) as each display starts and
 * emptied by FUNC(unregisterRenderer) as it is toggled off, so a curator with
 * every display switched off costs one `findDisplay` and two empty-array tests
 * per frame — the camera basis is never built. Renderers still self-gate on
 * their own finer conditions (data arrived, selection non-empty); registration
 * only tracks whether the SYSTEM is on.
 *
 * Renderers run in ascending priority order, so a later-registered display
 * cannot jump the draw order of an earlier one.
 *
 * Being the one place every display passes through, this is also where the
 * per-display profiling lives: under the RTZ_perf gate (FUNC(perfSample)) the world
 * pass times each renderer under its registered id. See the branch at the bottom for
 * why it is a duplicated loop and not a conditional inside one.
 *
 * Loading: called unconditionally from XEH_postInit on every interface machine —
 * it reads no settings to install itself and is free while nothing is
 * registered. Registers one Draw3D MEH, no scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_core_fnc_frameLoop
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

[missionNamespace, "Draw3D", {
    private _ui    = GVAR(uiRenderers);
    private _world = GVAR(worldRenderers);
    // Nothing switched on at all — the common case for a non-curator, and for a
    // curator who runs none of these displays.
    if (_ui isEqualTo [] && {_world isEqualTo []}) exitWith {};

    // Resolved ONCE for every display. getAssignedCuratorLogic as well as the
    // display: a machine showing the curator display without an assigned curator
    // gets [] back from curatorSelected, and SELECTED_OBJECTS would then index
    // into an empty array.
    private _disp = findDisplay IDD_RSCDISPLAYCURATOR;
    private _uiDisp = if (isNull _disp || {isNull (getAssignedCuratorLogic player)}) then {
        displayNull
    } else {
        _disp
    };

    // UI pass. Runs even with Zeus closed (displayNull) so each renderer can drop
    // its control references on the transition rather than leaking them until the
    // next time Zeus opens.
    // Wrapped for the same reason as the world pass below — one call convention for
    // both, so a UI renderer written with `params [...]` cannot fall into the same
    // trap the moment someone hands it more than a display.
    {
        [_uiDisp] call (_x select 1);
    } forEach _ui;

    // World pass. Zeus open, curator assigned, and the map NOT covering the view.
    if (isNull _uiDisp || {visibleMap} || {_world isEqualTo []}) exitWith {};

    // Shared frame context: one camera basis, one mouse query, one clock read for
    // every world renderer. _camRight / _camUp are the camera-right and camera-up
    // unit vectors in world space — the axes screen-space offsets are applied
    // along, so "right of the text" and "one line down" hold at any camera
    // orientation (a world +Z lift projects to nothing from a top-down camera).
    //
    // THE BASIS IS DIFFERENCED IN ASL, NEVER IN THE AGL positionCameraToWorld
    // RETURNS. Its documented return is PositionAGL, whose Z is measured from the
    // terrain DIRECTLY UNDER THE POINT, so subtracting two AGL probes taken 1 m
    // apart does not yield the camera axis — it yields that axis PLUS the terrain
    // slope under the camera:
    //
    //     camRight.z = trueRight.z + (terrainZ(cam) - terrainZ(cam + right))
    //
    // Renderers multiply this vector by tens of metres (a tag chunk offset, an
    // icon gap), so a hillside under the camera tilted the axis enough to lay a
    // head tag out along a DIAGONAL: its three coloured chunks stepped upward left
    // to right, spaced correctly but each on its own screen line. The horizontal
    // spacing stayed right because the callers measure their UI scale off a
    // screen-X delta, which a spurious world-Z does not disturb — and the tell
    // was that the break moved with the CAMERA, not with the tagged entity.
    //
    // The camera POSITION stays AGL: renderers use it only for `distance` against
    // AGL anchors, and every consumer would have to change together.
    //
    // Input axis order is [x, z, y] — x right, z UP, y forward, Y and Z swapped
    // versus model space — so [1,0,0] and [0,1,0] are right and up as intended.
    private _camPos    = positionCameraToWorld [0, 0, 0];
    private _camPosASL = AGLToASL _camPos;

    // Renderers divide by this for their distance fade, so it must never be 0.
    private _viewDist = getObjectViewDistance select 0;
    if (_viewDist <= 0) then { _viewDist = viewDistance };

    private _ctx = [
        _camPos,
        (AGLToASL positionCameraToWorld [1, 0, 0]) vectorDiff _camPosASL,
        (AGLToASL positionCameraToWorld [0, 1, 0]) vectorDiff _camPosASL,
        getMousePosition,
        CBA_missionTime,
        _viewDist
    ];
    // The display is deliberately NOT a seventh element. RENDER_UI renderers get
    // it as their whole argument above; RENDER_WORLD renderers never read it, so
    // carrying it here was one array slot built per frame for nobody.

    // Wrapped in an argument array, NOT passed bare. Every renderer opens with
    // `params ["_ctx"]`, and `params` DESTRUCTURES `_this` — so a bare `_ctx call`
    // handed each renderer `_this select 0` (the camera position) as its whole
    // context. `_ctx select CTX_CAMPOS` then read a bare number and `_ctx select
    // CTX_VIEWDIST` ran off the end, so every renderer threw on its first
    // `distance` and aborted, drawing nothing. Matches each renderer's documented
    // "Arguments: 0: Frame context".
    //
    // Two copies of the same loop, chosen by ONE missionNamespace read per frame —
    // the RTZ_perf gate (FUNC(perfSample)). Timing each renderer separately is what
    // turns "the mod costs frames" into a per-display bill: tags, supply lines, spot
    // icons and the RC indicator each report under the id they registered with, so a
    // display that is always switched on can be weighed against one that is not.
    //
    // Written as a branch rather than a timed loop with the clock reads inside an
    // `if`, and the accumulation INLINED rather than sent through FUNC(perfSample),
    // for the same reason FUNC(drawSpots) inlines its colour block: a `call` here is
    // a fresh scope and a `params` destructure PER RENDERER PER FRAME on every
    // curator's machine. The off path below must stay byte-for-byte what it was.
    if (GETMVAR(RTZ_perf,false)) then {
        private _acc = GVAR(perfAcc);
        {
            private _t0 = diag_tickTime;
            [_ctx] call (_x select 1);
            private _ms = (diag_tickTime - _t0) * 1000;

            private _id    = _x select 0;
            private _entry = _acc get _id;
            if (isNil "_entry") then {
                _entry = [0, 0, 0, ""];
                _acc set [_id, _entry];
            };
            _entry set [PERF_N,   (_entry select PERF_N) + 1];
            _entry set [PERF_SUM, (_entry select PERF_SUM) + _ms];
            if (_ms > (_entry select PERF_MAX)) then { _entry set [PERF_MAX, _ms] };
        } forEach _world;
    } else {
        {
            [_ctx] call (_x select 1);
        } forEach _world;
    };
}] call CBA_fnc_addBISEventHandler;
