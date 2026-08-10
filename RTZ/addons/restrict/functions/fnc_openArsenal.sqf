#include "script_component.hpp"
/*
 * Author: Maxim
 * Statement of the context menu's Loadout parent and its Edit child, replacing
 * ZEN's own through the CfgContext patch in CfgContext.hpp.
 *
 * The Edit child is already hidden out of zone by FUNC(canEditLoadout), so for
 * that entry this is belt and braces. The parent is the reason the gate has to
 * exist at statement level at all: its condition must stay intact to keep the
 * Loadout submenu — and Copy, Paste, Reset and Switch Weapon with it — reachable
 * out of zone, yet clicking the parent row on its own opens the arsenal. So the
 * parent stays visible and reports the refusal instead of vanishing.
 *
 * zen_common_fnc_openArsenal would be the one chokepoint every arsenal entry
 * point funnels into, but CBA compiles ZEN's functions final, so it cannot be
 * wrapped by reassignment. Each entry point is gated where it is invoked.
 *
 * Arguments:
 * 0: Entity <OBJECT> (passed as _this by the context menu)
 *
 * Return Value:
 * None
 *
 * Example:
 * _hoveredEntity call rtz_restrict_fnc_openArsenal
 *
 * Public: No
 */

params ["_entity"];

if (GVAR(arsenal) && {!([_entity] call FUNC(canEditEntity))}) exitWith {
    [LSTRING(MsgOutsideZone)] call zen_common_fnc_showMessage;
};

_entity call zen_common_fnc_openArsenal
