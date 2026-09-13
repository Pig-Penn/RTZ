#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a modal session already owns the curator display's mouse: any picker
 * holding zen_common_selectPositionActive (ZEN's own, and every RTZ picker that
 * follows the same contract), or an rtz_path planning session.
 *
 * rtz_path is the one mode that deliberately does NOT hold the ZEN flag — it is a
 * long-lived keybind mode, and holding the flag would suppress ZEN's context menu
 * for its whole duration. That kept it out of every other picker's entry test, so a
 * placement session (Shift + T) or a context-menu picker could open on top of a path
 * session, and both would act on the same left click. Every picker entry point asks
 * here instead of re-deriving the pair.
 *
 * rtz_path_planning is a SOFT read by name with a false default: rtz_path requiring
 * rtz_common is the declared edge, never the reverse, and rtz_path may be absent.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * A session is active <BOOL>
 *
 * Example:
 * if (call rtz_common_fnc_pickerActive) exitWith {false};
 *
 * Public: No
 */

GETMVAR(zen_common_selectPositionActive,false) || {GETMVAR(rtz_path_planning,false)}
