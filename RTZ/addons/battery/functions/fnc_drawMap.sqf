#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the counter-battery picture on the Zeus map: a hollow circle over the area
 * each hostile gun fired from, and — while the rounds are still in the air — a
 * second circle over where they are about to land.
 *
 * Attached to the curator display's map control by FUNC(startDisplay), and only
 * while the overlay is actually on. Nothing here re-tests GVAR(enabled) or
 * GVAR(visible): attaching and detaching the handler IS the toggle, which is what
 * makes a hidden overlay cost exactly zero rather than one variable read per frame
 * (the shape EFUNC(mine,start) established).
 *
 * The ellipses are drawn with an empty fill texture — outline only, as
 * EFUNC(spotting,initCuratorDisplay)'s officer zone rings are. A filled ellipse is
 * markedly more expensive and reads worse stacked over Zeus's own map layers.
 *
 * Arguments:
 * 0: Zeus map control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ctrlMap] call rtz_battery_fnc_drawMap
 *
 * Public: No
 */

params ["_ctrlMap"];

private _contacts = GVAR(contacts);
if (count _contacts == 0) exitWith {};

private _now = CBA_missionTime;

// One float compare on almost every frame. FUNC(pruneContacts) maintains
// GVAR(nextExpiry) as the earliest deadline in the store, so the walk is entered
// only on the frames something can actually have expired.
//
// The prune and the emptiness re-test are two statements rather than one `then`
// block with an exitWith in it: exitWith exits only the scope it is written in, so
// a bail inside the `then` would fall through and draw over an emptied store
// (Gotchas §2).
if (_now >= GVAR(nextExpiry)) then {
    call FUNC(pruneContacts);
};

if (count _contacts == 0) exitWith {};

private _showIncoming = GVAR(showIncoming);

{
    private _record = _y;
    _record params ["_centre", "_radius", "", "", "", "", "", "",
                    "_incCentre", "_incRadius", "_splashTime"];

    _ctrlMap drawEllipse [_centre, _radius, _radius, 0, COLOR_ORIGIN, ""];
    _ctrlMap drawIcon [
        ICON_ORIGIN, COLOR_ORIGIN, _centre, MAP_ICON_SIZE, MAP_ICON_SIZE, 0,
        ([_record, _now] call FUNC(contactLabel)), 0, LABEL_TEXT_SIZE, LABEL_FONT
    ];

    // ── Incoming impact ──────────────────────────────────────────────────
    // Held SPLASH_HOLD past the estimated splash rather than cut at it: the
    // estimate is a symmetric ballistic arc taken from one velocity sample
    // (FUNC(detectShot)), so it is a few seconds out either way, and a warning
    // that vanishes before the rounds land is worse than one that lingers.
    //
    // Tests ordered cheapest first, and each written as its own `continue` at the
    // TOP of what it guards — a `break`/`continue` placed after the work it means
    // to skip costs the whole iteration anyway (Gotchas §2).
    if (!_showIncoming) then { continue };
    if (_now > _splashTime + SPLASH_HOLD) then { continue };
    if (count _incCentre < 2) then { continue };

    // A zero radius means the curator asked for the exact predicted point; the
    // icon still marks it, but a zero-axis ellipse is nothing worth asking the
    // engine to rasterise.
    if (_incRadius > 0) then {
        _ctrlMap drawEllipse [_incCentre, _incRadius, _incRadius, 0, COLOR_INCOMING, ""];
    };

    _ctrlMap drawIcon [ICON_INCOMING, COLOR_INCOMING, _incCentre, MAP_ICON_SIZE, MAP_ICON_SIZE, 0];
} forEach _contacts;
