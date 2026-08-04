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
    private _camPos = positionCameraToWorld [0, 0, 0];

    // Renderers divide by this for their distance fade, so it must never be 0.
    private _viewDist = getObjectViewDistance select 0;
    if (_viewDist <= 0) then { _viewDist = viewDistance };

    private _ctx = [
        _camPos,
        (positionCameraToWorld [1, 0, 0]) vectorDiff _camPos,
        (positionCameraToWorld [0, 1, 0]) vectorDiff _camPos,
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
    {
        [_ctx] call (_x select 1);
    } forEach _world;
}] call CBA_fnc_addBISEventHandler;
