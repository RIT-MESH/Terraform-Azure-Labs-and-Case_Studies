import React from 'react';
import {AbsoluteFill, interpolate, useCurrentFrame} from 'remotion';

/* RECAP — 3-6 concepts actually covered this episode; no new information.
 * Narration-timed reveal (instruction §19): when step_frames are present (one
 * recap step per point, measured from the real narration audio), each point
 * fades in as the narration reaches it; the old fixed i*10 stagger is only the
 * fallback for episodes rendered before the timing upgrade. */

export type StepFrames = {key: string; start: number; end: number}[];

export const RecapScene: React.FC<{points?: string[]; step_frames?: StepFrames}> = (props) => {
  const frame = useCurrentFrame();
  const sf = props.step_frames;
  const startFor = (i: number): number => {
    if (sf && sf.length > 0) {
      return sf[Math.min(i, sf.length - 1)].start;
    }
    return 12 + i * 10;
  };
  return (
    <AbsoluteFill style={{backgroundColor: '#0B1120', padding: 140, fontFamily: 'Inter'}}>
      <div style={{color: '#50E6FF', fontSize: 40, letterSpacing: 6}}>RECAP</div>
      {(props.points ?? []).map((p, i) => {
        const s = startFor(i);
        const o = interpolate(frame, [s, s + 10], [0, 1], {extrapolateRight: 'clamp'});
        return (
          <div key={i} style={{color: '#E8EEFA', fontSize: 48, marginTop: 34, opacity: o}}>
            {p}
          </div>
        );
      })}
    </AbsoluteFill>
  );
};