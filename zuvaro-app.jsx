// Zuvaro — main app screens: Home (feed), Leaderboard, Profile
// Consumes window globals from zuvaro-theme.jsx + zuvaro-onboarding.jsx.

// ─── Bottom tab bar (shared across main app) ─────────────────────────────
function TabBar({ active = 'home', onChange = () => {} }) {
  const tabs = [
    { id: 'home',  icon: Icons.home,   label: 'Today' },
    { id: 'board', icon: Icons.trophy, label: 'Board' },
    { id: 'me',    icon: Icons.user,   label: 'Me'    },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0, height: 92,
      paddingBottom: 28,
      background: 'linear-gradient(180deg, transparent, rgba(8,8,10,0.92) 35%)',
      display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
    }}>
      <div style={{
        display: 'flex', gap: 4, padding: 6, borderRadius: 999,
        background: 'rgba(20,20,23,0.85)', border: `1px solid ${ZTheme.stroke}`,
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      }}>
        {tabs.map(t => {
          const on = t.id === active;
          return (
            <button key={t.id} onClick={() => onChange(t.id)} style={{
              display: 'flex', alignItems: 'center', gap: 8,
              padding: on ? '10px 16px' : '10px 14px',
              borderRadius: 999, border: 'none', cursor: 'pointer',
              background: on ? ZTheme.pink : 'transparent',
              color: on ? '#0A0508' : ZTheme.textMute,
              ...T.body(13), fontWeight: 600,
              transition: 'all .15s',
            }}>
              <t.icon size={18} stroke={on ? '#0A0508' : ZTheme.textMute}/>
              {on && <span>{t.label}</span>}
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─── Reusable header ─────────────────────────────────────────────────────
function AppHeader({ title, subtitle, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', padding: '70px 24px 16px' }}>
      <div>
        {subtitle && <div style={{ ...T.label(10), color: ZTheme.textMute, marginBottom: 6 }}>{subtitle}</div>}
        <h1 style={{ ...T.display(30), margin: 0 }}>{title}</h1>
      </div>
      {right}
    </div>
  );
}

// ─── HOME — today's session + recent log ─────────────────────────────────
function HomeScreen({ onOpenEntry, onOpenBoard } = {}) {
  const entries = [
    { d: 'Tue',  date: '07', title: 'Long run · easy', sub: '12.4 km · zone 2', dur: '58:12', tag: 'run',     accent: ZTheme.pink },
    { d: 'Mon',  date: '06', title: 'Lower body · push', sub: '6 sets · 4 lifts', dur: '47:05', tag: 'lift',    accent: ZTheme.pinkLight },
    { d: 'Sun',  date: '05', title: 'Rest + mobility',  sub: '20 min flow',      dur: '20:00', tag: 'recovery',accent: ZTheme.magenta },
    { d: 'Sat',  date: '04', title: 'Threshold intervals', sub: '6 × 800m',      dur: '42:36', tag: 'run',     accent: ZTheme.pink },
  ];

  return (
    <ScreenBG>
      {/* soft top wash */}
      <div style={{
        position: 'absolute', top: -120, left: -40, right: -40, height: 360,
        background: `radial-gradient(ellipse at top, ${ZTheme.magenta}55 0%, transparent 60%)`,
        filter: 'blur(40px)', pointerEvents: 'none',
      }}/>

      <AppHeader
        title="Today"
        subtitle="Wed · May 21"
        right={
          <div style={{ display: 'flex', gap: 8 }}>
            <button style={iconBtn}><Icons.search size={18} stroke={ZTheme.textMute}/></button>
            <button style={iconBtn}><Icons.bell size={18} stroke={ZTheme.textMute}/></button>
          </div>
        }
      />

      <div style={{ padding: '0 24px 140px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* HERO — today's planned session */}
        <div style={{
          position: 'relative', overflow: 'hidden',
          borderRadius: 28, padding: 20, minHeight: 200,
          background: `linear-gradient(140deg, ${ZTheme.magenta} 0%, ${ZTheme.pink} 55%, ${ZTheme.pinkLight} 100%)`,
          color: '#160009',
        }}>
          <div style={{
            position: 'absolute', top: -60, right: -40, width: 220, height: 220, borderRadius: '50%',
            background: 'rgba(255,255,255,0.18)', filter: 'blur(20px)',
          }}/>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', position: 'relative' }}>
            <span style={{ ...T.label(10), color: 'rgba(22,0,9,0.7)' }}>Today&rsquo;s session</span>
            <span style={{
              padding: '4px 10px', borderRadius: 999, background: 'rgba(22,0,9,0.18)',
              ...T.label(10), color: '#160009',
            }}>5:30 pm</span>
          </div>
          <h2 style={{ ...T.display(28), color: '#160009', margin: '40px 0 6px' }}>Tempo run<br/>+ core finisher</h2>
          <div style={{ ...T.body(13), color: 'rgba(22,0,9,0.7)' }}>8 km · target 4:38/km · 45 min</div>

          <div style={{
            position: 'relative', display: 'flex', alignItems: 'center', gap: 10, marginTop: 18,
          }}>
            <button style={{
              flex: 1, height: 44, borderRadius: 14, border: 'none', cursor: 'pointer',
              background: '#0A0508', color: '#fff', ...T.body(14), fontWeight: 600,
            }}>Start session →</button>
            <button style={{
              width: 44, height: 44, borderRadius: 14, border: 'none', cursor: 'pointer',
              background: 'rgba(22,0,9,0.18)', color: '#160009', display: 'grid', placeItems: 'center',
            }}><Icons.calendar size={18} stroke="#160009"/></button>
          </div>
        </div>

        {/* streak + week mini-stats */}
        <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1fr', gap: 12 }}>
          <div style={statCard}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <Icons.flame size={16} stroke={ZTheme.pink}/>
              <span style={{ ...T.label(10), color: ZTheme.textMute }}>Streak</span>
            </div>
            <div style={{ ...T.display(28), marginTop: 8, color: ZTheme.text }}>
              23<span style={{ ...T.body(13), color: ZTheme.textMute, marginLeft: 4 }}>days</span>
            </div>
            <WeekBars />
          </div>
          <div style={statCard}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <Icons.bolt size={16} stroke={ZTheme.pinkLight}/>
              <span style={{ ...T.label(10), color: ZTheme.textMute }}>This week</span>
            </div>
            <div style={{ ...T.display(28), marginTop: 8 }}>4<span style={{ ...T.body(13), color: ZTheme.textMute, marginLeft: 4 }}>/ 6</span></div>
            <div style={{ ...T.body(12), color: ZTheme.textMute, marginTop: 6 }}>sessions logged</div>
          </div>
        </div>

        {/* RECENT — section header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 8 }}>
          <span style={{ ...T.label(10), color: ZTheme.textMute }}>Recent log</span>
          <span style={{ ...T.body(12), color: ZTheme.pink, fontWeight: 600 }}>See all</span>
        </div>

        {entries.map((e, i) => (
          <button key={i} onClick={onOpenEntry} style={{
            all: 'unset', cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 14, padding: '14px 16px',
            borderRadius: 18, background: ZTheme.card, border: `1px solid ${ZTheme.stroke}`,
          }}>
            <div style={{
              width: 44, height: 56, borderRadius: 12, display: 'flex', flexDirection: 'column',
              alignItems: 'center', justifyContent: 'center', flexShrink: 0,
              background: 'rgba(255,255,255,0.04)', border: `1px solid ${ZTheme.stroke}`,
            }}>
              <span style={{ ...T.label(9), color: ZTheme.textMute }}>{e.d}</span>
              <span style={{ ...T.display(20), marginTop: 2 }}>{e.date}</span>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ ...T.body(14), fontWeight: 600 }}>{e.title}</div>
              <div style={{ ...T.body(12), color: ZTheme.textMute, marginTop: 2 }}>{e.sub}</div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4 }}>
              <span style={{ ...T.mono(13), color: ZTheme.text }}>{e.dur}</span>
              <span style={{
                ...T.label(9), padding: '2px 8px', borderRadius: 999,
                background: `${e.accent}1F`, color: e.accent,
              }}>{e.tag}</span>
            </div>
          </button>
        ))}
      </div>

      {/* FAB */}
      <button style={{
        position: 'absolute', right: 24, bottom: 110, width: 56, height: 56, borderRadius: 18,
        border: 'none', cursor: 'pointer',
        background: ZTheme.pink, color: '#0A0508',
        display: 'grid', placeItems: 'center',
        boxShadow: `0 16px 30px -10px ${ZTheme.pink}, inset 0 1px 0 rgba(255,255,255,0.3)`,
      }}>
        <Icons.plus size={26} stroke="#0A0508" sw={2.2}/>
      </button>

      <TabBar active="home" onChange={(t) => t === 'board' && onOpenBoard?.()}/>
    </ScreenBG>
  );
}

function WeekBars() {
  // 7 vertical bars, last 4 filled (today highlighted)
  const data = [1,1,1,0,1,0.6,0];
  return (
    <div style={{ display: 'flex', gap: 4, alignItems: 'flex-end', height: 28, marginTop: 12 }}>
      {data.map((v, i) => (
        <div key={i} style={{
          flex: 1, height: `${20 + v * 70}%`, borderRadius: 3,
          background: v ? (i === 5 ? ZTheme.pink : `${ZTheme.pink}AA`) : 'rgba(255,255,255,0.08)',
        }}/>
      ))}
    </div>
  );
}

const statCard = {
  borderRadius: 20, padding: 16, background: ZTheme.card, border: `1px solid ${ZTheme.stroke}`,
};

// ─── LEADERBOARD ─────────────────────────────────────────────────────────
function LeaderboardScreen({ onBack, onOpenProfile } = {}) {
  const podium = [
    { rank: 2, name: 'Mira K.',   pts: 1218, color: ZTheme.pinkLight },
    { rank: 1, name: 'Asha D.',   pts: 1342, color: ZTheme.pink },
    { rank: 3, name: 'Theo R.',   pts: 1184, color: ZTheme.magenta },
  ];
  const others = [
    { rank: 4, name: 'Jules Vance', sub: '12 sessions',  pts: 982,  delta: '+24' },
    { rank: 5, name: 'Nina Park',   sub: '11 sessions',  pts: 904,  delta: '+11' },
    { rank: 6, name: 'You',         sub: '10 sessions',  pts: 871,  delta: '+38', me: true },
    { rank: 7, name: 'Sam Holt',    sub: '9 sessions',   pts: 812,  delta: '-4'  },
    { rank: 8, name: 'Rae L.',      sub: '8 sessions',   pts: 760,  delta: '+2'  },
  ];

  return (
    <ScreenBG>
      <div style={{
        position: 'absolute', top: -80, left: '50%', transform: 'translateX(-50%)',
        width: 380, height: 280,
        background: `radial-gradient(ellipse, ${ZTheme.pink}66 0%, transparent 60%)`,
        filter: 'blur(40px)', pointerEvents: 'none',
      }}/>

      {/* header */}
      <div style={{ position: 'relative', padding: '70px 18px 12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={iconBtn}><Icons.chevL size={18} stroke={ZTheme.text}/></button>
        <div style={{ textAlign: 'center' }}>
          <div style={{ ...T.label(10), color: ZTheme.textMute }}>This week</div>
          <div style={{ ...T.title(18), marginTop: 2 }}>Leaderboard</div>
        </div>
        <button style={iconBtn}><Icons.share size={18} stroke={ZTheme.textMute}/></button>
      </div>

      {/* segmented control */}
      <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 24px 16px' }}>
        <div style={{
          display: 'flex', gap: 4, padding: 4, borderRadius: 12,
          background: ZTheme.card, border: `1px solid ${ZTheme.stroke}`,
        }}>
          {['Friends', 'Club', 'Global'].map((s, i) => (
            <button key={s} style={{
              padding: '7px 14px', borderRadius: 9, border: 'none', cursor: 'pointer',
              background: i === 0 ? ZTheme.pink : 'transparent',
              color: i === 0 ? '#0A0508' : ZTheme.textMute,
              ...T.body(12), fontWeight: 600,
            }}>{s}</button>
          ))}
        </div>
      </div>

      {/* podium */}
      <div style={{ position: 'relative', display: 'flex', justifyContent: 'center', alignItems: 'flex-end', gap: 16, padding: '8px 28px 24px' }}>
        {podium.map((p) => {
          const isFirst = p.rank === 1;
          return (
            <div key={p.rank} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10, flex: 1 }}>
              <div style={{ position: 'relative' }}>
                <Avatar name={p.name} size={isFirst ? 76 : 60} ring={p.color}/>
                {isFirst && (
                  <div style={{
                    position: 'absolute', top: -16, left: '50%', transform: 'translateX(-50%) rotate(-6deg)',
                    fontSize: 22,
                  }}>
                    <svg width="28" height="20" viewBox="0 0 28 20">
                      <path d="M2 18 L8 4 L14 14 L20 4 L26 18 Z" fill={ZTheme.pink} stroke={ZTheme.pinkLight} strokeWidth="1"/>
                    </svg>
                  </div>
                )}
              </div>
              <div style={{ textAlign: 'center' }}>
                <div style={{ ...T.body(13), fontWeight: 600 }}>{p.name}</div>
                <div style={{ ...T.mono(12), color: p.color, marginTop: 2 }}>{p.pts}<span style={{ ...T.body(10), color: ZTheme.textMute }}> pts</span></div>
              </div>
              <div style={{
                width: 52, height: isFirst ? 56 : p.rank === 2 ? 40 : 28, borderRadius: '12px 12px 0 0',
                background: isFirst
                  ? `linear-gradient(180deg, ${ZTheme.pink}, ${ZTheme.magenta})`
                  : `linear-gradient(180deg, ${p.color}AA, ${p.color}55)`,
                display: 'grid', placeItems: 'center', color: '#0A0508',
                ...T.display(20),
              }}>{p.rank}</div>
            </div>
          );
        })}
      </div>

      {/* list */}
      <div style={{ padding: '8px 18px 120px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {others.map((o) => (
          <button key={o.rank} onClick={o.me ? onOpenProfile : undefined} style={{
            all: 'unset', cursor: o.me ? 'pointer' : 'default',
            display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px',
            borderRadius: 16,
            background: o.me ? `linear-gradient(90deg, ${ZTheme.pink}22, ${ZTheme.magenta}11)` : ZTheme.card,
            border: o.me ? `1px solid ${ZTheme.pink}55` : `1px solid ${ZTheme.stroke}`,
          }}>
            <span style={{
              width: 28, ...T.mono(13),
              color: o.me ? ZTheme.pink : ZTheme.textMute, textAlign: 'center',
            }}>{o.rank}</span>
            <Avatar name={o.name} size={36} ring={o.me ? ZTheme.pink : 'transparent'}/>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ ...T.body(14), fontWeight: o.me ? 700 : 500 }}>{o.name}</div>
              <div style={{ ...T.body(11), color: ZTheme.textMute }}>{o.sub}</div>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 2 }}>
              <span style={{ ...T.mono(13) }}>{o.pts}</span>
              <span style={{
                ...T.mono(11),
                color: o.delta.startsWith('-') ? ZTheme.textMute : ZTheme.pinkLight,
              }}>{o.delta}</span>
            </div>
          </button>
        ))}
      </div>

      <TabBar active="board" onChange={(t)=>{
        if (t === 'home') onBack?.();
        if (t === 'me') onOpenProfile?.();
      }}/>
    </ScreenBG>
  );
}

