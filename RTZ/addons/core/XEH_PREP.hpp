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

// The ONE place the subscription payload's rules live — which slices a consumer
// has demanded, and the hull gate. Both senders (the poll's tick and reportNow)
// go through it, because the two hand-written copies it replaced were required to
// agree and eventually would not have.
PREP(buildReport);

// "The server's picture of me is stale, send it again now." The ONE supported way
// to force a re-subscription — consumers never build the payload or touch the
// poll's diff baseline themselves.
PREP(reportNow);

// Default snapshot receiver: store raw, let the draw function bake it lazily.
// A stream that wants its snapshot unpacked differently names its own.
PREP(receiveOverlay);

// ── Shared overlay-toggle halves ─────────────────────────────────────────────
// Statement and modifierFunction for every toggleable overlay stream, in any
// component. Both read the stream's registered wording, so neither knows which
// overlays exist.
PREP(toggleOverlay);
PREP(overlayActionModifier);
