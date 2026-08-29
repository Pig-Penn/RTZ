private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// GLOBAL, not client-local. The two halves of this component run on DIFFERENT
// machines — FUNC(detectShot) wherever the firing gun is local, FUNC(dispatchContact)
// on the server — and if they disagreed a gun owner's machine would keep reporting
// shots to a server that has no receiver registered for them. rtz_airstrike and
// rtz_path carry the same hazard and resolve it the same way.
//
// Default OFF. Counter-battery materially changes PvP balance — it is what makes a
// parked battery die — and no mission should acquire that merely by upgrading the mod.
[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;

// Read on the SERVER only (FUNC(dispatchContact) rolls the offset there and sends
// the displaced centre), so Global is what keeps one authoritative fuzz for every
// curator rather than a value each client could disagree about — the true gun
// position never crosses the wire, and this setting is why.
[
    QGVAR(originRadius), "SLIDER",
    [LSTRING(OriginRadius), LSTRING(OriginRadius_Description)],
    _category,
    [50, 1000, 250, 0],
    true // Global
] call CBA_fnc_addSetting;

// Same treatment for the incoming-impact ring. 0 puts the ring exactly on the
// predicted splash point.
[
    QGVAR(incomingRadius), "SLIDER",
    [LSTRING(IncomingRadius), LSTRING(IncomingRadius_Description)],
    _category,
    [0, 500, 150, 0],
    true // Global
] call CBA_fnc_addSetting;

// Read on BOTH sides: the server's re-roll test (a track older than this gets a
// fresh offset rather than the stale one) and the client's prune. Global so the two
// cannot disagree about when a contact stops existing.
[
    QGVAR(contactLifetime), "SLIDER",
    [LSTRING(ContactLifetime), LSTRING(ContactLifetime_Description)],
    _category,
    [30, 1800, 300, 0],
    true // Global
] call CBA_fnc_addSetting;

// Purely a per-curator draw preference, read inside FUNC(drawMap)'s incoming pass —
// so Local, and no re-registration is needed when it changes.
[
    QGVAR(showIncoming), "CHECKBOX",
    [LSTRING(ShowIncoming), LSTRING(ShowIncoming_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;

// The outgoing half, and deliberately NOT gated on GVAR(enabled) above: that one
// governs counter-battery detection, is Global and defaults OFF, so sharing it
// would hide this action on every stock server for a reason that has nothing to do
// with it.
//
// Local, unlike detection's pair of machines: everything up to the moment the guns
// are told to fire happens on the one curator's client — the condition, the picker,
// ZEN's dialog — and the order itself crosses the wire as ZEN's own
// zen_common_fireArtillery target event, which does not consult this setting.
// Default ON because it replaces a ZEN entry that was on by default.
[
    QGVAR(enableFireMission), "CHECKBOX",
    [LSTRING(EnableFireMission), LSTRING(EnableFireMission_Description)],
    _category,
    true,
    false // Local
] call CBA_fnc_addSetting;
