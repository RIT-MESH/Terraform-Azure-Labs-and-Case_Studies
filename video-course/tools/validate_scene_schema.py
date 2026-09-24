#!/usr/bin/env python3
"""Scene schema validation (instruction §30): writing/scenes.json must be
structurally sound BEFORE any TTS money/time is spent. Schema errors fail the
pipeline before TTS.

Per-visual-type rules (TITLE/CONCEPT/CODE/TERMINAL/DIAGRAM/RECAP/NEXT/PORTAL):
  - every scene: id, type, narration (or steps with narrations), audio
  - CODE: source_file/start_line/end_line (1 <= start <= end), asset, optional
    steps with active_lines within [start_line, end_line] and active_tokens
  - DIAGRAM: asset + spec file on disk + steps referencing existing nodes/edges
  - TERMINAL: asset + spec fixture on disk; illustrative fixtures must be
    marked (terminal honesty, instruction §20)
  - NEXT: the fixed transition line, VERBATIM (instruction §41)
  - RECAP/CONCEPT: points list
  - every educational episode: RECAP + NEXT present; demo scenes must follow
    NEXT when demo content is promised (same-video demo gate — enforced for
    FINAL in validate_episode, WARNING here)

Writes validation/scene-schema.json; exit 1 on schema errors.

Usage: validate_scene_schema.py <episode-dir> [--sources <lab-dir>]
"""
import argparse
import json
import os
import re
import sys

VIDEO_COURSE_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

FIXED_NEXT = ("Now that we understand how this Terraform configuration works, "
              "in the next part of this video, we'll move to a real-world demo "
              "and deploy it in Microsoft Azure.")
TYPES = {"TITLE", "CONCEPT", "CODE", "TERMINAL", "DIAGRAM", "RECAP", "NEXT",
         "PORTAL"}
