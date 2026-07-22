#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is visible
// in the RPT. A separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] casualty postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Everything is deferred until CBA_settingsInitialized so the enable read below sees
// the server's synced value (a bare setting read straight from postInit races the
// server->client sync — nil on clients — and a nil `if` aborts the whole postInit).
["CBA_settingsInitialized", {
    // Opt-in master switch. When off, NOTHING below runs: no HandleDamage handlers are
    // attached, no client draw handler, no context action condition passes — the
    // feature is truly inert.
    if !(GVAR(enable)) exitWith {};

    // ── CLIENT — casualty indicator + Medical Zone module ─────────────────────
    if (hasInterface) then {
        [] call FUNC(casualtyIndicator);      // Draw3D marker + sync/toast receivers
        [] call FUNC(registerMedicalZone);    // "Medical Zone" Zeus module → safe-zone marker
    };

    // moveInCargo must run where the casualty is local — NOT necessarily the
    // server: AI in a player-led group is local to that player's machine.
    // FUNC(loadCasualtyApply) (server-only, below) targets this at the casualty.
    [QGVAR(loadCasualtyMoveIn), LINKFUNC(loadCasualtyMoveIn)] call CBA_fnc_addEventHandler;

    // ── SERVER — authoritative roll, tracking, evacuation handler ─────────────
    if (isServer) then {
        GVAR(casualties)    = createHashMap;   // unit netId -> [unit, bleedoutDeadline, state]
        GVAR(casualtyOwner) = createHashMap;   // unit netId -> owning curator netId ("" if none)
        GVAR(medZones)      = createHashMap;   // zone id  -> [pos2D, radius, ownerCuratorNetId]
        GVAR(managerHandle) = -1;              // CBA PFH id, or -1 while idle (no casualties)

        [QGVAR(loadCasualty), LINKFUNC(loadCasualtyApply)] call CBA_fnc_addEventHandler;
        [QGVAR(zoneApply),    LINKFUNC(medZoneApply)] call CBA_fnc_addEventHandler;

        // Attach a RAW HandleDamage EH to every current & future infantryman on this
        // machine. CBA has no HandleDamage class EH (its return-value semantics don't
        // fit XEH aggregation — Extended_HandleDamage is commented out in CBA), so we
        // ride the "init" class EH and add the engine handler ourselves. Only where the
        // unit is local (the server, for AI) and never on players — the handler's return
        // value only affects damage on the local machine, and players use their own
        // respawn/medical path. `true` retroactive covers units already spawned.
        ["CAManBase", "init", {
            params ["_unit"];
            if (!local _unit || {isPlayer _unit}) exitWith {};
            _unit addEventHandler ["HandleDamage", LINKFUNC(handleLethalDamage)];
        }, true, [], true] call CBA_fnc_addClassEventHandler;
    };
}] call CBA_fnc_addEventHandler;
