import React from 'react';
import {AbsoluteFill, Img, staticFile, useCurrentFrame, interpolate} from 'remotion';

/*
 * CODE — displays the pre-generated Shiki SVG/PNG of EXACT ACTIVE_LAB code
 * (assets/code/). Code is never altered or re-typed. highlight_lines drive a
 * soft highlight sweep; inactive lines dim via the asset pipeline.
 */
export const CodeScene: React.FC<{asset?: string; source_file?: string; highlight_lines?: number[]}> = (props) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 10], [0, 1], {extrapolateRight: 'clamp'});
  return (
    <AbsoluteFill style={{backgroundColor: '#0B1120', padding: 96}}>
      {props.source_file ? (
        <div style={{color: '#50E6FF', fontFamily: 'JetBrains Mono', fontSize: 30, marginBottom: 24, opacity}}>
          {props.source_file}
        </div>
      ) : null}
      {props.asset ? (
        <Img src={staticFile(props.asset)} style={{width: '100%', objectFit: 'contain', opacity}} />
      ) : null}
    </AbsoluteFill>
  );
};
