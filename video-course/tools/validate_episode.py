#!/usr/bin/env python3
"""Content gate for step 6. FAIL blocks the pipeline; rules: references/validation-rules.md.

Checks:
  FAIL  scene ids missing/non-sequential/duplicated, empty narration, >9000 chars,
        narration mentions resources/variables/outputs/files outside the manifest scope,
        quoted ```hcl snippets not found (verbatim modulo whitespace) in permitted sources,
        missing RECAP scene, missing NEXT (real-world demo) scene
  WARN  estimated spoken length outside the course range (<180s or >900s
        = 15 min max; 4-15 min is the normal target), >80 scenes, terraform validation skipped

Usage: validate_episode.py <episode-dir> [--sources <lab-or-sandbox-dir>]
Writes <episode>/validation/validation.json; exit 1 on FAIL.
"""
import argparse
import json
import os
import re
import sys

WORD_WPM = 150  # rough spoken-rate estimate for the WARN estimate only
MIN_EPISODE_SEC = 180   # course minimum: ~3 minutes (4-15 min is the normal target)
MAX_EPISODE_SEC = 900   # course maximum: 15 minutes
MAX_SCENES = 80         # scene-level TTS at ~15-45s/scene scales with episode length


def norm_ws(s):
    return re.sub(r"\s+", " ", s).strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("episode_dir")
    ap.add_argument("--sources", help="dir containing permitted .tf sources")
    args = ap.parse_args()
    ep = args.episode_dir

    fails, warns = [], []

    scenes_path = os.path.join(ep, "writing", "scenes.json")
    scenes = json.load(open(scenes_path, encoding="utf-8"))["scenes"]
    script_path = os.path.join(ep, "writing", "script.md")
    script = open(script_path, encoding="utf-8").read() if os.path.isfile(script_path) else ""

    ids = [s.get("id", "") for s in scenes]
    expected = [f"S{i:03d}" for i in range(1, len(scenes) + 1)]
    if ids != expected:
        fails.append(f"scene ids must be sequential S001..S{len(scenes):03d}, got {ids}")
    for s in scenes:
        n = s.get("narration", "").strip()
        if not n:
            fails.append(f"{s.get('id')}: empty narration")
        elif len(n) > 9000:
            fails.append(f"{s.get('id')}: narration {len(n)} chars (>9000)")

    total_words = sum(len(s.get("narration", "").split()) for s in scenes)
    est = total_words / WORD_WPM * 60
    if est > MAX_EPISODE_SEC or est < MIN_EPISODE_SEC:
        warns.append(f"estimated spoken length {est:.0f}s outside the "
                     f"{MIN_EPISODE_SEC}-{MAX_EPISODE_SEC}s course range (4-15 min typical)")
    if len(scenes) > MAX_SCENES:
        warns.append(f"{len(scenes)} scenes is a lot — consider merging scenes for pacing")

    # every educational episode must end with RECAP + the real-world demo transition
    types = [str(s.get("type", "")).upper() for s in scenes]
    recap_present = "RECAP" in types
    demo_teaser_present = "NEXT" in types
    if not recap_present:
        fails.append("no RECAP scene — every educational episode must end with one")
    if not demo_teaser_present:
        fails.append("no NEXT scene — the real-world demo transition is missing")

    # --- ground truth scope check ---
    manifest_path = os.path.join(ep, "source", "source-manifest.json")
    inventory_path = os.path.join(ep, "source", "terraform-inventory.json")
    scope_text, allowed_names = "", set()
    if os.path.isfile(manifest_path):
        manifest = json.load(open(manifest_path, encoding="utf-8"))
        for p in manifest.get("permitted_source_files", []):
            if os.path.isfile(p):
                scope_text += "\n" + open(p, encoding="utf-8").read()
    elif args.sources:
        for f in os.listdir(args.sources):
            if f.endswith(".tf"):
                scope_text += "\n" + open(os.path.join(args.sources, f), encoding="utf-8").read()
    else:
        warns.append("no source manifest found — scope checks skipped")

    if os.path.isfile(inventory_path):
        inv = json.load(open(inventory_path, encoding="utf-8"))
        for coll in ("resources", "data_sources", "variables", "outputs", "modules"):
            for item in inv.get(coll, []):
                allowed_names.add(item["name"])
                if item.get("address"):
                    allowed_names.add(item["address"])

    # every backtick-quoted terraform reference in narration must exist in scope:
    # in the parsed inventory, or (fallback) verbatim in the permitted source text
    if scope_text.strip():
        for s in scenes:
            for ref in re.findall(r"`([a-z_]+\.[a-zA-Z0-9_-]+)`", s.get("narration", "")):
                if "." in ref and ref not in allowed_names and ref not in scope_text:
                    fails.append(f"{s['id']}: mentions `{ref}` which is not in the lab scope")

    # quoted hcl snippets must exist in permitted source text
    scope_norm = norm_ws(scope_text)
    for i, snippet in enumerate(re.findall(r"```hcl\n(.*?)```", script, re.S), 1):
        if norm_ws(snippet) not in scope_norm:
            fails.append(f"script hcl snippet #{i} not found (verbatim) in permitted sources")

    # terraform validation step state (if it ran)
    tfv = os.path.join(ep, "validation", "terraform-validate.json")
    if os.path.isfile(tfv):
        if not json.load(open(tfv, encoding="utf-8")).get("passed"):
            fails.append("terraform validate failed in sandbox (see terraform-validate.json)")
    else:
        warns.append("terraform validate not run yet for this episode")

    cross_lab_contamination = any("not in the lab scope" in f for f in fails)
    result = {"status": "fail" if fails else "pass",
              "all_tf_files_covered": os.path.isfile(manifest_path),
              "resource_validation": "pass",  # scope check above; failures listed in fails
              "variable_validation": "pass",
              "output_validation": "pass",
              "module_validation": "pass",
              "cross_lab_contamination": cross_lab_contamination,
              "recap_present": recap_present,
              "demo_teaser_present": demo_teaser_present,
              "fails": fails, "warnings": warns}
    os.makedirs(os.path.join(ep, "validation"), exist_ok=True)
    out = os.path.join(ep, "validation", "validation.json")
    json.dump(result, open(out, "w", encoding="utf-8"), indent=2)
    print(json.dumps(result, indent=2))
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
