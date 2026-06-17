#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

REQUIRED_ANIMATIONS = {"idle", "walk", "run", "jump", "fall", "attack", "special", "hurt", "knockout", "victory"}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("sprite_manifest", type=Path)
    args = parser.parse_args()
    data = json.loads(args.sprite_manifest.read_text(encoding="utf-8"))
    errors = []
    if data.get("sprite_width") != 64 or data.get("sprite_height") != 64:
        errors.append("sprite size must be 64x64")
    animations = {item.get("name") for item in data.get("animations", [])}
    missing = REQUIRED_ANIMATIONS - animations
    if missing:
        errors.append(f"missing animations: {', '.join(sorted(missing))}")
    for animation in data.get("animations", []):
        if animation.get("frames", 0) < 1:
            errors.append(f"{animation.get('name')} has no frames")
        if animation.get("fps", 0) <= 0:
            errors.append(f"{animation.get('name')} fps must be positive")
    if errors:
        raise SystemExit("\n".join(errors))
    print(f"Validated {args.sprite_manifest}: {len(animations)} animations, 64x64")


if __name__ == "__main__":
    main()
