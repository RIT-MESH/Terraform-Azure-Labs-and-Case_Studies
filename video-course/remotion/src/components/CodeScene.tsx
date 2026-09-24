import React, {useEffect, useLayoutEffect, useMemo, useRef, useState} from 'react';
import {AbsoluteFill, Img, continueRender, delayRender, interpolate, staticFile, useCurrentFrame} from 'remotion';

/*
 * CODE — EXACT ACTIVE_LAB source, never rewritten (course-wide rule).
 *
 * Two display modes:
 *  1. STATIC (no steps): the pre-generated Shiki PNG from assets/code/, as
 *     before. highlight_lines are baked in by the asset pipeline.
 *  2. NARRATION-SYNCED (steps present): fetches the Shiki HTML file that
 *     render_code_html.mjs writes beside the PNG (`<span class="line">` per
 *     source line) and focuses the line(s) the narration is talking about:
 *     active lines 1.0, adjacent lines 0.7, unrelated lines 0.5 — driven by
 *     the step's active_lines (absolute source line numbers) and the
 *     step_frames windows measured from the actual narration audio (TTS is
 *     the timing authority). Without step_frames the FIRST step stays lit.
 * The PNG remains the fallback and the visual ground truth; the HTML is only
 * ever shown with identical Shiki output.
 */

export type CodeStep = {
  narration?: string;
  active_lines?: number[];
  active_tokens?: string[]; // best-effort: future token-level focus
};

export type StepFrames = {key: string; start: number; end: number}[];

const DIM = 0.5;
const NEAR = 0.7;
const RAMP = 8;

export const CodeScene: React.FC<{
  asset?: string;
  source_file?: string;
  highlight_lines?: number[];
  start_line?: number;
  steps?: CodeStep[];
  step_frames?: StepFrames;
}> = (props) => {
  const frame = useCurrentFrame();
  const {steps, step_frames: sf, start_line: base} = props;
  const synced = !!steps && steps.length > 0 && !!sf && sf.length === steps.length;
  const enter = interpolate(frame, [0, 10], [0, 1], {extrapolateRight: 'clamp'});

  // static PNG mode
  if (!synced) {
    return (
      <AbsoluteFill style={{backgroundColor: '#0B1120', padding: 96}}>
        {props.source_file ? (
          <div style={{color: '#50E6FF', fontFamily: 'JetBrains Mono', fontSize: 30, marginBottom: 24, opacity: enter}}>
            {props.source_file}
          </div>
        ) : null}
        {props.asset ? (
          <Img src={staticFile(props.asset)} style={{width: '100%', objectFit: 'contain', opacity: enter}} />
        ) : null}
      </AbsoluteFill>
    );
  }

  // narration-synced HTML mode
  return <SyncedCode {...props} synced={synced} enter={enter} />;
};

const SyncedCode: React.FC<{
  asset?: string;
  source_file?: string;
  steps?: CodeStep[];
  step_frames?: StepFrames;
  start_line?: number;
  synced: boolean;
  enter: number;
}> = (props) => {
  const frame = useCurrentFrame();
  const hostRef = useRef<HTMLDivElement>(null);
  const [htmlText, setHtmlText] = useState<string | null>(null);
  const [handle] = useState(() => delayRender('code html load'));

  useEffect(() => {
    if (!props.asset) {
      continueRender(handle);
      return;
    }
    let cancelled = false;
    // the Shiki HTML lives beside the PNG; same stem, .html extension
    const htmlAsset = props.asset.replace(/\.(png|svg)$/i, '.html');
    fetch(staticFile(htmlAsset))
      .then((r) => {
        if (!r.ok) {
          throw new Error(`missing ${htmlAsset}`);
        }
        return r.text();
      })
      .then((text) => {
        if (!cancelled) {
          setHtmlText(text);
        }
        continueRender(handle);
      })
      .catch(() => {
        // no HTML beside the PNG — never break the render; static mode is the
        // visual ground truth
        if (!cancelled) {
          setHtmlText('');
        }
        continueRender(handle);
      });
    return () => {
      cancelled = true;
    };
  }, [props.asset, handle]);

  // which step is lit at this frame (first step before its window)
  const activeIdx = useMemo(() => {
    const sf = props.step_frames!;
    let idx = 0;
    for (let i = 0; i < sf.length; i++) {
      if (frame >= sf[i].start) {
        idx = i;
      }
    }
    return idx;
  }, [frame, props.step_frames]);
  const activeLines = new Set(props.steps![activeIdx].active_lines ?? []);

  // per-line opacity timeline, memoized once per active-step change
  const lineOpacity = useMemo(() => {
    const baseLine = props.start_line ?? 1;
    return (i: number) => {
      const lineNo = baseLine + i;
      if (activeLines.has(lineNo)) {
        return 1.0;
      }
      // adjacent lines stay near-full so context is readable
      for (const l of activeLines) {
        if (Math.abs(l - lineNo) <= 1) {
          return NEAR;
        }
      }
      return DIM;
    };
  }, [activeLines, props.start_line]);

  // apply styles synchronously before paint
  useLayoutEffect(() => {
    const host = hostRef.current;
    if (!host || htmlText === null) {
      return;
    }
    host.querySelectorAll<HTMLElement>('.line').forEach((ln, i) => {
      const o = lineOpacity(i);
      ln.style.opacity = String(o);
    });
  }, [frame, htmlText, lineOpacity, activeIdx]);

  const firstActive = [...activeLines].sort((a, b) => a - b);

  return (
    <AbsoluteFill style={{backgroundColor: '#0B1120', padding: 96}}>
      {props.source_file ? (
        <div style={{color: '#50E6FF', fontFamily: 'JetBrains Mono', fontSize: 30, marginBottom: 24, opacity: props.enter}}>
          {props.source_file}
        </div>
      ) : null}
      <div
        ref={hostRef}
        style={{
          width: '100%',
          height: '86%',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          fontFamily: 'JetBrains Mono',
          fontSize: 36,
          lineHeight: 1.5,
          opacity: props.enter,
        }}
        dangerouslySetInnerHTML={{__html: htmlText ?? ''}}
      />
      {firstActive.length > 0 ? (
        <div
          style={{
            color: '#9BD1FF',
            fontFamily: 'JetBrains Mono',
            fontSize: 28,
            marginTop: 16,
            opacity: props.enter,
          }}
        >
          {`line${firstActive.length > 1 ? 's' : ''} ${firstActive.join(', ')} of ${props.source_file ?? 'main.tf'}`}
        </div>
      ) : null}
    </AbsoluteFill>
  );
};