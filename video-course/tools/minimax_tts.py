#!/usr/bin/env python3
"""Scene-based TTS. TTS is the timing authority.

Reads writing/scenes.json — { "scenes": [ { "id": "S001", "narration": "..." } ] } —
and generates ONE audio file per scene: audio/S001.mp3, ... Regenerate a single
scene with --only S003; never re-pay for the whole episode.

After all scene files exist, concatenates them into the archive
audio/narration.mp3 (guide §23 — scenes remain the timing authority; the
concatenation is for archive/reference only).

Providers:
  minimax — MiniMax Speech 2.8 HD cloud API (guide §22; needs MINIMAX_API_KEY,
            https://platform.minimax.io).
  edge    — Microsoft edge-tts, FREE, no account/key (the proven course voice,
            en-US-AndrewNeural — same male narrator used by the earlier
            terraform-azure-essentials production). Requires uvx on PATH.
  auto    (default) minimax when MINIMAX_API_KEY is set, otherwise edge.

Defaults come from config/voice.json (override by flags).
Env: MINIMAX_API_KEY (required for minimax), MINIMAX_API_BASE
(default https://api.minimax.io/v1; China: https://api.minimaxi.com/v1).

Usage:
  minimax_tts.py <episode-dir>            # uses <episode>/writing/scenes.json -> <episode>/audio/
  minimax_tts.py <episode-dir> --only S003,S007
  minimax_tts.py <episode-dir> --provider edge
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import time

import requests

HERE = os.path.dirname(os.path.abspath(__file__))
VIDEO_COURSE_ROOT = os.path.dirname(HERE)  # tools/ -> video-course/
DEFAULT_VOICE_CFG = os.path.join(VIDEO_COURSE_ROOT, "config", "voice.json")

API_KEY = os.getenv("MINIMAX_API_KEY")
API_BASE = os.getenv("MINIMAX_API_BASE", "https://api.minimax.io/v1").rstrip("/")

_WINGET_FFMPEG = os.path.expandvars(
    r"%LOCALAPPDATA%\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget"
    r".Source_8wekyb3d8bbwe\ffmpeg-*-full_build\bin\ffmpeg.exe")


def find_ffmpeg():
    """PATH first, then (Windows only) the winget ffmpeg install (not always on PATH)."""
    found = shutil.which("ffmpeg")
    if not found and os.name == "nt":
        import glob
        hits = glob.glob(_WINGET_FFMPEG)
        found = hits[0] if hits else None
    return found


def _pct(x, unit, label):
    """Map a 1.0-based factor to edge-tts's '+Nunit' string (e.g. '+0%')."""
    n = round((float(x) - 1.0) * 100)
    return f"{'+' if n >= 0 else ''}{n}{unit}"


def tts_edge(text, cfg, out_path, timeout=180):
    """Free edge-tts synthesis (no API key). Writes MP3 to out_path.

    Uses uvx edge-tts — same invocation the terraform-azure-essentials
    production used (en-US-AndrewNeural male narrator).
    """
    uvx = shutil.which("uvx")
    if not uvx:
        sys.exit("ERROR: uvx not found on PATH — required for the edge-tts "
                 "provider (install: pip install uv).")
    cmd = [uvx, "edge-tts",
           "--voice", cfg.get("edge_voice", "en-US-AndrewNeural")]
    if float(cfg.get("speed", 1.0)) != 1.0:
        cmd += ["--rate", _pct(cfg["speed"], "%", "rate")]
    if float(cfg.get("vol", 1.0)) != 1.0:
        cmd += ["--volume", _pct(cfg["vol"], "%", "volume")]
    if int(cfg.get("pitch", 0)) != 0:
        cmd += ["--pitch", f"{'+' if int(cfg['pitch']) >= 0 else ''}{int(cfg['pitch'])}Hz"]
    cmd += ["--text", text, "--write-media", out_path]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    if r.returncode != 0 or not os.path.isfile(out_path) or os.path.getsize(out_path) == 0:
        # raise (not sys.exit) so the caller's bounded retry can re-run the scene
        raise RuntimeError(f"edge-tts failed (rc={r.returncode}): {r.stderr.strip()[:400]}")


