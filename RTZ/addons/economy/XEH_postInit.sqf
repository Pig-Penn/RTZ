#include "script_component.hpp"

// Cost tables are queried on the machine entering the curator interface,
// points and income are managed by the server
if (!isServer && {!hasInterface}) exitWith {};

// When the next income payout lands, published by the server on every payout (see
// the income tick below) and replayed to JIP clients off CBA's own JIP stack.
// Registered at top level rather than inside the settings gate: the JIP replay
// arrives on its own schedule and must not be able to land before its handler.
[QGVAR(nextIncomeAt), {
    params ["_next"];
    GVAR(nextIncome) = _next;
}] call CBA_fnc_addEventHandler;

["CBA_settingsInitialized", {
    // Curator modules can be created mid-mission (e.g. ZEN's Add Zeus module),
    // so the income tick doubles as lazy detection of new modules. The PFH
    // fires every TICK_INTERVAL regardless, and the income payout itself
    // self-gates on the live GVAR(incomeInterval) via a next-run time carried
    // in the PFH args, so the payout cadence can be retuned mid-mission.
    [{
        // Curators are set up even with the economy disabled, so that disabled
        // reliably means free rather than whatever the mission's Zeus modules
        // were configured with.
        //
        // SERVER ONLY. This used to run on every interface machine as well, which
        // meant a getVariable per curator module every TICK_INTERVAL on every
        // client for the whole mission, to catch an event that happens a handful
        // of times. The client half of FUNC(initCurator) only attaches a
        // CuratorObjectRegistered handler, and that handler only ever fires "on
        // the machine of the player entering the curator interface" — so the
        // client is served exactly as well by doing it when the curator display
        // actually opens (see the zen_curatorDisplayLoaded handler below).
        if (isServer) then {
            {_x call FUNC(initCurator)} forEach allCurators;
        };

        if (isServer && {GVAR(enable)} && {GVAR(income) > 0}) then {
            (_this select 0) params ["_nextIncomeRun"];

            if (CBA_missionTime >= _nextIncomeRun) then {
                // Floored at TICK_INTERVAL, not the bare setting — see
                // INCOME_INTERVAL in script_component.hpp for what a zero does
                // to this loop. FUNC(incomeClockTick) reads it through the same
                // macro so the countdown and the schedule cannot disagree.
                private _interval = INCOME_INTERVAL;
                private _next = CBA_missionTime + _interval;
                (_this select 0) set [0, _next];

                // The schedule otherwise lives only in this PFH's args, so a
                // curator's own machine has no way to know when the next payout
                // lands (see FUNC(incomeClockTick)). The size of the payout does
                // not need publishing — income and incomeInterval are both GLOBAL
                // settings, so every machine can work it out; only the phase is
                // missing, and CBA_missionTime is synchronized.
                //
                // globalEventJIP, NOT publicVariable. This was a bare
                // `publicVariable QGVAR(nextIncome)` under a comment claiming it
                // "also reaches JIP clients". It does not, and the mod's own
                // docs said so (docs/Knowledge Base/Gotchas.md §4): a curator
                // connecting mid-operation read the preInit default of -1 and got
                // a blank countdown until the next payout — up to a full interval
                // of a display that exists to say when the next payout lands.
                //
                // CBA is the proof rather than the Biki, which returns 403 to any
                // scripted fetch: CBA_fnc_globalEventJIP does not use
                // publicVariable for its own JIP stack. It publishes a NETWORKED
                // NAMESPACE once and then writes each entry with
                // `setVariable [id, value, true]` — the object-setVariable public
                // flag, which is the mechanism that does persist for late joiners.
                // If publicVariable reached them, none of that would be needed.
                //
                // One stable JIP id, so each payout OVERWRITES the last rather
                // than stacking an entry per interval for a joiner to replay.
                [QGVAR(nextIncomeAt), [_next], QGVAR(nextIncomeJIP)] call CBA_fnc_globalEventJIP;

                private _points = GVAR(income) * _interval / 60;
                {[_x, _points] call FUNC(addPoints)} forEach allCurators;
            };
        };
    }, TICK_INTERVAL, [0]] call CBA_fnc_addPerFrameHandler;
}] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

// Cost feedback while the curator is choosing something to place. The display
// and its controls are recreated on every open, so these handlers go with them
["zen_curatorDisplayLoaded", {
    params ["_display"];

    // Client-side half of the lazy curator detection the income tick used to do
    // for everyone (see above). FUNC(initCurator) is idempotent, and this is the
    // moment the handler it attaches starts to matter — a module created
    // mid-mission is picked up the next time anyone opens Zeus.
    {_x call FUNC(initCurator)} forEach allCurators;

    {
        (_display displayCtrl _x) ctrlAddEventHandler ["TreeSelChanged", LINKFUNC(placementToast)];
    } forEach IDCS_CREATE_TREES;

    // Countdown to the next income payout in the clock bar's dead mission-countdown slot
    [_display] call FUNC(startIncomeClock);
}] call CBA_fnc_addEventHandler;
