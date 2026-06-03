// Zuvaro — theme tokens, logo mark, icon set
// All shared visual primitives live here.

const ZTheme = {
  // surfaces
  bg:        '#08080A',
  bgAlt:     '#0E0E11',
  card:      '#141417',
  cardHi:    '#1C1C20',
  stroke:    'rgba(255,255,255,0.06)',
  strokeHi:  'rgba(255,255,255,0.12)',

  // brand
  pink:      '#FF2D87',
  pinkLight: '#FF7AB6',
  magenta:   '#C81E5B',
  magentaDk: '#8A0E3D',

  // text
  text:      '#FFFFFF',
  textMute:  'rgba(255,255,255,0.55)',
  textDim:   'rgba(255,255,255,0.32)',
  textHint:  'rgba(255,255,255,0.18)',

  // type
  display:   "'Space Grotesk', system-ui, sans-serif",
  body:      "'Inter', system-ui, sans-serif",
  mono:      "'JetBrains Mono', ui-monospace, monospace",
};

// ─── Logo: two interlocking petal-strokes forming a chain-link Z ─────────
// Original mark. Two oblong loops, weaving over/under, mirrored across the
// horizontal axis. Stroked, not filled, so it reads at all sizes.
function ZuvaroMark({ size = 64, color = ZTheme.pink, stroke = 6 }) {
  const w = size, h = size;
  return (
    <svg width={w} height={h} viewBox="0 0 100 100" fill="none" aria-label="Zuvaro">
      <defs>
        <linearGradient id="zg" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor={ZTheme.pinkLight} />
          <stop offset="60%" stopColor={color} />
          <stop offset="100%" stopColor={ZTheme.magenta} />
        </linearGradient>
        <mask id="zm">
          <rect width="100" height="100" fill="white" />
          {/* knock out a sliver from the back loop where the front passes over */}
          <path d="M50 50 m-9 -2 a 11 11 0 0 1 18 4" stroke="black" strokeWidth="9" fill="none" />
        </mask>
      </defs>
      {/* back loop — leaning right */}
      <g mask="url(#zm)">
        <path
          d="M20 24 C 20 10, 50 10, 60 30 S 80 76, 80 76"
          stroke="url(#zg)" strokeWidth={stroke} strokeLinecap="round" fill="none"
        />
        <path
          d="M80 76 C 80 90, 50 90, 40 70 S 20 24, 20 24"
          stroke="url(#zg)" strokeWidth={stroke} strokeLinecap="round" fill="none"
        />
      </g>
      {/* front loop — mirrored, weaves through the back */}
      <path
        d="M80 24 C 80 10, 50 10, 40 30 S 20 76, 20 76"
        stroke="url(#zg)" strokeWidth={stroke} strokeLinecap="round" fill="none"
      />
      <path
        d="M20 76 C 20 90, 50 90, 60 70 S 80 24, 80 24"
        stroke="url(#zg)" strokeWidth={stroke} strokeLinecap="round" fill="none"
      />
    </svg>
  );
}

// ─── Wordmark — Space Grotesk weight 600, tight tracking ──────────────────
function ZuvaroWordmark({ size = 22, color = ZTheme.text }) {
  return (
    <span style={{
      fontFamily: ZTheme.display, fontWeight: 600, fontSize: size,
      letterSpacing: -0.04 * size, color,
    }}>zuvaro</span>
  );
}

// ─── Icons (24px, line, 1.6 stroke) ──────────────────────────────────────
const Icon = ({ d, size = 22, stroke = ZTheme.text, fill = 'none', sw = 1.6, children }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill}
       stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
    {d ? <path d={d}/> : children}
  </svg>
);

