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

// Shared per-class config lookups, each cached mission-long.
PREP(classInfo);
PREP(magazineCapacity);

// Shared UI / presentation helpers.
PREP(notifyCurator);
PREP(removeContextActions);
PREP(showCountMessage);
PREP(sideColor);
