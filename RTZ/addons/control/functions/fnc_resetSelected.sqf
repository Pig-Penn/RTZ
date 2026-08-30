#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind entry point for the reset action: runs FUNC(reset) on the current
 * Zeus selection, so the shortcut and the context menu entry share one code
 * path — the same group collection, the same targeted event, the same display
 * refresh and count message.
 *
 * No hovered entity is passed: a keybind press has no cursor target, unlike the
 * right-click the context action is reached through. objNull is what
 * FUNC(reset) and FUNC(canReset) already expect for "nothing hovered", and
 * EFUNC(common,collectSquads) drops it.
 *
 * Declines through FUNC(canReset) — the context action's own condition —
 * rather than a second inline copy of the predicate, so the key passes through
 * on an empty or players-only selection instead of being swallowed. Reset has
 * no vanilla Zeus counterpart to shadow (contrast rtz_delete, which swallows
 * deliberately to keep Zeus's refunding delete from firing), so passing the key
 * through costs nothing and matches rtz_slide and rtz_path.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Key handled <BOOL>
 *
 * Example:
 * call rtz_control_fnc_resetSelected
 *
 * Public: No
 */

CHECK_CURATOR_INPUT;

private _args = [SELECTED_OBJECTS, SELECTED_GROUPS, objNull];

if !(_args call FUNC(canReset)) exitWith { false };

_args call FUNC(reset);

true // Handled
