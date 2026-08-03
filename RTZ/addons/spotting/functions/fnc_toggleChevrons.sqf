#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: master on/off switch for the individual
 * spotted-unit chevron markers (pass 2 of FUNC(drawSpots)), PER-CLIENT.
 * Group icons (pass 1) are unaffected — this only hides/shows the per-member
 * wedge chevrons.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_spotting_fnc_toggleChevrons
 *
 * Public: No
 */

GVAR(chevronsEnabled) = !GVAR(chevronsEnabled);

[[LLSTRING(MsgChevronsHidden), LLSTRING(MsgChevronsShown)] select GVAR(chevronsEnabled)] call zen_common_fnc_showMessage;
