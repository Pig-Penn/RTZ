// Stream engine — one client half, one server half, shared by every overlay.
PREP(streamClient);
PREP(streamServer);

// Per-stream server gatherers: hull -> one snapshot entry (or [] to skip).
PREP(gatherDestination);
PREP(gatherTarget);

// Per-stream client renderers: bake a fresh snapshot once, then draw it each
// frame from the shared frame context.
PREP(drawDestination);
PREP(drawTarget);

// Shared context-action halves, parameterised by stream id.
PREP(overlayActionModifier);
PREP(toggleOverlay);
