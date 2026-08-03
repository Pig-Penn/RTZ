// ── Frame pipeline ───────────────────────────────────────────────────────────
// ONE Draw3D handler for every curator-view display in RTZ; any component
// registers a renderer with it rather than adding a handler of its own.
PREP(frameLoop);
PREP(registerRenderer);
PREP(unregisterRenderer);

// ── Stream engine ────────────────────────────────────────────────────────────
// ONE client selection poll, ONE server watcher registry and poll loop, ONE
// snapshot receiver — shared by every curator data feed.
PREP(selectionPoll);
PREP(streamClient);
PREP(streamServer);
PREP(registerStream);

// ── Per-stream server gatherers: one slice entry -> one snapshot entry ───────
PREP(gatherUnitInfo);
PREP(gatherVehicleInfo);
PREP(gatherDestination);
PREP(gatherTarget);

// ── Per-stream client receivers: one snapshot -> the store its display reads ─
// Registered with the stream (FUNC(registerStream)) and dispatched blindly by
// FUNC(streamClient); receiveOverlay is the default for any stream that does not
// name one. These were `case` branches inside streamClient, which is what made
// the shared engine know the ids of specific displays.
PREP(receiveOverlay);
PREP(receiveUnitData);
PREP(receiveVehicleData);

// ── Renderers ────────────────────────────────────────────────────────────────
// drawSpots / drawRcIndicator are registered by rtz_spotting, which owns their
// data; they live here because this component owns the drawing.
PREP(drawUnitTags);
PREP(drawVehicleTags);
PREP(drawVehicleCards);
PREP(drawVehicleLinks);
PREP(drawDestination);
PREP(drawTarget);
PREP(drawSpots);
PREP(drawRcIndicator);

// ── Display start-up + runtime toggles ───────────────────────────────────────
PREP(unitTags);
PREP(vehicleTags);
PREP(vehicleOverlay);
PREP(applyTagVisibility);
PREP(toggleTags);
PREP(toggleVehicleCards);
PREP(toggleOverlay);
PREP(tagsContext);
PREP(overlayActionModifier);

// ── Selection info dialog ────────────────────────────────────────────────────
PREP(openSelectionInfo);
PREP(buildSelectionRows);

// ── Presentation helpers ─────────────────────────────────────────────────────
PREP(buildTagEntry);
PREP(buildVtagEntry);
PREP(vehicleCardCreate);
PREP(vehicleCardBody);
PREP(vehicleCardLayout);
PREP(loadTagLabels);
PREP(textWidth);
