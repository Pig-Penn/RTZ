---
name: rpt
description: Read the newest Arma 3 RPT log and report script errors, RTZ build stamps, and anything suspicious
---

# Analyze the latest Arma 3 RPT log

The RPT log is this project's "test output" — there is no automated test runner. Find the newest log and report what matters.

## Steps

1. Find the newest `.rpt` file in `%LOCALAPPDATA%\Arma 3\`:

```powershell
Get-ChildItem "$env:LOCALAPPDATA\Arma 3\*.rpt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 FullName, LastWriteTime, Length
```

   Report the file's timestamp so the user can confirm it is the session they just ran. If the directory doesn't exist, this machine has no Arma install — say so and stop.

2. Search it (Grep on the file path) for, in priority order:
   - **RTZ build stamps**: lines matching `\[RTZ\]` — the per-machine postInit stamps (`version, isServer, hasInterface, clientOwner`). Missing stamps for an addon = that PBO's postInit died or a stale PBO is loaded.
   - **Script errors**: `Error in expression`, `Error position`, `Error Undefined variable`, `Error Missing`. For each hit, also read ~5 lines of context — the engine prints the offending expression and file/line on adjacent lines.
   - **RTZ file references**: lines containing `rtz` (case-insensitive) near errors — pins the error to our addon vs. someone else's.
   - **Include/config problems**: `include not found`, `Warning Message`, `Cannot load`.
   - Exclude the known noise: lines matching `Bone|skeleton` (model warnings, not script problems).

3. If the user passed arguments, treat them as an additional case-insensitive search term in the same log and show matches with context.

4. Report: build stamps found (which addons, which machines), each distinct script error with file/line and the offending expression, and a one-line verdict (clean / errors in RTZ / errors only in other mods). Distinct is key — the same error often repeats hundreds of times per frame; count repeats instead of listing them.
