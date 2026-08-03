# Extras

Components that are **not built and not checked**. HEMTT only scans `addons/`,
so nothing in here is compiled, linted, or validated by `hemtt check` — it will
drift out of sync with the rest of the mod silently. Treat every file here as a
snapshot, not as working code.

| Component | Status |
|---|---|
| `casualty` | Unfinished feature: wounded units, medical zones, casualty evacuation. Never shipped |
| `unit_info` | Superseded. Its per-unit 3D info draw is now `rtz_hud`'s unit tags, fed by `rtz_core`'s stream engine |
| `vehicle_info` | Superseded. Same story as `unit_info`, replaced by `rtz_hud`'s vehicle tags |

To revive one: move it back under `addons/`, then expect a round of fixes — the
`main`/`core` macro contracts, the `rtz_common` split, and the stream/renderer
registration API have all changed since these were last built. Start by running
`hemtt check` and working through what it reports.
