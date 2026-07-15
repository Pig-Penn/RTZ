#include "script_component.hpp"

if (!hasInterface) exitWith {};

// ZEN built-in actions
["Formation"]    call zen_context_menu_fnc_removeAction;
["Behaviour"]    call zen_context_menu_fnc_removeAction;
["CombatMode"]   call zen_context_menu_fnc_removeAction;
["SpeedMode"]    call zen_context_menu_fnc_removeAction;
["Stance"]       call zen_context_menu_fnc_removeAction;
["HealUnits"]    call zen_context_menu_fnc_removeAction;
["TeleportZeus"] call zen_context_menu_fnc_removeAction;

// LAMBS Danger FSM context groups
["lambs_danger"]    call zen_context_menu_fnc_removeAction;
["lambs_wp"]        call zen_context_menu_fnc_removeAction;
["lambs_wp_Search"] call zen_context_menu_fnc_removeAction;
