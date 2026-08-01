#include "script_component.hpp"
/*
 * Author: Maxim
 * Shows a ZEN curator message, suffixed with "  xN" when the order affected
 * more than one thing. Every RTZ order action reports back this way; the
 * suffix is what tells a curator his click landed on the whole selection and
 * not just the unit under the cursor.
 *
 * A count of 1 (or 0, for actions that report before they know a total) prints
 * the bare message, so callers can hand over `count _things` unconditionally
 * instead of guarding at each call site.
 *
 * Arguments:
 * 0: Message <STRING>
 * 1: Affected count <NUMBER> (default: 1)
 *
 * Return Value:
 * None
 *
 * Example:
 * [LLSTRING(MsgReloading), count _grps] call rtz_common_fnc_showCountMessage
 *
 * Public: No
 */

params ["_message", ["_count", 1]];

if (_count > 1) then {
    _message = format ["%1  x%2", _message, _count];
};

// Passed as a format ARGUMENT, not as the format string: showMessage runs
// `format` over what it is given, so a translation containing a literal "%"
// would otherwise be re-scanned as a placeholder and mangle the toast.
["%1", _message] call zen_common_fnc_showMessage;
