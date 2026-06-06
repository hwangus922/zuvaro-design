// Zuvaro v3 light — white field · hot pink primary · magenta depth · orange heat.
// Same exports as v2 dark theme; only token values differ.

const Z = {
  bg:        '#FFFFFF',
  bgAlt:     '#FAFAFC',
  card:      '#F4F3F8',
  cardHi:    '#EEEDF3',
  stroke:    'rgba(10,10,20,0.06)',
  strokeHi:  'rgba(10,10,20,0.14)',

  // brand — unchanged
  pink:      '#FF2D87',
  pinkLight: '#FF7AB6',
  magenta:   '#C81E5B',
  magentaDk: '#8A0E3D',

  // ORANGE — the "loot / fire / pts" color (unchanged)
  orange:    '#FF6A2C',
  orangeLt:  '#FFB347',
  orangeDk:  '#C84A12',

  // text — inverted
  text:      '#0A0A0F',
  textMute:  'rgba(10,10,15,0.62)',
  textDim:   'rgba(10,10,15,0.38)',
  textHint:  'rgba(10,10,15,0.18)',
  gridLine:  'rgba(10,10,20,0.6)',
  inkOnWarm: '#170006',   // always-dark text used on warm-gradient surfaces
  auraScale: 0.32,        // light mode: dial the pink/orange aura WAY down on white bg
  sheetOverlay: 'linear-gradient(180deg, rgba(10,10,15,0.08) 0%, rgba(10,10,15,0.28) 50%, #FFFFFF 75%)',
  dotOff:    'rgba(10,10,20,0.14)',
  skeleton:  'rgba(10,10,20,0.08)',

  // type — figma uses Inter throughout
  display:   "'Inter', system-ui, sans-serif",
  body:      "'Inter', system-ui, sans-serif",
  mono:      "'Cairo', 'Inter', system-ui, sans-serif",
};

// Gradient set we reuse
const Z_GRAD = {
  warm:    `linear-gradient(135deg, ${Z.orange} 0%, ${Z.pink} 60%, ${Z.magenta} 100%)`,
  pink:    `linear-gradient(180deg, ${Z.pinkLight}, ${Z.pink})`,
  orange:  `linear-gradient(180deg, ${Z.orangeLt}, ${Z.orange})`,
  cardWarm:`linear-gradient(140deg, ${Z.magenta} 0%, ${Z.pink} 55%, ${Z.orange} 100%)`,
};

// ─── Logo: knotted-arrow mark ────────────────────────────────────────────
// Two interlocking pill capsules at perpendicular 45° angles (chain-link X),
// with an arrowhead at the upper-right tip. Faithful to the figma vector.
function ZMark({ size = 64, gradient = false, color = Z.text, stroke = 7 }) {
  const uid = React.useId ? React.useId() : `_${Math.random().toString(36).slice(2, 8)}`;
  const gid = `zg${uid}`, mid = `zm${uid}`;
  // Pill: horizontal capsule 76 wide × 24 tall, centered at (50,50). rx=12 → fully rounded.
  const pillX = 12, pillY = 38, pillW = 76, pillH = 24, pillR = 12;
  const strokeProps = {
    stroke: gradient ? `url(#${gid})` : color,
    strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round', fill: 'none',
  };
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" fill="none" aria-label="Zuvaro">
      <defs>
        <linearGradient id={gid} x1="0" y1="100%" x2="100%" y2="0">
          <stop offset="0%" stopColor={Z.magenta}/>
          <stop offset="55%" stopColor={Z.pink}/>
          <stop offset="100%" stopColor={Z.orange}/>
        </linearGradient>
        {/* Mask: hide a small chunk of the BACK pill where the FRONT pill passes over */}
        <mask id={mid} maskUnits="userSpaceOnUse">
          <rect width="100" height="100" fill="white"/>
          {/* knockout where the ↗ pill crosses OVER the ↘ pill in the upper-right half */}
          <circle cx="62" cy="38" r={stroke * 1.4} fill="black"/>
        </mask>
      </defs>

      {/* BACK pill — diagonal ↘ (rotated -45° around center) */}
      <g mask={`url(#${mid})`}>
        <rect x={pillX} y={pillY} width={pillW} height={pillH} rx={pillR}
              transform="rotate(-45 50 50)" {...strokeProps}/>
      </g>

      {/* FRONT pill — diagonal ↗ (rotated +45° around center), with arrowhead at tip */}
      <g>
        <rect x={pillX} y={pillY} width={pillW} height={pillH} rx={pillR}
              transform="rotate(45 50 50)" {...strokeProps}/>
        {/* arrowhead at the upper-right tip of the ↗ pill (tip ~ (84,16)) */}
        <path d="M76 14 L86 14 L86 24" {...strokeProps}/>
      </g>
    </svg>
  );
}

