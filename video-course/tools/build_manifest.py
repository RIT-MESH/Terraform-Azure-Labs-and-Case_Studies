#!/usr/bin/env python3
"""Build source-manifest.json for a lab: the permitted source scope.

Includes the lab's own .tf files plus all local module sources referenced
(recursively), so a `module "vnet" { source = "../../../modules/vnet" }`
brings modules/vnet/*.tf into scope. Registry/git module sources are recorded
but not vendored.

Also records the viewer-facing public GitHub location derived from the path
relative to the source root (E:\\labs stays internal — viewers see the repo).

Usage: build_manifest.py <lab-dir> [--out source-manifest.json]
"""
import argparse
import json
import os
import re

RE_MODULE = re.compile(r'(?ms)^\s*module\s+"([^"]+)"\s*\{(.*?)\}')
RE_SOURCE = re.compile(r'source\s*=\s*"([^"]+)"')

SOURCE_ROOT = os.environ.get("COURSE_SOURCE_ROOT", r"E:\labs")
HERE = os.path.dirname(os.path.abspath(__file__))
VIDEO_COURSE_ROOT = os.path.dirname(HERE)  # tools/ -> video-course/
COURSE_CFG = os.path.join(VIDEO_COURSE_ROOT, "config", "course.json")


def collect_tf_files(dirpath):
    if not os.path.isdir(dirpath):
        return []
    return sorted(os.path.join(dirpath, f) for f in os.listdir(dirpath) if f.endswith(".tf"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("lab_dir")
    ap.add_argument("--out", help="write JSON here (default: stdout)")
    args = ap.parse_args()

    lab_abs = os.path.abspath(args.lab_dir)
    files, module_entries, remote_modules = [], [], []
    visited = set()
    queue = collect_tf_files(lab_abs)

    while queue:
        path = queue.pop()
        path = os.path.abspath(path)
        if path in visited or not os.path.isfile(path):
            continue
        visited.add(path)
        files.append(path)
        text = open(path, encoding="utf-8").read()
        for name, body in RE_MODULE.findall(text):
            m = RE_SOURCE.search(body)
            if not m:
                continue
            source = m.group(1)
            if source.startswith((".", "..")):
                mod_dir = os.path.normpath(os.path.join(os.path.dirname(path), source))
                module_entries.append({"name": name, "source": source,
                                       "resolved": os.path.abspath(mod_dir)})
                queue.extend(collect_tf_files(mod_dir))
            else:
                remote_modules.append({"name": name, "source": source})

    # viewer-facing public location (guide §13): derive from path relative to source root
    course = json.load(open(COURSE_CFG, encoding="utf-8"))
    rel = os.path.relpath(lab_abs, SOURCE_ROOT).replace("\\", "/")
    manifest = {
        "source_root": SOURCE_ROOT,
        "lab": lab_abs,
        "active_lab": lab_abs,
        "lab_path": rel,
        "public_repository": course["public_repository"],
        "public_labs_root": course["public_labs_root"],
        "public_lab_url": f"{course['public_labs_root']}/{rel}",
        "permitted_source_files": files,
        "local_modules": module_entries,
        "remote_modules": remote_modules,
    }
    out = json.dumps(manifest, indent=2)
    if args.out:
        os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(out)
        print(f"-> {args.out} ({len(files)} files, "
              f"{len(module_entries)} local modules, {len(remote_modules)} remote)")
    else:
        print(out)


if __name__ == "__main__":
    main()
