#include "script_component.hpp"
/*
 * Author: Maxim
 * Everything about how one spotted group is DRAWN that does not depend on who is
 * looking at it: the anchor the group icon hangs over, its NATO symbol, colour, side
 * index and echelon amplifier, whether it draws a group icon at all, and its members'
 * netIds. Returns the INV_* bundle FUNC(spotCheck) caches in the group tuple's GRP_INV
 * slot.
 *
 * WHY IT IS A FUNCTION AND NOT INLINE. FUNC(spotCheck)'s detection loop runs per group
 * PER CURATOR SIDE, and all of this ran inside it — a `findIf` with an
 * EFUNC(common,classInfo) call per member, a `count` with an `isKindOf` per member,
 * FUNC(unitMarker) and FUNC(echelonTex). None of those asks anything about the
 * OBSERVER: which group an entity is in, how many men it holds, whether it is a
 * command element and what symbol it takes are the same answers for every side that
 * can see it. This is called once per group per tick and every later curator side
 * reads the result back.
 *
 * LAZY BY DESIGN — see the INV_* block in script_component.hpp. Building this in
 * FUNC(collectSides) instead would pay a classInfo call per member for every group in
 * the mission, including the majority that are out of contact and never scored.
 *
 * The one member-count subtlety, carried over from the code this replaces: GRP_MEN
 * counts MEN only. A crewed hull rides in the member list alongside its crew, so
 * counting raw members reads a 3-man tank crew as 4 and skews the echelon amplifier
 * for every mechanised group. FUNC(collectSides) increments it only in the allUnits
 * loop, where every entry is a CAManBase by construction.
 *
 * Arguments:
 * 0: Group tuple, GRP_* indices — read only, never mutated here <ARRAY>
 *
 * Return Value:
 * Side-invariant render bundle, INV_* indices <ARRAY>
 *
 * Example:
 * private _inv = [_tuple] call rtz_spotting_fnc_groupInvariants
 *
 * Public: No
 */

params ["_tuple"];
_tuple params ["_leader", "_members", "", "_menCount", "_leaderInMembers"];

// The group leader is not necessarily a SPOTTABLE entity: the hostile buckets exclude
// players and simulation-disabled units, but the grouping keys on `leader group`, so an
// AI squad led by a player reports the PLAYER as its leader. Anchoring the group icon on
// him would track a player's exact position for the enemy Zeus every frame (and seed the
// callout's location lookup) — precisely what the isPlayer filter exists to prevent, and
// not something his chevron-less members ever reveal. Fall back to a member that
// genuinely is spotted, preferring a MAN: a crewed hull rides in the members alongside
// its crew, and anchoring on the man both classifies correctly (FUNC(unitMarker),
// FUNC(contactCategory)) and still renders on the hull, since FUNC(drawSpots) anchors
// every icon on `vehicle _unit`. findIf returns -1 when the group is men-less (a UAV),
// where index 0 — the hull — is what we want.
//
// GRP_KEY keeps the ORIGINAL leader's netId as the group key, so chevron→group
// association (the hover peek in FUNC(drawSpots)) and the callout last-seen gate are
// unaffected; the anchor itself rides in the payload signature.
//
// GRP_LDRIN is set at bucket time by a single isEqualTo against the member being pushed,
// which replaces an O(members) `in` scan run once per group per curator side.
if (!_leaderInMembers) then {
    _leader = _members select ((_members findIf { _x isKindOf "CAManBase" }) max 0);
};

// HQ: any member whose class display name says "officer" / "HQ" makes the whole group a
// command element, so the group frame becomes the staff symbol. classInfo is a
// mission-long per-class memo, but it is still a `call` and a `typeOf` per member.
private _isHQ = -1 < _members findIf { ([_x] call EFUNC(common,classInfo)) select 2 };

// Classify once; the colour is the side colour, shared by the group icon and every
// chevron built from this group.
([_leader, _isHQ] call FUNC(unitMarker)) params ["_leaderTex", "_mrkrColor", "_sideIdx"];

// Group icon. Drawn for groups of >1 man, OR whenever the anchor is in a vehicle (a
// single-crewed vehicle is still worth marking), OR whenever the anchor IS a vehicle —
// a hull whose crew never reach the members because they are absent from allUnits (a
// UAV). A lone infantryman shows no group icon; his chevron still marks him.
private _drawGroup = (_menCount > 1)
    || { !isNull objectParent _leader }
    || { !(_leader isKindOf "CAManBase") };

[
    _leader,
    netId _leader,
    _leaderTex,
    _mrkrColor,
    _sideIdx,
    [_leader, _menCount] call FUNC(echelonTex),   // size amplifier
    _drawGroup,
    // One netId per member, parallel to GRP_MEMBERS. The member loop in FUNC(spotCheck)
    // needs one for every alive member and used to spend the engine call once per
    // curator side; a netId is fixed for the life of the object, so it is resolved here
    // with the rest of the group's invariants.
    _members apply { netId _x }
]
