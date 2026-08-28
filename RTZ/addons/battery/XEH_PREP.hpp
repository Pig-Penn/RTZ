// Bring-up / teardown, run on every machine and re-run on every setting change.
PREP(startSystem);

// GUN OWNER'S MACHINE — the ArtilleryShellFired handler body.
PREP(detectShot);

// SERVER — the track registry and the fan-out to hostile curators. Curator
// resolution is its own function because both halves need it at different moments:
// the registry to decide whether a track is worth creating at all, the sender to
// re-check after a deferred flush.
PREP(dispatchContact);
PREP(hostileCurators);
PREP(sendContact);

// CURATOR CLIENT — the contact store and its housekeeping.
PREP(receiveContact);
PREP(pruneContacts);

// CURATOR CLIENT — the Zeus map overlay. FUNC(startDisplay) attaching and
// detaching the Draw handler IS the toggle; nothing here re-tests a setting per
// frame (see EFUNC(mine,start) for the same shape).
PREP(contactLabel);
PREP(drawMap);
PREP(startDisplay);
PREP(stopDisplay);

// CURATOR CLIENT — the ZEN context action's two halves.
PREP(displayActionModifier);
PREP(toggleDisplay);
