#include "script_component.hpp"

// Drive orders are executed where the vehicle is local — setVelocity only
// moves an object on the machine that owns it
[QGVAR(slide), LINKFUNC(slideTo)] call CBA_fnc_addEventHandler;

// Teardown for a maneuver whose vehicle or driver is no longer ours. Registered on
// EVERY machine, because the one that has to run it is by definition not the one
// that started the maneuver — FUNC(slideTick) ends a slide on `!local _vehicle`,
// and every restore in FUNC(endSlide) takes a local argument, so the releases
// would otherwise be four silent no-ops and the vehicle would keep the released
// parking brake the maneuver gave it.
//
// FUNC(endSlide) itself is the body: it applies whichever half is local here and
// ignores the other. The `false` is what stops a split pair (player in the seat of
// an AI-owned hull) bouncing the event between the two owners forever.
[QGVAR(release), {
    params ["_record"];

    [_record, false] call FUNC(endSlide);
}] call CBA_fnc_addEventHandler;
