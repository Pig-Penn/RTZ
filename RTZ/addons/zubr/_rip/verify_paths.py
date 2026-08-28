"""Collect every x\\rtz\\addons\\... reference out of the addon's p3d, rvmat, sqf
and config files, and confirm each one is under this addon and resolves to a file
that is actually packed. Anything missing, or left pointing at another addon's
folder, shows up in game as an untextured surface or an 'addon not found' error."""
import os, re

DEST = r"c:\Users\Maxim\OneDrive\1D Documents\Modding\Real-Time Zeus\RTZ\addons\zubr"
PREFIX = r"x\rtz\addons\zubr"

refs = {}   # path -> set of files referencing it
stale = {}  # same, but under some other RTZ addon name - see the report below
for root, _, files in os.walk(DEST):
    for f in files:
        if not f.lower().endswith((".p3d", ".rvmat", ".sqf", ".cpp", ".hpp")):
            continue
        p = os.path.join(root, f)
        with open(p, "rb") as fh:
            blob = fh.read()
        # Match any addon name, not just ours: renaming the addon folder leaves
        # the paths baked into the binarised .p3d pointing at the old name, and
        # a rename done with grep or find-and-replace skips binaries silently.
        for m in re.finditer(rb"(?i)x\\rtz\\addons\\([a-z0-9_]+)\\[a-z0-9_\\.%]+", blob):
            ref = m.group(0).decode("latin1")
            name = m.group(1).decode("latin1").lower()
            if name == "zubr":
                refs.setdefault(ref.lower(), set()).add(os.path.relpath(p, DEST))
            elif name != "main":    # main carries the shared script_macros headers
                stale.setdefault(ref.lower(), set()).add(os.path.relpath(p, DEST))

missing, ok = [], 0
for ref, sources in sorted(refs.items()):
    rel = ref[len(PREFIX) + 1:].replace("\\", os.sep)
    if "%1" in rel:                       # runtime format string: check the folder
        rel = os.path.dirname(rel)
        target = os.path.join(DEST, rel)
        exists = os.path.isdir(target)
    else:
        target = os.path.join(DEST, rel)
        exists = os.path.exists(target)
        if not exists and not os.path.splitext(rel)[1]:
            exists = any(os.path.exists(target + e) for e in (".wss", ".ogg", ".p3d"))
    if exists:
        ok += 1
    else:
        missing.append((ref, sorted(sources)))

print("%d referenced paths resolve" % ok)
if missing:
    print("\n%d MISSING:" % len(missing))
    for ref, sources in missing:
        print("  %s\n      referenced by: %s" % (ref, ", ".join(sources)))
else:
    print("nothing missing")

if stale:
    print("\n%d STALE ADDON PREFIX (not %s):" % (len(stale), PREFIX))
    for ref, sources in sorted(stale.items()):
        print("  %s\n      referenced by: %s" % (ref, ", ".join(sorted(sources))))
else:
    print("no paths under another addon name")

# Any non-vanilla path left that is neither ours nor a3\?
foreign = set()
for root, _, files in os.walk(DEST):
    for f in files:
        if not f.lower().endswith((".p3d", ".rvmat", ".sqf", ".cpp", ".hpp")):
            continue
        with open(os.path.join(root, f), "rb") as fh:
            blob = fh.read()
        for m in re.finditer(rb"(?i)\"\\?([a-z0-9_]+)\\[a-z0-9_\\.]+\.(paa|rvmat|p3d|wss|ogg|rtm|jpg)", blob):
            root_dir = m.group(1).decode("latin1").lower()
            if root_dir not in ("x", "a3", "ca"):
                foreign.add(m.group(0).decode("latin1"))
print("\nforeign roots: %s" % (sorted(foreign) if foreign else "none (only x\\, a3\\, ca\\)"))
