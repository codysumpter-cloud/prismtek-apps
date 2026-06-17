#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path


def png_size(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        sig = handle.read(24)
    if sig[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path} is not a PNG")
    return int.from_bytes(sig[16:20], "big"), int.from_bytes(sig[20:24], "big")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("frames_dir", type=Path)
    parser.add_argument("--animation", required=True)
    parser.add_argument("--fps", type=float, default=12)
    parser.add_argument("--loop", action="store_true")
    args = parser.parse_args()
    frames = sorted(args.frames_dir.glob("*.png"))
    if not frames:
        raise SystemExit(f"No PNG frames in {args.frames_dir}")
    width, height = png_size(frames[0])
    manifest = {
        "animation": args.animation,
        "frames": len(frames),
        "fps": args.fps,
        "loop": args.loop,
        "sprite_width": width,
        "sprite_height": height,
        "origin": [width // 2, max(0, height - 8)],
        "hurtbox": [20, 10, 24, 42],
        "hitbox": [18, 8, 28, 46],
        "frames_detail": [{"file": frame.name, "duration_ms": round(1000 / args.fps)} for frame in frames]
    }
    out = args.frames_dir / "manifest.json"
    out.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
