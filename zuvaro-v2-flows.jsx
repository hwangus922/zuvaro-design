// Zuvaro v2 — MVP flow screens: auth, challenge detail/complete, quest chain.
// Consumes ZScreen, HeatAura, ZGrid, ChallengeCard patterns from onboarding + app.

const Z_CHALLENGES = [
  { time: '6 min', text: 'Let yo bih go thru yo phone', pts: 20, hook: 'Oh hell naw jigsaw u tweaking bruh', minutes: 6,
    rules: 'Hand your phone unlocked to someone in the room for 6 minutes. They can scroll anything except banking apps. Screen recording counts as a skip.' },
  { time: '9 min', text: 'Text your ex', pts: 10, hook: 'Yes.', minutes: 9,
    rules: 'Send one honest text to your ex. No scheduling a call. Screenshot optional — we trust the chaos.' },
  { time: '2 hrs', text: 'Run 10 km', pts: 50, hook: 'Burn some calories', minutes: 120,
    rules: 'Continuous run or walk. Strava / Apple Health / a sweaty selfie counts as proof.' },
  { time: '5 hrs', text: 'Larp having money', pts: 60, hook: 'Larp larp larp sahur', minutes: 300,
    rules: 'Post a story flexing obvious fake wealth for at least 5 hours. Comments must stay in character.' },
  { time: '1 min', text: 'Make a dumb joke', pts: null, hook: 'Pure embarrassment', minutes: 1,
    rules: 'Tell the joke out loud to at least two people. Groans = success. No points, only shame.' },
];

const zCtaPrimary = {
  width: '100%', height: 48, borderRadius: 24, border: 'none', cursor: 'pointer',
  background: Z_GRAD.warm, color: Z.inkOnWarm || '#0A0508', ...ZT.body(16, 700),
  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
  boxShadow: `0 14px 32px -10px ${Z.pink}, inset 0 1px 0 rgba(255,255,255,0.3)`,
};

const zCtaSecondary = {
  width: '100%', height: 48, borderRadius: 24, cursor: 'pointer',
  background: Z.cardHi, color: Z.text, border: `1px solid ${Z.strokeHi}`, ...ZT.body(16, 600),
  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
};

const zIconBtn = {
  width: 40, height: 40, borderRadius: 12, cursor: 'pointer',
  border: `1px solid ${Z.stroke}`, background: Z.card,
  display: 'grid', placeItems: 'center', padding: 0,
};

function ZField({ label, type = 'text', placeholder, value, onChange }) {
  return (
    <label style={{ display: 'block' }}>
      <span style={{ ...ZT.label(10), color: Z.textMute, display: 'block', marginBottom: 8 }}>{label}</span>
      <input
        type={type}
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        style={{
          width: '100%', height: 48, borderRadius: 14, padding: '0 16px', boxSizing: 'border-box',
          border: `1px solid ${Z.strokeHi}`, background: Z.card, color: Z.text,
          ...ZT.body(16, 500), outline: 'none',
        }}
      />
    </label>
  );
}

// ─── Sign in (returning user) ────────────────────────────────────────────
function ZSignIn({ onBack, onEmail, onGoogle, onSignUp } = {}) {
  return (
    <ZScreen>
      <HeatAura y="12%" r={200} opacity={0.45}/>
      <ZGrid/>

      <div style={{
        position: 'absolute', top: 56, left: 24, right: 24,
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <button onClick={onBack} style={zIconBtn} aria-label="Back">
          <ZIcons.chevL size={18} stroke={Z.text} sw={2}/>
        </button>
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, top: 120 }}>
        <ZMark size={56} stroke={5}/>
        <h1 style={{ ...ZT.display(32, 700), margin: '20px 0 0' }}>
          Welcome <span style={{
            background: Z_GRAD.warm, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
            backgroundClip: 'text',
          }}>back</span>
        </h1>
        <p style={{ ...ZT.body(14), color: Z.textMute, marginTop: 10 }}>
          Pick up where you left off. Your streak is still judging you.
        </p>
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, bottom: 56, display: 'flex', flexDirection: 'column', gap: 10 }}>
        <button onClick={onEmail} style={zCtaPrimary}>
          <ZIcons.mail size={18} stroke={Z.inkOnWarm || '#0A0508'} sw={2}/>
          <span>Continue with email</span>
        </button>
        <button onClick={onGoogle} style={zCtaSecondary}>
          <ZIcons.google size={18} stroke={Z.text}/>
          <span>Continue with Google</span>
        </button>
        <button onClick={onSignUp} style={{
          marginTop: 8, width: '100%', height: 28, cursor: 'pointer',
          background: 'transparent', border: 'none',
          ...ZT.body(13), color: Z.textMute, textDecoration: 'underline',
        }}>New here? Sign up</button>
        <p style={{ ...ZT.body(11), color: Z.textDim, marginTop: 6, textAlign: 'center' }}>
          By continuing you agree to our Terms &amp; Privacy.
        </p>
      </div>
    </ZScreen>
  );
}

