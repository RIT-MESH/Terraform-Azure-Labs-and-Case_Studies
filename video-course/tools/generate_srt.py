#!/usr/bin/env python3
"""Generate the separate SRT for an episode, timed from ACTUAL audio.

Policy (render.json): the SRT is standalone — never burned into the MP4, never
embedded as a subtitle stream, never rendered by Remotion.

Timing sources, in preference order:
  1. timing/timestamps.json with whisperx word alignment -> accurate cue breaks
  2. scene-level timing from timing/timed-scenes.json -> narration distributed
     evenly across the scene duration (fallback)

Cue style (render.json srt_style): 1-2 lines, ~35-45 chars/line, 1.5-6s per cue,
no overlaps; technical identifiers (paths, resource refs) are kept on one line.
Editor instructions are never put in the SRT (they never enter narration either).

Output: captions/episode.srt and final/episode.srt

Usage: generate_srt.py <episode-dir>
"""
import argparse
import json
import os
import re
import shutil
import sys

VIDEO_COURSE_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RENDER_CFG = os.path.join(VIDEO_COURSE_ROOT, "config", "render.json")


def fmt_ts(sec):
    ms = round(sec * 1000)
    h, ms = divmod(ms, 3600000); m, ms = divmod(ms, 60000); s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def split_cues(text, maxlen):
    """Greedy word-wrap cue text; keep identifiers (no-space tokens) intact."""
    words = text.split()
    lines, cur = [], ""
    for w in words:
        if cur and len(cur) + 1 + len(w) > maxlen:
            lines.append(cur); cur = w
        else:
            cur = f"{cur} {w}".strip()
    if cur:
        lines.append(cur)
    return lines or [""]


def scene_cues(narration, start, dur, style):
    """Distribute narration into 1.5-6s cues proportionally to word count."""
    min_t, max_t = style["segment_sec"]
    maxchars = style["chars_per_line"][1]
    sentences = [s.strip() for s in re.split(r"(?<=[.!?])\s+(?![\"'])", narration) if s.strip()]
    if not sentences:
        return [(start, start + dur, narration)]
    words = [len(s.split()) for s in sentences]
    total = sum(words) or 1
    cues, t = [], start
    i = 0
    while i < len(sentences):
        seg, seg_words = [sentences[i]], words[i]
        seg_t = max(min_t, dur * words[i] / total)
        while (i + 1 < len(sentences) and seg_t < max_t
               and len(" ".join(seg + [sentences[i + 1]])) <= 2 * maxchars):
            i += 1
            seg.append(sentences[i])
            seg_words += words[i]
            seg_t = max(min_t, dur * seg_words / total)
        end = min(t + max(min(seg_t, max_t), min_t), start + dur)
        cues.append((t, end, " ".join(seg)))
        t = end
        i += 1
    # stretch final cue to scene end
    if cues:
        s0, _, txt = cues[-1]
        cues[-1] = (s0, start + dur, txt)
    return cues


def word_aligned_cues(scene, style):
    words = scene.get("words") or []
    if not words:
        return None
    maxchars = style["chars_per_line"][1] * 2
    min_t, max_t = style["segment_sec"]
    cues, buf, t0 = [], [], None
    for w in words:
        if t0 is None:
            t0 = w["start"]
        buf.append(w["word"])
        txt = " ".join(buf)
        if (w["end"] - t0) >= max_t or len(txt) > maxchars or re.search(r"[.!?]$", w["word"]):
            cues.append((t0, w["end"], txt)); buf, t0 = [], None
    if buf:
        cues.append((t0, words[-1]["end"], " ".join(buf)))
    return cues


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("episode_dir")
    args = ap.parse_args()
    ep = args.episode_dir

    cfg = json.load(open(RENDER_CFG, encoding="utf-8"))
    style = cfg["srt_style"]
    fps = json.load(open(os.path.join(VIDEO_COURSE_ROOT, "config", "theme.json"),
                         encoding="utf-8"))["fps"]

    scenes_def = {s["id"]: s for s in json.load(
        open(os.path.join(ep, "writing", "scenes.json"), encoding="utf-8"))["scenes"]}
    timed = json.load(open(os.path.join(ep, "timing", "timed-scenes.json"),
                           encoding="utf-8"))
    ts_path = os.path.join(ep, "timing", "timestamps.json")
    aligned = {}
    if os.path.isfile(ts_path):
        ts = json.load(open(ts_path, encoding="utf-8"))
        if ts.get("mode") == "whisperx-word-alignment":
            aligned = {s["id"]: s for s in ts["scenes"]}

    cues = []
    for sc in timed["scenes"]:
        sid = sc["id"]
        start = sc["starts_at_frame"] / fps
        dur = sc["audio_frames"] / fps
        text = scenes_def[sid].get("narration", "").strip()
        # MiniMax pause tags (<#0.8#>) control TTS delivery only — never subtitle text
        text = re.sub(r"<#\d+(?:\.\d+)?#>", " ", text)
        text = re.sub(r"\s+", " ", text).strip()
        if not text:
            continue
        wc = word_aligned_cues(aligned.get(sid, {}), style)
        if wc:
            cues.extend((start + a, start + b, t) for a, b, t in wc)
        else:
            cues.extend(scene_cues(text, start, dur, style))

    # enforce: no overlaps, ordered
    cues.sort(key=lambda c: c[0])
    fixed = []
    for i, (a, b, t) in enumerate(cues):
        if fixed and a < fixed[-1][1]:
            a = fixed[-1][1]
        if b - a < 0.3:
            b = a + 0.3
        fixed.append((a, b, t))

    srt_lines = []
    for i, (a, b, t) in enumerate(fixed, 1):
        body = "\n".join(split_cues(t, style["chars_per_line"][1])[: style["max_lines"]])
        srt_lines.append(f"{i}\n{fmt_ts(a)} --> {fmt_ts(b)}\n{body}\n")
    srt = "\n".join(srt_lines)

    os.makedirs(os.path.join(ep, "captions"), exist_ok=True)
    os.makedirs(os.path.join(ep, "final"), exist_ok=True)
    cap = os.path.join(ep, "captions", "episode.srt")
    fin = os.path.join(ep, "final", "episode.srt")
    open(cap, "w", encoding="utf-8").write(srt)
    shutil.copyfile(cap, fin)
    print(f"-> {cap}\n-> {fin} ({len(fixed)} cues)")


if __name__ == "__main__":
    main()
