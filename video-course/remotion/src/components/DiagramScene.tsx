import React, {useEffect, useLayoutEffect, useMemo, useRef, useState} from 'react';
import {AbsoluteFill, continueRender, delayRender, interpolate, staticFile, useCurrentFrame} from 'remotion';

/*
 * DIAGRAM — narration-synchronized diagram (course-wide, since Lab 02).
 *
 * The SVG comes from build_diagram.py, which guarantees:
 *   - stable element ids  node-<id> / edge-<from>-<to>  (group wrappers)
 *   - a label-collision QC gate (exits 3) so labels never overlap lines,
 *     arrowheads, node borders or each other.
 *
 * Animation (timing rule): the timing pipeline (minimax_tts steps →
 * measure_audio → calculate_scene_frames) emits, per scene,
 *   steps:       [{nodes?: string[], edges?: string[]}, ...]   (writing/scenes.json)
 *   step_frames: [{key, start, end}, ...]                       (timed-scenes.json,
 *                frames RELATIVE to the scene start; TTS is the timing authority)
 * The step whose window contains the current frame is "active": its nodes and
 * edges (plus the endpoints of its edges — relationship highlighting includes
 * the label) render at full opacity with a glow; every other element dims.
 * Before the first step the full diagram shows as overview.
 */

export type DiagramStep = {
  narration?: string;
  nodes?: string[];
  edges?: string[];
};

export type StepFrames = {key: string; start: number; end: number}[];

const DIM_OPACITY = 0.3;
const RAMP = 8; // frames to fade a highlight change

const endpointsOf = (edgeId: string): string[] => edgeId.split('-');

export const DiagramScene: React.FC<{
  asset?: string;
  caption?: string;
  steps?: DiagramStep[];
  step_frames?: StepFrames;
}> = (props) => {
  const frame = useCurrentFrame();
  const [svgHtml, setSvgHtml] = useState<string | null>(null);
  const hostRef = useRef<HTMLDivElement>(null);
  const [handle] = useState(() =>
    props.asset ? delayRender('diagram svg load') : null,
  );

  useEffect(() => {
    if (!props.asset || handle === null) {
      return;
    }
    let cancelled = false;
    fetch(staticFile(props.asset))
      .then((r) => r.text())
      .then((text) => {
        if (cancelled) {
          return;
        }
        const doc = new DOMParser().parseFromString(text, 'image/svg+xml');
        const el = doc.documentElement;
        // capture the natural size as a viewBox BEFORE dropping the fixed
        // width/height — without it the SVG renders at natural pixel size,
        // un-scaled and cropped
        const w = el.getAttribute('width');
        const h = el.getAttribute('height');
        if (w && h && !el.getAttribute('viewBox')) {
          el.setAttribute('viewBox', `0 0 ${w} ${h}`);
        }
        el.removeAttribute('width');
        el.removeAttribute('height');
        el.setAttribute('preserveAspectRatio', 'xMidYMid meet');
        el.setAttribute('width', '100%');
        el.setAttribute('height', '100%');
        setSvgHtml(el.outerHTML);
        continueRender(handle);
      })
      .catch((e) => {
        continueRender(handle);
        throw e;
      });
    return () => {
      cancelled = true;
    };
  }, [props.asset, handle]);

  const {steps, step_frames: sf} = props;
  const canAnimate = !!steps && steps.length > 0 && !!sf && sf.length === steps.length;

  // per-element opacity timeline, memoized once (breakpoints are static)
  const timelines = useMemo(() => {
    if (!canAnimate) {
      return null;
    }
    const sceneEnd = sf[sf.length - 1].end + 120;
    const build = (isActive: (i: number) => boolean) => {
      const pts: [number, number][] = [[0, 1]];
      for (let i = 0; i < steps!.length; i++) {
        const start = sf![i].start;
        const target = isActive(i) ? 1 : DIM_OPACITY;
        const prev = pts[pts.length - 1][1];
        if (target !== prev) {
          if (pts[pts.length - 1][0] !== start) {
            pts.push([start, prev]);
          }
          pts.push([start + RAMP, target]);
        } else if (pts[pts.length - 1][0] < start) {
          pts.push([start, target]);
        }
      }
      pts.push([sceneEnd, pts[pts.length - 1][1]]);
      return pts;
    };
    const nodeActive: Record<string, boolean[]> = {};
    const edgeActive: Record<string, boolean[]> = {};
    steps!.forEach((st, i) => {
      for (const n of st.nodes ?? []) {
        (nodeActive[n] ??= [])[i] = true;
      }
      for (const e of st.edges ?? []) {
        (edgeActive[e] ??= [])[i] = true;
        // relationship highlighting: source + destination nodes light up too
        for (const n of endpointsOf(e)) {
          (nodeActive[n] ??= [])[i] = true;
        }
      }
    });
    return {
      nodes: Object.fromEntries(
        Object.entries(nodeActive).map(([n, a]) => [n, build((i) => !!a[i])]),
      ),
      edges: Object.fromEntries(
        Object.entries(edgeActive).map(([e, a]) => [e, build((i) => !!a[i])]),
      ),
    };
  }, [canAnimate, steps, sf]);

  // apply highlight styles synchronously before paint (no flicker).
  // Enumerate the SVG's actual node/edge groups so elements never named in any
  // step (e.g. an edge that is only context) still get the dim treatment.
  useLayoutEffect(() => {
    const host = hostRef.current;
    if (!host || !canAnimate) {
      return;
    }
    const defaultPts: [number, number][] = [
      [0, 1],
      [sf![0].start + RAMP, DIM_OPACITY],
      [sf![sf!.length - 1].end + 120, DIM_OPACITY],
    ];
    const apply = (g: SVGGElement, pts: [number, number][]) => {
      const v = interpolate(
        frame,
        pts.map((p) => p[0]),
        pts.map((p) => p[1]),
        {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'},
      );
      const glow = Math.max(0, v - DIM_OPACITY) / (1 - DIM_OPACITY);
      g.style.opacity = String(v);
      g.style.filter =
        glow > 0.02
          ? `drop-shadow(0 0 ${(10 * glow).toFixed(1)}px rgba(80,230,255,${(0.85 * glow).toFixed(2)}))`
          : 'none';
      g.style.transform = `scale(${(1 + 0.045 * glow).toFixed(4)})`;
      g.style.transformBox = 'fill-box';
      g.style.transformOrigin = 'center';
    };
    const groups = host.querySelectorAll<SVGGElement>(
      'g[id^="node-"], g[id^="edge-"]',
    );
    groups.forEach((g) => {
      const eid = g.id.replace(/^(node|edge)-/, '');
      const map = g.id.startsWith('node-') ? timelines!.nodes : timelines!.edges;
      apply(g, map[eid] ?? defaultPts);
    });
  }, [frame, svgHtml, timelines, canAnimate]);

  const enter = interpolate(frame, [0, 20], [0, 1], {extrapolateRight: 'clamp'});

  return (
    <AbsoluteFill
      style={{
        backgroundColor: '#0B1120',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 96,
      }}
    >
      {props.caption ? (
        <div
          style={{
            color: '#E8EEFA',
            fontFamily: 'Inter',
            fontSize: 44,
            marginBottom: 40,
            opacity: enter,
            textAlign: 'center',
          }}
        >
          {props.caption}
        </div>
      ) : null}
      <div
        ref={hostRef}
        style={{
          width: '100%',
          height: props.caption ? '72%' : '82%',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          opacity: enter,
        }}
        dangerouslySetInnerHTML={{__html: svgHtml ?? ''}}
      />
    </AbsoluteFill>
  );
};