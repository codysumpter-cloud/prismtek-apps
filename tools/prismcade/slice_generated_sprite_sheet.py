#!/usr/bin/env python3
"""Slice generated Prismcade sprite sheets into game-ready runtime assets.

Requires:
  python -m pip install pillow numpy

Usage:
  python tools/prismcade/slice_generated_sprite_sheet.py --job data/prismcade/sprite-sheet-jobs/prismtek-fixed-hair-game-ready.json
"""

from __future__ import annotations

import argparse
import json
import math
import shutil
import zipfile
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image


def remove_connected_bright_background(img: Image.Image) -> Image.Image:
    """Remove generated checkerboard/white backgrounds without deleting internal highlights."""
    arr = np.array(img.convert("RGB"))
    height, width, _ = arr.shape
    maxc = arr.max(axis=2)
    minc = arr.min(axis=2)
    bright = (minc > 218) & ((maxc - minc) < 22)

    visited = np.zeros((height, width), dtype=bool)
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        for y in (0, height - 1):
            if bright[y, x] and not visited[y, x]:
                visited[y, x] = True
                queue.append((y, x))
    for y in range(height):
        for x in (0, width - 1):
            if bright[y, x] and not visited[y, x]:
                visited[y, x] = True
                queue.append((y, x))

    while queue:
        y, x = queue.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny = y + dy
            nx = x + dx
            if 0 <= ny < height and 0 <= nx < width and bright[ny, nx] and not visited[ny, nx]:
                visited[ny, nx] = True
                queue.append((ny, nx))

    rgba = np.dstack([arr, np.full((height, width), 255, dtype=np.uint8)])
    rgba[visited, 3] = 0
    return Image.fromarray(rgba, "RGBA")


def x_groups(alpha: np.ndarray, row: dict) -> list[list[int]]:
    y0 = int(row["y0"])
    y1 = int(row["y1"])
    x_min = int(row.get("x_min", 140))
    expected = int(row["frames"])
    gap = int(row.get("gap", 35))

    mask = alpha[y0:y1, x_min:] > 0
    columns = mask.any(axis=0)
    intervals: list[list[int]] = []
    running = False
    start = 0

    for i, visible in enumerate(columns):
        if visible and not running:
            start = i
            running = True
        if not visible and running:
            intervals.append([start + x_min, i + x_min])
            running = False
    if running:
        intervals.append([start + x_min, len(columns) + x_min])

    groups: list[list[int]] = []
    for left, right in intervals:
        if not groups or left - groups[-1][1] > gap:
            groups.append([left, right])
        else:
            groups[-1][1] = right

    while len(groups) > expected:
        smallest_gap, merge_at = min(
            (groups[i + 1][0] - groups[i][1], i) for i in range(len(groups) - 1)
        )
        _ = smallest_gap
        groups[merge_at][1] = groups[merge_at + 1][1]
        del groups[merge_at + 1]

    while len(groups) < expected and groups:
        _width, split_at = max((group[1] - group[0], i) for i, group in enumerate(groups))
        left, right = groups[split_at]
        mid = (left + right) // 2
        groups[split_at] = [left, mid]
        groups.insert(split_at + 1, [mid, right])

    return groups[:expected]


def bbox_for_group(alpha: np.ndarray, group: list[int], row: dict, pad: int = 8) -> tuple[int, int, int, int]:
    x0, x1 = group
    y0 = int(row["y0"])
    y1 = int(row["y1"])
    sub = alpha[y0:y1, x0:x1] > 0
    ys = np.where(sub.any(axis=1))[0]
    xs = np.where(sub.any(axis=0))[0]
    if len(xs) == 0 or len(ys) == 0:
        return x0, y0, x1, y1
    return (
        max(0, x0 + int(xs[0]) - pad),
        max(0, y0 + int(ys[0]) - pad),
        min(alpha.shape[1], x0 + int(xs[-1]) + 1 + pad),
        min(alpha.shape[0], y0 + int(ys[-1]) + 1 + pad),
    )


