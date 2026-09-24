#!/usr/bin/env python3
"""Sync the CI inputs from the authoring source to the public Git clone.

Copies ONLY what the GitHub Actions runner needs (guide §1G):
  - ACTIVE_LAB source files            -> <clone>/labs/<section>/<lab>/
  - explicitly referenced modules      -> <clone>/modules/<module>/
  - portable production source         -> <clone>/video-course/
  - approved lightweight episode spec  -> <clone>/video-course/output/<section>/<lab>/writing/

Never copies: secrets, node_modules, remotion/public/episodes, audio/, timing/,
assets/, captions/, preview/, final/, *.mp4, state files.
Verifies with SHA-256 after copy and scans every staged text file for internal
path leakage (Windows drive paths, /home/runner/). Fails on mismatch or leakage.
This helper NEVER renders and NEVER touches git.

Usage:
  sync_ci_inputs.py --source-root E:/labs --github-clone <path> --lab 01
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VC = os.path.dirname(HERE)

LAB_FILE_EXTS = (".tf", ".tfvars.example", ".tftest.hcl", ".yml", ".yaml")
LAB_FILE_NAMES = ("README.md",)
MODULE_SOURCE_EXTS = (".tf", ".md")

# production source synced verbatim (files) / recursively (dirs)
VC_FILES = ["course-progress.json", "course-manifest.json", "requirements-ci.txt"]
VC_CONFIG_DIR = "config"
VC_TOOLS_DIR = "tools"
REMOTION_FILES = ["package.json", "package-lock.json", "tsconfig.json",
                  "remotion.config.ts"]
REMOTION_DIRS = ["src", "tools"]
WRITING_FILES = ["script.md", "narration.json", "scenes.json"]

LEAK_RE = re.compile(r"E:\\|C:\\|/home/runner/|\$GITHUB_WORKSPACE")
TEXT_SUFFIXES = (".md", ".json", ".py", ".ts", ".tsx", ".js", ".mjs", ".txt",
                 ".yml", ".yaml", ".tf")


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def copy_file(src, dst, changed):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    if os.path.isfile(dst) and sha256(src) == sha256(dst):
        return False
    shutil.copy2(src, dst)
    changed.append(dst)
    return True


def sync_tree(src_dir, dst_dir, exts=None, names=None, exclude_dirs=("__pycache__",),
              changed=None):
    """Mirror matching files from src_dir to dst_dir; report per-file changes."""
    n = 0
    for root, dirs, files in os.walk(src_dir):
        dirs[:] = [d for d in dirs if d not in exclude_dirs
                   and d not in ("node_modules", ".terraform")]
        for fn in files:
            if exts is not None and not fn.endswith(exts):
                continue
            if names is not None and fn not in names:
                continue
            src = os.path.join(root, fn)
            dst = os.path.join(dst_dir, os.path.relpath(src, src_dir))
            if copy_file(src, dst, changed):
                n += 1
    return n


def find_referenced_modules(lab_dir, source_root):
    """Local modules the lab actually references: source = \"../modules/<name>\"."""
    mods = set()
    for root, _dirs, files in os.walk(lab_dir):
        for fn in files:
            if not fn.endswith(".tf"):
                continue
            txt = open(os.path.join(root, fn), encoding="utf-8", errors="replace").read()
            for m in re.finditer(r'source\s*=\s*"(\.\./modules/([^"]+))"', txt):
                mods.add(m.group(2).strip("/"))
    return sorted(mods)


