#include "script_component.hpp"
/*
 * Author: Maxim
 * Dispatches a radio contact-report to every spotter Zeus's client.
 * Called server-side by FUNC(spotCheck) when a side newly spots a group
 * and the per-group cooldown (managed by the caller) has expired.
 * The location lookup and phrasing run once; every curator on the side gets
 * the identical message.
 *
 * Arguments:
 * 0: Unit that authors the report (resolved to a man by the caller) <OBJECT>
 * 1: Contact category strings built during detection (e.g. ["infantry","armor"]) <ARRAY>
 * 2: Spotter Zeus player objects (CBA targetEvent destinations) <ARRAY>
 * 3: World position of the first new contact, for the location lookup <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [_reporter, ["infantry"], [_player], getPos _leader] call rtz_spotting_fnc_spotCallout
 *
 * Public: No
 */
params ["_reporter", "_reportCats", "_spotterPlayers", ["_contactPos", []]];

// ── Location qualifier ──────────────────────────────────────────────────────
// Find the nearest named place to the first new contact and build a suffix:
//   < 150 m  → "in <Name>"              (inside the settlement)
//   < 400 m  → "near <Name>"            (tactically close)
//   < 1500 m → "<direction> of <Name>"  (e.g. "northwest of Goisse")
//   otherwise → ""                       (nothing close enough to be meaningful)
private _locText = "";
if (_contactPos isNotEqualTo []) then {
    private _locs = nearestLocations [_contactPos, ["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "Airport", "Strategic"], 1500];
    if (_locs isNotEqualTo []) then {
        private _loc  = _locs # 0;
        private _name = text _loc;
        if (_name != "") then {
            // distance2D ignores altitude so the thresholds are true map distances,
            // not inflated by terrain elevation on hilly maps like Malden.
            private _dist = _contactPos distance2D (locationPosition _loc);
            _locText = switch (true) do {
                case (_dist < 150): { format [" in %1", _name] };
                case (_dist < 400): { format [" near %1", _name] };
                default {
                    private _dir = (locationPosition _loc) getDir _contactPos;
                    private _cardinal = switch (true) do {
                        case (_dir < 22.5 || _dir >= 337.5): { "north" };
                        case (_dir < 67.5):                  { "northeast" };
                        case (_dir < 112.5):                 { "east" };
                        case (_dir < 157.5):                 { "southeast" };
                        case (_dir < 202.5):                 { "south" };
                        case (_dir < 247.5):                 { "southwest" };
                        case (_dir < 292.5):                 { "west" };
                        default                              { "northwest" };
                    };
                    format [" %1 of %2", _cardinal, _name]
                };
            };
        };
    };
};

// One phrase picked at random so repeated contacts don't sound identical.
// %1 = contact category string, %2 = location qualifier (may be empty).
private _CONTACT_PHRASES = [
    "Contact! Enemy %1 spotted%2.",
    "Eyes on enemy %1%2!",
    "Be advised, enemy %1%2.",
    "Visual on enemy %1%2.",
    "Enemy %1 contact%2!",
    "We've got enemy %1 in sight%2.",
    "Spotted enemy %1%2 — keep your heads down.",
    "Heads up, enemy %1 on the move%2."
];

// Build the category string ("infantry", "infantry and armor", etc.).
// Copy the array — deleteAt must not mutate the caller's local.
private _cats = +_reportCats;
private _catText = if (count _cats == 1) then {
    _cats # 0
} else {
    private _last = _cats deleteAt (count _cats - 1);
    (_cats joinString ", ") + " and " + _last
};

private _message = format [selectRandom _CONTACT_PHRASES, _catText, _locText];
{
    [QGVAR(spotAlert), [_reporter, _message], _x] call CBA_fnc_targetEvent;
} forEach _spotterPlayers;