// ─── PROFILE / STATS ─────────────────────────────────────────────────────
function ProfileScreen({ onBack, onHome, onBoard } = {}) {
  const stats = [
    { k: 'Sessions logged',        v: '184',        sub: '+12 vs last mo.' },
    { k: 'Total distance',         v: '627 km',     sub: 'lifetime · running' },
    { k: 'Volume lifted',          v: '42,180 kg',  sub: 'lifetime · strength' },
    { k: 'Avg. session length',    v: '47 min',     sub: 'rolling 30 days' },
    { k: 'Top streak',             v: '38 days',    sub: 'set Mar 2026' },
    { k: 'Friends training',       v: '14',         sub: '3 active today' },
  ];

  return (
    <ScreenBG>
      <div style={{
        position: 'absolute', top: -80, left: '50%', transform: 'translateX(-50%)',
        width: 360, height: 260,
        background: `radial-gradient(ellipse, ${ZTheme.pink}55 0%, transparent 65%)`,
        filter: 'blur(40px)', pointerEvents: 'none',
      }}/>

      {/* header */}
      <div style={{ position: 'relative', padding: '70px 18px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={onBack} style={iconBtn}><Icons.chevL size={18} stroke={ZTheme.text}/></button>
        <div style={{ ...T.label(10), color: ZTheme.textMute }}>Profile</div>
        <button style={iconBtn}><Icons.settings size={18} stroke={ZTheme.textMute}/></button>
      </div>

      {/* avatar block */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, padding: '16px 24px 8px' }}>
        <div style={{ position: 'relative' }}>
          <Avatar name="You" size={96} ring={ZTheme.pink} thick/>
          <div style={{
            position: 'absolute', bottom: -2, right: -2, width: 28, height: 28, borderRadius: '50%',
            background: ZTheme.pink, color: '#0A0508', display: 'grid', placeItems: 'center',
            border: `3px solid ${ZTheme.bg}`,
          }}><Icons.flame size={14} stroke="#0A0508"/></div>
        </div>
        <h1 style={{ ...T.display(26), margin: '8px 0 0' }}>Alex Moreno</h1>
        <div style={{ ...T.body(13), color: ZTheme.textMute }}>@alex.m · joined Jan 2026</div>
        <div style={{ display: 'flex', gap: 6, marginTop: 6 }}>
          <Pill>23 day streak</Pill>
          <Pill tint={ZTheme.pinkLight}>rank #6</Pill>
        </div>
      </div>

      {/* statistics section */}
      <div style={{ padding: '20px 24px 140px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
          <span style={{ ...T.label(10), color: ZTheme.textMute }}>Statistics</span>
          <span style={{ ...T.body(12), color: ZTheme.pink, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 4 }}>
            All time <Icons.chevD size={12} stroke={ZTheme.pink}/>
          </span>
        </div>
        <div style={{
          borderRadius: 20, background: ZTheme.card, border: `1px solid ${ZTheme.stroke}`,
          overflow: 'hidden',
        }}>
          {stats.map((s, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '14px 16px',
              borderBottom: i === stats.length - 1 ? 'none' : `1px solid ${ZTheme.stroke}`,
            }}>
              <div style={{ minWidth: 0 }}>
                <div style={{ ...T.body(13), color: ZTheme.text }}>{s.k}</div>
                <div style={{ ...T.body(11), color: ZTheme.textDim, marginTop: 2 }}>{s.sub}</div>
              </div>
              <div style={{ ...T.mono(15), color: ZTheme.text }}>{s.v}</div>
            </div>
          ))}
        </div>

        {/* logout */}
        <button style={{
          marginTop: 14, width: '100%', height: 50, borderRadius: 16, cursor: 'pointer',
          background: 'rgba(200,30,91,0.12)', border: `1px solid ${ZTheme.magenta}55`,
          color: ZTheme.pinkLight, ...T.body(14), fontWeight: 600,
        }}>Log out</button>
      </div>

      <TabBar active="me" onChange={(t)=>{
        if (t === 'home')  onHome?.();
        if (t === 'board') onBoard?.();
      }}/>
    </ScreenBG>
  );
}

// ─── Small primitives ────────────────────────────────────────────────────
function Pill({ children, tint = ZTheme.pink }) {
  return (
    <span style={{
      ...T.label(9), padding: '4px 10px', borderRadius: 999,
      background: `${tint}1A`, color: tint, border: `1px solid ${tint}44`,
    }}>{children}</span>
  );
}

function Avatar({ name = '', size = 40, ring = 'transparent', thick = false }) {
  // monogram from initials; deterministic hue from name
  const initials = name.split(/\s+/).filter(Boolean).slice(0, 2).map(s => s[0]).join('').toUpperCase() || '·';
  let h = 0;
  for (const c of name) h = (h * 31 + c.charCodeAt(0)) % 360;
  const isMe = name === 'You' || name === 'Alex Moreno';
  const bg = isMe
    ? `linear-gradient(135deg, ${ZTheme.pink}, ${ZTheme.magenta})`
    : `linear-gradient(135deg, hsl(${h}, 30%, 22%), hsl(${(h+40)%360}, 30%, 14%))`;
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: bg, color: ZTheme.text,
      display: 'grid', placeItems: 'center',
      fontFamily: ZTheme.display, fontWeight: 600, fontSize: size * 0.36,
      letterSpacing: -0.02 * size,
      boxShadow: ring !== 'transparent'
        ? `0 0 0 ${thick ? 3 : 2}px ${ZTheme.bg}, 0 0 0 ${thick ? 5 : 3}px ${ring}` : 'none',
      flexShrink: 0,
    }}>{initials}</div>
  );
}

Object.assign(window, {
  TabBar, AppHeader,
  HomeScreen, LeaderboardScreen, ProfileScreen,
  Pill, Avatar, WeekBars,
});
