#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: shows or hides the counter-battery map overlay for THIS
 * curator. Per-client state — nothing is broadcast, and no other curator's view
 * changes.
 *
 * Hiding detaches the map Draw handler (FUNC(startDisplay)) but leaves the contact
 * store filling, so switching back on shows the live picture rather than starting
 * again from the next hostile shot.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_battery_fnc_toggleDisplay
 *
 * Public: No
 */

GVAR(visible) = !GVAR(visible);

[[LLSTRING(MsgContactsHidden), LLSTRING(MsgContactsShown)] select GVAR(visible)] call zen_common_fnc_showMessage;

// Apply it now rather than at the next display open — the curator is looking at the
// map they just toggled.
[] call FUNC(startDisplay);