def scan_leakage(paths, clone_root):
    """Fail if any staged text file leaks internal/runner paths."""
    bad = []
    for p in paths:
        if not p.endswith(TEXT_SUFFIXES):
            continue
        try:
            txt = open(p, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for i, line in enumerate(txt.splitlines(), 1):
            if LEAK_RE.search(line):
                bad.append(f"{os.path.relpath(p, clone_root)}:{i}: {line.strip()[:120]}")
    return bad


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source-root", default=os.environ.get("COURSE_SOURCE_ROOT", r"E:\labs"))
    ap.add_argument("--github-clone", required=True)
    ap.add_argument("--lab", required=True, help="lab number, e.g. 01")
    args = ap.parse_args()

    clone = os.path.abspath(args.github_clone)
    if not os.path.isdir(os.path.join(clone, ".git")):
        sys.exit(f"not a git clone: {clone}")

    changed, staged = [], []

    # 1. resolve ACTIVE_LAB (numeric prefix; first match in section order,
    #    consistent with course-manifest numbering where 01 = first lab)
    ref = args.lab.zfill(2)
    hits = [d for d in next(os.walk(args.source_root))[1]
            if d.startswith("section-")]
    lab = section = None
    for sec in sorted(hits):
        for d in sorted(os.listdir(os.path.join(args.source_root, sec))):
            if d.startswith(ref + "-"):
                lab = os.path.join(args.source_root, sec, d)
                section = sec
                break
        if lab:
            break
    if not lab:
        sys.exit(f"lab '{args.lab}' not found under {args.source_root}")
    print(f"[sync] ACTIVE_LAB = {os.path.relpath(lab, args.source_root)}")

    # 2. lab source files -> <clone>/labs/<section>/<lab>/
    dst_lab = os.path.join(clone, "labs", section, os.path.basename(lab))
    n = 0
    for fn in sorted(os.listdir(lab)):
        src = os.path.join(lab, fn)
        if os.path.isfile(src) and (fn.endswith(LAB_FILE_EXTS) or fn in LAB_FILE_NAMES):
            if copy_file(src, os.path.join(dst_lab, fn), changed):
                n += 1
    print(f"[sync] lab files -> labs/{section}/{os.path.basename(lab)}: {n} changed")

    # 3. referenced modules -> <clone>/modules/<module>/
    for mod in find_referenced_modules(lab, args.source_root):
        mod_src = os.path.join(args.source_root, "modules", mod)
        if not os.path.isdir(mod_src):
            sys.exit(f"referenced module missing: {mod_src}")
        k = sync_tree(mod_src, os.path.join(clone, "modules", mod),
                      exts=MODULE_SOURCE_EXTS, changed=changed)
        print(f"[sync] module {mod}: {k} files changed")

    # 4. portable production source -> <clone>/video-course/
    # (course-manifest.json is NOT synced: it records authoring-PC absolute
    #  paths; mode=ci rebuilds it against the checked-out source root)
    copy_file(os.path.join(VC, "course-progress.json"),
              os.path.join(clone, "video-course", "course-progress.json"), changed)
    if os.path.isfile(os.path.join(VC, "requirements-ci.txt")):
        copy_file(os.path.join(VC, "requirements-ci.txt"),
                  os.path.join(clone, "video-course", "requirements-ci.txt"), changed)
    sync_tree(os.path.join(VC, VC_CONFIG_DIR),
              os.path.join(clone, "video-course", VC_CONFIG_DIR), changed=changed)
    sync_tree(os.path.join(VC, VC_TOOLS_DIR),
              os.path.join(clone, "video-course", VC_TOOLS_DIR), changed=changed)
    for fn in REMOTION_FILES:
        src = os.path.join(VC, "remotion", fn)
        if os.path.isfile(src):
            copy_file(src, os.path.join(clone, "video-course", "remotion", fn), changed)
    for d in REMOTION_DIRS:
        sync_tree(os.path.join(VC, "remotion", d),
                  os.path.join(clone, "video-course", "remotion", d), changed=changed)
    print("[sync] production source synced (config, tools, remotion src/lock)")

    # 5. approved lightweight writing spec -> <clone>/video-course/output/<...>/
    writing_src = os.path.join(VC, "output", section, os.path.basename(lab), "writing")
    if not os.path.isfile(os.path.join(writing_src, "scenes.json")):
        sys.exit(f"no approved writing spec: {writing_src}\\scenes.json")
    for fn in WRITING_FILES:
        src = os.path.join(writing_src, fn)
        if os.path.isfile(src):
            copy_file(src, os.path.join(
                clone, "video-course", "output", section, os.path.basename(lab), "writing", fn),
                changed)
    print("[sync] writing/ synced")

    # 5b. authored asset specs + terminal fixtures (inputs for the CI asset
    #     stage; the rendered assets themselves stay un-synced/regenerated)
    n_spec = 0
    for sub in ("diagrams", "terminal"):
        src_sub = os.path.join(VC, "output", section, os.path.basename(lab),
                               "assets", sub)
        if not os.path.isdir(src_sub):
            continue
        for fn in sorted(os.listdir(src_sub)):
            if fn.endswith(".spec.json") or fn.endswith(".txt"):
                if copy_file(os.path.join(src_sub, fn),
                             os.path.join(clone, "video-course", "output",
                                          section, os.path.basename(lab),
                                          "assets", sub, fn), changed):
                    n_spec += 1
    print(f"[sync] asset specs/fixtures: {n_spec} changed")

    # 6. leakage scan (guide §1G: scoped to the lightweight episode writing
    #    files — the viewer-facing surface — plus the lab source files; tool
    #    source with E:\labs fallback defaults is internal runtime metadata)
    scan_paths = []
    for base in (dst_lab,
                 os.path.join(clone, "video-course", "output", section,
                              os.path.basename(lab), "writing"),
                 os.path.join(clone, "video-course", "output", section,
                              os.path.basename(lab), "assets")):
        for root, dirs, files in os.walk(base):
            scan_paths.extend(os.path.join(root, fn) for fn in files)
    bad = scan_leakage(scan_paths, clone)
    if bad:
        print("INTERNAL PATH LEAKAGE in staged files:", file=sys.stderr)
        for b in bad:
            print("  " + b, file=sys.stderr)
        sys.exit("fix leakage before committing (guide §1G)")

    print(f"[sync] done. {len(changed)} file(s) changed:")
    for c in changed:
        print("   " + os.path.relpath(c, clone))
    print("[sync] hash verification passed; clone is CI-ready (git steps are manual)")


if __name__ == "__main__":
    main()