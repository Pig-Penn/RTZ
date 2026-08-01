// Gate predicate — resolves a row's target scope against the curator's
// editing areas, cached per frame.
PREP(canEdit);

// Registry snapshot taken once at postInit: which ZEN attribute rows are
// servicing rows, and what each one writes to.
PREP(initGate);

// Per-window install (gui.hpp hook control) and the per-row confirm hook it
// leaves behind, which is where a refused edit is actually stopped.
PREP(gateDisplay);
PREP(onConfirm);
