// NOTE: the frame loop, the renderer registry and the stream engine are NOT here.
// They belong to rtz_core; this component is one of their consumers. It declares
// streams (XEH_postInit) and registers renderers (FUNC(applyTagVisibility)) like
// any other addon does.

// ── Per-stream server gatherers: one slice entry -> one snapshot entry ───────
PREP(gatherUnitInfo);
PREP(gatherVehicleInfo);
PREP(gatherDestination);
PREP(gatherTarget);

// ── Per-stream client receivers: one snapshot -> the store its display reads ─
// Registered with the stream (EFUNC(core,registerStream)) and dispatched blindly by
// EFUNC(core,streamClient); receiveOverlay is the default for any stream that does not
// name one. These were `case` branches inside streamClient, which is what made
// the shared engine know the ids of specific displays.
PREP(receiveUnitData);
PREP(receiveVehicleData);

// ── Renderers ────────────────────────────────────────────────────────────────
// drawSpots / drawRcIndicator are registered by rtz_spotting, which owns their
// data; they live here because this component owns the drawing.
PREP(drawUnitTags);
PREP(drawVehicleTags);
PREP(drawDestination);
PREP(drawTarget);
PREP(drawSpots);
PREP(drawRcIndicator);

// ── Display start-up + runtime toggles ───────────────────────────────────────
PREP(unitTags);
PREP(vehicleTags);
PREP(applyTagVisibility);
PREP(toggleTags);
PREP(tagsContext);

// ── Selection info dialog ────────────────────────────────────────────────────
PREP(openSelectionInfo);
PREP(buildSelectionRows);

// ── Presentation helpers ─────────────────────────────────────────────────────
PREP(buildTagEntry);
PREP(buildVtagEntry);
PREP(loadTagLabels);
PREP(textWidth);
