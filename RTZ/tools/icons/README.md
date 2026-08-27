# Icon pipeline

Source of truth for RTZ's own context-menu icons. Before this existed the `.paa`
files were the only representation, which meant they could not be edited — only
replaced by hand.

```
icons.py  →  build/*.png (128×128 RGBA)  →  ImageToPAA  →  addons/<component>/ui/<name>_ca.paa
verify.py →  decodes the .paa back and checks it
```

Everything here is pure stdlib Python 3 — no Pillow, no numpy, no cairo.

| | |
|---|---|
| `icons.py` | builds the PNGs; geometry constants live at the top |
| `paa.py` | `.paa` container, LZO1X, DXT5 decode (read-only) |
| `verify.py` | checks the shipped `.paa` files, non-zero exit on regression |
| `src/` | checked-in source art that is *not* synthesised (`trash_ca.png`) |
| `build/` | generated, gitignored |

`pause_ca` and `play_ca` are generated from the constants in `icons.py`.
`trash_ca` is a hand-shaped silhouette, so its alpha is checked in under `src/`
and passed through. Do not point `build_trash` back at the shipped `.paa` — that
would make each run re-read its own output and compound a DXT5 generation.

## Regenerating

```sh
python tools/icons/icons.py
"C:/Program Files (x86)/Steam/steamapps/common/Arma 3 Tools/ImageToPAA/ImageToPAA.exe" \
    tools/icons/build/pause_ca.png addons/control/ui/pause_ca.paa
# ...same for play_ca and trash_ca
python tools/icons/verify.py          # exits non-zero if anything regressed
```

`icons.py` also writes `*_preview.png` next to each output. Use them — the real
icons are white on transparent and look like a blank square in most viewers.
Each preview shows the full-resolution sheet beside the same alpha filtered down
to 20 px, which is roughly what the menu draws.

## Why the icons look the way they do

ZEN renders these into an `RscPicture` (`IDC 185050`, ~0.9 GUI grid cells ≈
**18–24 px** at 1080p) and tints them with `ctrlSetTextColor`. That multiplies
the texture, so two rules follow:

- **The glyph lives in the alpha channel.** RGB is flooded white.
- **RGB must be white even where alpha is 0.** Transparent texels still
  contribute colour under bilinear filtering. The old `pause_ca`/`play_ca` had
  black there and it showed up as a dark fringe at menu size.

Because the icons share a submenu, they are sized to carry equal optical weight
rather than to fill equal bounding boxes:

| | sheet | vertical extent | ink @50% |
|---|---|---|---|
| `pause_ca` | 128² | y14–113 | 33.8 % |
| `play_ca` | 128² | y14–113 | 30.1 % |
| `trash_ca` | 128² | y13–113 | 35.1 % |

Ink fraction — the share of the canvas above 50 % alpha — is the useful proxy
for how heavy a glyph reads once it is 20 px wide. Bounding boxes are not:
a triangle that fills the same box as a rectangle reads much lighter.

Two deliberate exceptions, both enforced in `verify.py`:

- **`play_ca` is not horizontally symmetric.** It sits 3 px right of centre
  (L/R inset 1.44), because a triangle is optically centred nearer its centroid
  than its bounding box. Only 3 px, though — `fnc_squadHideActionModifier`
  swaps pause and play into the *same* menu row, so a larger offset would make
  that row visibly jump.
- **`surrender_ca` is not regenerated.** It is a verbatim copy of ACE3's, kept
  byte-identical for provenance (see `captive/script_component.hpp`). It still
  has the black-fringe defect; `verify.py` reports that as a waived note.

## How the shapes are built

Antialiasing comes from signed distance fields, not supersampling. For a
rounded rect or rounded polygon the exact distance is cheap, and one sample per
pixel gives a clean one-pixel ramp — the old 64 px `play_ca` had a visible
staircase on its diagonals. Axis-aligned edges are placed on integer pixel
boundaries so they stay perfectly hard.

Rounded polygons are done by shrinking the outline by `r` (`offset_inward`) and
then taking `sd_polygon(...) - r`. Note that this pulls sharp corners in a long
way — at the play triangle's 29° apex, `r = 5` costs ~5 px of reach — so the
constants in `icons.py` describe the *sharp* outline and are larger than the
box the glyph ends up occupying. Change them and re-read `verify.py`'s numbers;
do not assume they are the rendered geometry.

`trash_ca` was not redrawn — it was rebuilt by subtraction. `src/trash_ca.png`
was produced once from the old slotted icon:

```sh
python tools/icons/icons.py --derive-trash <old_trash_ca.paa>
```

That fills each body row solid between its own outermost ink, closing the three
vertical slots and touching nothing else. The outer silhouette — handle, lid,
lid gap, taper, and its antialiased edge — is preserved exactly. The slots
contradicted the brief already written in `delete/script_component.hpp`: at menu
size they averaged to grey and left the can washed out beside solid neighbours.

`--derive-trash` is a one-shot that rewrites `src/`. It is not part of the
normal build; run it only if you need to re-derive from some other `.paa`.

## Notes

- `ImageToPAA` writes uncompressed mipmaps here (22 KB/icon) rather than the
  LZO-compressed ones the old `trash_ca` had (4.5 KB). It exposes no flag for
  this, and `surrender_ca` was already uncompressed, so the ~50 KB is accepted.
- `tools/` is outside anything HEMTT packs: `.hemtt/project.toml`'s `[files]`
  list is `LICENSE`, `mod.cpp`, `README.md`, and it otherwise builds only
  `addons/`.
- `paa.py` implements the `.paa` container, LZO1X decompression and DXT5 block
  decoding. It reads what ImageToPAA writes; it does not write `.paa` itself.
