import React, {useMemo} from 'react';
import {AbsoluteFill, interpolate, useCurrentFrame} from 'remotion';

/*
 * CONCEPT — text/teaching scene; also renders the "where this lab lives"
 * GitHub breadcrumb (NEVER local paths) when github_path is provided.
 * centered: true vertically/horizontally centers the content (outro scene).
 *
 * Progressive reveal (instruction §18): when the scene has narration steps +
 * measured step_frames, each point fades in as the narration reaches it —
 * matched by keyword overlap between the point text and the step narration
 * (deterministic; no LLM at render time). Without steps the whole set fades in
 * proportionally, as before. A point never appears before its step's narration
 * mentions it; all points are lit by the scene end.
 */

export type StepFrames = {key: string; start: number; end: number}[];

const STOP = new Set(['the', 'a', 'an', 'and', 'or', 'of', 'to', 'in', 'is', 'are',
  'it', 'this', 'that', 'with', 'for', 'on', 'as', 'we', 'our', 'you', 'your']);

const keywords = (text: string): Set<string> =>
  new Set(text.toLowerCase().split(/[^a-z0-9_]+/).filter((w) => w.length > 2 && !STOP.has(w)));

export const ConceptScene: React.FC<{
  heading?: string;
  points?: string[];
  github_path?: string;
  publicLabUrl?: string;
  centered?: boolean;
  steps?: {narration?: string; [k: string]: unknown}[];
  step_frames?: StepFrames;
}> = (props) => {
  const frame = useCurrentFrame();
  const {points, steps, step_frames: sf} = props;
  const synced = !!points && !!steps && steps.length > 0 && !!sf && sf.length === steps.length;

  // step start frames (used as fallback reveal times)
  const stepStarts = useMemo<number[] | null>(() => {
    if (!synced || !points) {
      return null;
    }
    return steps!.map((_, i) => sf![i].start);
  }, [synced, points, steps, sf]);

  // deterministic keyword match: point reveals in the first step that names it
  const matchedStart = useMemo<number[] | null>(() => {
    if (!stepStarts || !points || !steps) {
      return null;
    }
    const kw = points.map(keywords);
    const starts: number[] = [];
    for (let p = 0; p < points.length; p++) {
      let start = -1;
      for (let i = 0; i < steps.length && start < 0; i++) {
        const skw = keywords(steps[i].narration ?? '');
        for (const w of kw[p]) {
          if (skw.has(w)) {
            start = stepStarts[i];
            break;
          }
        }
      }
      // fallback for never-mentioned points: proportional between step starts
      starts.push(start >= 0 ? start : stepStarts[Math.min(p, stepStarts.length - 1)]);
    }
    return starts;
  }, [stepStarts, points, steps, sf]);

  const starts = synced && matchedStart ? matchedStart : null;

  const opacityFor = (i: number) => {
    const s = starts ? starts[i] : 12 + i * 12;
    return interpolate(frame, [s, s + 10], [0, 1], {extrapolateRight: 'clamp'});
  };

  return (
    <AbsoluteFill style={{backgroundColor: '#0B1120', padding: 120, fontFamily: 'Inter',
                         display: 'flex', flexDirection: 'column',
                         alignItems: props.centered ? 'center' : 'flex-start',
                         justifyContent: props.centered ? 'center' : 'flex-start',
                         textAlign: props.centered ? 'center' : 'left'}}>
      {props.heading ? (
        <div style={{color: '#E8EEFA', fontSize: 60, fontWeight: 700}}>{props.heading}</div>
      ) : null}
      {props.github_path ? (
        <div style={{color: '#50E6FF', fontFamily: 'JetBrains Mono', fontSize: 30, marginTop: 36, lineHeight: 1.8, whiteSpace: 'pre'}}>
          {props.github_path}
        </div>
      ) : null}
      {(props.points ?? []).map((p, i) => (
        <div key={i} style={{color: '#C9D3E8', fontSize: 40, marginTop: 28, opacity: opacityFor(i)}}>
          {p}
        </div>
      ))}
    </AbsoluteFill>
  );
};