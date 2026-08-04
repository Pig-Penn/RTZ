#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens a route planning session for the current Zeus selection: seeds one route
 * record per routable entity, installs the mode's input handlers and starts its
 * tick.
 *
 * Entirely client-local. Nothing is broadcast and nothing is authoritative until
 * the session is committed — the curator owns the selection and the cursor, so
 * there is no reason for the server to hear about a route being drawn.
 *
 * Selection is normalized through EFUNC(common,collectUnits) and
 * EFUNC(common,collectVehicles) rather than read raw: a Zeus selection can hand
 * back groups and waypoints as well as objects, and clicking a crewman should
 * plan the vehicle he is riding in, matching every other RTZ vehicle order. The
 * two collectors cannot double-count — a selected vehicle's crew arrives via the
 * first and is dropped by the on-foot test.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * A session was opened <BOOL>
 *
 * Example:
 * call rtz_route_fnc_beginPlanning
 *
 * Public: No
 */

private _display = findDisplay IDD_RSCDISPLAYCURATOR;
if (isNull _display) exitWith {false};

private _selection = SELECTED_OBJECTS;
private _hulls = [];

// Men on foot contribute themselves. Crew of a selected vehicle also arrive
// here and are dropped by the objectParent test — they are routed as their
// vehicle by the collector below instead.
{
    if (isNull objectParent _x) then {
        _hulls pushBackUnique _x;
    };
} forEach ([_selection] call EFUNC(common,collectUnits));

// Selected vehicles, and the vehicle a selected crewman is riding in
{
    _hulls pushBackUnique _x;
} forEach ([_selection] call EFUNC(common,collectVehicles));

private _routes = [];
private _palette = GVAR(palette);
private _paletteSize = count _palette;

{
    // Tested at the TOP of the body: a `break` at the bottom still pays for the
    // whole iteration it is meant to skip (Gotchas §2).
    if (count _routes >= MAX_ROUTES) then {break};

    private _hull = _x;
    private _kind = [_hull] call FUNC(routeKind);
    if (_kind == KIND_NONE) then {continue};

    // Who receives the order: the man himself, or the vehicle's driver. The hull
    // is what moves and what the geometry tests measure against.
    private _unit = if (_kind == KIND_INFANTRY) then {_hull} else {driver _hull};

    // Resolved once, here, and carried in the record. Both renderers draw it
    // every frame; Wargame rebuilds its equivalent with a `str` per handle per
    // frame, in each of its two draw routines.
    private _label = if (_kind == KIND_INFANTRY) then {
        name _unit
    } else {
        ([_hull] call EFUNC(common,classInfo)) select 0
    };

    _routes pushBack [
        _unit,
        _hull,
        [],
        _palette select ((count _routes) mod _paletteSize),
        _kind,
        getPosASL _hull,
        getDir _hull,
        _label,
        // Seeded from where the aircraft already is, so the readout is right
        // before anything has been drawn. Kept current by FUNC(appendPoint).
        if (_kind == KIND_AIR) then {
            format ["%1 m", round (getPosATL _hull select 2)]
        } else {
            ""
        },
        0,        // ROUTE_SEARCH — no auto-path search outstanding
        objNull   // ROUTE_LEADER — not trailing anything
    ];
} forEach _hulls;

if (_routes isEqualTo []) exitWith {
    // Reported rather than failing silently: this mode is modal, so a press that
    // changes nothing and says nothing reads as a broken keybind. The press is
    // still passed through (false) — nothing was consumed.
    [LLSTRING(MsgNoneRoutable)] call EFUNC(common,showCountMessage);
    false
};

GVAR(routes) = _routes;
GVAR(planning) = true;
GVAR(grabbed) = objNull;
GVAR(hovered) = objNull;
GVAR(hoveredPoint) = [];
GVAR(mods) = [false, false, false];

GVAR(inputEHs) = [_display] call FUNC(handleInput);

// The 3D half goes on rtz_core's shared frame loop rather than a Draw3D handler
// of its own — registering and unregistering with the mode is what makes it free
// while no session is open. Priority puts it over the mine and supply overlays:
// while a route is being traced it is the thing being interacted with.
[QGVAR(routes3D), LINKFUNC(drawRoutes), RENDER_WORLD, 65] call EFUNC(core,registerRenderer);

// The map half, attached by id so ZEN's own Draw handlers on the same control
// survive the detach
private _mapCtrl = _display displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP;
if (!isNull _mapCtrl) then {
    GVAR(mapEH) = _mapCtrl ctrlAddEventHandler ["Draw", {_this call FUNC(drawRoutesMap)}];
};

// Args carry the prune clock; see FUNC(planTick). Runs every frame because
// tracing a path is a per-frame sample of the cursor — everything in the tick
// that is not that is throttled inside it.
GVAR(planPfh) = [LINKFUNC(planTick), 0, [0, getMousePosition]] call CBA_fnc_addPerFrameHandler;

// Optional soft hold so the selection does not walk out from under the routes
// being drawn for it. doStop, NOT Wargame's disableAI "PATH": disabling PATH
// would make FUNC(routeKind) reject the very units this froze, and doStop is
// what the executor issues first anyway, so freezing and executing compose
// instead of fighting. Released by FUNC(endPlanning) on either exit path.
// Which units were held is RECORDED, not re-derived on the way out: an admin
// toggling the setting mid-session would otherwise leave them stopped forever.
GVAR(held) = [];
if (GETGVAR(freezeWhilePlanning,false)) then {
    {
        private _unit = _x select ROUTE_UNIT;
        GVAR(held) pushBack _unit;
        [QGVAR(hold), [_unit, true], _unit] call CBA_fnc_targetEvent;
    } forEach _routes;
};

[LLSTRING(MsgPlanning), count _routes] call EFUNC(common,showCountMessage);

true
