// Zuvaro v2 — onboarding screens (logo + welcome variants + sign up sheet)
// Sized for the 390×844 figma artboard; renders inside IOSDevice content area.

function ZScreen({ children, style }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, background: Z.bg, color: Z.text,
      fontFamily: Z.body, overflow: 'hidden', ...style,
    }}>{children}</div>
  );
}

// Heat aura — orange→pink→magenta radial glow used on hero screens.
// Theme can scale the strength via Z.auraScale (light mode dials it WAY down).
function HeatAura({ x = '50%', y = '32%', r = 280, opacity = 0.6 }) {
  const scale = Z.auraScale ?? 1;
  return (
    <div style={{
      position: 'absolute', left: x, top: y, transform: 'translate(-50%, -50%)',
      width: r * 2, height: r * 2, borderRadius: '50%',
      background: `radial-gradient(circle, ${Z.orange} 0%, ${Z.pink} 28%, ${Z.magenta} 50%, transparent 72%)`,
      filter: 'blur(60px)', opacity: opacity * scale, pointerEvents: 'none',
    }}/>
  );
}

// Grid texture (faint) — picks line color from theme so it inverts in light mode
function ZGrid({ opacity = 0.04 }) {
  const line = Z.gridLine || 'rgba(255,255,255,0.6)';
  return (
    <div style={{
      position: 'absolute', inset: 0, pointerEvents: 'none', opacity,
      backgroundImage:
        `linear-gradient(${line} 1px, transparent 1px),` +
        `linear-gradient(90deg, ${line} 1px, transparent 1px)`,
      backgroundSize: '32px 32px',
      maskImage: 'radial-gradient(ellipse at center, black 30%, transparent 75%)',
      WebkitMaskImage: 'radial-gradient(ellipse at center, black 30%, transparent 75%)',
    }}/>
  );
}

// ─── ONBOARDING 1 — splash (logo only) ───────────────────────────────────
function ZOnboarding1() {
  return (
    <ZScreen>
      <HeatAura y="50%" r={220} opacity={0.65}/>
      <ZGrid/>
      <div style={{
        position: 'absolute', inset: 0,
        display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 24,
      }}>
        <ZMark size={140} stroke={6}/>
        <ZWord size={32}/>
        <span style={{ ...ZT.label(10), color: Z.textMute, letterSpacing: 0.32 }}>dare · do · earn</span>
      </div>
    </ZScreen>
  );
}

