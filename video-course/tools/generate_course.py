#!/usr/bin/env python3
"""Course orchestrator CLI (batch + per-episode driver).

    generate_course.py --source-root E:/labs --mode scripts [--lab 01]
    generate_course.py --lab 05 --mode voice|subtitles|render|validate
    generate_course.py --lab 01 --mode all

Modes
  scripts    PASS A only: resolve lab -> manifest -> inventory -> episode dirs +
             progress skeleton. Script writing itself is agent work (Claude/GLM);
             this stage prepares each episode and REPORTS what remains.
  validate   terraform sandbox gate (fmt/init/validate, never deploys) + content
             gate on episodes that have writing/scenes.json
  voice      PASS B: minimax_tts for VALIDATED episodes -> audio/ (needs MINIMAX_API_KEY)
  subtitles  generate_srt.py for VOICE_COMPLETE episodes (needs timing)
  render     render via Remotion CLI for RENDERED-pending episodes + quality_check
  all        every deterministic stage for one lab, in order, stopping at gates
  ci         deterministic media pipeline for GitHub Actions: assumes approved
             writing/ already exists (synced from the authoring PC); runs every
             stage from manifest/inventory rebuild through render + QC + parts.
             No LLM call. Exits nonzero if any stage fails.

Lab resolution: numeric prefix match across sections -> course-manifest.json
mapping -> ordered discovery index. Never guesses: ambiguous -> error.

Every stage is restartable; FINAL episodes are skipped unless --force.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys

# Portable roots: this file lives in <video-course>/tools, so derive the
# video-course root from __file__ (works on Windows AND the CI runner, where
# the source root is $GITHUB_WORKSPACE/labs — a different tree from tools).
TOOLS = os.path.dirname(os.path.abspath(__file__))
VC = os.path.dirname(TOOLS)
# Source root: --source-root > COURSE_SOURCE_ROOT env > local default.
ROOT_DEFAULT = os.environ.get("COURSE_SOURCE_ROOT", r"E:\labs")
MANIFEST = os.path.join(VC, "course-manifest.json")
PROGRESS = os.path.join(VC, "course-progress.json")
COURSE_CFG = os.path.join(VC, "config", "course.json")
REMO_DIR = os.path.join(VC, "remotion")

STATUSES = ["DRAFT", "VALIDATED", "APPROVED", "VOICE_COMPLETE", "RENDERED", "FINAL"]


def run(script, *script_args):
    p = subprocess.run([sys.executable, os.path.join(TOOLS, script), *script_args])
    if p.returncode != 0:
        raise SystemExit(f"stage failed: {script} {' '.join(script_args)}")


def npx_cmd(*npx_args):
    """Cross-platform npx invocation. Windows: npx is a .cmd shim CreateProcess
    can't exec directly; on Linux (GitHub Actions runner) plain npx works."""
    npx = shutil.which("npx")
    if npx and os.name == "nt":
        return ["cmd", "/c", os.path.abspath(npx), *npx_args]
    return ["npx", *npx_args]


def discover_all(root):
    p = subprocess.run([sys.executable, os.path.join(TOOLS, "discover_labs.py"),
                        "--root", root], capture_output=True, text=True)
    if p.returncode != 0:
        raise SystemExit(f"discover_labs failed:\n{p.stderr}")
    return json.loads(p.stdout)


def public_lab_url(ep, course):
    rel = ep["path"].replace("\\", "/")
    return f"{course['public_labs_root']}/{rel}"


def load_manifest(root, course, rebuild=False):
    """course-manifest.json: canonical lab-number -> lab mapping (never guess).
    rebuild=True (mode=ci): the committed manifest records the authoring PC's
    absolute paths, so rediscover against the checked-out source root instead."""
    if not rebuild and os.path.isfile(MANIFEST):
        return json.load(open(MANIFEST, encoding="utf-8"))["labs"]
    labs = discover_all(root)
    doc = {"labs": [
        {**ep, "number": i + 1, "public_lab_url": public_lab_url(ep, course)}
        for i, ep in enumerate(labs)
    ]}
    json.dump(doc, open(MANIFEST, "w", encoding="utf-8"), indent=2)
    return doc["labs"]


def resolve_lab(lab_ref, labs):
    """'01' / '1' / exact dir name / 'storage-account' substring. Error if ambiguous."""
    matches = labs if lab_ref in (None, "all") else []
    if lab_ref not in (None, "all"):
        ref = str(lab_ref).lstrip("0").lower()
        prefix_hits = [l for l in labs if l["lab"].startswith(str(lab_ref).zfill(2) + "-")]
        name_hits = [l for l in labs if str(lab_ref).lower() in l["lab"].lower()]
        number_hits = [l for l in labs if ref.isdigit() and l["number"] == int(ref)]
        if len(prefix_hits) == 1:
            matches = prefix_hits
        elif number_hits:
            matches = number_hits[:1]  # canonical global numbering from manifest
        elif len(name_hits) == 1:
            matches = name_hits
        else:
            cand = (prefix_hits or name_hits)[:5]
            raise SystemExit(f"lab '{lab_ref}' is unknown or ambiguous. "
                             f"Candidates: {[c['path'] for c in cand]}")
    return matches