const Icons = {
  home:    (p)=> <Icon {...p}><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/></Icon>,
  trophy:  (p)=> <Icon {...p}><path d="M7 4h10v4a5 5 0 01-10 0V4z"/><path d="M5 6H3a3 3 0 003 3M19 6h2a3 3 0 01-3 3"/><path d="M9 21h6M12 17v4"/></Icon>,
  user:    (p)=> <Icon {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-7 8-7s8 3 8 7"/></Icon>,
  plus:    (p)=> <Icon {...p}><path d="M12 5v14M5 12h14"/></Icon>,
  search:  (p)=> <Icon {...p}><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></Icon>,
  bell:    (p)=> <Icon {...p}><path d="M6 16V11a6 6 0 1112 0v5l2 2H4l2-2z"/><path d="M10 21a2 2 0 004 0"/></Icon>,
  flame:   (p)=> <Icon {...p}><path d="M12 3s5 4 5 9a5 5 0 11-10 0c0-2 2-3 2-5 2 1 3 3 3-4z"/></Icon>,
  bolt:    (p)=> <Icon {...p}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/></Icon>,
  chevR:   (p)=> <Icon {...p}><path d="M9 6l6 6-6 6"/></Icon>,
  chevD:   (p)=> <Icon {...p}><path d="M6 9l6 6 6-6"/></Icon>,
  chevL:   (p)=> <Icon {...p}><path d="M15 6l-6 6 6 6"/></Icon>,
  close:   (p)=> <Icon {...p}><path d="M6 6l12 12M18 6L6 18"/></Icon>,
  apple:   (p)=> <Icon {...p} fill="currentColor" stroke="none"><path d="M16.4 12.7c0-2.3 1.9-3.4 2-3.5-1.1-1.6-2.8-1.8-3.4-1.8-1.4-.2-2.8.9-3.5.9-.7 0-1.9-.8-3.1-.8-1.6 0-3.1 1-3.9 2.4-1.7 2.9-.4 7.2 1.2 9.6.8 1.2 1.7 2.4 3 2.4 1.2 0 1.7-.8 3.1-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.4.6-.9 1.1-1.9 1.4-2.9-.1 0-2.7-1-2.7-3.9zM14.2 5.8c.7-.8 1.1-2 1-3.1-1 0-2.2.7-2.9 1.5-.6.7-1.2 1.9-1.1 3 1.1.1 2.3-.6 3-1.4z"/></Icon>,
  google:  (p)=> <Icon {...p} fill="currentColor" stroke="none"><path d="M21.6 12.2c0-.7-.1-1.3-.2-1.9H12v3.7h5.4c-.2 1.2-.9 2.3-2 3v2.5h3.2c1.9-1.7 3-4.3 3-7.3z"/><path d="M12 22c2.7 0 5-.9 6.6-2.4l-3.2-2.5c-.9.6-2 1-3.4 1-2.6 0-4.8-1.8-5.6-4.1H3.1v2.6C4.8 19.7 8.1 22 12 22z"/><path d="M6.4 14c-.2-.6-.3-1.3-.3-2s.1-1.4.3-2V7.3H3.1C2.4 8.7 2 10.3 2 12s.4 3.3 1.1 4.7L6.4 14z"/><path d="M12 5.9c1.5 0 2.8.5 3.8 1.5l2.8-2.8C16.9 3 14.7 2 12 2 8.1 2 4.8 4.3 3.1 7.3L6.4 9.9c.8-2.3 3-4 5.6-4z"/></Icon>,
  mail:    (p)=> <Icon {...p}><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></Icon>,
  help:    (p)=> <Icon {...p}><circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 015 0c0 1.7-2.5 2-2.5 4"/><circle cx="12" cy="17" r=".5" fill="currentColor"/></Icon>,
  settings:(p)=> <Icon {...p}><circle cx="12" cy="12" r="3"/><path d="M19.4 13.9l1.6 1-2 3.5-1.9-.7a8 8 0 01-2 1.2L14.5 21h-5l-.6-2.1a8 8 0 01-2-1.2l-1.9.7-2-3.5 1.6-1a8 8 0 010-2.2L3 10.7l2-3.5 1.9.7a8 8 0 012-1.2L9.5 4.7l5-.7.6 2.1a8 8 0 012 1.2l1.9-.7 2 3.5-1.6 1a8 8 0 010 2.2z"/></Icon>,
  share:   (p)=> <Icon {...p}><path d="M12 2v14M7 7l5-5 5 5M5 14v6h14v-6"/></Icon>,
  arrowU:  (p)=> <Icon {...p}><path d="M12 19V5M5 12l7-7 7 7"/></Icon>,
  arrowD:  (p)=> <Icon {...p}><path d="M12 5v14M5 12l7 7 7-7"/></Icon>,
  dot:     (p)=> <Icon {...p} fill="currentColor" stroke="none"><circle cx="12" cy="12" r="3"/></Icon>,
  medal:   (p)=> <Icon {...p}><circle cx="12" cy="15" r="6"/><path d="M9 9l-3-6M15 9l3-6M9 15h6"/></Icon>,
  calendar:(p)=> <Icon {...p}><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9h18M8 3v4M16 3v4"/></Icon>,
};

// Quick text-style helpers
const T = {
  display:  (s=48)=>({ fontFamily: ZTheme.display, fontWeight: 600, fontSize: s, letterSpacing: -0.03 * s, lineHeight: 1.05, color: ZTheme.text }),
  title:    (s=22)=>({ fontFamily: ZTheme.display, fontWeight: 600, fontSize: s, letterSpacing: -0.02 * s, lineHeight: 1.2,  color: ZTheme.text }),
  body:     (s=15)=>({ fontFamily: ZTheme.body, fontWeight: 400, fontSize: s, lineHeight: 1.45, color: ZTheme.text }),
  label:    (s=12)=>({ fontFamily: ZTheme.body, fontWeight: 500, fontSize: s, letterSpacing: 0.08, textTransform: 'uppercase', color: ZTheme.textMute }),
  mono:     (s=13)=>({ fontFamily: ZTheme.mono, fontWeight: 500, fontSize: s, letterSpacing: -0.02, color: ZTheme.text }),
};

Object.assign(window, { ZTheme, ZuvaroMark, ZuvaroWordmark, Icons, T });
