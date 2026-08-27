"""Collect every x\\rtz\\addons\\csat\\... reference out of the addon's p3d, rvmat,
sqf and config files, and confirm each one resolves to a file that is actually
packed. Anything missing would show up in game as an untextured surface or an
'addon not found' error."""
import os, re

DEST = r"c:\Users\Maxim\OneDrive\1D Documents\Modding\Real-Time Zeus\RTZ\addons\csat"
PREFIX = r"x\rtz\addons\csat"

refs = {}   # path -> set of files referencing it
for root, _, files in os.walk(DEST):
    for f in files:
        if not f.lower().endswith((".p3d", ".rvmat", ".sqf", ".cpp", ".hpp")):
            continue
        p = os.path.join(root, f)
        with open(p, "rb") as fh:
            blob = fh.read()
        for m in re.finditer(rb"(?i)x\\rtz\\addons\\csat\\[a-z0-9_\\.%]+", blob):
            ref = m.group(0).decode("latin1")
            refs.setdefault(ref.lower(), set()).add(os.path.relpath(p, DEST))

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
