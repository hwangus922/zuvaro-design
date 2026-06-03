// Zuvaro — onboarding screens (logo, welcome A/B, sign up)
// Each screen is a self-contained component sized for IOSDevice's content area.

// ─── Shared scaffolding ──────────────────────────────────────────────────
function ScreenBG({ children, style }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, background: ZTheme.bg, color: ZTheme.text,
      fontFamily: ZTheme.body, overflow: 'hidden', ...style,
    }}>
      {children}
    </div>
  );
}

// Radial pink glow used on hero screens
function PinkAura({ x = '50%', y = '32%', r = 280, opacity = 0.55 }) {
  return (
    <div style={{
      position: 'absolute', left: x, top: y, transform: 'translate(-50%, -50%)',
      width: r * 2, height: r * 2, borderRadius: '50%',
      background: `radial-gradient(circle, ${ZTheme.pink} 0%, ${ZTheme.magenta} 30%, transparent 70%)`,
      filter: 'blur(60px)', opacity, pointerEvents: 'none',
    }} />
  );
}

// Faint grid texture
function GridTex({ opacity = 0.05 }) {
  return (
    <div style={{
      position: 'absolute', inset: 0, pointerEvents: 'none', opacity,
      backgroundImage:
        'linear-gradient(rgba(255,255,255,0.6) 1px, transparent 1px),' +
        'linear-gradient(90deg, rgba(255,255,255,0.6) 1px, transparent 1px)',
      backgroundSize: '32px 32px',
      maskImage: 'radial-gradient(ellipse at center, black 30%, transparent 75%)',
      WebkitMaskImage: 'radial-gradient(ellipse at center, black 30%, transparent 75%)',
    }} />
  );
}

// ─── Logo-only card ──────────────────────────────────────────────────────
function LogoScreen() {
  return (
    <ScreenBG>
      <PinkAura y="50%" r={220} opacity={0.55} />
      <GridTex opacity={0.04} />
      <div style={{
        position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 28,
      }}>
        <ZuvaroMark size={160} stroke={5} />
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
          <ZuvaroWordmark size={28} />
          <span style={{ ...T.label(10), letterSpacing: 0.32, color: ZTheme.textMute }}>
            move · track · belong
          </span>
        </div>
      </div>
    </ScreenBG>
  );
}

// ─── Welcome A (centered, prominent CTA) ─────────────────────────────────
function WelcomeA({ onContinue, onSignIn } = {}) {
  return (
    <ScreenBG>
      <PinkAura y="38%" r={260} opacity={0.7} />
      <GridTex />
      {/* tagline pill, top */}
      <div style={{ position: 'absolute', top: 64, left: 0, right: 0, display: 'flex', justifyContent: 'center' }}>
        <div style={{
          padding: '8px 14px', borderRadius: 999,
          background: 'rgba(255,255,255,0.04)', border: `1px solid ${ZTheme.strokeHi}`,
          ...T.label(10), color: ZTheme.textMute, backdropFilter: 'blur(8px)',
        }}>
          <span style={{ color: ZTheme.pinkLight }}>●</span>  beta · v0.4
        </div>
      </div>

      {/* logo + headline */}
      <div style={{
        position: 'absolute', top: 0, bottom: 220, left: 0, right: 0,
        display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 32, padding: '0 32px',
      }}>
        <ZuvaroMark size={104} stroke={5} />
        <div style={{ textAlign: 'center', maxWidth: 320 }}>
          <h1 style={{ ...T.display(44), margin: 0 }}>
            Welcome to <span style={{ color: ZTheme.pink }}>Zuvaro</span>
          </h1>
          <p style={{ ...T.body(15), color: ZTheme.textMute, marginTop: 14, textWrap: 'pretty' }}>
            Train with your people. Log every session.
            Climb the board.
          </p>
        </div>
      </div>

      {/* CTAs */}
      <div style={{
        position: 'absolute', bottom: 56, left: 24, right: 24,
        display: 'flex', flexDirection: 'column', gap: 12,
      }}>
        <button onClick={onContinue} style={ctaPrimary}>Get started</button>
        <button onClick={onSignIn} style={ctaText}>I already have an account</button>
      </div>
    </ScreenBG>
  );
}

