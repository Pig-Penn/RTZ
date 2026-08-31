// Detection and routing — the class event handler body (runs wherever the target
// is local), the server hop that resolves who owns the target, and the curator
// client's receiver.
PREP(detectIncoming);
PREP(reportIncoming);
PREP(receiveIncoming);

// Curator overlay — one prune shared by both draw passes, the 3D marker on
// rtz_core's frame loop, the Zeus map marker, and the idempotent start/stop that
// registers whichever of the two their settings ask for.
PREP(draw3D);
PREP(drawMap);
PREP(pruneTracked);
PREP(start);
PREP(stop);
