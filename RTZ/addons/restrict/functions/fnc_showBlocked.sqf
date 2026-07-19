#include "script_component.hpp"
/*
 * Author: Maxim
 * Curator toast shown when a gated attribute confirm is refused because the
 * unit (or part of the selection) is outside every editing zone. Split out so
 * the compiled statement wrappers in FUNC(wrapAttributes) can reference it by
 * name.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_restrict_fnc_showBlocked
 *
 * Public: No
 */

[LSTRING(MsgOutsideZone)] call zen_common_fnc_showMessage;
