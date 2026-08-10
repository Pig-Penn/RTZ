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

// Arsenal restriction. Its own setting, its own predicate — every arsenal
// surface acts on one entity rather than on a selection scope.
PREP(canEditEntity);

// One gate per curator entry point into the arsenal: the context menu's
// Loadout condition and statement, and ZEN's Zeus module. The Object display's
// Arsenal button is gated in FUNC(initGate) alongside Damage.
PREP(canEditLoadout);
PREP(openArsenal);
PREP(moduleArsenal);
