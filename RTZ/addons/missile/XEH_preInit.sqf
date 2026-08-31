#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Live tracks on this curator's client, newest last. See the REC_* indices in
// script_component.hpp; FUNC(pruneTracked) owns the ageing, both draw passes only
// read.
GVAR(tracked) = [];

// Zeus map Draw handler id. The control it sits on belongs to the curator display
// and is never stored — controls are not serializable, and one left in the mission
// namespace trips an engine warning on save — so FUNC(start) re-resolves it. The
// id is dropped when the display closes so the next one re-attaches.
GVAR(mapEH) = -1;

// Ammo classname -> is it a guided missile, filled lazily by FUNC(detectIncoming).
// Defined on every machine, not just curator clients: the detection gate runs
// wherever the threatened unit is local. The config read happens once per ammo
// type ever seen, never once per launch.
GVAR(guidedAmmo) = createHashMap;

// Server-side coalescing window, netId of the target -> absolute expiry.
// Meaningless off the server, but a bare createHashMap costs nothing.
GVAR(recent) = createHashMap;

#include "initSettings.inc.sqf"

ADDON = true;