// ─── Email auth (sign up + sign in) ──────────────────────────────────────
function ZEmailAuth({ mode = 'signup', onBack, onSubmit, onToggleMode } = {}) {
  const [email, setEmail] = React.useState('you@example.com');
  const [password, setPassword] = React.useState('');
  const [showError, setShowError] = React.useState(false);
  const isSignUp = mode === 'signup';

  return (
    <ZScreen>
      <HeatAura y="10%" r={180} opacity={0.4}/>
      <ZGrid/>

      <div style={{
        position: 'absolute', top: 56, left: 24, right: 24,
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <button onClick={onBack} style={zIconBtn} aria-label="Back">
          <ZIcons.chevL size={18} stroke={Z.text} sw={2}/>
        </button>
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, top: 112 }}>
        <h1 style={{ ...ZT.display(28, 700), margin: 0 }}>
          {isSignUp ? 'Create account' : 'Sign in'}
        </h1>
        <p style={{ ...ZT.body(14), color: Z.textMute, marginTop: 10 }}>
          {isSignUp ? 'Email in, dignity optional.' : 'Same email you used last time.'}
        </p>

        <div style={{ marginTop: 28, display: 'flex', flexDirection: 'column', gap: 16 }}>
          <ZField label="Email" type="email" placeholder="you@example.com"
            value={email} onChange={(e) => setEmail(e.target.value)}/>
          <ZField label="Password" type="password" placeholder="••••••••"
            value={password} onChange={(e) => setPassword(e.target.value)}/>
        </div>

        {showError && (
          <p style={{
            ...ZT.small(12), color: Z.orange, marginTop: 12,
            padding: '10px 12px', borderRadius: 12,
            background: `${Z.orange}14`, border: `1px solid ${Z.orange}44`,
          }}>
            Example error: that password is weaker than your last dare.
          </p>
        )}
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, bottom: 56, display: 'flex', flexDirection: 'column', gap: 10 }}>
        <button onClick={() => {
          if (!password) { setShowError(true); return; }
          onSubmit?.();
        }} style={zCtaPrimary}>
          {isSignUp ? 'Create account' : 'Sign in'}
        </button>
        <button onClick={onToggleMode} style={{
          width: '100%', height: 28, cursor: 'pointer',
          background: 'transparent', border: 'none',
          ...ZT.body(13), color: Z.textMute, textDecoration: 'underline',
        }}>
          {isSignUp ? 'Already have an account? Sign in' : 'New here? Create account'}
        </button>
      </div>
    </ZScreen>
  );
}

