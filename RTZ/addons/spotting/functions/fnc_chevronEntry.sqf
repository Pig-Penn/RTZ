#include "script_component.hpp"
/*
 * Author: Maxim
 * Everything one individually-confirmed enemy's chevron needs in order to be drawn:
 * its colour, the display name the hover shows, its officer editing-area zone, and the
 * payload signature that decides whether the client is told about it again.
 *
 * SIDE-INVARIANT, which is why it is a function and why FUNC(spotCheck) memoises the
 * result for the whole tick. WHICH members earn a chevron is very much side-dependent —
 * it falls out of that side's knowsAbout scores and its own latch map — but what a
 * chevron for a given man LOOKS like is a property of the man: his class, his side, his
 * NCO status, whether he has surrendered, whether he is down, and whether he is an
 * officer holding an editing area. A man visible to two hostile curator sides used to
 * have all of it built twice, including two `call`s into cached helpers and three array
 * allocations, once per detection tick for as long as he stayed spotted.
 *
 * The group facts (_mrkrColor, _leaderNetId) are passed in rather than re-derived: a man
 * belongs to exactly one group, so they are the same whichever curator side happens to
 * build his entry first — which is what makes memoising on the member alone correct.
 *
 * Arguments:
 * 0: The spotted man <OBJECT>
 * 1: His netId, already resolved by the group's invariant bundle <STRING>
 * 2: The group's marker colour, the default for a non-NCO <ARRAY>
 * 3: The group's key — the original leader's netId, carried into the signature <STRING>
 * 4: Officer zone map, officerNetId → [plantedCenter, radius] <HASHMAP>
 * 5: Shared read-only empty-array sentinel for the "no zone" case <ARRAY>
 *
 * Return Value:
 * [unit, netId, colour, displayName, zone, payloadSignature] <ARRAY>
 *
 * Example:
 * [_member, _memberId, _mrkrColor, _leaderNetId, _officerZones, _emptyArr] call rtz_spotting_fnc_chevronEntry
 *
 * Public: No
 */

params ["_member", "_memberId", "_mrkrColor", "_leaderNetId", "_officerZones", "_emptyArr"];

([_member] call EFUNC(common,classInfo)) params ["_memberName", "_isLeaderName"];

// NCOs — any unit whose class display name contains "leader" (Squad Leader, Team
// Leader, …) — get the brighter "own-group" palette (EFUNC(common,sideColor) leader
// variant) so leadership reads at a glance.
private _base = if (_isLeaderName)
    then { [side _member, true] call EFUNC(common,sideColor) }
    else { _mrkrColor };
private _wedgeColor = [_base#0, _base#1, _base#2, WEDGE_ALPHA];

// Surrendered (rtz_captive) overrides → white-flag chevron, so a curator can pick the
// men who have given up out of a firefight without hovering them. Captured prisoners
// keep the flag: capture never clears QEGVAR(captive,surrendered).
//
// A SOFT read, like the officer zone map below and rtz_hud's read of
// QEGVAR(orders,flyHeight): a public variable by name, with a false default, so
// rtz_captive being absent is a supported configuration and no requiredAddons edge is
// implied (see config.cpp).
if (_member getVariable [QEGVAR(captive,surrendered), false]) then {
    _wedgeColor = COLOR_SURRENDERED;
};

// Incapacitated (BIS revive / setUnconscious) overrides → civilian-purple chevron.
// Last, so it wins over the surrender flag above: a man who gave up and was then
// dropped anyway is down first and surrendered second.
if (lifeState _member isEqualTo "INCAPACITATED") then {
    _wedgeColor = COLOR_INCAPACITATED;
};

// Officer zone ring: [] for the overwhelming majority (non-officers, or officers with no
// active area) — one O(1) lookup, no extra pass. The [plantedCenter, radius] pair rides
// the wedge payload verbatim and is folded into the signature, so planting, re-planting
// or clearing the area while the officer stays spotted re-sends the wedge and the client
// updates/clears its ring the same tick.
private _zone = _officerZones getOrDefault [_memberId, _emptyArr];

[_member, _memberId, _wedgeColor, _memberName, _zone, [_wedgeColor, _leaderNetId, _zone]]