// ─── Welcome B (with feature list, secondary variant) ────────────────────
function WelcomeB({ onContinue, onSignIn } = {}) {
  const features = [
    { icon: Icons.flame, label: 'Daily streaks', tint: ZTheme.pink },
    { icon: Icons.trophy, label: 'Friend-group leaderboard', tint: ZTheme.pinkLight },
    { icon: Icons.bolt, label: 'Live session check-ins', tint: ZTheme.magenta },
  ];
  return (
    <ScreenBG>
      <PinkAura y="22%" r={220} opacity={0.6} />
      <GridTex />
      <div style={{
        position: 'absolute', top: 80, left: 24, right: 24,
        display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 24,
      }}>
        <ZuvaroMark size={64} stroke={5} />
        <div>
          <h1 style={{ ...T.display(38), margin: 0 }}>Welcome to<br/>
            <span style={{ color: ZTheme.pink }}>Zuvaro.</span>
          </h1>
          <p style={{ ...T.body(15), color: ZTheme.textMute, marginTop: 12, textWrap: 'pretty', maxWidth: 320 }}>
            A community-first training log built for people who&nbsp;turn up.
          </p>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, width: '100%', marginTop: 8 }}>
          {features.map((f, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px',
              borderRadius: 16, background: ZTheme.card, border: `1px solid ${ZTheme.stroke}`,
            }}>
              <span style={{
                width: 36, height: 36, borderRadius: 12, display: 'grid', placeItems: 'center',
                background: 'rgba(255,45,135,0.12)', color: f.tint,
              }}><f.icon size={18} stroke={f.tint}/></span>
              <span style={{ ...T.body(14), color: ZTheme.text }}>{f.label}</span>
            </div>
          ))}
        </div>
      </div>
      <div style={{ position: 'absolute', bottom: 56, left: 24, right: 24, display: 'flex', flexDirection: 'column', gap: 12 }}>
        <button onClick={onContinue} style={ctaPrimary}>Get started</button>
        <button onClick={onSignIn} style={ctaText}>Sign in instead</button>
      </div>
    </ScreenBG>
  );
}

// ─── Sign up (auth providers) ────────────────────────────────────────────
function SignUpScreen({ onApple, onGoogle, onEmail, onBack } = {}) {
  return (
    <ScreenBG>
      <PinkAura y="20%" r={200} opacity={0.45} />
      <GridTex />

      {/* nav */}
      <div style={{
        position: 'absolute', top: 60, left: 0, right: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '8px 18px',
      }}>
        <button onClick={onBack} style={iconBtn}><Icons.chevL size={20} stroke={ZTheme.text}/></button>
        <button style={iconBtn}><Icons.help size={20} stroke={ZTheme.textMute}/></button>
      </div>

      {/* hero */}
      <div style={{ position: 'absolute', top: 140, left: 24, right: 24 }}>
        <ZuvaroMark size={56} stroke={5} />
        <h1 style={{ ...T.display(32), margin: '24px 0 0' }}>Sign up to <span style={{ color: ZTheme.pink }}>Zuvaro</span></h1>
        <p style={{ ...T.body(14), color: ZTheme.textMute, marginTop: 10 }}>
          Pick a way to sign in. We&rsquo;ll never post or message your contacts.
        </p>
      </div>

      {/* providers */}
      <div style={{ position: 'absolute', bottom: 56, left: 24, right: 24, display: 'flex', flexDirection: 'column', gap: 10 }}>
        <button onClick={onApple} style={ctaSecondary}>
          <Icons.apple size={18} stroke={ZTheme.text} />
          <span>Continue with Apple</span>
        </button>
        <button onClick={onGoogle} style={ctaSecondary}>
          <Icons.google size={18} stroke={ZTheme.text} />
          <span>Continue with Google</span>
        </button>
        <button onClick={onEmail} style={{ ...ctaPrimary, marginTop: 6 }}>
          <Icons.mail size={18} stroke="#000" />
          <span>Continue with email</span>
        </button>
        <p style={{ ...T.body(11), color: ZTheme.textDim, marginTop: 10, textAlign: 'center' }}>
          By continuing you agree to our <u>Terms</u> &amp; <u>Privacy</u>.
        </p>
      </div>
    </ScreenBG>
  );
}

// ─── Shared button styles ────────────────────────────────────────────────
const ctaPrimary = {
  height: 54, borderRadius: 16, border: 'none', cursor: 'pointer',
  background: `linear-gradient(180deg, ${ZTheme.pinkLight}, ${ZTheme.pink})`,
  color: '#0A0508', ...T.body(15), fontWeight: 600,
  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
  boxShadow: '0 10px 24px -10px rgba(255,45,135,0.7), inset 0 1px 0 rgba(255,255,255,0.35)',
};
const ctaSecondary = {
  height: 54, borderRadius: 16, cursor: 'pointer',
  background: ZTheme.card, color: ZTheme.text, border: `1px solid ${ZTheme.strokeHi}`,
  ...T.body(15), fontWeight: 500,
  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
};
const ctaText = {
  height: 40, borderRadius: 12, cursor: 'pointer',
  background: 'transparent', color: ZTheme.textMute, border: 'none',
  ...T.body(13), fontWeight: 500,
};
const iconBtn = {
  width: 36, height: 36, borderRadius: 12, display: 'grid', placeItems: 'center',
  background: 'rgba(255,255,255,0.05)', border: `1px solid ${ZTheme.stroke}`, cursor: 'pointer',
  padding: 0,
};

Object.assign(window, {
  LogoScreen, WelcomeA, WelcomeB, SignUpScreen,
  ScreenBG, PinkAura, GridTex,
  ctaPrimary, ctaSecondary, ctaText, iconBtn,
});
