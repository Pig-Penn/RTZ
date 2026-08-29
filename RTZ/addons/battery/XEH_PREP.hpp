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

// CURATOR CLIENT — the outgoing fire mission action. FUNC(fireMissionGuns) is its
// own function rather than inlined because both halves need the same answer at
// different moments: the condition to decide whether the entry appears at all, the
// statement to decide the anchor and which guns the picker draws lines from.
PREP(fireMissionGuns);
PREP(canFireMission);
PREP(selectFireMission);

// CURATOR CLIENT — the two ZEN overrides the action installs, each resolved from a
// `function` config entry rather than called by RTZ (CfgVehicles.hpp and gui.hpp).
// Both delegate to ZEN once they have done their one piece of work, so a curator who
// reaches either the Create Target module or the fire mission dialog by ZEN's own
// route sees stock behaviour.
PREP(createTarget);
PREP(guiFireMission);

// ANY MACHINE — the target cleanup, PREP'd everywhere because the target logic can
// end up local to a machine that has no curator on it.
PREP(discardTarget);
