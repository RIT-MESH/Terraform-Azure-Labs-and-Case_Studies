#!/usr/bin/env python3
"""Build an Azure-architecture diagram as SVG.

Two input modes:
  --mermaid file.mmd   -> rendered via mermaid-cli (npx @mermaid-js/mermaid-cli)
  --json spec.json     -> built-in layered boxes+arrows SVG
                          { "nodes": [{"id","label","group"}...],
                            "edges": [{"from","to","label"?}...],
                            "layers": [["id"...], ...] }  # optional explicit columns

Diagram animation + label-safety rules (course-wide, since Lab 02):
  - Every node/edge gets a stable id (`node-<id>`, `edge-<from>-<to>`) so
    Remotion can highlight the block currently being narrated.
  - Relationship labels sit clear of lines, arrowheads and node borders.
  - NO diagram is written if a label-collision or overflow check fails:
    the tool prints the offending boxes and exits 3 (pipeline gate).
"""
import argparse
import html
import json
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VIDEO_COURSE_ROOT = os.path.dirname(HERE)  # tools/ -> video-course/
THEME_CFG = os.path.join(VIDEO_COURSE_ROOT, "config", "theme.json")

FONT_SIZE = 26
CHAR_W = 15          # conservative px per char at FONT_SIZE (label width estimate)
LABEL_H = 34         # label bounding-box height
BOX_H = 110
MIN_GAP = 200        # minimum horizontal gap between columns (room for arrows)
LABEL_PAD = 24       # min px between a label and anything else
LINE_LABEL_LIFT = 18  # label baseline above the connector line


def est_w(text):
    return max(len(line) for line in text.split("\n")) * CHAR_W


def mermaid_to_svg(mmd, out):
    subprocess.run(["npx", "-y", "@mermaid-js/mermaid-cli", "-i", mmd,
                    "-o", out, "-b", "transparent"], check=True)
    print(f"-> {out} (mermaid-cli)")


def naive_layout(spec):
    """Assign (col, row) positions from explicit layers or simple BFS order."""
    if spec.get("layers"):
        return {nid: (c, r) for c, col in enumerate(spec["layers"])
                for r, nid in enumerate(col)}
    # no layers given: single column in declaration order
    return {n["id"]: (0, i) for i, n in enumerate(spec["nodes"])}


def rects_overlap(a, b):
    return not (a[0] + a[2] <= b[0] or b[0] + b[2] <= a[0] or
                a[1] + a[3] <= b[1] or b[1] + b[3] <= a[1])


