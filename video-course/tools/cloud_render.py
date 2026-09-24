#!/usr/bin/env python3
"""Cloud render trigger (instruction §24): push the heavy render to the free
GitHub Actions ubuntu-latest runner for the public repository.

Responsibilities:
  resolve lab (shared course_index) -> sync CI inputs -> verify no
  secrets/internal paths -> trigger .github/workflows/render-course-video.yml
  -> show run URL -> optionally wait -> download the final artifact.

Uses the GitHub CLI (`gh`) when available. If gh is missing, prints the exact
commands instead of silently falling back to heavy local rendering.

Usage:
  cloud_render.py --lab 01 [--wait] [--clone C:/Users/.../GitHub/<repo>]
"""
import argparse
import json
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from course_index import episode_dir, load_course_manifest, resolve_lab  # noqa: E402
from sync_ci_inputs import sync_episode  # noqa: E402

WORKFLOW = "render-course-video.yml"
DEFAULT_CLONE = os.path.join(os.path.expanduser("~"), "Documents", "GitHub",
                             "Terraform-Azure-Labs-and-Case_Studies")


def gh(*gh_args, check=True):
    return subprocess.run(["gh", *gh_args], check=check)


def trigger(ep, source_root):
    """Sync CI inputs + dispatch the workflow. Returns the run id."""
    clone = DEFAULT_CLONE
    sync_episode(ep, source_root, clone)
    p = subprocess.run(["gh", "workflow", "run", WORKFLOW, "--repo",
                        _origin_repo(), "-f", f"lab={ep['lab'][:2]}"],
                       capture_output=True, text=True)
    if p.returncode != 0:
        sys.exit(f"gh workflow run failed: {p.stderr.strip()}\n"
                 "Run it manually:\n"
                 f"  gh workflow run {WORKFLOW} -f lab={ep['lab'][:2]}\n"
                 f"  gh run watch   # then download the artifact")
    # newest queued run for this workflow
    r = subprocess.run(["gh", "run", "list", "--workflow", WORKFLOW,
                        "--limit", "1", "--json", "databaseId,url"],
                       capture_output=True, text=True)
    try:
        import json as _json
        run = _json.loads(r.stdout)[0]
        print(f"[cloud] dispatched: {run['url']}")
        return run["databaseId"]
    except (ValueError, KeyError):
        print("[cloud] dispatched (run list unavailable)")
        return None


def _origin_repo():
    r = subprocess.run(["git", "-C", DEFAULT_CLONE, "remote", "get-url", "origin"],
                       capture_output=True, text=True)
    url = r.stdout.strip()
    if ".git" in url:
        url = url.rsplit(".git", 1)[0]
    return url.replace("https://github.com/", "")


def wait_and_download(run_id, ep):
    subprocess.run(["gh", "run", "watch", str(run_id), "--exit-status"])
    dest = os.path.join(episode_dir(ep), "final")
    os.makedirs(dest, exist_ok=True)
    subprocess.run(["gh", "run", "download", str(run_id),
                    "-D", os.path.dirname(dest)])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lab", required=True)
    ap.add_argument("--source-root", default=os.environ.get("COURSE_SOURCE_ROOT", r"E:\labs"))
    ap.add_argument("--wait", action="store_true", help="watch the run, then download")
    args = ap.parse_args()

    if not shutil_gh():
        repo = "RIT-MESH/Terraform-Azure-Labs-and-Case_Studies"
        print(f"gh CLI unavailable — run these exact commands:\n"
              f"  1. python video-course/tools/sync_ci_inputs.py --lab {args.lab}\n"
              f"     (then git add/commit/push the changed files)\n"
              f"  2. gh workflow run {WORKFLOW} -R {repo} -f lab={args.lab}\n"
              f"  3. gh run watch / gh run download  # artifact -> final/")
        return
    labs = load_course_manifest(args.source_root)
    ep = resolve_lab(args.lab, labs)[0]
    run_id = trigger(ep, args.source_root)
    if args.wait and run_id:
        wait_and_download(run_id, ep)


def shutil_gh():
    from shutil import which
    return which("gh")


if __name__ == "__main__":
    main()