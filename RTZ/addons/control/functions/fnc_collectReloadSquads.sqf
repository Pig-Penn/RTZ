#include "script_component.hpp"
/*
 * Author: Maxim
 * Resolves a Zeus selection to the groups a reload order would actually change:
 * EFUNC(common,collectSquads) filtered down to the ones holding at least one
 * alive AI unit that FUNC(needsReload) says has something to swap.
 *
 * Single source of truth for the context action, like FUNC(collectDismountVehicles)
 * is for the dismount lock: the condition and the statement both come through
 * here, so the action cannot appear for a squad the click would leave untouched,
 * and the "N squads reloading" toast cannot count squads that ignored the order.
 *
 * The player filter mirrors FUNC(reloadSquadApply), which skips players so a
 * curator can never force a human's reload animation — without it a player-led
 * squad whose only low weapon is the player's own would offer an action that
 * does nothing.
 *
 * COST: both loops short-circuit (`findIf`, and `select` over an already-small
 * group list), and the per-unit test is a handful of engine reads against
 * mission-long config caches. It runs when the menu is BUILT, not per frame
 * (docs/Knowledge Base/Gotchas.md §5), so the worst case is one pass over the
 * selection per right-click — and the common case stops at the first unit of the
 * first group.
 *
 * Arguments:
 * 0: Selected objects, hovered entity included <ARRAY>
 *
 * Return Value:
 * Groups with something to reload <ARRAY>
 *
 * Example:
 * [_objects + [_hoveredEntity]] call rtz_control_fnc_collectReloadSquads
 *
 * Public: No
 */

params ["_objects"];

([_objects] call EFUNC(common,collectSquads)) select {
    // Alias: the inner findIf rebinds _x to a unit and leaves it clobbered for
    // the rest of this iteration (docs/Knowledge Base/Gotchas.md §2).
    private _grp = _x;

    (units _grp findIf {
        alive _x && {!isPlayer _x} && {[_x] call FUNC(needsReload)}
    }) > -1
}
