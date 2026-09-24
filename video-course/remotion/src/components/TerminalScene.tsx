import React from 'react';
import {AbsoluteFill, Img, staticFile} from 'remotion';

/* TERMINAL — deterministic render_terminal_svg.py output (assets/terminal/). */
export const TerminalScene: React.FC<{asset?: string}> = (props) => (
  <AbsoluteFill style={{backgroundColor: '#0B1120', justifyContent: 'center', alignItems: 'center'}}>
    {props.asset ? <Img src={staticFile(props.asset)} style={{maxWidth: '88%'}} /> : null}
  </AbsoluteFill>
);