def tts(text, cfg, timeout=120):
    """Sync TTS via t2a_v2. Returns raw audio bytes."""
    if not API_KEY:
        sys.exit("ERROR: MINIMAX_API_KEY is not set.")
    voice_setting = {"voice_id": cfg["voice_id"], "speed": cfg["speed"],
                     "vol": cfg["vol"], "pitch": cfg["pitch"]}
    if cfg.get("emotion"):
        voice_setting["emotion"] = cfg["emotion"]
    payload = {
        "model": cfg["model"],
        "text": text,
        "stream": False,
        "voice_setting": voice_setting,
        "audio_setting": {"sample_rate": 32000, "bitrate": 128000,
                          "format": cfg["audio_format"], "channel": 1},
        "language_boost": "auto",
        "output_format": "hex",
    }
    resp = requests.post(f"{API_BASE}/t2a_v2",
                         headers={"Authorization": f"Bearer {API_KEY}",
                                  "Content-Type": "application/json"},
                         json=payload, timeout=timeout)
    resp.raise_for_status()
    data = resp.json()
    base_resp = data.get("base_resp", {})
    if base_resp.get("status_code", 0) != 0:
        sys.exit(f"MiniMax API error {base_resp.get('status_code')}: "
                 f"{base_resp.get('status_msg')}")
    audio_hex = (data.get("data") or {}).get("audio")
    if not audio_hex:
        sys.exit(f"Unexpected response (no audio): {json.dumps(data)[:500]}")
    return bytes.fromhex(audio_hex)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("episode_dir")
    ap.add_argument("--only", help="comma-separated scene ids to (re)generate")
    ap.add_argument("--voice-config", default=DEFAULT_VOICE_CFG)
    ap.add_argument("--voice");  ap.add_argument("--model")
    ap.add_argument("--provider", choices=["auto", "minimax", "edge"],
                    default="auto",
                    help="TTS provider (default: auto = minimax if MINIMAX_API_KEY "
                         "is set, else free edge-tts)")
    args = ap.parse_args()

    cfg = json.load(open(args.voice_config, encoding="utf-8"))
    if args.voice: cfg["voice_id"] = args.voice
    if args.model: cfg["model"] = args.model

    if args.provider == "edge":
        provider = "edge"
    elif args.provider == "minimax":
        provider = "minimax"
    else:
        provider = "minimax" if API_KEY else "edge"
    if provider == "edge":
        fmt = "mp3"  # edge-tts outputs mp3
        print(f"provider: edge-tts (free, no API key) — voice {cfg.get('edge_voice', 'en-US-AndrewNeural')}")
    else:
        fmt = cfg["audio_format"]
        print(f"provider: minimax {cfg['model']}")

    scenes_path = os.path.join(args.episode_dir, "writing", "scenes.json")
    doc = json.load(open(scenes_path, encoding="utf-8"))
    scenes = doc["scenes"]
    only = set(args.only.split(",")) if args.only else None
    audio_dir = os.path.join(args.episode_dir, "audio")
    os.makedirs(audio_dir, exist_ok=True)

    def synth(text, path):
        """One TTS call -> path, with bounded retry on transient failures."""
        if provider == "edge":
            tmp = path + ".tmp.mp3"
            try:
                last_err = None
                for attempt in range(3):  # bounded retry: transient network hiccups
                    try:
                        tts_edge(text, cfg, tmp)
                        os.replace(tmp, path)
                        return
                    except (RuntimeError, subprocess.SubprocessError) as e:
                        last_err = e
                        time.sleep(2 * (attempt + 1))
                sys.exit(f"edge-tts failed after 3 attempts: {last_err}")
            finally:
                if os.path.exists(tmp):
                    os.remove(tmp)
        else:
            open(path, "wb").write(tts(text, cfg))

    def concat(parts, out_path):
        """ffmpeg-concat step audios into the scene file (same codec)."""
        ffmpeg = find_ffmpeg()
        if not ffmpeg:
            sys.exit("ffmpeg not found — required to concatenate step audios.")
        lst = out_path + ".concat.txt"
        with open(lst, "w", encoding="utf-8") as f:
            for p in parts:
                # ffmpeg resolves list entries against the LIST FILE's directory,
                # so these must be absolute
                esc = os.path.abspath(p).replace("\\", "/").replace("'", "'\\''")
                f.write(f"file '{esc}'\n")
        r = subprocess.run([ffmpeg, "-y", "-f", "concat", "-safe", "0", "-i", lst,
                            "-c", "copy", out_path], capture_output=True, text=True)
        os.remove(lst)
        if r.returncode != 0 or not os.path.isfile(out_path) or os.path.getsize(out_path) == 0:
            sys.exit(f"step concat failed for {out_path}: {r.stderr.strip()[:400]}")

    for s in scenes:
        sid = s["id"]
        if only and sid not in only:
            continue
        steps = s.get("steps") or []
        if steps:
            # Narration-synced diagram scene: one TTS call per step, then the
            # step files are concatenated into the scene file. TTS (measured
            # per step) stays the timing authority for highlight changes.
            step_paths, step_keys = [], []
            for i, st in enumerate(steps, 1):
                text = st.get("narration", "").strip()
                if not text:
                    sys.exit(f"Scene {sid} step {i} has empty narration.")
                spath = os.path.join(audio_dir, f"{sid}.step{i}.{fmt}")
                synth(text, spath)
                step_paths.append(spath)
                step_keys.append(f"audio/{sid}.step{i}.{fmt}")
                print(f"  {sid}.step{i}: {os.path.getsize(spath)//1024} KB")
            path = os.path.join(audio_dir, f"{sid}.{fmt}")
            concat(step_paths, path)
            s["step_audio"] = step_keys
            s["audio"] = f"audio/{sid}.{fmt}"
            print(f"  {sid}: {len(steps)} steps concatenated -> {path}")
        else:
            text = s.get("narration", "").strip()
            if not text:
                sys.exit(f"Scene {sid} has empty narration — fix scenes.json first.")
            if len(text) > 9000:
                sys.exit(f"Scene {sid} is {len(text)} chars (>9000). Split it.")
            path = os.path.join(audio_dir, f"{sid}.{fmt}")
            synth(text, path)
            s["audio"] = f"audio/{sid}.{fmt}"
            print(f"  {sid}: {os.path.getsize(path)//1024} KB -> {path}")

    # persist the audio path mapping back into scenes.json (whole doc — the
    # top-level title/lesson_label must survive the rewrite)
    with open(scenes_path, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2, ensure_ascii=False)
    print("scenes.json updated with audio paths.")

    # archive narration.mp3 = all scene files in order (needs every scene present)
    fmts = {"audio_format": fmt}
    expected = [os.path.join(audio_dir, f"{s['id']}.{fmt}") for s in scenes]
    if all(os.path.isfile(p) for p in expected):
        ffmpeg = find_ffmpeg()
        if not ffmpeg:
            print("ffmpeg not found — skipped archive narration.mp3 concat.")
            return
        lst = os.path.join(audio_dir, "concat.txt")
        with open(lst, "w", encoding="utf-8") as f:
            for p in expected:
                esc = p.replace("\\", "/").replace("'", "'\\''")
                f.write(f"file '{esc}'\n")
        out_mp3 = os.path.join(audio_dir, "narration.mp3")
        subprocess.run([ffmpeg, "-y", "-f", "concat", "-safe", "0", "-i", lst,
                       "-c", "copy", out_mp3], capture_output=True)
        os.remove(lst)
        print(f"archive narration.mp3 -> {out_mp3}")
    else:
        print("some scene audio missing — archive narration.mp3 not rebuilt.")


if __name__ == "__main__":
    main()