// ─── Challenge detail ──────────────────────────────────────────────────────
function ZChallengeDetail({ challenge, questIndex = 1, questTotal = 5, onBack, onAccept, onQuestChain } = {}) {
  const c = challenge || Z_CHALLENGES[0];
  const ptsLabel = c.pts ? `+${c.pts}pts` : 'for the lulz';

  return (
    <ZScreen>
      <div style={{
        position: 'absolute', top: -80, left: -40, right: -40, height: 280,
        background: `radial-gradient(ellipse at top, ${Z.magenta}55 0%, ${Z.pink}33 35%, transparent 70%)`,
        filter: 'blur(40px)', pointerEvents: 'none', opacity: Z.auraScale ?? 1,
      }}/>

      <div style={{
        position: 'absolute', top: 56, left: 24, right: 24,
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <button onClick={onBack} style={zIconBtn} aria-label="Back">
          <ZIcons.chevL size={18} stroke={Z.text} sw={2}/>
        </button>
        <button onClick={onQuestChain} style={{
          flex: 1, height: 32, borderRadius: 16, cursor: 'pointer',
          border: `1px solid ${Z.strokeHi}`, background: Z.card,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          ...ZT.small(11, 600), color: Z.textMute,
        }}>
          <ZIcons.clock size={12} stroke={Z.textMute} sw={2}/>
          Quest Chain · {questIndex}/{questTotal}
        </button>
        <span style={{
          padding: '6px 12px', borderRadius: 999,
          background: c.pts ? `linear-gradient(135deg, ${Z.orange}, ${Z.pink})` : Z.card,
          border: c.pts ? 'none' : `1px solid ${Z.strokeHi}`,
          color: c.pts ? '#160009' : Z.textMute,
          ...ZT.body(12, 700),
        }}>{ptsLabel}</span>
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, top: 112 }}>
        <span style={{ ...ZT.small(12, 500), color: Z.textMute }}>{c.hook}</span>
        <h1 style={{ ...ZT.display(30, 700), margin: '10px 0 0', letterSpacing: -0.5 }}>{c.text}</h1>
        <span style={{
          display: 'inline-flex', alignItems: 'center', gap: 6, marginTop: 14,
          ...ZT.mono(13, 600), color: Z.textMute,
        }}>
          <ZIcons.clock size={14} stroke={Z.textMute} sw={2}/>{c.time} to complete
        </span>
      </div>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 260, bottom: 120,
        borderRadius: 20, background: Z.card, border: `1px solid ${Z.stroke}`,
        padding: 18, overflow: 'auto',
      }}>
        <div style={{ ...ZT.label(10), color: Z.textMute, marginBottom: 10 }}>Rules</div>
        <p style={{ ...ZT.body(15, 500), color: Z.text, margin: 0, lineHeight: 1.5 }}>{c.rules}</p>
      </div>

      <div style={{
        position: 'absolute', left: 24, right: 24, bottom: 40,
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        <button onClick={onAccept} style={zCtaPrimary}>Accept dare</button>
        <button onClick={onBack} style={{
          ...zCtaSecondary, background: 'transparent', border: 'none',
          color: Z.textMute, height: 40,
        }}>Not today</button>
      </div>
    </ZScreen>
  );
}

