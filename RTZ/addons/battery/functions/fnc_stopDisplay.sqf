#include "script_component.hpp"
/*
 * Author: Maxim
 * Called when the curator display closes.
 *
 * The map Draw handler needs no removal — it lives on a control of the display that
 * has just been destroyed — but its stored id DOES have to be dropped, or the next
 * curator display would be handed a stale handle from the last one and skip
 * re-attaching, leaving the overlay silently dead for the rest of the mission.
 *
 * The contact store is deliberately NOT cleared. Contacts keep arriving while Zeus
 * is closed, and a curator who reopens the map should see what happened while it
 * was shut — the store bounds itself on expiry (FUNC(pruneContacts)) and on
 * CONTACT_CAP.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_battery_fnc_stopDisplay
 *
 * Public: No
 */

GVAR(mapEH) = -1;
