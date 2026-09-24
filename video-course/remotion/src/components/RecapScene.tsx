import React from 'react';
import {AbsoluteFill, useCurrentFrame, interpolate} from 'remotion';

/* RECAP — 3-6 concepts actually covered this episode; no new information. */
export const RecapScene: React.FC<{points?: string[]}> = (props) => {
  const frame = useCurrentFrame();
  return (
    <AbsoluteFill style={{backgroundColor: '#0B1120', padding: 140, fontFamily: 'Inter'}}>
      <div style={{color: '#50E6FF', fontSize: 40, letterSpacing: 6}}>RECAP</div>
      {(props.points ?? []).map((p, i) => {
        const o = interpolate(frame, [12 + i * 10, 22 + i * 10], [0, 1], {extrapolateRight: 'clamp'});
        return (
          <div key={i} style={{color: '#E8EEFA', fontSize: 48, marginTop: 34, opacity: o}}>
            {p}
          </div>
        );
      })}
    </AbsoluteFill>
  );
};