// ─── Challenge in progress ─────────────────────────────────────────────────
function ZChallengeInProgress({ challenge, onDone, onBack } = {}) {
  const c = challenge || Z_CHALLENGES[0];
  const [seconds, setSeconds] = React.useState((c.minutes ?? 6) * 60);

  React.useEffect(() => {
    const id = setInterval(() => setSeconds(s => Math.max(0, s - 1)), 1000);
    return () => clearInterval(id);
  }, []);

  const mm = String(Math.floor(seconds / 60)).padStart(2, '0');
  const ss = String(seconds % 60).padStart(2, '0');

  return (
    <ZScreen>
      <div style={{
        position: 'absolute', top: -80, left: -40, right: -40, height: 280,
        background: `radial-gradient(ellipse at top, ${Z.magenta}55 0%, ${Z.pink}33 35%, transparent 70%)`,
        filter: 'blur(40px)', pointerEvents: 'none', opacity: Z.auraScale ?? 1,
      }}/>

      <div style={{
        position: 'absolute', top: 56, left: 24, right: 24,
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <button onClick={onBack} style={zIconBtn} aria-label="Back">
          <ZIcons.chevL size={18} stroke={Z.text} sw={2}/>
        </button>
        <span style={{ ...ZT.label(10), color: Z.textMute, flex: 1, textAlign: 'center' }}>DARE IN PROGRESS</span>
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, top: 120, textAlign: 'center' }}>
        <h1 style={{ ...ZT.display(28, 700), margin: 0 }}>{c.text}</h1>
        <div style={{
          marginTop: 28, padding: '24px 20px', borderRadius: 20,
          background: Z.card, border: `1px solid ${Z.stroke}`,
        }}>
          <div style={{ ...ZT.display(48, 800), fontVariantNumeric: 'tabular-nums' }}>{mm}:{ss}</div>
          <div style={{ ...ZT.body(14), color: Z.textMute, marginTop: 8 }}>Time remaining</div>
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 320, bottom: 120,
        borderRadius: 20, background: Z.card, border: `1px solid ${Z.stroke}`,
        padding: 18, overflow: 'auto',
      }}>
        <div style={{ ...ZT.label(10), color: Z.textMute, marginBottom: 10 }}>Rules recap</div>
        <p style={{ ...ZT.body(15, 500), color: Z.text, margin: 0, lineHeight: 1.5 }}>{c.rules}</p>
      </div>

      <div style={{
        position: 'absolute', left: 24, right: 24, bottom: 40,
      }}>
        <button onClick={onDone} style={zCtaPrimary}>I did it — submit proof</button>
      </div>
    </ZScreen>
  );
}

// ─── Submit proof ──────────────────────────────────────────────────────────
function ZSubmitProof({ challenge, onBack, onSubmit } = {}) {
  const c = challenge || Z_CHALLENGES[0];
  const [hasPhoto, setHasPhoto] = React.useState(false);
  const ptsLabel = c.pts ? `+${c.pts}pts` : 'for the lulz';

  return (
    <ZScreen>
      <div style={{
        position: 'absolute', top: -80, left: -40, right: -40, height: 280,
        background: `radial-gradient(ellipse at top, ${Z.magenta}55 0%, ${Z.pink}33 35%, transparent 70%)`,
        filter: 'blur(40px)', pointerEvents: 'none', opacity: Z.auraScale ?? 1,
      }}/>

      <div style={{
        position: 'absolute', top: 56, left: 24, right: 24,
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <button onClick={onBack} style={zIconBtn} aria-label="Back">
          <ZIcons.chevL size={18} stroke={Z.text} sw={2}/>
        </button>
        <span style={{
          padding: '6px 12px', borderRadius: 999, marginLeft: 'auto',
          background: c.pts ? `linear-gradient(135deg, ${Z.orange}, ${Z.pink})` : Z.card,
          color: c.pts ? '#160009' : Z.textMute, ...ZT.body(12, 700),
        }}>{ptsLabel}</span>
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, top: 112 }}>
        <span style={{ ...ZT.label(10), color: Z.textMute }}>SUBMIT PROOF</span>
        <h1 style={{ ...ZT.display(26, 700), margin: '8px 0 0' }}>{c.text}</h1>
        <p style={{ ...ZT.body(14), color: Z.textMute, marginTop: 10, lineHeight: 1.45 }}>
          Upload a photo showing you completed this dare. Points are awarded after your proof is approved.
        </p>
      </div>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 230,
        padding: '14px 16px', borderRadius: 16,
        background: `${Z.orange}14`, border: `1px solid ${Z.orange}44`,
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <ZIcons.star size={20} stroke={Z.orange} sw={2} fill={Z.orange}/>
        <div style={{ flex: 1 }}>
          <div style={{ ...ZT.small(11, 600), color: Z.textMute }}>Points at stake</div>
          <div style={{ ...ZT.body(16, 700), color: Z.text }}>{ptsLabel}</div>
        </div>
        <span style={{ ...ZT.small(11, 600), color: Z.textMute }}>Review ~24h</span>
      </div>

      <button onClick={() => setHasPhoto(true)} style={{
        all: 'unset', cursor: 'pointer',
        position: 'absolute', left: 24, right: 24, top: 310, height: 220,
        borderRadius: 20, background: Z.card, border: `1px solid ${Z.stroke}`,
        display: 'grid', placeItems: 'center', textAlign: 'center', padding: 20,
      }}>
        {hasPhoto ? (
          <div>
            <div style={{
              width: '100%', height: 140, borderRadius: 14,
              background: `linear-gradient(135deg, ${Z.pink}33, ${Z.orange}22)`,
              display: 'grid', placeItems: 'center', marginBottom: 12,
            }}>
              <ZIcons.check size={40} stroke={Z.success || '#22C55E'} sw={2.5}/>
            </div>
            <span style={{ ...ZT.body(14, 600), color: Z.text }}>Photo selected · tap to change</span>
          </div>
        ) : (
          <div>
            <span style={{ fontSize: 36 }}>📷</span>
            <div style={{ ...ZT.body(15, 600), color: Z.text, marginTop: 12 }}>Add photo proof</div>
            <div style={{ ...ZT.small(12), color: Z.textMute, marginTop: 4 }}>Required to earn points</div>
          </div>
        )}
      </button>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 548, bottom: 100,
        borderRadius: 20, background: Z.card, border: `1px solid ${Z.stroke}`,
        padding: 16, overflow: 'auto',
      }}>
        <div style={{ ...ZT.label(10), color: Z.textMute, marginBottom: 8 }}>What counts as proof</div>
        <p style={{ ...ZT.body(14, 500), color: Z.text, margin: 0, lineHeight: 1.5 }}>{c.rules}</p>
      </div>

      <div style={{
        position: 'absolute', left: 24, right: 24, bottom: 40,
        display: 'flex', flexDirection: 'column', gap: 10,
      }}>
        <button
          onClick={() => hasPhoto && onSubmit?.()}
          disabled={!hasPhoto}
          style={{
            ...zCtaPrimary,
            opacity: hasPhoto ? 1 : 0.45,
            cursor: hasPhoto ? 'pointer' : 'not-allowed',
          }}
        >
          Submit proof · {c.pts ? `${c.pts}pts` : 'no pts'}
        </button>
      </div>
    </ZScreen>
  );
}