// Wordmark — Inter bold, tight
function ZWord({ size = 22, color = Z.text }) {
  return (
    <span style={{
      fontFamily: Z.display, fontWeight: 700, fontSize: size,
      letterSpacing: -0.03 * size, color, lineHeight: 1,
    }}>zuvaro</span>
  );
}

// ─── Icons ───────────────────────────────────────────────────────────────
const ZIcon = ({ d, size = 22, stroke = Z.text, fill = 'none', sw = 1.8, children }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill}
       stroke={stroke} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">
    {d ? <path d={d}/> : children}
  </svg>
);

const ZIcons = {
  home:    (p)=> <ZIcon {...p}><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/></ZIcon>,
  trophy:  (p)=> <ZIcon {...p}><path d="M7 4h10v4a5 5 0 01-10 0V4z"/><path d="M5 6H3a3 3 0 003 3M19 6h2a3 3 0 01-3 3"/><path d="M9 21h6M12 17v4"/></ZIcon>,
  user:    (p)=> <ZIcon {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-7 8-7s8 3 8 7"/></ZIcon>,
  search:  (p)=> <ZIcon {...p}><circle cx="11" cy="11" r="7"/><path d="M20 20l-3.5-3.5"/></ZIcon>,
  thunder: (p)=> <ZIcon {...p}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/></ZIcon>,
  fire:    (p)=> <ZIcon {...p}><path d="M12 3s5 4 5 9a5 5 0 11-10 0c0-2 2-3 2-5 2 1 3 3 3-4z"/></ZIcon>,
  clock:   (p)=> <ZIcon {...p}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></ZIcon>,
  flame:   (p)=> <ZIcon {...p}><path d="M12 3s5 4 5 9a5 5 0 11-10 0c0-2 2-3 2-5 2 1 3 3 3-4z"/></ZIcon>,
  trending:(p)=> <ZIcon {...p}><path d="M3 17l6-6 4 4 8-8M21 7h-5M21 7v5"/></ZIcon>,
  chevR:   (p)=> <ZIcon {...p}><path d="M9 6l6 6-6 6"/></ZIcon>,
  chevD:   (p)=> <ZIcon {...p}><path d="M6 9l6 6 6-6"/></ZIcon>,
  chevU:   (p)=> <ZIcon {...p}><path d="M6 15l6-6 6 6"/></ZIcon>,
  chevL:   (p)=> <ZIcon {...p}><path d="M15 6l-6 6 6 6"/></ZIcon>,
  check:   (p)=> <ZIcon {...p}><path d="M5 12l4 4L19 6"/></ZIcon>,
  edit:    (p)=> <ZIcon {...p}><path d="M4 20h4L20 8l-4-4L4 16v4z"/></ZIcon>,
  star:    (p)=> <ZIcon {...p}><path d="M12 2l3 6.7 7.3.7-5.5 4.9 1.7 7.1L12 17.8 5.5 21.4l1.7-7.1L1.7 9.4l7.3-.7L12 2z"/></ZIcon>,
  bolt:    (p)=> <ZIcon {...p}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/></ZIcon>,
  google:  (p)=> <ZIcon {...p} fill="currentColor" stroke="none"><path d="M21.6 12.2c0-.7-.1-1.3-.2-1.9H12v3.7h5.4c-.2 1.2-.9 2.3-2 3v2.5h3.2c1.9-1.7 3-4.3 3-7.3z"/><path d="M12 22c2.7 0 5-.9 6.6-2.4l-3.2-2.5c-.9.6-2 1-3.4 1-2.6 0-4.8-1.8-5.6-4.1H3.1v2.6C4.8 19.7 8.1 22 12 22z"/><path d="M6.4 14c-.2-.6-.3-1.3-.3-2s.1-1.4.3-2V7.3H3.1C2.4 8.7 2 10.3 2 12s.4 3.3 1.1 4.7L6.4 14z"/><path d="M12 5.9c1.5 0 2.8.5 3.8 1.5l2.8-2.8C16.9 3 14.7 2 12 2 8.1 2 4.8 4.3 3.1 7.3L6.4 9.9c.8-2.3 3-4 5.6-4z"/></ZIcon>,
  mail:    (p)=> <ZIcon {...p}><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></ZIcon>,
  close:   (p)=> <ZIcon {...p}><path d="M6 6l12 12M18 6L6 18"/></ZIcon>,
  settings:(p)=> <ZIcon {...p}><circle cx="12" cy="12" r="3"/><path d="M19.4 13.9l1.6 1-2 3.5-1.9-.7a8 8 0 01-2 1.2L14.5 21h-5l-.6-2.1a8 8 0 01-2-1.2l-1.9.7-2-3.5 1.6-1a8 8 0 010-2.2L3 10.7l2-3.5 1.9.7a8 8 0 012-1.2L9.5 4.7l5-.7.6 2.1a8 8 0 012 1.2l1.9-.7 2 3.5-1.6 1a8 8 0 010 2.2z"/></ZIcon>,
  bell:    (p)=> <ZIcon {...p}><path d="M18 16v-5a6 6 0 10-12 0v5l-2 2h16l-2-2z"/><path d="M9 20a3 3 0 006 0"/></ZIcon>,
  message: (p)=> <ZIcon {...p}><path d="M21 12a8 8 0 01-8 8H7l-4 3V12a8 8 0 018-8h2a8 8 0 018 8z"/></ZIcon>,
  plus:    (p)=> <ZIcon {...p}><path d="M12 5v14M5 12h14"/></ZIcon>,
  users:   (p)=> <ZIcon {...p}><circle cx="9" cy="8" r="3"/><circle cx="16" cy="9" r="2.5"/><path d="M3 20c0-3 3-5 6-5s6 2 6 5M14 20c0-2 2-3.5 4-3.5"/></ZIcon>,
};

// Type helpers
const ZT = {
  display: (s=24, w=700)=>({ fontFamily: Z.display, fontWeight: w, fontSize: s, letterSpacing: -0.02 * s, lineHeight: 1.1,  color: Z.text }),
  body:    (s=16, w=400)=>({ fontFamily: Z.body,    fontWeight: w, fontSize: s, lineHeight: '22px', color: Z.text }),
  small:   (s=12, w=400)=>({ fontFamily: Z.body,    fontWeight: w, fontSize: s, lineHeight: '22px', color: Z.text }),
  label:   (s=10)         =>({ fontFamily: Z.body,    fontWeight: 700, fontSize: s, letterSpacing: 0.1, textTransform: 'uppercase', color: Z.textMute }),
  mono:    (s=16, w=700)=>({ fontFamily: Z.mono,    fontWeight: w, fontSize: s, lineHeight: 1, color: Z.text }),
};

Object.assign(window, { Z, Z_GRAD, ZMark, ZWord, ZIcons, ZT });
