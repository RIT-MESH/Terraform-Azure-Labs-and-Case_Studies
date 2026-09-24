#!/usr/bin/env python3
"""Discover course labs under E:\\labs\\section-*.

Emits a JSON episode list: section, lab id, path, absolute path.
Usage: discover_labs.py [--root E:\\labs] [--out episodes.json]
"""
import argparse
import json
import os
import re


def discover(root):
    episodes = []
    for section in sorted(os.listdir(root)):
        sec_dir = os.path.join(root, section)
        if not (section.startswith("section-") and os.path.isdir(sec_dir)):
            continue
        for lab in sorted(os.listdir(sec_dir)):
            lab_dir = os.path.join(sec_dir, lab)
            if not os.path.isdir(lab_dir):
                continue
            if not any(f.endswith(".tf") for f in os.listdir(lab_dir)):
                continue  # a lab must contain terraform code
            num = re.match(r"(\d+)", lab)
            episodes.append({
                "section": section,
                "lab": lab,
                "order": int(num.group(1)) if num else 0,
                "path": f"{section}/{lab}",
                "abs_path": os.path.abspath(lab_dir),
            })
    return episodes


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=r"E:\labs")
    ap.add_argument("--out", help="write JSON here (default: stdout)")
    args = ap.parse_args()
    episodes = discover(args.root)
    out = json.dumps(episodes, indent=2)
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(out)
        print(f"{len(episodes)} labs -> {args.out}")
    else:
        print(out)


if __name__ == "__main__":
    main()
