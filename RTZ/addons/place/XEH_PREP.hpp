// Placement session — one keybind-entered mode, on the curator's client only.
// FUNC(togglePlacement) is the keybind handler; everything else is the session's
// own machinery. Every exit routes through FUNC(endPlacement).
PREP(beginPlacement);
PREP(commitPlacement);
PREP(drawGhosts);
PREP(endPlacement);
PREP(handleInput);
PREP(placeTick);
PREP(seedPositions);
PREP(togglePlacement);
