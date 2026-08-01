#include "script_component.hpp"

// Both halves are registered UNCONDITIONALLY — no CBA_settingsInitialized fork
// and no GVAR(enable*Display) gate:
//   — Neither half reads a setting to install itself, so there is nothing to
//     wait for. The client registers one early-exiting Draw3D handler plus a
//     snapshot receiver; the server registers one subscribe receiver plus a PFH
//     that bails on `count == 0` while nobody is watching. Both are free while
//     the feature is switched off.
//   — Gating on the setting was wrong: the context actions read it LIVE, so an
//     admin enabling one mid-mission surfaced a working-looking action on
//     machines that never registered the machinery, and the toggle silently did
//     nothing. That is also why the settings no longer demand a mission
//     restart; FUNC(streamClient) instead watches CBA_SettingChanged and shuts a
//     running overlay down when its master switch goes off.
// `call`, not `spawn`: both bodies register handlers and return.
call FUNC(streamClient);
call FUNC(streamServer);
