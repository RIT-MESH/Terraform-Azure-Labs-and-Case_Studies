#!/usr/bin/env python3
"""Automated QC for the rendered episode (step 15).

Checks final/episode.mp4 against timing/timed-scenes.json + config/theme.json:
  - file exists and has a video AND an audio stream
  - duration within 0.5s of expected total frames / fps
  - resolution matches theme
  - fps matches theme
  - final/episode.srt exists as a SEPARATE file (never inside the MP4)
  - MP4 contains no embedded subtitle stream (SRT policy: external only)

Usage: quality_check.py <episode-dir>
Exit 1 on any failed check.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VIDEO_COURSE_ROOT = os.path.dirname(HERE)  # tools/ -> video-course/
THEME_CFG = os.path.join(VIDEO_COURSE_ROOT, "config", "theme.json")

_WINGET_FFMPEG_BIN = os.path.expandvars(
    r"%LOCALAPPDATA%\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget"
    r".Source_8wekyb3d8bbwe\ffmpeg-*-full_build\bin")


def _ffprobe():
    """PATH first, then (Windows only) the winget ffmpeg install (not always on PATH)."""
    import glob
    found = shutil.which("ffprobe")
    if found or os.name != "nt":
        return found
    hits = glob.glob(os.path.join(_WINGET_FFMPEG_BIN, "ffprobe.exe"))
    return hits[0] if hits else None


def probe(path):
    p = subprocess.run([_ffprobe(), "-v", "quiet", "-print_format", "json",
                        "-show_format", "-show_streams", path],
                       capture_output=True, text=True)
    return json.loads(p.stdout) if p.returncode == 0 else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("episode_dir")
    args = ap.parse_args()
    ep = args.episode_dir

    if _ffprobe() is None:
        sys.exit("ffprobe not found (PATH and winget install).")

    mp4 = os.path.join(ep, "final", "episode.mp4")
    checks, ok = [], True

    def check(name, passed, detail=""):
        nonlocal ok
        checks.append({"check": name, "passed": passed, "detail": detail})
        ok = ok and passed

    check("file exists", os.path.isfile(mp4), mp4)
    check("separate episode.srt exists", os.path.isfile(os.path.join(ep, "final", "episode.srt")),
          os.path.join(ep, "final", "episode.srt"))
    if os.path.isfile(mp4):
        info = probe(mp4)
        check("ffprobe readable", info is not None)
        if info:
            streams = [s["codec_type"] for s in info.get("streams", [])]
            check("has video stream", "video" in streams, str(streams))
            check("has audio stream", "audio" in streams, str(streams))
            check("no embedded subtitle stream", "subtitle" not in streams, str(streams))
            theme = json.load(open(THEME_CFG, encoding="utf-8"))
            vids = [s for s in info["streams"] if s["codec_type"] == "video"]
            if vids:
                res_ok = (vids[0]["width"] == theme["resolution"]["width"]
                          and vids[0]["height"] == theme["resolution"]["height"])
                check("resolution matches theme", res_ok,
                      f"{vids[0]['width']}x{vids[0]['height']}")
                rate = vids[0].get("r_frame_rate", "")
                try:
                    num, den = (int(x) for x in rate.split("/"))
                    check("fps matches theme", abs(num / den - theme["fps"]) < 0.01,
                          f"{rate} (expected {theme['fps']} fps)")
                except (ValueError, ZeroDivisionError):
                    check("fps matches theme", False, f"unparseable r_frame_rate: {rate!r}")
            ts_path = os.path.join(ep, "timing", "timed-scenes.json")
            if os.path.isfile(ts_path):
                ts = json.load(open(ts_path, encoding="utf-8"))
                expected = ts["total_duration_frames"] / ts["fps"]
                actual = float(info["format"]["duration"])
                check("duration matches timeline", abs(actual - expected) <= 0.5,
                      f"expected {expected:.2f}s, actual {actual:.2f}s")

    report = {"episode": os.path.abspath(ep), "qc_passed": ok, "checks": checks}
    out = os.path.join(ep, "validation", "quality-check.json")
    json.dump(report, open(out, "w", encoding="utf-8"), indent=2)
    print(json.dumps(report, indent=2))
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