// ─── Challenge complete ────────────────────────────────────────────────────
function ZChallengeComplete({
  points = 20, questDone = 2, questTotal = 5,
  onHome, onNext,
} = {}) {
  const pct = Math.round((questDone / questTotal) * 100);
  const hasPts = points != null && points > 0;

  return (
    <ZScreen>
      <HeatAura y="35%" r={240} opacity={0.55}/>
      <ZGrid opacity={0.03}/>

      <div style={{
        position: 'absolute', inset: 0,
        display: 'flex', flexDirection: 'column', alignItems: 'center',
        padding: '80px 32px 40px', textAlign: 'center',
      }}>
        <div style={{
          width: 88, height: 88, borderRadius: '50%',
          background: Z_GRAD.warm, display: 'grid', placeItems: 'center',
          boxShadow: `0 20px 48px -12px ${Z.pink}`,
        }}>
          <ZIcons.check size={40} stroke={Z.inkOnWarm || '#0A0508'} sw={3}/>
        </div>

        <h1 style={{ ...ZT.display(32, 700), margin: '28px 0 0' }}>Proof submitted</h1>
        <p style={{ ...ZT.body(15), color: Z.textMute, marginTop: 10 }}>
          We’ll review your photo and credit points once approved.
        </p>

        <div style={{
          marginTop: 32, padding: '20px 24px', borderRadius: 20, width: '100%',
          background: Z.card, border: `1px solid ${Z.stroke}`,
        }}>
          {hasPts ? (
            <div style={{
              ...ZT.display(40, 800),
              background: Z_GRAD.warm, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
              backgroundClip: 'text',
            }}>+{points}pts</div>
          ) : (
            <div style={{ ...ZT.display(28, 800), color: Z.text }}>for the lulz</div>
          )}
          <div style={{ ...ZT.body(14), color: Z.textMute, marginTop: 8 }}>
            {hasPts ? 'pending review' : 'no points — dignity still lost'}
          </div>
          {hasPts && (
            <div style={{ ...ZT.small(12), color: Z.orange, marginTop: 8 }}>
              Usually approved within 24 hours
            </div>
          )}
        </div>

        <div style={{
          marginTop: 16, padding: '16px 18px', borderRadius: 16, width: '100%',
          background: Z_GRAD.cardWarm, color: Z.inkOnWarm || '#0A0508', textAlign: 'left',
        }}>
          <div style={{ ...ZT.body(14, 700) }}>Quest Chain · {questDone}/{questTotal}</div>
          <div style={{ ...ZT.small(12, 500), opacity: 0.75, marginTop: 4 }}>refreshes in 3 hours</div>
          <div style={{ marginTop: 10, height: 6, borderRadius: 3, background: 'rgba(10,5,8,0.22)' }}>
            <div style={{ width: `${pct}%`, height: '100%', borderRadius: 3, background: '#0A0508' }}/>
          </div>
        </div>

        <div style={{ marginTop: 'auto', width: '100%', display: 'flex', flexDirection: 'column', gap: 10 }}>
          <button onClick={onNext} style={zCtaPrimary}>Next dare</button>
          <button onClick={onHome} style={{
            ...zCtaSecondary, background: 'transparent', border: 'none',
            color: Z.textMute, height: 40,
          }}>Back to Home</button>
        </div>
      </div>
    </ZScreen>
  );
}

