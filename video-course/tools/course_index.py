#!/usr/bin/env python3
"""Shared course index: THE one lab resolver for every tool.

All scripts that need to turn "Lab 17" (or "17", or a folder name) into
ACTIVE_LAB must use this module — never a private prefix-matching heuristic
(generate_course.py and sync_ci_inputs.py used to disagree; that is the bug
this module removes).

Resolution order (course policy):
  1. numeric directory prefix   "NN-…" under any section-*
  2. course-manifest.json mapping (canonical global numbering)
  3. ordered discovery index (discover_labs.py order)
Ambiguity fails loudly; nothing is ever guessed.

Importable (from generate_course.py, sync_ci_inputs.py, cloud_render.py,
tests, …) AND runnable as a CLI for debugging:

    course_index.py resolve --lab 17 [--root E:/labs]
    course_index.py discover [--root E:/labs]
"""
import argparse
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VC = os.path.dirname(HERE)  # tools/ -> video-course/
MANIFEST = os.path.join(VC, "course-manifest.json")
COURSE_CFG = os.path.join(VC, "config", "course.json")


def course_cfg():
    with open(COURSE_CFG, encoding="utf-8") as f:
        return json.load(f)


def public_lab_url(ep, course=None):
    """Viewer-facing GitHub URL for a lab episode record (never a local path)."""
    course = course or course_cfg()
    rel = ep["path"].replace("\\", "/")
    return f"{course['public_labs_root']}/{rel}"


def discover_labs(root):
    """Ordered discovery index (section-*, NN- name, contains .tf)."""
    sys.path.insert(0, HERE)
    from discover_labs import discover  # single source of ordering truth
    return discover(root)


def load_course_manifest(root, rebuild=False, manifest_path=None):
    """Canonical lab-number -> lab mapping. rebuild=True re-discovers against
    `root` (CI: the committed manifest records authoring-PC paths)."""
    manifest_path = manifest_path or MANIFEST
    if not rebuild and os.path.isfile(manifest_path):
        with open(manifest_path, encoding="utf-8") as f:
            return json.load(f)["labs"]
    labs = discover_labs(root)
    course = course_cfg()
    doc = {"labs": [
        {**ep, "number": i + 1, "public_lab_url": public_lab_url(ep, course)}
        for i, ep in enumerate(labs)
    ]}
    os.makedirs(os.path.dirname(manifest_path), exist_ok=True)
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2)
    return doc["labs"]


def resolve_lab(lab_ref, labs):
    """'01' / '1' / exact dir name / unique substring. Ambiguous -> SystemExit."""
    if lab_ref in (None, "all"):
        return list(labs)
    ref = str(lab_ref)
    prefix_hits = [l for l in labs if l["lab"].startswith(ref.zfill(2) + "-")]
    name_hits = [l for l in labs if ref.lower() in l["lab"].lower()]
    number_hits = [l for l in labs if ref.lstrip("0").isdigit()
                   and l.get("number") == int(ref.lstrip("0"))]
    if len(prefix_hits) == 1:
        return prefix_hits
    if number_hits:
        return number_hits[:1]  # canonical global numbering from the manifest
    if len(name_hits) == 1:
        return name_hits
    cand = (prefix_hits or name_hits)[:5]
    raise SystemExit(
        f"lab '{lab_ref}' is unknown or ambiguous. "
        f"Candidates: {[c['path'] for c in cand]}")


def episode_dir(ep, video_course_root=None):
    """Episode folder: <video-course>/output/<section>/<lab> (portable: same on
    the authoring PC and the CI runner)."""
    vc = video_course_root or VC
    return os.path.join(vc, "output", ep["section"], ep["lab"])


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["resolve", "discover"])
    ap.add_argument("--lab")
    ap.add_argument("--root", default=os.environ.get("COURSE_SOURCE_ROOT", r"E:\labs"))
    ap.add_argument("--rebuild-manifest", action="store_true")
    args = ap.parse_args()
    labs = load_course_manifest(args.root, rebuild=args.rebuild_manifest)
    if args.cmd == "discover":
        print(json.dumps(labs, indent=2))
        return
    hits = resolve_lab(args.lab, labs)
    print(json.dumps(hits, indent=2))


if __name__ == "__main__":
    main()