// ─── Phone-in-phone illustration (used on onboarding 2 / 3) ──────────────
function PhoneMockup() {
  return (
    <div style={{
      position: 'absolute', left: 99, top: 88, width: 192, height: 416,
      borderRadius: 40, overflow: 'hidden',
      background: `linear-gradient(180deg, ${Z.cardHi} 0%, ${Z.card} 60%, ${Z.bg} 100%)`,
      border: `1px solid ${Z.strokeHi}`,
      boxShadow: `inset 0 1px 0 rgba(255,255,255,0.06), 0 24px 60px -20px ${Z.pink}44`,
    }}>
      {/* notch */}
      <div style={{
        position: 'absolute', top: 8, left: '50%', transform: 'translateX(-50%)',
        width: 60, height: 18, borderRadius: 9, background: '#000',
      }}/>
      {/* aura behind logo */}
      <div style={{
        position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%,-50%)',
        width: 200, height: 200,
        background: `radial-gradient(circle, ${Z.pink}44 0%, ${Z.orange}22 40%, transparent 70%)`,
        filter: 'blur(20px)',
      }}/>
      {/* logo */}
      <div style={{
        position: 'absolute', left: 64, top: 176, width: 64, height: 64,
        display: 'grid', placeItems: 'center',
      }}>
        <ZMark size={64} stroke={5}/>
      </div>
      {/* fake ui hints — dare card silhouettes */}
      <div style={{ position: 'absolute', left: 16, bottom: 28, right: 16, display: 'flex', flexDirection: 'column', gap: 6 }}>
        {[Z.orange, Z.pink, Z.magenta].map((c, i) => (
          <div key={i} style={{
            height: 26, borderRadius: 8, background: Z.cardHi,
            border: `1px solid ${Z.stroke}`, display: 'flex', alignItems: 'center', gap: 6, padding: '0 8px',
          }}>
            <div style={{ width: 14, height: 14, borderRadius: 7, background: c }}/>
            <div style={{ height: 4, flex: 1, borderRadius: 2, background: Z.skeleton || 'rgba(255,255,255,0.08)' }}/>
            <div style={{
              padding: '2px 6px', borderRadius: 4, background: `${c}22`, color: c,
              ...ZT.small(8, 700), letterSpacing: 0.1,
            }}>+{(i+1)*10}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

// page-indicator dots (4 dots, one active = pill)
function PageDots({ active = 0, count = 4 }) {
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, top: 640,
      display: 'flex', justifyContent: 'center', gap: 8,
    }}>
      {Array.from({ length: count }).map((_, i) => {
        const on = i === active;
        return <div key={i} style={{
          width: on ? 22 : 6, height: 6, borderRadius: 3,
          background: on
            ? `linear-gradient(90deg, ${Z.pink}, ${Z.orange})`
            : (Z.dotOff || 'rgba(255,255,255,0.18)'),
          transition: 'all .2s',
        }}/>;
      })}
    </div>
  );
}

// ─── ONBOARDING 2 — welcome + TOS unchecked + Get Started ────────────────
function ZOnboarding2({ onContinue, onSignIn } = {}) {
  return (
    <ZScreen>
      <HeatAura y="18%" r={200} opacity={0.5}/>
      <ZGrid/>
      <PhoneMockup/>

      {/* title */}
      <div style={{ position: 'absolute', left: 0, right: 0, top: 522, textAlign: 'center', padding: '0 32px' }}>
        <h1 style={{ ...ZT.display(28, 700), margin: 0 }}>Welcome to <span style={{
          background: Z_GRAD.warm, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
          backgroundClip: 'text',
        }}>Zuvaro</span></h1>
        <p style={{ ...ZT.body(14), color: Z.textMute, marginTop: 10, textWrap: 'pretty' }}>
          Daily dares from the group chat. Climb the board. Get clout, lose dignity, repeat.
        </p>
      </div>

      <PageDots active={0}/>

      {/* TOS row */}
      <div style={{ position: 'absolute', left: 24, right: 24, top: 660, display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{
          width: 24, height: 24, borderRadius: '50%',
          border: `2px solid ${Z.strokeHi}`, background: 'transparent',
        }}/>
        <span style={{ ...ZT.body(14), color: Z.text }}>I agree to the Terms of Service</span>
      </div>

      {/* CTA — disabled state */}
      <button onClick={onContinue} style={{
        position: 'absolute', left: 15, right: 14, top: 706, height: 48,
        borderRadius: 24, border: `1px solid ${Z.stroke}`, cursor: 'pointer',
        background: Z.card, color: Z.textDim, ...ZT.body(16, 600),
      }}>Get Started</button>

      <button onClick={onSignIn} style={{
        position: 'absolute', left: 0, right: 0, top: 770, height: 20,
        background: 'transparent', border: 'none', cursor: 'pointer',
        ...ZT.body(16), color: Z.textMute, textDecoration: 'underline',
      }}>I already have an account</button>
    </ZScreen>
  );
}

// ─── ONBOARDING 3 — same, but TOS checked + CTA hot ──────────────────────
function ZOnboarding3({ onContinue, onSignIn } = {}) {
  return (
    <ZScreen>
      <HeatAura y="18%" r={200} opacity={0.5}/>
      <ZGrid/>
      <PhoneMockup/>

      <div style={{ position: 'absolute', left: 0, right: 0, top: 522, textAlign: 'center', padding: '0 32px' }}>
        <h1 style={{ ...ZT.display(28, 700), margin: 0 }}>Welcome to <span style={{
          background: Z_GRAD.warm, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
          backgroundClip: 'text',
        }}>Zuvaro</span></h1>
        <p style={{ ...ZT.body(14), color: Z.textMute, marginTop: 10, textWrap: 'pretty' }}>
          Daily dares from the group chat. Climb the board. Get clout, lose dignity, repeat.
        </p>
      </div>

      <PageDots active={0}/>

      {/* TOS row — checked */}
      <div style={{ position: 'absolute', left: 24, right: 24, top: 660, display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{
          width: 24, height: 24, borderRadius: '50%',
          background: Z_GRAD.warm, display: 'grid', placeItems: 'center',
          boxShadow: `0 0 0 1px ${Z.pink}`,
        }}>
          <ZIcons.check size={16} stroke="#0A0508" sw={3}/>
        </div>
        <span style={{ ...ZT.body(14), color: Z.text }}>I agree to the Terms of Service</span>
      </div>

      {/* CTA — enabled hot pink */}
      <button onClick={onContinue} style={{
        position: 'absolute', left: 15, right: 14, top: 706, height: 48,
        borderRadius: 24, border: 'none', cursor: 'pointer',
        background: Z_GRAD.warm, color: '#0A0508', ...ZT.body(16, 700),
        boxShadow: `0 14px 32px -10px ${Z.pink}, inset 0 1px 0 rgba(255,255,255,0.3)`,
      }}>Get Started</button>

      <button onClick={onSignIn} style={{
        position: 'absolute', left: 0, right: 0, top: 770, height: 20,
        background: 'transparent', border: 'none', cursor: 'pointer',
        ...ZT.body(16), color: Z.textMute, textDecoration: 'underline',
      }}>I already have an account</button>
    </ZScreen>
  );
}

// ─── ONBOARDING 4 — sign up sheet over dimmed screen ─────────────────────
function ZOnboarding4({ onEmail, onGoogle, onSignIn } = {}) {
  return (
    <ZScreen>
      <HeatAura y="14%" r={180} opacity={0.4}/>
      <ZGrid opacity={0.03}/>

      {/* dimmed phone behind */}
      <div style={{ opacity: 0.42, filter: 'blur(0.5px)' }}>
        <PhoneMockup/>
      </div>

      {/* dim overlay */}
      <div style={{
        position: 'absolute', inset: 0,
        background: Z.sheetOverlay || `linear-gradient(180deg, rgba(10,10,12,0.4) 0%, rgba(10,10,12,0.7) 50%, ${Z.bg} 75%)`,
        pointerEvents: 'none',
      }}/>

      {/* bottom sheet */}
      <div style={{
        position: 'absolute', left: 0, right: 0, top: 523, height: 320,
        borderRadius: '30px 30px 0 0',
        background: `linear-gradient(180deg, ${Z.bgAlt} 0%, ${Z.bg} 100%)`,
        border: `1px solid ${Z.strokeHi}`, borderBottom: 'none',
        padding: '14px 24px 0',
      }}>
        {/* grab handle */}
        <div style={{
          width: 64, height: 4, borderRadius: 2,
          background: `linear-gradient(90deg, ${Z.pink}, ${Z.orange})`,
          margin: '0 auto 18px',
        }}/>
        <h2 style={{ ...ZT.display(24, 700), textAlign: 'center', margin: 0 }}>
          Sign up to <span style={{
            background: Z_GRAD.warm, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
            backgroundClip: 'text',
          }}>Zuvaro</span>
        </h2>
        <p style={{ ...ZT.body(15), color: Z.textMute, textAlign: 'center', marginTop: 10 }}>
          Pick a way in. We won&rsquo;t post or message your contacts.
        </p>

        <button onClick={onEmail} style={{
          marginTop: 30, width: '100%', height: 48, borderRadius: 24, border: 'none', cursor: 'pointer',
          background: Z_GRAD.warm, color: '#0A0508', ...ZT.body(16, 700),
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          boxShadow: `0 14px 32px -10px ${Z.pink}, inset 0 1px 0 rgba(255,255,255,0.3)`,
        }}>
          <ZIcons.mail size={18} stroke="#0A0508" sw={2}/>
          <span>Continue with email</span>
        </button>

        <button onClick={onGoogle} style={{
          marginTop: 10, width: '100%', height: 48, borderRadius: 24, cursor: 'pointer',
          background: Z.cardHi, color: Z.text, border: `1px solid ${Z.strokeHi}`, ...ZT.body(16, 600),
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
        }}>
          <ZIcons.google size={18} stroke={Z.text}/>
          <span>Continue with Google</span>
        </button>

        <button onClick={onSignIn} style={{
          marginTop: 14, width: '100%', height: 28, cursor: 'pointer',
          background: 'transparent', border: 'none',
          ...ZT.body(13), color: Z.textMute, textDecoration: 'underline',
        }}>I already have an account</button>
      </div>
    </ZScreen>
  );
}

Object.assign(window, {
  ZScreen, HeatAura, ZGrid, PhoneMockup, PageDots,
  ZOnboarding1, ZOnboarding2, ZOnboarding3, ZOnboarding4,
});
