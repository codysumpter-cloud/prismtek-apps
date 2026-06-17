#!/usr/bin/env python3
"""Extract GIF frames into PNGs and write timing metadata.

Reference-only workflow: outputs should stay under assets/reference/onepiece-test
and must not be included in release builds.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

try:
    from PIL import Image, ImageSequence
except ImportError as exc:
    raise SystemExit("Pillow is required for GIF extraction. Install with: python -m pip install pillow") from exc


def extract(gif_path: Path, output_dir: Path, animation: str) -> dict:
    output_dir.mkdir(parents=True, exist_ok=True)
    frames = []
    with Image.open(gif_path) as image:
        for index, frame in enumerate(ImageSequence.Iterator(image)):
            duration_ms = int(frame.info.get("duration", image.info.get("duration", 83)))
            out = output_dir / f"{animation}_{index:03d}.png"
            frame.convert("RGBA").save(out)
            frames.append({"file": out.name, "duration_ms": duration_ms})
        width, height = image.size
    total_ms = sum(frame["duration_ms"] for frame in frames) or 1
    return {
        "animation": animation,
        "source": gif_path.name,
        "frames": len(frames),
        "fps": round(1000 / (total_ms / max(1, len(frames))), 2),
        "loop": True,
        "sprite_width": width,
        "sprite_height": height,
        "origin": [width // 2, max(0, height - 8)],
        "hurtbox": [width // 3, height // 6, width // 3, height * 2 // 3],
        "hitbox": [width // 4, height // 8, width // 2, height * 3 // 4],
        "frames_detail": frames,
        "reference_only": True
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("gif", type=Path)
    parser.add_argument("--out", type=Path, default=Path("assets/reference/onepiece-test"))
    parser.add_argument("--animation", default=None)
    args = parser.parse_args()
    animation = args.animation or args.gif.stem.lower().replace(" ", "_")
    manifest = extract(args.gif, args.out / animation, animation)
    manifest_path = args.out / animation / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
