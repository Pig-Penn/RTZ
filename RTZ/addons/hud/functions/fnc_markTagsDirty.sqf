#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Invalidate one tag system's built-entry cache, so its renderer rebuilds
 * from the new data on its next frame.
 *
 * Called by the stream receivers as each snapshot lands. Silently does nothing
 * for a system that is not running — the master settings gate each system
 * independently, so a receiver may well be storing packets for a display the
 * curator switched off, and that is not an error worth guarding at every call
 * site (docs/Knowledge Base/Gotchas.md §2 — a nil read would abort the receiver).
 *
 * Arguments:
 * 0: System id, as passed to FUNC(startTagSystem) <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(unitTags)] call rtz_hud_fnc_markTagsDirty
 *
 * Public: No
 */

params ["_id"];

private _sys = GVAR(tagSystems) get _id;
if (isNil "_sys") exitWith {};

_sys set [TAG_DIRTY, true];
