#!/usr/bin/env python3
"""Parse terraform files in a directory into terraform-inventory.json.

Prefers python-hcl2 when installed; falls back to a regex pass that is still
deterministic (no LLM). Extracts: resources, data sources, variables, outputs,
locals, modules (with source), provider versions.

Usage: parse_terraform.py <lab-dir> [--out inventory.json]
"""
import argparse
import glob
import json
import os
import re


def parse_with_hcl2(tf_files):
    import hcl2  # noqa
    resources, data, variables, outputs, modules = [], [], [], [], []
    for path in tf_files:
        with open(path, encoding="utf-8") as f:
            parsed = hcl2.load(f)
        for block in parsed.get("resource", []):
            for rtype, named in block.items():
                for name in named:
                    resources.append({"type": rtype, "name": name,
                                      "address": f"{rtype}.{name}", "file": os.path.basename(path)})
        for block in parsed.get("data", []):
            for dtype, named in block.items():
                for name in named:
                    data.append({"type": dtype, "name": name, "file": os.path.basename(path)})
        for block in parsed.get("variable", []):
            variables.extend({"name": k, "file": os.path.basename(path)} for k in block)
        for block in parsed.get("output", []):
            outputs.extend({"name": k, "file": os.path.basename(path)} for k in block)
        for block in parsed.get("module", []):
            for name, body in block.items():
                modules.append({"name": name, "source": body.get("source"),
                                "file": os.path.basename(path)})
    return resources, data, variables, outputs, modules


RE_RESOURCE = re.compile(r'(?m)^\s*resource\s+"([^"]+)"\s+"([^"]+)"')
RE_DATA = re.compile(r'(?m)^\s*data\s+"([^"]+)"\s+"([^"]+)"')
RE_VARIABLE = re.compile(r'(?m)^\s*variable\s+"([^"]+)"')
RE_OUTPUT = re.compile(r'(?m)^\s*output\s+"([^"]+)"')
RE_MODULE = re.compile(r'(?ms)^\s*module\s+"([^"]+)"\s*\{(.*?)\}')
RE_MODULE_SOURCE = re.compile(r'source\s*=\s*"([^"]+)"')


def parse_with_regex(tf_files):
    resources, data, variables, outputs, modules = [], [], [], [], []
    for path in tf_files:
        text = open(path, encoding="utf-8").read()
        base = os.path.basename(path)
        for rtype, name in RE_RESOURCE.findall(text):
            resources.append({"type": rtype, "name": name,
                              "address": f"{rtype}.{name}", "file": base})
        for dtype, name in RE_DATA.findall(text):
            data.append({"type": dtype, "name": name, "file": base})
        for name in RE_VARIABLE.findall(text):
            variables.append({"name": name, "file": base})
        for name in RE_OUTPUT.findall(text):
            outputs.append({"name": name, "file": base})
        for name, body in RE_MODULE.findall(text):
            m = RE_MODULE_SOURCE.search(body)
            modules.append({"name": name, "source": m.group(1) if m else None,
                            "file": base})
    return resources, data, variables, outputs, modules


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("lab_dir")
    ap.add_argument("--out", help="write JSON here (default: stdout)")
    args = ap.parse_args()

    tf_files = sorted(glob.glob(os.path.join(args.lab_dir, "*.tf")))
    try:
        inventory = parse_with_hcl2(tf_files)
        parser = "python-hcl2"
    except ImportError:
        inventory = parse_with_regex(tf_files)
        parser = "regex-fallback"

    resources, data, variables, outputs, modules = inventory
    result = {
        "lab_dir": os.path.abspath(args.lab_dir),
        "parser": parser,
        "files": [os.path.basename(f) for f in tf_files],
        "resources": resources,
        "data_sources": data,
        "variables": variables,
        "outputs": outputs,
        "modules": modules,
    }
    out = json.dumps(result, indent=2)
    if args.out:
        os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
        with open(args.out, "w", encoding="utf-8") as f:
            f.write(out)
        print(f"-> {args.out} (parser: {parser}, "
              f"{len(resources)} resources, {len(modules)} modules)")
    else:
        print(out)


if __name__ == "__main__":
    main()
