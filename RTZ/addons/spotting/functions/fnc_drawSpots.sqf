#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the spotting picture: group icons (pass 1, each on a
 * stem down to its leader as the basegame's own Zeus icons are) and individual
 * chevrons (pass 2) above spotted enemies in the Zeus cursor view.
 * Positions are sampled live from the unit each frame so icons track smoothly
 * between the server's spot cycles; texture, colour, echelon amplifier, side
 * index and display name are all pre-resolved server-side.
 *
 * Lives in this component because this component owns the DATA: FUNC(spotCheck)
 * decides what is spotted and FUNC(spottingClient) keeps the stores below
 * current. It used to sit in rtz_hud on the reasoning that rtz_hud owns every
 * display — but reading seven of this component's globals from over there made
 * the two addons mutually dependent (rtz_spotting required rtz_hud to register
 * the renderer, rtz_hud needed rtz_spotting's stores to run it) while only one
 * direction was ever declared, leaving their load order undefined. rtz_supply
 * and rtz_mine already own their own renderers; this follows them.
 *
 * Registered with EFUNC(core,frameLoop), which resolves the Zeus test, the camera
 * position and the mouse position once for every display — this pass does no
 * camera query of its own, and is skipped entirely while the Zeus map is up.
 *
 * TWO PHASES, because the stores are unbounded. GVAR(spotChevrons) holds one entry per
 * individually-identified enemy man with no cap anywhere in the chain, and this used to
 * walk every entry EVERY FRAME, paying `alive` + `vehicle` + `isNull` + `distance` before
 * it could decide an icon was out of range and skip it. At a few hundred spotted enemies
 * that is thousands of engine calls a frame to draw the few dozen chevrons actually
 * within CHEVRON_MAX_DIST — and on the listen server this mod runs on, that machine is
 * also running the detection pass.
 *
 *   BROAD  — every CULL_INTERVAL seconds. Walks the stores, runs the alive/null-anchor
 *            tests once, resolves each anchor once, and sorts the survivors into three
 *            compact stores (see below).
 *   NARROW — every frame. Iterates only those, and RE-READS the camera distance from the
 *            live anchor. Distance is deliberately NOT cached by the broad phase: the
 *            fade alpha and the group icon's height offset are both functions of it, and
 *            a cached one would make them step 5 times a second as the camera moves.
 *
 * What is throttled is only which icons are CANDIDATES. A chevron can therefore appear or
 * disappear up to CULL_INTERVAL late when the camera crosses a cutoff or a unit dies —
 * invisible against the 1-10 s server detection interval that already gates it, and a new
 * contact does not wait at all, because FUNC(spottingClient) invalidates the phase on
 * spotDetected/spotLost.
 *
 * Distance/size tunables (WEDGE_MAX_DIST, CHEVRON_MAX_DIST, CULL_INTERVAL, CULL_SLACK,
 * CHEVRON_W_NEAR/FAR, HOVER_MAX_DIST, HOVER_HIT_R2, GROUP_HOVER_R2, AMP_GAPS_WORLD,
 * GROUP_ZMOD_*) are #defined in script_component.hpp.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in script_component.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_spotting_fnc_drawSpots
 *
 * Public: No
 */

params ["_ctx"];

// Empty-store test first: cheapest check and the common case on a quiet mission.
if (count GVAR(spotGroups) == 0 && { count GVAR(spotChevrons) == 0 }) exitWith {};

private _camPos   = _ctx select CTX_CAMPOS;
// Camera-up unit vector in world space — the axis the echelon amplifier's gap above
// the group icon rides. See the note at _ampPos for why that gap cannot be a world
// +Z lift.
private _camUp    = _ctx select CTX_CAMUP;
private _mousePos = _ctx select CTX_MOUSE;
private _viewDist = _ctx select CTX_VIEWDIST;
// The frame loop's clock, for the broad-phase throttle only. Kept distinct from the
// blink's `_now` below, which is `time`: GVAR(blinkUntil) is stamped from `time` by the
// QGVAR(blink) receiver, and CTX_NOW is CBA_missionTime — the two run at different rates
// under time acceleration and comparing across them would leave chevrons stuck white.
private _clock = _ctx select CTX_NOW;

// ── Broad phase ─────────────────────────────────────────────────────────────
// Re-derives the candidate sets on its own throttle. GVAR(cullAt) is set to -1 by the
// spotDetected / spotLost receivers (FUNC(spottingClient)) so a contact appearing or
// vanishing is picked up on the very next frame rather than waiting out the interval.
//
// Chevron candidates are split in two, and that split is the whole reason this pays:
//   GVAR(spotChevronsVisible) — inside CHEVRON_MAX_DIST + CULL_SLACK. Drawn every frame.
//   GVAR(spotChevronsPeek)    — leaderNetId → entries beyond that but inside
//                               WEDGE_MAX_DIST, i.e. the ones pass 2's group-hover peek
//                               reveals. Read ONLY on the frames a group icon is
//                               actually hovered.
// A single list cut at CHEVRON_MAX_DIST would silently kill the peek; one cut at
// WEDGE_MAX_DIST would give back most of the saving. Bucketing by leader also makes the
// peek itself cheaper than it was — it used to be a test applied while rescanning every
// chevron in the store, and is now one hashmap read per hovered group.
//
// Each stored entry carries its RESOLVED ANCHOR appended, so the narrow phase needs no
// `vehicle` call — that one IS fixed for the life of the unit. It does not carry a
// distance, and it does not carry a head position: both change every frame, and the
// head one is read through the HEAD_POS macro so that costs no call scope.
if (_clock >= GVAR(cullAt)) then {
    GVAR(cullAt) = _clock + CULL_INTERVAL;

    private _visGroups   = [];
    private _visChevrons = [];
    private _peek        = createHashMap;
    private _chevCull    = CHEVRON_MAX_DIST + CULL_SLACK;

    {
        // _x = markerName (HashMap key); _y = stored display data.
        if (!alive (_y select 0)) then { continue };   // alive objNull is false — covers deleted units too
        // Anchor on the vehicle so a mounted leader is handled (vehicle = unit on foot).
        // `distance` throws a Generic error on a null object, and a runtime error ABORTS
        // THE WHOLE forEach — so a single bad entry costs every icon after it, not just
        // its own. `alive` does not cover this: it is false for objNull, but a live unit
        // can still resolve to a null vehicle.
        private _anchor = vehicle (_y select 0);
        if (isNull _anchor) then { continue };
        // Group icons have no cutoff of their own — past view distance the fade alpha is
        // 0, so there was never anything to see. Culled with slack for the same reason
        // the chevrons are: the camera may be approaching.
        if (_camPos distance _anchor >= _viewDist + CULL_SLACK) then { continue };

        _visGroups pushBack [_x, _y, _anchor];
    } forEach GVAR(spotGroups);

    {
        if (!alive (_y select 0)) then { continue };
        private _anchor = vehicle (_y select 0);
        if (isNull _anchor) then { continue };
        private _dist = _camPos distance _anchor;
        if (_dist > WEDGE_MAX_DIST || {_dist >= _viewDist}) then { continue };

        // The head position is NOT resolved here alongside the anchor, though it used
        // to be. `selectionPosition` reports the selection in model space "pertaining
        // to the current animation in render time scope" — the head moves within model
        // space as the man leans, crouches, goes prone or turns his torso — so a value
        // sampled once per CULL_INTERVAL is stale for up to that long, and the value it
        // was sampled through (a per-CLASS memo) was never right for more than one pose
        // of one man. It is read per frame in the narrow phase now, through HEAD_POS,
        // which is a macro precisely so that per-frame read costs no call scope.
        private _entry = [_x, _y, _anchor];
        if (_dist <= _chevCull) then {
            _visChevrons pushBack _entry;
        } else {
            // _y select 3 is the pre-resolved leader netId — the same key pass 2's
            // hover test looks the group up by.
            // get + isNil, not getOrDefault with an inline []: SQF evaluates that default
            // EAGERLY, and this branch runs once per distant chevron on every broad
            // phase — the per-entity allocation the rest of this component avoids.
            private _key    = _y select 3;
            private _bucket = _peek get _key;
            if (isNil "_bucket") then {
                _bucket = [];
                _peek set [_key, _bucket];
            };
            _bucket pushBack _entry;
        };
    } forEach GVAR(spotChevrons);

    GVAR(spotGroupsVisible)   = _visGroups;
    GVAR(spotChevronsVisible) = _visChevrons;
    GVAR(spotChevronsPeek)    = _peek;
};

private _groups   = GVAR(spotGroupsVisible);
private _chevrons = GVAR(spotChevronsVisible);
if (_groups isEqualTo [] && { _chevrons isEqualTo [] } && { count GVAR(spotChevronsPeek) == 0 }) exitWith {};

// Blink state, hoisted out of the per-icon colour blocks below: `time` is read once per
// frame instead of once per icon, and _anyBlink lets the common case skip the per-icon
// map lookup outright.
//
// Gated on GVAR(blinkAnyUntil) — the high-water mark of every stamp in the map — and
// NOT on `count _blinkUntil > 0`, which is what this was and which does not work.
// FUNC(spottingClient) only removes an entry on spotLost, never when it expires, so a
// count test goes true on the first shot of the mission and never comes back down
// while that man stays spotted: the hoist below then costs a getOrDefault per icon
// per frame forever, which is exactly what it exists to avoid. Every blink runs the
// same BLINK_DURATION, so the newest stamp is the maximum and this test is exact,
// true only inside the real ~0.15 s windows.
private _blinkUntil = GVAR(blinkUntil);
private _now        = time;
private _anyBlink   = _now <= GVAR(blinkAnyUntil);

// Echelon amplifier gap above the group icon, indexed by the payload's side index
// (0 = BLUFOR rectangle, 1 = OPFOR diamond — peaks highest so needs the most lift,
// 2 = independent/civilian square). A fraction scaled by camera distance and applied
// along CAMERA-UP, giving a constant screen gap at any zoom AND any camera pitch.
private _AMP_GAPS = AMP_GAPS_WORLD;

// Hoisted once per frame: is anything actually under remote control? Testing only
// that the map EXISTS made this true whenever the RC indicator is merely enabled,
// so every chevron paid a netId + hashmap lookup every frame for nothing.
// Plain read, no default: this component's preInit creates the store unconditionally
// on every interface machine. It used to carry a `createHashMap` default for the
// case where the RC system is switched off — and SQF evaluates that argument
// eagerly, so it built and threw away a hashmap on every frame of every curator's
// session, whether or not the store existed.
private _rcDisplay = GVAR(rcDisplay);
private _hasRC     = count _rcDisplay > 0;

// The distance fade × stored base alpha, with a white flash while the unit is firing,
// is spelled INLINE in both passes below rather than factored into a `_fnc_drawColor`
// helper. It is four lines duplicated once, and it runs per icon per frame on every
// curator's machine — a `call` there buys a fresh scope and a `params` destructure per
// icon per frame for nothing, which is the same cost pass 2 already refuses to pay for
// its size ramp (see the linearConversion note there). The two copies are kept
// deliberately identical; change one, change the other.

// ── Pass 1: group icons ─────────────────────────────────────────────────────
// Also records which group leaders the mouse is currently near, so pass 2 can
// reveal that group's chevrons past the cutoff.
private _chevronsEnabled = GVAR(chevronsEnabled);
// The hover test exists ONLY to unlock the peek bucket, so it is gated on that bucket
// having something in it — on the ordinary frame, where every spotted man is either
// inside the cutoff or not spotted at all, no worldToScreen runs at all.
private _peekByLeader = GVAR(spotChevronsPeek);
private _anyPeek      = _chevronsEnabled && {count _peekByLeader > 0};
// Built unconditionally, even though only pass 2 reads it and only under _anyPeek.
// Making it conditional would save one small map allocation per frame and leave a
// possibly-nil private in a renderer — and a nil read aborts the whole enclosing scope
// (Gotchas §2), which here means silently dropping every remaining icon for the frame.
// That is a poor trade for one allocation: the costs this component is written to avoid
// are per-ENTITY-per-frame, not per-frame.
private _groupHoverByLeader = createHashMap;
{
    // Broad-phase entry: [markerName, stored display data, resolved anchor]. The
    // alive / null-anchor tests were paid there.
    _x params ["_mrkr", "_data", "_anchor"];
    _data params ["", "_texture", "_colorArray", "_echelonTex", "_sideIdx", "_ldrId"];

    // Re-read every frame, never cached by the broad phase: _zMod and the fade alpha
    // are both functions of it and would otherwise step at CULL_INTERVAL.
    private _dist = _camPos distance _anchor;
    // Past view distance the fade alpha is 0 — there was never anything to see, so
    // skip the icon (and its hover worldToScreen) rather than issue invisible
    // draws. Group icons, unlike chevrons, have no cutoff of their own; the broad
    // phase culls at _viewDist + CULL_SLACK, so this is the exact test.
    if (_dist >= _viewDist) then { continue };

    // Native Zeus group-icon recipe: world-space height offset grows with camera
    // distance (GROUP_ZMOD_MIN→MAX over GROUP_ZMOD_NEAR→FAR m, floored close in),
    // holding a roughly constant screen gap above the unit as you zoom. Aim pos
    // from the VEHICLE, not the crewman (else it skews out along the gun).
    private _zMod = linearConversion [GROUP_ZMOD_NEAR, GROUP_ZMOD_FAR, _dist, GROUP_ZMOD_MIN, GROUP_ZMOD_MAX, true];
    if (_dist >= GROUP_ZMOD_NEAR) then { _zMod = _zMod * GROUP_ZMOD_FLOOR_SCALE };
    // unitAimPositionVisual returns [] for a vehicle with no crew aim point to
    // resolve through (empty hull, or the frames before Zeus moves its crew in),
    // and [] vectorAdd [...] stays [] — fall back to the bounding-box top centre.
    // That fallback returns [] as well while the model has not resolved on this
    // machine (the frames right after Zeus creates the object), so re-test: every
    // draw below would be an invisible no-op on an [] position anyway.
    private _aim = unitAimPositionVisual _anchor;
    if (count _aim < 3) then {
        private _top = ((boundingBoxReal _anchor) param [1, []]) param [2, 0];
        _aim = _anchor modelToWorldVisual [0, 0, _top];
    };
    if (count _aim < 3) then { continue };
    private _iconPos = _aim vectorAdd [0, 0, _zMod];
    // Size amplifier lifted along CAMERA-UP, not world +Z. drawIcon3D offers no
    // screen-space offset for the ICON — its offsetX/offsetY move the TEXT, which
    // here is "" — so the gap has to be a world vector, and the axis it rides is
    // what matters. A world +Z gap projects to screen as gap * sin(angle between
    // +Z and the view axis): full looking at the horizon, HALF at 60° down, and
    // ZERO looking straight down, where the amplifier landed exactly on the group
    // icon it is meant to sit above. Top-down is the Zeus working angle, so that
    // collapse was the normal case, not an edge case. Camera-up is perpendicular
    // to the view axis by construction, so this offset leaves the amplifier at the
    // icon's depth and the screen gap is exact at every pitch. Same fix and same
    // reason as EFUNC(hud,drawUnitTags)' tag lift; the frame loop resolves the
    // camera basis once per frame precisely so renderers can do this.
    //
    // Still scaled by _dist (not _zMod, which floors close up) so the gap also
    // holds through zoom. Each side's frame peaks at a different height, so the
    // size comes from the per-side table above via the payload's side index.
    private _ampPos = _iconPos vectorAdd (_camUp vectorMultiply (_dist * (_AMP_GAPS select _sideIdx)));
    private _iconW  = GROUP_ICON_WIDTH;

    // Only worth asking for a group that HAS chevrons waiting past the cutoff.
    if (_anyPeek && {_ldrId in _peekByLeader}) then {
        private _scr = worldToScreen _iconPos;
        if (_scr isNotEqualTo []) then {
            private _dx = (_scr#0) - (_mousePos#0);
            private _dy = (_scr#1) - (_mousePos#1);
            if ((_dx * _dx) + (_dy * _dy) <= GROUP_HOVER_R2) then {
                _groupHoverByLeader set [_ldrId, true];
            };
        };
    };

    // Distance fade × stored base alpha (_dist >= _viewDist is skipped above), flashing
    // white while the unit is firing. Inlined — see the note above pass 1.
    private _alpha = ((_viewDist - _dist) / _viewDist) * (_colorArray#3);
    private _col = if (_anyBlink && {_now <= (_blinkUntil getOrDefault [_mrkr, 0])})
        then { [1, 1, 1, _alpha] }
        else { [_colorArray#0, _colorArray#1, _colorArray#2, _alpha] };
    // Native Zeus stem. The icon floats _zMod above the leader, so on its own it
    // reads as hanging over whatever terrain happens to be under it — from a
    // shallow camera angle that can be a hillside a hundred metres behind the
    // group. The line back down to the body says which unit the icon is for.
    //
    // Black rather than the side colour, as the basegame draws it: a red stem
    // over dry Altis terrain is nearly invisible, and black reads against both
    // sky and ground. Alpha is lifted straight off _col so the stem fades with
    // the icon in step — including the white muzzle-flash blink, which changes
    // only the RGB.
    //
    // Drawn BEFORE the icon so the frame covers the point where the line meets
    // it; the path renderer's air stalk lands on its handle icon the same way.
    drawLine3D [_iconPos, _aim, [0, 0, 0, _col select 3]];
    drawIcon3D [_texture, _col, _iconPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.035];
    if (_echelonTex != "") then {
        drawIcon3D [_echelonTex, _col, _ampPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.035];
    };
} forEach _groups;

// ── Pass 2: individual chevrons ─────────────────────────────────────────────
// Skipped entirely while chevrons are toggled off (FUNC(toggleChevrons)) —
// group icons above are unaffected.
if (!_chevronsEnabled) exitWith {};

private _chevronNames = GVAR(chevronNames);

// The frame's draw list: everything inside the cutoff, plus the peek buckets of whichever
// groups pass 1 found under the cursor. Appending to the near list itself would mutate a
// store the broad phase still owns and grow it without bound, so the hovered case copies
// first — `select [0]`, a SHALLOW copy, not `+`, which would deep-copy every entry's
// payload array for nothing. It runs only on frames where a group icon is actually
// hovered, and even then it replaces a rescan of the ENTIRE chevron store, which is what
// this test used to cost every frame.
private _drawList = _chevrons;
if (count _groupHoverByLeader > 0) then {
    _drawList = _chevrons select [0];
    // Plain `get`, no default: pass 1 only records a hover for a leader it first
    // confirmed is a key of _peekByLeader, so the bucket is always there.
    { _drawList append (_peekByLeader get _x) } forEach keys _groupHoverByLeader;
};

{
    // Broad-phase entry: [markerName, stored display data, resolved anchor]. The
    // alive / null-anchor / cutoff tests were paid there — what survives here is a
    // candidate, and the only per-frame question left is where it is now.
    _x params ["_mrkr", "_data", "_anchor"];
    _data params ["_unit", "_texture", "_colorArray", "_ldrId", "_name", "_unitId"];

    private _dist = _camPos distance _anchor;
    // Re-tested every frame even though the broad phase already culled: CULL_SLACK exists
    // so a chevron the camera is APPROACHING is already a candidate, not so it draws
    // early. These two tests are the real edges, unchanged from before the split.
    if (_dist > WEDGE_MAX_DIST || {_dist >= _viewDist}) then { continue };
    // Past the normal cutoff, only show this chevron if its group's icon is
    // currently hovered — lets the curator "peek" at squad composition from afar.
    // Leader netId is pre-resolved server-side, so no group traversal per frame.
    if (_dist > CHEVRON_MAX_DIST && {!(_groupHoverByLeader getOrDefault [_ldrId, false])}) then { continue };

    // Suppress chevron when the RC indicator is already showing for this unit.
    // The netId is carried in the payload (pre-resolved server-side, where it is already
    // the unit half of the spot key) rather than re-derived here: `netId` is an engine
    // call, and this ran once per chevron per frame for every curator whenever anything
    // at all was under remote control.
    if (_hasRC && {_unitId in _rcDisplay}) then { continue };

    // Native EG-spectator chevron (ACE recipe): head + 1 m, size scaled by
    // distance. Smooth ramp rather than a stepped table — same endpoints, one
    // engine call, and no per-chevron `call {}` scope per frame.
    // BOTH halves of HEAD_POS are read here, per frame: modelToWorldVisual because
    // the man moves, and selectionPosition because the head moves WITHIN him as he
    // leans, crouches or goes prone. Hoisting the second one to the broad phase is
    // what used to leave chevrons hanging off to the side of their unit.
    private _iconPos = HEAD_POS(_unit) vectorAdd [0, 0, 1];
    // modelToWorldVisual returns [] while the model has not resolved on this
    // machine — the handful of frames after Zeus places a unit — and
    // [] vectorAdd [...] stays []. drawIcon3D would then silently draw nothing
    // and worldToScreen below would throw, aborting the scope and dropping
    // every REMAINING chevron this frame. The group pass above guards the same
    // way (Gotchas §3).
    if (count _iconPos < 3) then { continue };

    private _iconW   = linearConversion [0, WEDGE_MAX_DIST, _dist, CHEVRON_W_NEAR, CHEVRON_W_FAR, true];

    // Inlined twin of the group pass's fade/blink block — see the note above pass 1.
    private _alpha = ((_viewDist - _dist) / _viewDist) * (_colorArray#3);
    private _col = if (_anyBlink && {_now <= (_blinkUntil getOrDefault [_mrkr, 0])})
        then { [1, 1, 1, _alpha] }
        else { [_colorArray#0, _colorArray#1, _colorArray#2, _alpha] };
    drawIcon3D [_texture, _col, _iconPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, 0];

    if (_chevronNames && {_dist <= HOVER_MAX_DIST}) then {
        private _scr = worldToScreen _iconPos;
        if (_scr isNotEqualTo []) then {
            private _dx = (_scr#0) - (_mousePos#0);
            private _dy = (_scr#1) - (_mousePos#1);
            if ((_dx * _dx) + (_dy * _dy) <= HOVER_HIT_R2) then {
                // Display name pre-resolved server-side — no configOf per frame.
                drawIcon3D ["", _col, _iconPos vectorAdd [0, 0, 0.6], 0, 0, 0, _name, 1, 0.025, "RobotoCondensed", "center", false, 0, 0];
            };
        };
    };
} forEach _drawList;
