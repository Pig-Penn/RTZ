#include "script_component.hpp"
/*
 * Author: Maxim
 * CuratorObjectDeleted handler. Decides whether a deletion is refundable and,
 * if it is, queues the class for the server to price (FUNC(refundApply)).
 *
 * The engine's own "delete" coefficient is held at zero (FUNC(applyCoefs)),
 * and the refund paid from script here instead. The coefficient prices a
 * deletion off the class alone: a corpse is worth exactly what the living
 * soldier cost, so clearing a battlefield of enemy dead is free income, and no
 * engine-side setting can tell the two apart. Script can, against two
 * conditions — the object has to have been placed by a curator (see
 * FUNC(markPlaced)) and has to still be worth something.
 *
 * Runs on the machine of the curator doing the deleting, while the object is
 * still there: the engine fires this before the deletion, so _entity can still
 * be read. Curator points are server-side, hence the event.
 *
 * Arguments:
 * 0: Curator module <OBJECT>
 * 1: Deleted object <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_curator, _entity] call rtz_economy_fnc_refundDeleted
 *
 * Public: No
 */

params ["_curator", "_entity"];

if (!GVAR(enable) || {GVAR(deleteRefund) <= 0}) exitWith {};
if (isNull _curator || {isNull _entity}) exitWith {};

// A corpse or a wreck has already been spent — the points went up with it
if (!alive _entity) exitWith {};
if (!(_entity getVariable [QGVAR(paid), false])) exitWith {};

GVAR(refundQueue) pushBack (typeOf _entity);

// One server event per delete ACTION, not per object: a curator clearing a
// 50 object selection fires this handler 50 times in the same frame. The flush
// empties the queue, so finding anything already in it means one is scheduled.
if (count GVAR(refundQueue) > 1) exitWith {};

[{
    private _classes = GVAR(refundQueue);
    GVAR(refundQueue) = [];

    // Every deletion in a frame comes from the one curator interface this
    // machine has open, so the curator captured with the first covers them all
    [QGVAR(refund), [_this, _classes]] call CBA_fnc_serverEvent;
}, _curator] call CBA_fnc_execNextFrame;
