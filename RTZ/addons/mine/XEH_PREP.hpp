// Place a mine — the context menu children (one per carried mine magazine), the
// order they fire, and the selection resolution both share so the two can never
// disagree about who is carrying what.
PREP(getLayers);
PREP(orderPlace);
PREP(placeActions);

// Place errand — walk the layer over (on EFUNC(common,approach)) and plant.
// Runs where the layer is local.
PREP(placeMine);
PREP(plantMine);

// Clear mines — the context menu entry, its gate, and the group-level sweep.
// The sweep runs where the group is local.
PREP(canDisarm);
PREP(demine);
PREP(getDeminers);
PREP(orderDisarm);

// Spotted-mine markers — a curator-only overlay: one cache refreshed on a slow
// PFH, drawn by whichever of the 3D / map handlers FUNC(start) has registered.
PREP(draw3D);
PREP(drawMap);
PREP(refreshMines);
PREP(start);
PREP(stop);
