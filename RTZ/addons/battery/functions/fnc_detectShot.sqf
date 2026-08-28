#include "script_component.hpp"
/*
 * Author: Maxim
 * The ArtilleryShellFired handler body, on the machine that owns the firing gun.
 * Resolves the firer's side and an estimated time of flight, then hands one report
 * to the server; every decision about who may see it is made there.
 *
 * This runs on EVERY machine (FUNC(startSystem) registers the handler everywhere,
 * because most RTZ guns are local to a curator's client rather than to the server)
 * and immediately narrows to one. ArtilleryShellFired fires both on the PC that
 * triggered the action AND on the PC where the vehicle is local, which are often
 * different machines — a server-ordered LAMBS fire mission against a client-owned
 * gun raises it twice. `local _vehicle` picks exactly one reporter and is why there
 * is no de-duplication window on the server: a window would have to be wide enough
 * for network jitter, and would then swallow the genuinely distinct rounds of a
 * rocket salvo fired a tenth of a second apart.
 *
 * THAT LOCALITY CLAIM IS THE ONE THING HERE NOT ESTABLISHED FROM SOURCE. The Biki
 * states it, but community.bistudio.com answers 403 to every automated fetch
 * (Gotchas §4), and the only shipped mod using this event — Zeus Wargame's
 * artillery radar, jac_wargameMain.sqf:12379 — registers the handler with no
 * locality gate at all, so it corroborates the event and not the rule. Two in-game
 * checks settle it, and both are worth running before trusting this file:
 *   - a gun local to a CLIENT, fired on a dedicated server, must still produce a
 *     contact (if it does not, the event never reaches the owner and this gate is
 *     dropping everything);
 *   - the round count on a contact must match the rounds actually fired (a count of
 *     exactly 2x means the gate is not narrowing to one machine).
 *
 * Nothing else is decided here. In particular the firing POSITION is sent raw: the
 * offset that turns it into a zone is rolled on the server (FUNC(dispatchContact))
 * so that every curator on a side sees the same circle and no client is ever handed
 * the true position.
 *
 * Arguments: (the engine's ArtilleryShellFired payload)
 * 0: Firing vehicle <OBJECT>
 * 1: Weapon <STRING>
 * 2: Ammo <STRING>
 * 3: Gunner <OBJECT>
 * 4: Instigator <OBJECT>
 * 5: Artillery target <OBJECT>
 * 6: Target position <ARRAY>
 * 7: Shell <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_vehicle, _weapon, _ammo, _gunner, _instigator, _target, _targetPos, _shell] call rtz_battery_fnc_detectShot
 *
 * Public: No
 */

params ["_vehicle", "", "", "_gunner", "", "", "_targetPosition", "_shell"];

if (!local _vehicle) exitWith {};

// The gun's side is its CREW's side. A static mortar and a crewed SPG both resolve
// through _gunner; effectiveCommander covers a hull whose gunner slot the engine
// left null (a UAV's crew is absent from allUnits entirely), and `side _vehicle`
// is the last resort for an unmanned hull firing under script.
private _firer = _gunner;
if (isNull _firer) then { _firer = effectiveCommander _vehicle };
private _firerSide = if (isNull _firer) then { side _vehicle } else { side _firer };

// ── Time of flight ──────────────────────────────────────────────────────────
// One sample of the shell's launch velocity, turned into a symmetric ballistic
// arc: t = 2*vz/g. It ignores the gun/target altitude difference and is simply
// wrong for a rocket that keeps burning, which is what the clamp is for — and why
// the client holds the ring for SPLASH_HOLD past the estimate instead of cutting
// at it.
//
// The accurate alternative is to watch the shell object until it goes null, which
// is a per-frame condition per round of every salvo for the length of its flight,
// on a mission that runs for hours. That is precisely the cost CLAUDE.md rules out,
// and it would buy accuracy in the one number here that does not need to be
// accurate: it only decides when a warning ring stops being drawn.
//
// count < 3 rather than isEqualTo []: a position/vector command can hand back a
// SHORT array as well as an empty one, and reading index 2 off a 2-element array
// returns nil rather than erroring, which would then propagate into the arithmetic
// far from the cause (Gotchas §3).
private _tof = TOF_FALLBACK;
if (!isNull _shell) then {
    private _vel = velocity _shell;
    if (count _vel > 2) then {
        private _vz = _vel # 2;
        if (_vz > 0) then {
            _tof = ((2 * _vz) / GRAVITY) max TOF_MIN min TOF_MAX;
        };
    };
};

// Normalised to [] rather than passed through, so the server has one shape to test
// instead of guessing whether a short array is a 2D position or a broken one. A
// position command handing back an empty or short array is the ordinary case, not
// the exceptional one (Gotchas §3), and distance2D against [] is a Generic error
// that would abort the dispatch scope well downstream of here.
if (count _targetPosition < 2) then { _targetPosition = [] };

// getPos (AGL) rather than an ASL position: everything downstream of here is a map
// draw, which takes a world position and ignores Z.
[QGVAR(shotReported), [_vehicle, getPos _vehicle, _firerSide, _targetPosition, _tof]] call CBA_fnc_serverEvent;
