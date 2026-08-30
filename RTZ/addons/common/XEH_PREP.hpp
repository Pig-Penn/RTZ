// Selection normalizers — expand a raw ZEN selection into a flat, unique list
// of units / groups / vehicles. Every RTZ entry point goes through these.
PREP(collectSpecialists);
PREP(collectSquads);
PREP(collectUnits);
PREP(collectVehicles);

// Errand engine — the shared walk-there-then-do-something machinery behind
// rtz_assemble, rtz_mine, rtz_loot and rtz_repair, the timed-work loop the
// arrival hooks hand off to (rtz_repair, rtz_supply), plus the curator
// ownership it needs to hand freshly spawned objects back to Zeus.
PREP(approach);
PREP(clearErrand);
PREP(curatorsOf);
PREP(errandToken);
PREP(grantCurators);
PREP(progressJob);

// Surface tracing — "what can something stand on here". FUNC(cursorSurface)
// answers for the point the curator is aiming at; FUNC(surfaceStack) answers for
// a vertical column at an arbitrary x/y and hands back every floor in it.
PREP(cursorSurface);
PREP(surfaceStack);

// Shared per-class config lookups, each cached mission-long.
PREP(classInfo);
PREP(magazineCapacity);

// Shared UI / presentation helpers.
PREP(drawZeusIcon);
PREP(notifyCurator);
PREP(placementPreview);
PREP(regroupVehicleActions);
PREP(removeContextActions);
PREP(showCountMessage);
PREP(sideColor);
