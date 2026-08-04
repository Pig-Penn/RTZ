# Ramblings

This is a *weird*, *unofficial*, and *messy* record of my own personal ramblings.

## To-Do List

1. ~~Would like to incorporate Zeus Wargame's Path Planning system into my mod.~~ Done — `addons/route`. Not a port so much as a rebuild: the drawing half is the same gesture (toggle, drag a handle per unit, toggle to execute), the executing half is not. Wargame walks infantry footstep by footstep with `disableAI "MOVE"/"ANIM"` and three per-frame handlers per unit, and flies aircraft with its own `setVelocity` physics at 0.0005s; both are unusable at the unit counts and session lengths this mod is for. Land vehicles here hand off to `setDriveOnPath`, everything else to a `doMove` chain kept alive against the formation FSM by watching `expectedDestination` (LAMBS' trick), and one shared 0.1s tick drives the lot. Keybind is unbound by default — Tab is not ours to take inside ZEN.
2. Would like to incorporate Zeus Wargame's cover system into my mod.
3. Update the captive addon's icons.
4. Design a system that would, on the map, draw a zone showing the general area that a hostile artillery piece fired from. This would make counter battery possible.
