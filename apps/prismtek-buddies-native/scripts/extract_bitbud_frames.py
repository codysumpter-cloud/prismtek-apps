#!/usr/bin/env python3
"""Slice Cody's own Bitbud atlas (bitbud/spritesheet.webp) into per-state PNG frames.

Reproducible, committed slicer. Reads the READ-ONLY source atlas and writes PNG frames
into Shared/Resources/BitbudFrames/<state>_<n>.png. Never mutates the source.

Atlas: 1536x1872 WebP, 8 cols x 9 rows, cell 192x208.
Source asset belongs to Cody (Bitbud). No third-party art, no network, no credits.

Usage:
  python3 scripts/extract_bitbud_frames.py
"""
from PIL import Image
from pathlib import Path

SRC = Path("/Users/prismtek/.codex/pets/bitbud/spritesheet.webp")
CW, CH = 192, 208
ROWS = [
    ("idle", 6),
    ("running-right", 8),
    ("running-left", 8),
    ("waving", 4),
    ("jumping", 5),
    ("failed", 8),
    ("waiting", 6),
    ("running", 6),
    ("review", 6),
]


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    out = Path(__file__).resolve().parent.parent / "Shared" / "Resources" / "BitbudFrames"
    out.mkdir(parents=True, exist_ok=True)
    count = 0
    for r, (state, n) in enumerate(ROWS):
        for c in range(n):
            box = (c * CW, r * CH, c * CW + CW, r * CH + CH)
            src.crop(box).save(out / f"{state}_{c}.png")
            count += 1
    print(f"{count} frames extracted to {out}")


if __name__ == "__main__":
    main()
