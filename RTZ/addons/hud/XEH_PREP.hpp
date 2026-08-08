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
// drawSpots / drawRcIndicator are NOT here — they belong to rtz_spotting, which
// owns the stores they read and registers them itself. Keeping them here made
// the two components mutually dependent while only one direction was declared.
PREP(drawUnitTags);
PREP(drawVehicleTags);
PREP(drawDestination);
PREP(drawTarget);

// ── Head-tag systems ─────────────────────────────────────────────────────────
// ONE mechanism with two declarations (XEH_postInit), not two implementations —
// FUNC(unitTags) and FUNC(vehicleTags) were near-identical start functions whose
// per-system globals every consumer then had to read behind `isNil` guards.
PREP(startTagSystem);
PREP(applyTagVisibility);
PREP(markTagsDirty);
PREP(toggleTags);
PREP(tagsContext);

// ── Selection info dialog ────────────────────────────────────────────────────
// openSelectionInfo creates it and grabs its controls; selectionTick keeps it
// live; applySelectionRows writes a built model into the listbox;
// releaseSelectionInfo is the one teardown all five close paths route through.
PREP(openSelectionInfo);
PREP(selectionTick);
PREP(applySelectionRows);
PREP(releaseSelectionInfo);

// The row model: buildSelectionRows owns the STRUCTURE (bucketing, ordering, the
// key list) and the four below own what each line says. They were inline closures
// rebuilt on every call, and this model is rebuilt four times a second for as
// long as the dialog is open.
PREP(buildSelectionRows);
PREP(selectionHeader);
PREP(selectionRow);
PREP(selectionTooltip);
PREP(groupDescriptor);
PREP(joinRow);
PREP(unitCount);

// ── Presentation helpers ─────────────────────────────────────────────────────
// The two entry builders differ in which fields they collect and not at all in
// what they do with them, so the shared tail and the shared draw live once:
// tagEntryTail composes and measures the line, drawTagLine renders it with the
// status word split off in its own colour, tagAnchor resolves what either kind of
// entity hangs its tag above.
PREP(buildTagEntry);
PREP(buildVtagEntry);
PREP(tagEntryTail);
PREP(drawTagLine);
PREP(tagAnchor);
PREP(loadTagLabels);
PREP(textWidth);