def connected_components(mask: np.ndarray) -> list[np.ndarray]:
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    comps: list[list[tuple[int, int]]] = []

    for y in range(height):
        for x in range(width):
            if not mask[y, x] or visited[y, x]:
                continue
            queue: deque[tuple[int, int]] = deque([(y, x)])
            visited[y, x] = True
            pixels: list[tuple[int, int]] = []
            while queue:
                cy, cx = queue.popleft()
                pixels.append((cy, cx))
                for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    ny = cy + dy
                    nx = cx + dx
                    if 0 <= ny < height and 0 <= nx < width and mask[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        queue.append((ny, nx))
            comp = np.zeros_like(mask, dtype=bool)
            for py, px in pixels:
                comp[py, px] = True
            comps.append(comp)
    return comps


def clean_orphans(crop: Image.Image, keep_all: bool) -> Image.Image:
    arr = np.array(crop.convert("RGBA"))
    mask = arr[:, :, 3] > 0
    comps = connected_components(mask)
    if not comps:
        return crop

    areas = [int(comp.sum()) for comp in comps]
    max_area = max(areas)
    keep = np.zeros_like(mask, dtype=bool)

    if not keep_all:
        keep |= comps[int(np.argmax(areas))]
    else:
        for comp, area in zip(comps, areas):
            ys, xs = np.where(comp)
            if not len(xs):
                continue
            width = int(xs.max() - xs.min() + 1)
            height = int(ys.max() - ys.min() + 1)
            if area >= max(24, max_area * 0.03) or (width >= 8 and height >= 8):
                keep |= comp

    arr[:, :, 3] = arr[:, :, 3] * keep.astype(np.uint8)
    return Image.fromarray(arr, "RGBA")


def normalize_frame(crop: Image.Image, size: int) -> Image.Image:
    bbox = crop.getbbox()
    if not bbox:
        return Image.new("RGBA", (size, size), (0, 0, 0, 0))
    crop = crop.crop(bbox)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    scale = min((size * 0.92) / crop.width, (size * 0.92) / crop.height)
    new_w = max(1, int(round(crop.width * scale)))
    new_h = max(1, int(round(crop.height * scale)))
    resized = crop.resize((new_w, new_h), Image.Resampling.NEAREST)
    x = (size - new_w) // 2
    y = max(0, min(size - new_h, int(round(size * 0.94 - new_h))))
    canvas.alpha_composite(resized, (x, y))
    return canvas


def save_strip(frames: list[Image.Image], path: Path) -> None:
    w, h = frames[0].size
    sheet = Image.new("RGBA", (w * len(frames), h), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        sheet.alpha_composite(frame, (i * w, 0))
    sheet.save(path)


def save_gif(frames: list[Image.Image], path: Path, duration: int) -> None:
    if len(frames) == 1:
        frames = [frames[0], frames[0]]
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=duration, loop=0, disposal=2)


def save_atlas(size: int, frames_by_slot: dict[str, list[Image.Image]], rows: list[dict], out_dir: Path) -> dict:
    total = sum(len(frames) for frames in frames_by_slot.values())
    cols = min(8, max(1, total))
    atlas_rows = math.ceil(total / cols)
    atlas = Image.new("RGBA", (cols * size, atlas_rows * size), (0, 0, 0, 0))
    data: dict[str, list[dict]] = {}
    index = 0
    row_by_slot = {row["slot"]: row for row in rows}

    for slot, frames in frames_by_slot.items():
        data[slot] = []
        row = row_by_slot[slot]
        for frame_index, frame in enumerate(frames):
            col = index % cols
            atlas_row = index // cols
            x = col * size
            y = atlas_row * size
            atlas.alpha_composite(frame, (x, y))
            data[slot].append({
                "frame": frame_index,
                "x": x,
                "y": y,
                "w": size,
                "h": size,
                "durationMs": int(row["duration"]),
                "pivot": [0.5, 0.94],
                "containsProp": bool(row.get("containsProp", False)),
            })
            index += 1

    atlas_dir = out_dir / "atlas"
    atlas_dir.mkdir(parents=True, exist_ok=True)
    atlas.save(atlas_dir / "atlas.png")
    return data


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--job", required=True)
    parser.add_argument("--out", default=None)
    parser.add_argument("--zip", action="store_true")
    args = parser.parse_args()

    repo_root = Path.cwd()
    job_path = (repo_root / args.job).resolve()
    job = json.loads(job_path.read_text())
    out_root = (repo_root / (args.out or job["outputRoot"])).resolve()

    if out_root.exists():
        shutil.rmtree(out_root)
    out_root.mkdir(parents=True, exist_ok=True)

    source_sheets = {}
    source_dir = out_root / "source-sheets"
    source_dir.mkdir(parents=True, exist_ok=True)
    for name, rel_path in job["sourceSheets"].items():
        src = repo_root / rel_path
        if not src.exists():
            raise FileNotFoundError(f"Missing source sheet: {rel_path}")
        transparent = remove_connected_bright_background(Image.open(src))
        transparent.save(source_dir / f"{name}_transparent.png")
        source_sheets[name] = transparent

    crops_by_slot = {}
    for row in job["rows"]:
        sheet = source_sheets[row["sheet"]]
        alpha = np.array(sheet.getchannel("A"))
        groups = x_groups(alpha, row)
        crops = []
        bboxes = []
        for group in groups:
            bbox = bbox_for_group(alpha, group, row)
            crop = sheet.crop(bbox)
            crop = clean_orphans(crop, keep_all=bool(row.get("containsProp", False)))
            crops.append(crop)
            bboxes.append(list(bbox))
        crops_by_slot[row["slot"]] = {"row": row, "crops": crops, "bboxes": bboxes}

    allowed_sizes = [int(size[0]) for size in job["allowedSizes"]]
    root_manifest = {
        "schemaVersion": "prismcade-game-ready-animation-pack-v0",
        "characterId": job["characterId"],
        "displayName": job["displayName"],
        "defaultFrameSize": job["defaultFrameSize"],
        "allowedSizes": job["allowedSizes"],
        "slots": {},
    }

    for size in allowed_sizes:
        size_dir = out_root / "runtime" / str(size)
        (size_dir / "frames").mkdir(parents=True, exist_ok=True)
        (size_dir / "strips").mkdir(parents=True, exist_ok=True)
        (size_dir / "gifs").mkdir(parents=True, exist_ok=True)
        frames_by_slot = {}
        size_manifest = {"frameSize": [size, size], "slots": {}}

        for slot, data in crops_by_slot.items():
            row = data["row"]
            frames = [normalize_frame(crop, size) for crop in data["crops"]]
            frames_by_slot[slot] = frames
            frame_dir = size_dir / "frames" / slot
            frame_dir.mkdir(parents=True, exist_ok=True)
            for i, frame in enumerate(frames):
                frame.save(frame_dir / f"{slot}_{i:03d}_{size}.png")
            strip = size_dir / "strips" / f"{slot}_{size}.png"
            gif = size_dir / "gifs" / f"{slot}_{size}.gif"
            save_strip(frames, strip)
            save_gif(frames, gif, int(row["duration"]))
            size_manifest["slots"][slot] = {
                "frameCount": len(frames),
                "durationMs": int(row["duration"]),
                "containsProp": bool(row.get("containsProp", False)),
                "framesDir": f"frames/{slot}",
                "strip": f"strips/{slot}_{size}.png",
                "gif": f"gifs/{slot}_{size}.gif",
                "sourceBboxes": data["bboxes"],
            }

        size_manifest["atlas"] = {
            "image": "atlas/atlas.png",
            "frames": save_atlas(size, frames_by_slot, job["rows"], size_dir),
        }
        (size_dir / "manifest.json").write_text(json.dumps(size_manifest, indent=2))

    for slot, data in crops_by_slot.items():
        row = data["row"]
        root_manifest["slots"][slot] = {
            "frameCount": len(data["crops"]),
            "durationMs": int(row["duration"]),
            "containsProp": bool(row.get("containsProp", False)),
            "defaultStrip": f"runtime/64/strips/{slot}_64.png",
            "defaultGif": f"runtime/64/gifs/{slot}_64.gif",
            "defaultFramesDir": f"runtime/64/frames/{slot}",
        }

    (out_root / "manifest.prismcade-character.json").write_text(json.dumps(root_manifest, indent=2))
    (out_root / "slice-row-config.json").write_text(json.dumps(job["rows"], indent=2))

    if args.zip:
        zip_path = out_root.with_suffix(".zip")
        if zip_path.exists():
            zip_path.unlink()
        with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for file in out_root.rglob("*"):
                archive.write(file, file.relative_to(out_root.parent))
        print(f"Wrote {zip_path}")
    print(f"Wrote {out_root}")


if __name__ == "__main__":
    main()
