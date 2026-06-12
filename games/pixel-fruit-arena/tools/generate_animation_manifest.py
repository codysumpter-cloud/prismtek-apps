#!/usr/bin/env python3
"""Generate a hand-authored animation manifest skeleton for original sprites."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

DEFAULT_ANIMATIONS = ["idle", "walk", "run", "jump", "fall", "attack", "special", "hurt", "knockout", "victory"]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", default="prismtek_placeholder")
    parser.add_argument("--out", type=Path, default=Path("data/characters/prismtek-placeholder.animations.json"))
    parser.add_argument("--width", type=int, default=64)
    parser.add_argument("--height", type=int, default=64)
    args = parser.parse_args()
    manifest = {
        "character": args.name,
        "sprite_width": args.width,
        "sprite_height": args.height,
        "origin": [args.width // 2, args.height - 8],
        "hurtbox": [20, 10, 24, 42],
        "animations": {name: {"frames": 1, "fps": 8, "loop": name in {"idle", "walk", "run", "fall", "victory"}} for name in DEFAULT_ANIMATIONS},
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(args.out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
