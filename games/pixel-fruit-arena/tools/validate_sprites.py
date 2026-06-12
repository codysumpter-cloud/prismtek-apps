#!/usr/bin/env python3
"""Validate Pixel Fruit Arena data and asset safety rules."""
from __future__ import annotations

import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE_DIR = ROOT / "assets" / "reference" / "onepiece-test"
REQUIRED_ANIMATIONS = {"idle", "walk", "run", "jump", "fall", "attack", "special", "hurt", "knockout", "victory"}


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def fail(message: str) -> None:
    raise SystemExit(f"validate_sprites failed: {message}")


def main() -> int:
    fruits = load_json(ROOT / "data" / "fruits" / "core-fruits.json")
    if len(fruits) < 6:
        fail("expected at least 6 fruits")
    for fruit in fruits:
        if len(fruit.get("abilities", [])) != 3:
            fail(f"fruit {fruit.get('id')} must define exactly 3 abilities")
        if not fruit.get("awakening"):
            fail(f"fruit {fruit.get('id')} is missing awakening")

    stage = load_json(ROOT / "data" / "stages" / "sky-ruins-arena.json")
    if len(stage.get("platforms", [])) < 3 or len(stage.get("spawns", [])) < 4:
        fail("stage needs multiple platforms and 4 spawn points")

    profile = load_json(ROOT / "data" / "characters" / "default-profile.json")
    if "appearance" not in profile or "equipped_fruit" not in profile:
        fail("profile must keep appearance and equipped fruit separate")

    manifest = load_json(ROOT / "data" / "characters" / "prismtek-placeholder.animations.json")
    if manifest.get("sprite_width") != 64 or manifest.get("sprite_height") != 64:
        fail("original placeholder sprite must be 64x64")
    missing = REQUIRED_ANIMATIONS - set(manifest.get("animations", {}).keys())
    if missing:
        fail(f"missing animations: {sorted(missing)}")

    use_reference = os.environ.get("USE_REFERENCE_TEST_ASSETS", "false").lower() == "true"
    release = os.environ.get("NODE_ENV", "development") == "production"
    if release and use_reference:
        fail("release builds must force USE_REFERENCE_TEST_ASSETS=false")
    if REFERENCE_DIR.exists() and not use_reference:
        forbidden = [p for p in REFERENCE_DIR.rglob("*") if p.is_file() and p.name != "README_REFERENCE_ASSETS.md"]
        if forbidden:
            fail("reference extraction output exists while USE_REFERENCE_TEST_ASSETS=false")

    print("Pixel Fruit Arena validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
