// Incoming missiles — detection and routing. The class event handler body (runs
// wherever the target is local) and the server hop that resolves who owns the target.
PREP(detectIncoming);
PREP(reportIncoming);

// Incoming grenades — the same two stages for ZEN's curator-ordered throws. They are
// separate functions rather than branches in the missile pair because they share no
// step: a different event, a different discriminator, and ownership resolved from a
// POSITION rather than from a target object.
PREP(detectGrenade);
PREP(reportGrenade);

// What the two halves DO share, and what used to be duplicated verbatim between
// them: one client receiver over one store, one memoized CfgAmmo verdict cache, one
// server-side coalescing window.
PREP(receiveTrack);
PREP(ammoVerdict);
PREP(claimWindow);

// Curator overlay — one prune shared by both draw passes, the 3D marker on
// rtz_core's frame loop, the Zeus map marker, and the idempotent start/stop that
// registers whichever of the two their settings ask for.
PREP(draw3D);
PREP(drawMap);
PREP(pruneTracked);
PREP(start);
PREP(stop);