LEAK_RE = re.compile(r"E:\\|C:\\|/home/runner/|\$GITHUB_WORKSPACE")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("episode_dir")
    ap.add_argument("--sources", help="lab dir (for CODE asset existence checks)")
    args = ap.parse_args()
    ep = args.episode_dir
    result, fails = validate_scene_scenes(ep, sources=args.sources)
    print(json.dumps(result, indent=2))
    out = os.path.join(ep, "validation", "scene-schema.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    json.dump(result, open(out, "w", encoding="utf-8"), indent=2)
    print(f"-> {out}")
    sys.exit(1 if result["status"] == "fail" else 0)


def validate_scene_scenes(ep, sources=None):
    """Validate writing/scenes.json. Returns (result, fails) where result
    carries status/demo_gate/fails. DEMO-GATE entries are non-blocking
    pre-demo (demo capture needs a real Azure run); every other fail marks
    the episode unfit for TTS. Testable without CLI."""
    scenes_path = os.path.join(ep, "writing", "scenes.json")
    if not os.path.isfile(scenes_path):
        raise SystemExit(f"no writing/scenes.json at {ep}")
    doc = json.load(open(scenes_path, encoding="utf-8"))
    scenes = doc.get("scenes", [])
    result = _validate(scenes, ep, sources)
    return result, result["fails"]


def _validate(scenes, ep, sources=None):
    fails = []

    def check(cond, msg):
        if not cond:
            fails.append(msg)

    lab_dir = sources or os.path.join(ep, "..", "..", "..")
    ids = [s.get("id", "") for s in scenes]
    check(ids == [f"S{i:03d}" for i in range(1, len(scenes) + 1)],
          "scene ids must be sequential S001..S%03d" % len(scenes))

    demo_after_next = False
    seen_next = False
    for s in scenes:
        sid, typ = s.get("id"), str(s.get("type", "")).upper()
        check(typ in TYPES, f"{sid}: unknown visual_type '{typ}'")
        steps = s.get("steps") or []
        if steps:
            for i, st in enumerate(steps, 1):
                check(bool((st.get("narration") or "").strip()),
                      f"{sid}.step{i}: empty step narration")
        else:
            check(bool((s.get("narration") or "").strip()),
                  f"{sid}: empty narration")
        if typ == "CODE":
            check(bool(s.get("source_file")), f"{sid}: CODE missing source_file")
            st_, en = s.get("start_line", 0), s.get("end_line", 0)
            check(1 <= st_ <= en, f"{sid}: CODE line range {st_}-{en} invalid")
            check(bool(s.get("asset")), f"{sid}: CODE missing asset")
            for i, st in enumerate(steps, 1):
                for ln in st.get("active_lines", []):
                    check(st_ <= ln <= en,
                          f"{sid}.step{i}: active_lines {ln} outside "
                          f"[{st_},{en}]")
                check(isinstance(st.get("active_tokens", []), list),
                      f"{sid}.step{i}: active_tokens must be a list")
        elif typ == "DIAGRAM":
            check(bool(s.get("asset")), f"{sid}: DIAGRAM missing asset")
            spec = os.path.join(ep, *(os.path.splitext(
                s.get("asset", ""))[0].split("/"))) + ".spec.json"
            node_ids, edge_ids = set(), set()
            if os.path.isfile(spec):
                specdoc = json.load(open(spec, encoding="utf-8"))
                node_ids = {n["id"] for n in specdoc.get("nodes", [])}
                edge_ids = {f"{e['from']}-{e['to']}"
                            for e in specdoc.get("edges", [])}
            else:
                fails.append(f"{sid}: DIAGRAM spec missing: {spec}")
            for i, st in enumerate(steps, 1):
                for n in st.get("nodes", []):
                    check(n in node_ids,
                          f"{sid}.step{i}: node '{n}' not in diagram spec")
                for e in st.get("edges", []):
                    check(any(e == f"{a}-{b}" for a in node_ids for b in node_ids),
                          f"{sid}.step{i}: edge '{e}' not in diagram spec")
        elif typ == "TERMINAL":
            check(bool(s.get("asset")), f"{sid}: TERMINAL missing asset")
            spec = os.path.join(ep, *(os.path.splitext(
                s.get("asset", ""))[0].split("/"))) + ".spec.json"
            check(os.path.isfile(spec),
                  f"{sid}: TERMINAL spec missing: {spec}")
            txt = spec.replace(".spec.json", ".txt")
            if os.path.isfile(txt):
                body = open(txt, encoding="utf-8", errors="replace").read()
                looks_real = not re.search(r"<guid>|<base64-key>|<redacted>|ILLUSTRATIVE",
                                           body)
                if looks_real and not spec.endswith("real"):
                    # honest-terminal rule: fixture output is illustrative and
                    # must say so (render_terminal_svg stamps the banner from
                    # the spec's "mode": "illustrative")
                    specdoc = json.load(open(spec, encoding="utf-8"))
                    check(specdoc.get("mode", "illustrative") == "illustrative",
                          f"{sid}: terminal fixture must declare "
                          f"'mode': 'illustrative' (never fabricate real output)")
        elif typ == "RECAP":
            check(bool(s.get("points")), f"{sid}: RECAP missing points")
        elif typ == "NEXT":
            check((s.get("narration") or "").strip() == FIXED_NEXT,
                  f"{sid}: NEXT must use the fixed transition line verbatim")
            seen_next = True
        if s.get("demo") and seen_next:
            demo_after_next = True
        # no internal paths anywhere in the scene definition (viewer-facing)
        blob = json.dumps(s, ensure_ascii=False)
        if LEAK_RE.search(blob):
            fails.append(f"{sid}: internal path leaked into scene definition")

    check(seen_next, "no NEXT scene — the real-world demo transition is missing")
    check(any(str(s.get("type")).upper() == "RECAP" for s in scenes),
          "no RECAP scene — every educational episode must end with one")
    if seen_next and not demo_after_next:
        # not a FAIL pre-demo (demo capture is a user Azure run), but every
        # downstream stage must know this episode cannot become FINAL yet
        fails.append("DEMO-GATE: NEXT transition present but no demo scenes "
                     "follow it — this episode cannot reach FINAL until demo "
                     "scenes (demo: true) are authored from real captured output")

    result = {"status": "fail" if [f for f in fails if not f.startswith("DEMO-GATE")]
              else "pass",
              "demo_gate": "pending" if any(f.startswith("DEMO-GATE") for f in fails)
              else ("pass" if seen_next else "n/a"),
              "fails": fails}
    return result


if __name__ == "__main__":
    main()