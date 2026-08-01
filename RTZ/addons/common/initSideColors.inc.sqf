// Canonical RTZ side palette, built once per machine at preInit and served by
// FUNC(sideColor). Two index-parallel rows — [normal, leader] — so a lookup is
// `GVAR(sideColors) select _isLeader select _index`, with no per-call array
// construction. It is read per-unit-per-frame by the spotting markers, the
// target overlay and the remote-control indicator, so the arrays below are
// handed out as SHARED references: callers must treat them as read-only and
// build a copy (`_rgb + [_alpha]`, `select [0, 3]`, …) if they need to vary
// one.
//
// GVAR(sideColorOrder) fixes the column order; any side not listed falls to
// SIDE_COLOR_DEFAULT (civilian), which is why that entry is last.
GVAR(sideColorOrder) = [west, east, independent, sideUnknown];

GVAR(sideColors) = [
    // Standard palette
    [
        [0.00, 0.30, 0.60, 1.00], // west
        [0.50, 0.00, 0.00, 1.00], // east
        [0.00, 0.50, 0.00, 1.00], // independent
        [0.80, 0.80, 0.00, 1.00], // sideUnknown: yellow (Arma convention, e.g. unidentified UAV contacts)
        // Civilian: purple, the darker sibling of the leader palette's default —
        // previously duplicated independent's green, making civilian and
        // independent markers indistinguishable
        [0.40, 0.00, 0.50, 1.00]  // civilian / anything else
    ],
    // Leader palette — the brighter "own-group" set used for NCOs, i.e. units
    // whose class display name contains "leader" (see FUNC(classInfo)), so
    // leadership reads at a glance
    [
        [0.00, 0.45, 1.00, 1.00], // west
        [0.80, 0.35, 0.00, 1.00], // east
        [0.34, 0.75, 0.00, 1.00], // independent
        [1.00, 1.00, 0.00, 1.00], // sideUnknown
        [0.70, 0.00, 0.75, 1.00]  // civilian / anything else
    ]
];
