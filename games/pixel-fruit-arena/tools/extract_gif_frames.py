#!/usr/bin/env python3
"""Extract development-only GIF reference frames.

This tool is intentionally for local testing only. Do not commit extracted
third-party reference frames or include them in release artifacts.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

try:
    from PIL import Image, ImageSequence
except ImportError as exc:  # pragma: no cover
    raise SystemExit("Pillow is required: python3 -m pip install pillow") from exc


def extract(gif_path: Path, output_root: Path) -> dict:
    output_dir = output_root / gif_path.stem.replace(" ", "-").lower()
    output_dir.mkdir(parents=True, exist_ok=True)
    with Image.open(gif_path) as image:
        durations = []
        frames = []
        for index, frame in enumerate(ImageSequence.Iterator(image)):
            durations.append(int(frame.info.get("duration", 100)))
            output = output_dir / f"frame_{index:03d}.png"
            frame.convert("RGBA").save(output)
            frames.append(output.name)
        avg_duration = sum(durations) / max(1, len(durations))
        fps = round(1000 / avg_duration, 2) if avg_duration else 0
        manifest = {
            "animation": gif_path.stem,
            "source": gif_path.name,
            "reference_only": True,
            "frames": len(frames),
            "fps": fps,
            "frame_durations_ms": durations,
            "loop": True,
            "sprite_width": image.width,
            "sprite_height": image.height,
            "origin": [image.width // 2, image.height - 8],
            "hurtbox": [20, 10, max(1, image.width - 40), max(1, image.height - 20)],
            "hitbox": [18, 8, max(1, image.width - 36), max(1, image.height - 18)],
            "frames_files": frames,
        }
    (output_dir / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract GIF frames into reference-only PNGs.")
    parser.add_argument("gifs", nargs="+", type=Path)
    parser.add_argument("--out", type=Path, default=Path("assets/reference/onepiece-test"))
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    manifests = [extract(path, args.out) for path in args.gifs]
    print(json.dumps(manifests, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