def episode_dir(ep, course):
    # Episodes always live under the video-course root (portable: works on the
    # authoring PC and on the CI runner). course.json's episodes_root is the
    # legacy source-root-relative spelling of the same location.
    return os.path.join(VC, "output", ep["section"], ep["lab"])


def load_progress():
    if os.path.isfile(PROGRESS):
        return json.load(open(PROGRESS, encoding="utf-8"))
    return {"concepts_already_taught": [], "episodes": {}}


def save_progress(pr):
    json.dump(pr, open(PROGRESS, "w", encoding="utf-8"), indent=2)


def get_status(pr, ep):
    return pr["episodes"].get(ep["path"], {}).get("status", "DRAFT")


def set_status(pr, ep, status, **fields):
    rec = pr["episodes"].setdefault(ep["path"], {})
    rec.update(status=status, public_lab_url=fields.pop("public_lab_url", None) or rec.get("public_lab_url"), **fields)
    save_progress(pr)


def stage_scripts(ep, out_dir):
    os.makedirs(os.path.join(out_dir, "source"), exist_ok=True)
    for sub in ("writing", "audio", "timing", "validation", "captions", "final", "preview"):
        os.makedirs(os.path.join(out_dir, sub), exist_ok=True)
    for sub in ("diagrams", "code", "terminal", "portal", "screenshots"):
        os.makedirs(os.path.join(out_dir, "assets", sub), exist_ok=True)
    manifest_out = os.path.join(out_dir, "source", "source-manifest.json")
    if not os.path.isfile(manifest_out):
        run("build_manifest.py", ep["abs_path"], "--out", manifest_out)
    inv_out = os.path.join(out_dir, "source", "terraform-inventory.json")
    if not os.path.isfile(inv_out):
        run("parse_terraform.py", ep["abs_path"], "--out", inv_out)
    print(f"[scripts] prepared {ep['path']}; AGENT STEP: write script.md / "
          f"scenes.json / narration.json in {out_dir}\\writing from manifest + "
          f"inventory, then run mode=validate")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source-root", default=ROOT_DEFAULT)
    ap.add_argument("--mode", required=True,
                    choices=["scripts", "validate", "voice", "subtitles", "render", "all", "ci"])
    ap.add_argument("--lab", help="e.g. 01, 17, or all (default for batch modes)")
    ap.add_argument("--force", action="store_true", help="allow touching FINAL episodes")
    args = ap.parse_args()

    course = json.load(open(COURSE_CFG, encoding="utf-8"))
    labs = load_manifest(args.source_root, course, rebuild=(args.mode == "ci"))
    targets = resolve_lab(args.lab, labs)
    pr = load_progress()
    report = {"labs": len(targets), "done": 0, "skipped_final": 0, "failed": []}

    for ep in targets:
        out_dir = episode_dir(ep, course)
        status = get_status(pr, ep)
        if status == "FINAL" and not args.force:
            report["skipped_final"] += 1
            continue
        try:
            if args.mode in ("scripts", "all", "ci"):
                stage_scripts(ep, out_dir)
                # never downgrade an episode that already progressed (guide §41)
                if status not in ("VALIDATED", "APPROVED", "VOICE_COMPLETE", "RENDERED", "FINAL"):
                    set_status(pr, ep, "DRAFT", public_lab_url=ep["public_lab_url"])
            if args.mode in ("validate", "all", "ci"):
                scenes = os.path.join(out_dir, "writing", "scenes.json")
                if not os.path.isfile(scenes):
                    raise SystemExit(f"{ep['path']}: no writing/scenes.json — "
                                     "script stage (agent work) not done")
                # Deterministic terraform gate (outranks LLM judgment): copy the
                # lab's sources into a sandbox and run fmt/init/validate there —
                # never deployed, never mutates the real lab directory.
                tfv_out = os.path.join(out_dir, "validation", "terraform-validate.json")
                sandbox = os.path.join(out_dir, "validation", "sandbox")
                if os.path.isdir(sandbox):
                    shutil.rmtree(sandbox)
                shutil.copytree(ep["abs_path"], sandbox,
                                ignore=shutil.ignore_patterns(".terraform*", "*.tfstate*"))
                p = subprocess.run([sys.executable, os.path.join(TOOLS, "validate_terraform.py"),
                                    sandbox, "--out", tfv_out])
                if p.returncode == 1:
                    raise SystemExit(f"{ep['path']}: terraform validation FAILED in sandbox "
                                     "(see validation/terraform-validate.json)")
                if p.returncode == 2:
                    print(f"WARNING: {ep['path']}: terraform binary unavailable — "
                          "deterministic terraform validation skipped")
                p = subprocess.run([sys.executable, os.path.join(TOOLS, "validate_episode.py"),
                                    out_dir, "--sources", ep["abs_path"]])
                if p.returncode != 0:
                    raise SystemExit(f"{ep['path']}: content validation FAILED — repair script first")
                set_status(pr, ep, "VALIDATED")
            if args.mode in ("voice", "all", "ci"):
                cur = get_status(pr, ep)  # re-read: mode=all advanced it earlier this run
                if cur in ("VOICE_COMPLETE", "RENDERED", "FINAL") and not args.force:
                    raise SystemExit(f"{ep['path']}: voice already complete (status={cur}) "
                                     "— use --force to regenerate")
                if cur not in ("VALIDATED", "APPROVED"):
                    raise SystemExit(f"{ep['path']}: narration allowed only for VALIDATED "
                                     f"episodes (status={cur})")
                voice = json.load(open(os.path.join(VC, "config", "voice.json"), encoding="utf-8"))
                # The manual voice_id selection only gates the MiniMax path;
                # the free edge-tts fallback uses edge_voice and needs no key.
                using_minimax = bool(os.environ.get("MINIMAX_API_KEY"))
                if using_minimax and voice["voice_id"].startswith("TODO"):
                    raise SystemExit("Set the male voice_id in video-course/config/voice.json first (one-time manual selection).")
                run("minimax_tts.py", out_dir)
                set_status(pr, ep, "VOICE_COMPLETE")
            if args.mode in ("subtitles", "all", "ci"):
                cur = get_status(pr, ep)  # re-read: mode=all set VOICE_COMPLETE above
                if cur not in ("VOICE_COMPLETE", "RENDERED"):
                    raise SystemExit(f"{ep['path']}: subtitles need VOICE_COMPLETE audio "
                                     f"(status={cur})")
                run("measure_audio.py", out_dir)
                run("align_audio.py", out_dir)
                run("calculate_scene_frames.py", out_dir)
                run("generate_srt.py", out_dir)
            if args.mode in ("render", "all", "ci"):
                # regenerate every scene asset from its spec (Shiki code PNGs,
                # diagrams, terminal SVGs) — assets are not synced/committed
                run("generate_assets.py", out_dir, ep["abs_path"])
                out_mp4 = os.path.join(out_dir, "final", "episode.mp4")
                timed_scene_path = os.path.join(out_dir, "timing", "timed-scenes.json")
                timed_doc = json.load(open(timed_scene_path, encoding="utf-8"))
                scenes_doc = json.load(open(os.path.join(out_dir, "writing", "scenes.json"),
                                            encoding="utf-8"))
                # Remotion's staticFile() only serves remotion/public — mirror the
                # episode's runtime assets (audio + assets/) there for the bundler.
                slug = f"{ep['section']}--{ep['lab']}"
                pub_ep = os.path.join(REMO_DIR, "public", "episodes", slug)
                if os.path.isdir(pub_ep):
                    shutil.rmtree(pub_ep)
                os.makedirs(pub_ep, exist_ok=True)
                for sub in ("audio", "assets"):
                    src_sub = os.path.join(out_dir, sub)
                    if os.path.isdir(src_sub):
                        shutil.copytree(src_sub, os.path.join(pub_ep, sub))
                props = {
                    "episodeDir": f"episodes/{slug}",
                    "publicLabUrl": ep["public_lab_url"],
                    "title": scenes_doc.get("title") or ep["lab"],
                    "lessonLabel": scenes_doc.get("lesson_label") or ep["section"],
                    "timedScenes": timed_doc["scenes"],
                    "scenes": scenes_doc["scenes"],
                    "totalDurationFrames": timed_doc["total_duration_frames"],
                }
                props_file = os.path.join(out_dir, "render-props.json")
                json.dump(props, open(props_file, "w", encoding="utf-8"), indent=2)
                p = subprocess.run(npx_cmd("remotion", "render", "Episode",
                                           out_mp4, f"--props={props_file}"),
                                   cwd=REMO_DIR)
                if p.returncode != 0:
                    raise SystemExit(f"{ep['path']}: remotion render failed")
                run("quality_check.py", out_dir)
                run("generate_srt.py", out_dir)  # final SRT from actual audio
                set_status(pr, ep, "RENDERED")
            if args.mode == "ci":
                # two-part delivery format (course-wide): part1-main + part2-thankyou
                run("render_parts.py", out_dir)
            report["done"] += 1
        except SystemExit as e:
            report["failed"].append({"lab": ep["path"], "error": str(e)})
            if args.mode != "all":
                raise

    print(json.dumps(report, indent=2))
    if args.mode == "ci" and report["failed"]:
        sys.exit(1)  # CI job must fail, not just report


if __name__ == "__main__":
    main()
