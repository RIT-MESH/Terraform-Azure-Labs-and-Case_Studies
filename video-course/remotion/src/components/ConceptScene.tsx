import React from 'react';
import {AbsoluteFill} from 'remotion';

/* CONCEPT — text/teaching scene; also renders the "where this lab lives"
 * GitHub breadcrumb (NEVER local paths) when github_path is provided.
 * centered: true vertically/ horizontally centers the content (outro scene). */
export const ConceptScene: React.FC<{heading?: string; points?: string[]; github_path?: string; publicLabUrl?: string; centered?: boolean}> = (props) => (
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
      <div key={i} style={{color: '#C9D3E8', fontSize: 40, marginTop: 28}}>
        {p}
      </div>
    ))}
  </AbsoluteFill>
);
