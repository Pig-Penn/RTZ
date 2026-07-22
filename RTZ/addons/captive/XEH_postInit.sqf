#include "script_component.hpp"

// Build stamp — logged on every machine so a stale/mismatched client PBO is visible
// in the RPT. A separate PBO from main; it can be stale independently.
diag_log text format ["[RTZ] captive postInit — version %1, machine [isServer=%2 hasInterface=%3 clientOwner=%4]",
    QUOTE(VERSION_STR), isServer, hasInterface, clientOwner];

// Everything is deferred until CBA_settingsInitialized so the enable read below sees
// the server's synced value (a bare setting read straight from postInit races the
// server->client sync — nil on clients — and a nil `if` aborts the whole postInit).
["CBA_settingsInitialized", {
    if !(GVAR(enableSurrender)) exitWith {};

    // ── CLIENT — capture toast receiver ───────────────────────────────────
    if (hasInterface) then {
        [QGVAR(captureMsg), { _this call zen_common_fnc_showMessage }] call CBA_fnc_addEventHandler;
    };

    // Surrender toggle. The context action (CfgContext.hpp) is client-only; setCaptive /
    // disableAI / the hands-up animation must run where the unit is local — the toggle
    // fires QGVAR(surrenderApply) TARGETED AT EACH UNIT (CBA runs it on the unit's owner:
    // server, HC, or a player's machine for AI in his group), so the handler registers
    // on every machine.
    [QGVAR(surrenderApply), LINKFUNC(surrenderApply)] call CBA_fnc_addEventHandler;

    // ── SERVER — surrendered-unit registry + enemy-capture watch ─────────────
    if (isServer) then {
        GVAR(surrenderedUnits) = [];

        // surrenderApply runs on the unit's OWNER machine (not necessarily the
        // server), so it reports state flips here for the capture watch list.
        [QGVAR(registerSurrender), {
            params ["_unit", "_surrender"];
            if (_surrender) then {
                GVAR(surrenderedUnits) pushBackUnique _unit;
            } else {
                GVAR(surrenderedUnits) = GVAR(surrenderedUnits) - [_unit];
            };
        }] call CBA_fnc_addEventHandler;

        if (GVAR(enableCapture)) then {
            [] call FUNC(captureWatch);
        };
    };
}] call CBA_fnc_addEventHandler;