// ─── Quest Chain expanded ──────────────────────────────────────────────────
function ZQuestChain({ questDone = 1, questTotal = 5, onBack, onSelectChallenge } = {}) {
  return (
    <ZScreen>
      <div style={{
        position: 'absolute', top: -100, left: -40, right: -40, height: 320,
        background: `radial-gradient(ellipse at top, ${Z.magenta}55 0%, ${Z.pink}33 35%, transparent 70%)`,
        filter: 'blur(40px)', pointerEvents: 'none', opacity: Z.auraScale ?? 1,
      }}/>

      <div style={{
        position: 'absolute', top: 56, left: 24, right: 24,
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <button onClick={onBack} style={zIconBtn} aria-label="Back">
          <ZIcons.chevL size={18} stroke={Z.text} sw={2}/>
        </button>
        <span style={{ ...ZT.body(16, 700), flex: 1 }}>Quest Chain</span>
        <ZIcons.clock size={18} stroke={Z.textMute} sw={2}/>
      </div>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 104, height: 96,
        borderRadius: 20, overflow: 'hidden',
        background: Z_GRAD.cardWarm, color: Z.inkOnWarm || '#0A0508', padding: '14px 16px',
        boxShadow: `0 18px 40px -16px ${Z.pink}`,
      }}>
        <div style={{ ...ZT.body(16, 700) }}>{questDone}/{questTotal} daily challenges conquered</div>
        <div style={{ ...ZT.body(13, 500), opacity: 0.75, marginTop: 8 }}>refreshes in 3 hours</div>
        <div style={{ marginTop: 10, height: 6, borderRadius: 3, background: 'rgba(10,5,8,0.22)' }}>
          <div style={{ width: `${(questDone / questTotal) * 100}%`, height: '100%', borderRadius: 3, background: '#0A0508' }}/>
        </div>
      </div>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 220, bottom: 40,
        overflow: 'hidden', display: 'flex', flexDirection: 'column', gap: 12,
      }}>
        <div style={{ ...ZT.label(10), color: Z.textMute, marginBottom: 4 }}>Today&rsquo;s dares</div>
        {Z_CHALLENGES.map((c, i) => (
          <button key={i} onClick={() => onSelectChallenge?.(i)} style={{
            all: 'unset', cursor: 'pointer', width: '100%',
          }}>
            <ChallengeCard {...c}/>
          </button>
        ))}
      </div>
    </ZScreen>
  );
}

Object.assign(window, {
  Z_CHALLENGES,
  ZSignIn, ZEmailAuth, ZChallengeDetail, ZChallengeInProgress, ZSubmitProof, ZChallengeComplete, ZQuestChain,
});
