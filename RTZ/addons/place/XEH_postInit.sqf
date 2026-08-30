#include "script_component.hpp"

// Deliberately empty. The whole session — cursor, ghosts, commit — is
// client-local: curatorSelected and the cursor are UI-local, and setPosASL has
// global arguments and global effects, so FUNC(commitPlacement) moves even
// server-local AI directly from the curator's machine with no round trip. There
// is nothing for any other machine to receive, so there is no CBA event to
// register here.
//
// Kept as a file rather than dropped because CfgEventHandlers.hpp names it and
// the skeleton every other RTZ component follows has one.
