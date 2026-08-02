#include "script_component.hpp"
/*
 * Author: Maxim
 * Remove a renderer from the shared frame loop (FUNC(frameLoop)). Safe to call
 * for an id that is not registered.
 *
 * This is what makes a switched-off display genuinely free rather than merely
 * cheap: with both renderer lists empty FUNC(frameLoop) never builds the camera
 * basis at all. A display that only sets its own `visible` flag and keeps its
 * renderer registered still costs a call and an early exit every frame.
 *
 * Arguments:
 * 0: Renderer id, as passed to FUNC(registerRenderer) <STRING>
 * 1: Renderer class, RENDER_WORLD or RENDER_UI <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(unitTags), RENDER_WORLD] call rtz_hud_fnc_unregisterRenderer
 *
 * Public: No
 */

params ["_id", "_mode"];

if (!hasInterface) exitWith {};

if (_mode == RENDER_UI) then {
    GVAR(uiRenderers) = GVAR(uiRenderers) select {(_x select 0) != _id};
} else {
    GVAR(worldRenderers) = GVAR(worldRenderers) select {(_x select 0) != _id};
};