def json_to_svg(spec_path, out, theme):
    spec = json.load(open(spec_path, encoding="utf-8"))
    nodes = {n["id"]: n for n in spec["nodes"]}
    pos = naive_layout(spec)
    cols = max(c for c, r in pos.values()) + 1
    rows = max(r for c, r in pos.values()) + 1
    azure, tf_blue = theme["azure"]["primary"], theme["azure"]["secondary"]

    gap_y = 100
    # per-column box widths sized to their widest label (no text overflow)
    col_w = [MIN_GAP] * cols
    for n in spec["nodes"]:
        c, _ = pos[n["id"]]
        col_w[c] = max(col_w[c], est_w(n["label"]) + 56)
    # per-pair column gaps sized to the widest edge label between them
    pair_gap = {}
    for e in spec.get("edges", []):
        (c1, _), (c2, _) = pos[e["from"]], pos[e["to"]]
        if c2 - c1 != 1:
            continue
        pair_gap[c1] = max(pair_gap.get(c1, MIN_GAP), need_gap(e.get("label", "")))
    col_x = []
    x = 80
    for c in range(cols):
        col_x.append(x)
        x += col_w[c] + pair_gap.get(c, MIN_GAP)
    w = x - pair_gap.get(cols - 1, 0) + 40
    h = 60 + rows * (BOX_H + gap_y) + 20

    def xy(nid):
        c, r = pos[nid]
        return (col_x[c], 60 + r * (BOX_H + gap_y))

    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">',
             f'<rect width="{w}" height="{h}" fill="{theme["background"]}"/>',
             '<defs><marker id="arr" markerWidth="10" markerHeight="10" refX="9" refY="3" '
             'orient="auto"><path d="M0,0 L9,3 L0,6 z" fill="#50E6FF"/></marker></defs>',
             f'<g font-family="{theme["body"]["font"]}, sans-serif" font-size="{FONT_SIZE}">']

    # collect every rendered bounding box for the collision QC gate
    boxes = []          # (x, y, w, h, kind, name)
    for n in spec["nodes"]:
        nx, ny = xy(n["id"])
        boxes.append((nx, ny, col_w[pos[n["id"]][0]], BOX_H, "node", n["id"]))

    edge_parts = []
    for e in spec.get("edges", []):
        (c1, r1), (c2, r2) = pos[e["from"]], pos[e["to"]]
        x1, y1 = xy(e["from"]); x2, y2 = xy(e["to"])
        w1 = col_w[c1]
        eid = f"{e['from']}-{e['to']}"
        seg = []    # this edge's line + optional label
        if c1 == c2:  # same column: vertical top-to-bottom arrow
            lx = x1 + w1 // 2
            seg.append(f'<line x1="{lx}" y1="{y1 + BOX_H}" '
                       f'x2="{lx}" y2="{y2 - 8}" '
                       f'stroke="#50E6FF" stroke-width="3" marker-end="url(#arr)"/>')
            if e.get("label"):
                lw = est_w(e["label"])
                ty = (y1 + BOX_H + y2) // 2 + 8
                if lx + 18 + lw > w - 30:     # would overflow right edge: flip left
                    tx, anchor = lx - 18, "end"
                else:
                    tx, anchor = lx + 18, "start"
                seg.append(f'<text x="{tx}" y="{ty}" fill="#9BD1FF" '
                           f'text-anchor="{anchor}">{html.escape(e["label"])}</text>')
                bx = tx if anchor == "start" else tx - lw
                boxes.append((bx, ty - LABEL_H + 10, lw, LABEL_H, "label", f"edge:{eid}"))
        else:        # adjacent columns: horizontal left-to-right arrow
            ly1, ly2 = y1 + BOX_H // 2, y2 + BOX_H // 2
            ly = (ly1 + ly2) // 2
            sx, ex = x1 + w1, x2 - 8
            seg.append(f'<line x1="{sx}" y1="{ly}" x2="{ex}" y2="{ly}" '
                       f'stroke="#50E6FF" stroke-width="3" marker-end="url(#arr)"/>')
            if e.get("label"):
                lw = est_w(e["label"])
                tx = (sx + ex) // 2
                ty = ly - LINE_LABEL_LIFT     # above the line, clear of arrowhead
                seg.append(f'<text x="{tx}" y="{ty}" fill="#9BD1FF" '
                           f'text-anchor="middle">{html.escape(e["label"])}</text>')
                boxes.append((tx - lw // 2, ty - LABEL_H + 10, lw, LABEL_H,
                              "label", f"edge:{eid}"))
        edge_parts.append(f'<g id="edge-{eid}">' + "".join(seg) + "</g>")

    node_parts = []
    for n in spec["nodes"]:
        nx, ny = xy(n["id"])
        cw = col_w[pos[n["id"]][0]]
        color = azure if n.get("group") != "terraform" else theme["terraform"]["primary"]
        lines = n["label"].split("\n")
        lh = 34
        y0 = ny + BOX_H // 2 - (len(lines) - 1) * lh // 2 + 9
        tspans = "".join(
            f'<tspan x="{nx + cw // 2}" y="{y0 + i * lh}">{html.escape(ln)}</tspan>'
            for i, ln in enumerate(lines))
        node_parts.append(
            f'<g id="node-{n["id"]}">'
            f'<rect x="{nx}" y="{ny}" width="{cw}" height="{BOX_H}" rx="14" '
            f'fill="{color}" fill-opacity="0.15" stroke="{color}" stroke-width="2.5"/>'
            f'<text fill="#E8EEFA" text-anchor="middle">{tspans}</text></g>')

    # ---- label-collision QC gate: nothing may overlap anything else ----
    collisions = []
    for i in range(len(boxes)):
        for j in range(i + 1, len(boxes)):
            if rects_overlap(boxes[i][:4], boxes[j][:4]):
                collisions.append(f"{boxes[i][4]}:{boxes[i][5]}  <->  "
                                  f"{boxes[j][4]}:{boxes[j][5]}")
    if collisions:
        print("DIAGRAM QC FAILED — label collision / overflow detected:")
        for c in collisions:
            print("   ", c)
        sys.exit(3)

    parts_out = parts[:4] + edge_parts + node_parts + ["</g></svg>"]
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    open(out, "w", encoding="utf-8").write("".join(parts_out))
    print(f"-> {out} (built-in layout, collision QC passed)")


def need_gap(label):
    """Horizontal gap required between two columns for this edge label."""
    if not label:
        return MIN_GAP
    return max(MIN_GAP, est_w(label) + 2 * LABEL_PAD + 32)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mermaid"); ap.add_argument("--json")
    ap.add_argument("-o", "--out", required=True)
    ap.add_argument("--theme", default=THEME_CFG)
    args = ap.parse_args()
    if args.mermaid:
        mermaid_to_svg(args.mermaid, args.out)
    elif args.json:
        json_to_svg(args.json, args.out, json.load(open(args.theme, encoding="utf-8")))
    else:
        sys.exit("pass --mermaid or --json")


if __name__ == "__main__":
    main()