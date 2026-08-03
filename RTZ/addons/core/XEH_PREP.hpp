// ── Frame pipeline ───────────────────────────────────────────────────────────
// ONE Draw3D handler for every curator-view display in RTZ; any component
// registers a renderer with it rather than adding a handler of its own.
PREP(frameLoop);
PREP(registerRenderer);
PREP(unregisterRenderer);

// ── Stream engine ────────────────────────────────────────────────────────────
// ONE client selection poll, ONE server watcher registry and poll loop, ONE
// snapshot receiver — shared by every curator data feed, in this component or
// any other. A stream declares BOTH halves through registerStream.
PREP(selectionPoll);
PREP(streamClient);
PREP(streamServer);
PREP(registerStream);
PREP(setDemand);

// Default snapshot receiver: store raw, let the draw function bake it lazily.
// A stream that wants its snapshot unpacked differently names its own.
PREP(receiveOverlay);

// ── Shared overlay-toggle halves ─────────────────────────────────────────────
// Statement and modifierFunction for every toggleable overlay stream, in any
// component. Both read the stream's registered wording, so neither knows which
// overlays exist.
PREP(toggleOverlay);
PREP(overlayActionModifier);
