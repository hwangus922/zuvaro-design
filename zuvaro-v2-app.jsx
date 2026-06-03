// Zuvaro v2 — main app screens: Home (challenges), Leaderboard, Profile
// Faithful to the figma copy: "Oh hell naw...", "Let yo bih go thru yo phone",
// "Text your ex", "@IloveMyGTA6too", etc.

// ─── Bottom tab bar ──────────────────────────────────────────────────────
function ZTabBar({ active = 'home', onChange = () => {} }) {
  const tabs = [
    { id: 'home',  icon: ZIcons.home,   label: 'Home' },
    { id: 'board', icon: ZIcons.trophy, label: 'Board' },
    { id: 'me',    icon: ZIcons.user,   label: 'Me' },
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0, height: 92,
      paddingBottom: 28,
      background: `linear-gradient(180deg, transparent 0%, ${Z.bg} 60%)`,
      display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
    }}>
      {/* Tab pill is intentionally dark in BOTH modes — high-contrast nav */}
      <div style={{
        display: 'flex', gap: 4, padding: 6, borderRadius: 999,
        background: 'rgba(15,15,20,0.92)', border: '1px solid rgba(255,255,255,0.12)',
        backdropFilter: 'blur(20px)', WebkitBackdropFilter: 'blur(20px)',
      }}>
        {tabs.map(t => {
          const on = t.id === active;
          const inactive = 'rgba(255,255,255,0.6)';
          return (
            <button key={t.id} onClick={() => onChange(t.id)} style={{
              display: 'flex', alignItems: 'center', gap: 8,
              padding: on ? '10px 18px' : '10px 14px',
              borderRadius: 999, border: 'none', cursor: 'pointer',
              background: on ? Z_GRAD.warm : 'transparent',
              color: on ? Z.inkOnWarm : inactive,
              ...ZT.body(13, 700),
              transition: 'all .15s',
            }}>
              <t.icon size={18} stroke={on ? Z.inkOnWarm : inactive} sw={2}/>
              {on && <span>{t.label}</span>}
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ─── HOME — Quest Chain + filters + 5 challenge cards ────────────────────
function ZHome({ onOpenBoard, onOpenMe, onOpenChallenge, onOpenQuestChain } = {}) {
  const challenges = window.Z_CHALLENGES || [
    { time: '6 min', text: 'Let yo bih go thru yo phone', pts: 20, hook: 'Oh hell naw jigsaw u tweaking bruh' },
    { time: '9 min', text: 'Text your ex',                  pts: 10, hook: 'Yes.' },
    { time: '2 hrs', text: 'Run 10 km',                     pts: 50, hook: 'Burn some calories' },
    { time: '5 hrs', text: 'Larp having money',             pts: 60, hook: 'Larp larp larp sahur' },
    { time: '1 min', text: 'Make a dumb joke',              pts: null, hook: 'Pure embarrassment' },
  ];

  return (
    <ZScreen>
      {/* top heat wash */}
      <div style={{
        position: 'absolute', top: -100, left: -40, right: -40, height: 320,
        background: `radial-gradient(ellipse at top, ${Z.magenta}55 0%, ${Z.pink}33 35%, transparent 70%)`,
        filter: 'blur(40px)', pointerEvents: 'none', opacity: Z.auraScale ?? 1,
      }}/>

      {/* status bar area is owned by IOSDevice */}

      {/* header — avatar / trending / thunder / pts */}
      <div style={{ position: 'absolute', left: 24, top: 48, right: 24, display: 'flex', alignItems: 'center', gap: 12 }}>
        <Avatar size={40} ring={Z.pink}/>
        <div style={{ flex: 1 }}/>
        <button style={iconChip}><ZIcons.trending size={18} stroke={Z.text} sw={2}/></button>
        <span style={{ ...ZT.mono(15, 700), color: Z.text }}>45</span>
        <button style={iconChip}><ZIcons.bolt size={18} stroke={Z.orange} sw={2} fill={Z.orange}/></button>
        <span style={{
          ...ZT.mono(15, 700),
          background: Z_GRAD.warm, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
          backgroundClip: 'text',
        }}>70pts</span>
      </div>

      {/* Quest Chain card */}
      <button onClick={onOpenQuestChain} style={{
        all: 'unset', cursor: onOpenQuestChain ? 'pointer' : 'default',
        position: 'absolute', left: 24, top: 104, right: 24, height: 96,
        borderRadius: 20, overflow: 'hidden',
        background: Z_GRAD.cardWarm,
        color: '#0A0508', padding: '14px 16px', boxSizing: 'border-box',
        boxShadow: `0 18px 40px -16px ${Z.pink}`,
      }}>
        {/* sheen */}
        <div style={{
          position: 'absolute', top: -40, right: -30, width: 160, height: 160, borderRadius: '50%',
          background: 'rgba(255,255,255,0.22)', filter: 'blur(20px)',
        }}/>
        <div style={{ position: 'relative', display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ ...ZT.body(16, 700), color: '#0A0508' }}>1/5 daily challenges conquered</span>
          <div style={{ flex: 1 }}/>
          <ZIcons.clock size={16} stroke="#0A0508" sw={2.2}/>
        </div>
        <div style={{ position: 'relative', display: 'flex', alignItems: 'center', gap: 8, marginTop: 12 }}>
          <span style={{
            ...ZT.body(16, 700), color: '#0A0508',
            textShadow: '0 1px 0 rgba(255,255,255,0.18)',
          }}>Quest Chain</span>
          <span style={{ ...ZT.body(13, 500), color: 'rgba(10,5,8,0.7)' }}>refreshes in 3 hours</span>
        </div>
        {/* progress bar */}
        <div style={{ position: 'relative', marginTop: 10, height: 6, borderRadius: 3, background: 'rgba(10,5,8,0.22)' }}>
          <div style={{ width: '20%', height: '100%', borderRadius: 3, background: '#0A0508' }}/>
        </div>
      </button>

      {/* Filter chips */}
      <div style={{
        position: 'absolute', left: 24, top: 232, right: 24, display: 'flex', gap: 8, alignItems: 'center',
      }}>
        <FilterChip>All</FilterChip>
        <FilterChip active>Recommended</FilterChip>
        <FilterChip>Rewarding</FilterChip>
        <FilterChip>Short</FilterChip>
        <button style={{
          marginLeft: 'auto', width: 24, height: 24, borderRadius: 12, cursor: 'pointer',
          border: `1px solid ${Z.strokeHi}`, background: Z.card, display: 'grid', placeItems: 'center',
        }}>
          <ZIcons.search size={12} stroke={Z.textMute} sw={2}/>
        </button>
      </div>

      {/* Challenge list */}
      <div style={{
        position: 'absolute', left: 24, top: 280, right: 24, bottom: 100,
        overflow: 'hidden', display: 'flex', flexDirection: 'column', gap: 12,
      }}>
        {challenges.map((c, i) => (
          <button key={i} onClick={() => onOpenChallenge?.(i)} style={{
            all: 'unset', cursor: onOpenChallenge ? 'pointer' : 'default', width: '100%',
          }}>
            <ChallengeCard {...c}/>
          </button>
        ))}
      </div>

      <ZTabBar active="home" onChange={(t) => {
        if (t === 'board') onOpenBoard?.();
        if (t === 'me')    onOpenMe?.();
      }}/>
    </ZScreen>
  );
}

const iconChip = {
  width: 32, height: 32, borderRadius: 12, cursor: 'pointer',
  border: `1px solid ${Z.stroke}`, background: Z.card,
  display: 'grid', placeItems: 'center', padding: 0,
};

function FilterChip({ children, active = false }) {
  return (
    <button style={{
      height: 26, padding: active ? '0 14px' : '0 12px', borderRadius: 13, cursor: 'pointer',
      border: `1px solid ${active ? 'transparent' : Z.strokeHi}`,
      background: active ? Z_GRAD.warm : 'transparent',
      color: active ? '#0A0508' : Z.textMute,
      ...ZT.small(12, active ? 700 : 500),
      whiteSpace: 'nowrap',
    }}>{children}</button>
  );
}

function ChallengeCard({ hook, text, time, pts, onClick }) {
  // Each card has a pink underline-accent strip on the left for visual rhythm
  const inner = (
    <div style={{
      position: 'relative', height: 88, borderRadius: 20,
      background: Z.card, border: `1px solid ${Z.stroke}`,
      padding: '12px 16px', overflow: 'hidden',
    }}>
      {/* left accent bar */}
      <div style={{
        position: 'absolute', left: 0, top: 14, bottom: 14, width: 3, borderRadius: 0,
        background: pts ? Z_GRAD.warm : Z.strokeHi,
      }}/>

      {/* hook line + timer */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span style={{ ...ZT.small(12, 500), color: Z.textMute, flex: 1, minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {hook}
        </span>
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, ...ZT.mono(12, 500), color: Z.textMute }}>
          <ZIcons.clock size={12} stroke={Z.textMute} sw={2}/>{time}
        </span>
      </div>

      {/* main dare */}
      <div style={{ ...ZT.body(16, 700), color: Z.text, marginTop: 8, letterSpacing: -0.2 }}>
        {text}
      </div>

      {/* pts chip — orange! */}
      <div style={{ position: 'absolute', right: 14, bottom: 12 }}>
        {pts ? (
          <span style={{
            padding: '4px 10px', borderRadius: 999,
            background: `linear-gradient(135deg, ${Z.orange}, ${Z.pink})`,
            color: '#160009', ...ZT.body(12, 700),
            boxShadow: `0 4px 12px -4px ${Z.orange}`,
          }}>+{pts}pts</span>
        ) : (
          <span style={{
            padding: '4px 10px', borderRadius: 999,
            background: 'rgba(255,255,255,0.04)', border: `1px solid ${Z.strokeHi}`,
            color: Z.textMute, ...ZT.small(11, 600),
          }}>for the lulz</span>
        )}
      </div>
    </div>
  );
  if (onClick) {
    return (
      <button onClick={onClick} style={{ all: 'unset', cursor: 'pointer', width: '100%' }}>{inner}</button>
    );
  }
  return inner;
}

// ─── Avatar ──────────────────────────────────────────────────────────────
function Avatar({ size = 40, ring = 'transparent', emoji = '🦊', initials, glow = false }) {
  const content = initials
    ? <span style={{ ...ZT.body(size * 0.36, 700), color: Z.text }}>{initials}</span>
    : <span style={{ fontSize: size * 0.5 }}>{emoji}</span>;
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: `linear-gradient(135deg, ${Z.magenta}, ${Z.pink})`,
      display: 'grid', placeItems: 'center',
      boxShadow: ring !== 'transparent'
        ? `0 0 0 2px ${Z.bg}, 0 0 0 3px ${ring}${glow ? `, 0 0 24px -2px ${ring}` : ''}` : 'none',
      flexShrink: 0, position: 'relative',
    }}>{content}</div>
  );
}

// ─── LEADERBOARD ─────────────────────────────────────────────────────────
function ZLeaderboard({ onBack, onMe } = {}) {
  // exact figma copy
  const rows = [
    { rank: 1, name: 'John Winner',    handle: '@IloveMyGTA6too',    pts: 981, emoji: '👑' },
    { rank: 2, name: 'John Second',    handle: '@IloveMyGTA6137',    pts: 972, emoji: '🦊' },
    { rank: 3, name: 'John Third',     handle: '@IhateMyElCinco2',   pts: 970, emoji: '🐺' },
    { rank: 4, name: 'John Fourth',    handle: '@IloveMyElCinco5',   pts: 890, emoji: '🐸' },
    { rank: 5, name: 'John Fifth',     handle: '@IhateMyAirfrier6',  pts: 690, emoji: '🦝' },
    { rank: 67, name: 'John Airfrier', handle: '@IloveMyAirfrier48', pts: 70,  emoji: '🍳', me: true },
  ];

  return (
    <ZScreen>
      {/* aura */}
      <div style={{
        position: 'absolute', top: -90, left: '50%', transform: 'translateX(-50%)',
        width: 420, height: 280,
        background: `radial-gradient(ellipse, ${Z.orange}55 0%, ${Z.pink}33 40%, transparent 70%)`,
        filter: 'blur(40px)', pointerEvents: 'none', opacity: Z.auraScale ?? 1,
      }}/>

      {/* header */}
      <div style={{ position: 'absolute', left: 24, top: 56, right: 24, display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={onBack} style={iconChip} aria-label="Back">
          <ZIcons.chevL size={16} stroke={Z.text} sw={2}/>
        </button>
        <div style={{ flex: 1 }}/>
        <span style={{ ...ZT.label(10), color: Z.textMute }}>6 days left</span>
      </div>

      {/* title + tabs */}
      <div style={{ position: 'absolute', left: 24, top: 104, right: 24 }}>
        <h1 style={{
          ...ZT.display(34, 700), margin: 0,
        }}>
          Leader<span style={{
            background: Z_GRAD.warm, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
            backgroundClip: 'text',
          }}>board</span>
        </h1>
        <div style={{ display: 'flex', gap: 18, marginTop: 14 }}>
          {['Friends', 'Club', 'Global'].map((t, i) => (
            <span key={t} style={{
              ...ZT.body(15, i === 0 ? 700 : 500),
              color: i === 0 ? Z.text : Z.textMute,
              position: 'relative', paddingBottom: 6,
              borderBottom: i === 0 ? `2px solid ${Z.pink}` : '2px solid transparent',
            }}>{t}</span>
          ))}
        </div>
      </div>

      {/* Rank pages (1 / 2 / 3 page tabs — small pills) */}
      <div style={{ position: 'absolute', left: 24, top: 202, right: 24, display: 'flex', gap: 6 }}>
        {['1', '2', '3'].map((p, i) => (
          <span key={p} style={{
            width: 28, height: 22, borderRadius: 11, display: 'grid', placeItems: 'center',
            background: i === 0 ? Z.cardHi : 'transparent',
            border: `1px solid ${i === 0 ? Z.strokeHi : Z.stroke}`,
            color: i === 0 ? Z.text : Z.textDim,
            ...ZT.mono(11, 700),
          }}>{p}</span>
        ))}
      </div>

      {/* List */}
      <div style={{
        position: 'absolute', left: 0, right: 0, top: 244, bottom: 100,
        overflow: 'hidden',
      }}>
        {rows.map((r, i) => (
          <LbRow key={r.rank} {...r}
            sep={i === 4}  // visual break before the "you" row
            onClick={r.me ? onMe : undefined}/>
        ))}
      </div>

      <ZTabBar active="board" onChange={(t) => {
        if (t === 'home') onBack?.();
        if (t === 'me') onMe?.();
      }}/>
    </ZScreen>
  );
}

function LbRow({ rank, name, handle, pts, emoji, me, sep, onClick }) {
  const isTop3 = rank <= 3;
  const rankColor = rank === 1 ? Z.orange : rank === 2 ? Z.pinkLight : rank === 3 ? Z.pink : Z.textMute;
  return (
    <>
      {sep && (
        <div style={{
          height: 28, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          ...ZT.label(9), color: Z.textDim,
        }}>
          <span style={{ height: 1, flex: 1, background: Z.stroke, maxWidth: 80 }}/>
          <span>· · ·</span>
          <span style={{ height: 1, flex: 1, background: Z.stroke, maxWidth: 80 }}/>
        </div>
      )}
      <button onClick={onClick} style={{
        all: 'unset', cursor: onClick ? 'pointer' : 'default',
        width: '100%', height: 80, padding: '0 16px',
        display: 'flex', alignItems: 'center', gap: 12,
        borderTop: `1px solid ${Z.stroke}`,
        background: me ? `linear-gradient(90deg, ${Z.orange}22, ${Z.pink}11)` : 'transparent',
        position: 'relative',
        boxSizing: 'border-box',
      }}>
        {/* rank number */}
        <span style={{
          width: 28, textAlign: 'center', ...ZT.mono(rank > 9 ? 14 : 18, 700), color: rankColor,
        }}>{rank}</span>

        {/* avatar */}
        <div style={{ position: 'relative' }}>
          <Avatar size={48} emoji={emoji} ring={isTop3 ? rankColor : 'transparent'}/>
          {rank === 1 && (
            <div style={{
              position: 'absolute', top: -10, left: '50%', transform: 'translateX(-50%)',
              fontSize: 16,
            }}>👑</div>
          )}
        </div>

        {/* name + handle */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ ...ZT.body(16, me ? 700 : 500), color: Z.text }}>{name}</div>
          <div style={{ ...ZT.small(12), color: Z.textMute, marginTop: -2 }}>{handle}</div>
        </div>

        {/* pts */}
        <span style={{
          ...ZT.mono(16, 700),
          color: rank === 1 ? Z.orange : Z.text,
        }}>{pts}pts</span>
      </button>
    </>
  );
}

// ─── PROFILE ─────────────────────────────────────────────────────────────
function ZProfile({ onBack, onHome, onBoard } = {}) {
  const stats = [
    { k: 'Wins',                 v: '47'  },
    { k: 'Longest Streak',       v: '23'  },
    { k: 'Total Points',         v: '70'  },
    { k: 'Challenges Completed', v: '184' },
  ];

  return (
    <ZScreen>
      <div style={{
        position: 'absolute', top: -100, left: '50%', transform: 'translateX(-50%)',
        width: 360, height: 280,
        background: `radial-gradient(ellipse, ${Z.pink}55 0%, ${Z.orange}33 40%, transparent 70%)`,
        filter: 'blur(40px)', pointerEvents: 'none', opacity: Z.auraScale ?? 1,
      }}/>

      {/* avatar + edit pip */}
      <div style={{ position: 'absolute', left: 0, right: 0, top: 64, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
        <div style={{ position: 'relative' }}>
          <Avatar size={80} emoji="👑" ring={Z.orange} glow/>
          <div style={{
            position: 'absolute', bottom: -2, right: -6, width: 32, height: 32, borderRadius: '50%',
            background: Z.bg, display: 'grid', placeItems: 'center',
            border: `2px solid ${Z.pink}`, cursor: 'pointer',
          }}>
            <ZIcons.edit size={14} stroke={Z.pink} sw={2}/>
          </div>
        </div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ ...ZT.body(16, 600), color: Z.text }}>John Winner</div>
          <div style={{ ...ZT.small(12), color: Z.textMute, marginTop: -2 }}>@IloveMyGTA6too</div>
        </div>

        {/* hot streak badge */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 6, marginTop: 4,
          padding: '5px 10px', borderRadius: 999,
          background: `linear-gradient(135deg, ${Z.orange}33, ${Z.pink}22)`,
          border: `1px solid ${Z.orange}66`,
        }}>
          <ZIcons.flame size={12} stroke={Z.orange} sw={2.2}/>
          <span style={{ ...ZT.small(11, 700), color: Z.orange, letterSpacing: 0.1 }}>23 day streak · on fire</span>
        </div>
      </div>

      {/* Statistics section header */}
      <span style={{
        position: 'absolute', left: 35, top: 218,
        ...ZT.body(16, 700), color: Z.text,
      }}>Statistics</span>
      <span style={{
        position: 'absolute', right: 35, top: 218,
        ...ZT.small(12, 600), color: Z.pink, display: 'flex', alignItems: 'center', gap: 4,
      }}>All time <ZIcons.chevD size={12} stroke={Z.pink} sw={2}/></span>

      {/* Statistics card */}
      <div style={{
        position: 'absolute', left: 24, top: 248, right: 24,
        borderRadius: 20, background: Z.card, border: `1px solid ${Z.stroke}`,
        overflow: 'hidden',
      }}>
        {/* hero stat — total points, big number */}
        <div style={{
          padding: '18px 18px 16px', display: 'flex', alignItems: 'flex-end', gap: 12,
          background: `linear-gradient(180deg, ${Z.orange}1A 0%, transparent 100%)`,
        }}>
          <div>
            <div style={{ ...ZT.label(9), color: Z.textMute }}>Total points</div>
            <div style={{
              ...ZT.display(44, 800), marginTop: 4, letterSpacing: -1,
              background: Z_GRAD.warm, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
              backgroundClip: 'text',
            }}>70<span style={{ ...ZT.display(18, 700), color: Z.textMute, marginLeft: 4, WebkitTextFillColor: Z.textMute }}>pts</span></div>
          </div>
          <div style={{ flex: 1 }}/>
          <span style={{
            ...ZT.small(11, 700), color: Z.orange, letterSpacing: 0.1,
            padding: '4px 10px', borderRadius: 999, background: `${Z.orange}1F`,
          }}>+38 this wk</span>
        </div>

        {stats.map((s, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            padding: '16px 18px',
            borderTop: `1px solid ${Z.stroke}`,
          }}>
            <span style={{ ...ZT.body(16, 500), color: Z.text }}>{s.k}</span>
            <span style={{ ...ZT.mono(16, 700), color: Z.text }}>{s.v}</span>
          </div>
        ))}
      </div>

      {/* Account actions */}
      <div style={{
        position: 'absolute', left: 24, top: 640, right: 24, height: 96,
        borderRadius: 20, background: Z.card, border: `1px solid ${Z.stroke}`,
        overflow: 'hidden',
      }}>
        <button style={accountBtn}>
          <span style={{ ...ZT.body(16, 500) }}>Log out</span>
          <ZIcons.chevR size={16} stroke={Z.textMute} sw={2}/>
        </button>
        <div style={{ height: 1, background: Z.stroke }}/>
        <button style={{ ...accountBtn, color: Z.orange }}>
          <span style={{ ...ZT.body(16, 500), color: Z.orange }}>Delete Account</span>
          <ZIcons.chevR size={16} stroke={Z.orange} sw={2}/>
        </button>
      </div>

      <ZTabBar active="me" onChange={(t) => {
        if (t === 'home') onHome?.();
        if (t === 'board') onBoard?.();
      }}/>
    </ZScreen>
  );
}

const accountBtn = {
  all: 'unset', cursor: 'pointer', width: '100%', height: 47, padding: '0 16px', boxSizing: 'border-box',
  display: 'flex', alignItems: 'center', justifyContent: 'space-between', color: Z.text,
};

Object.assign(window, {
  ZTabBar, Avatar, FilterChip, ChallengeCard, LbRow,
  ZHome, ZLeaderboard, ZProfile,
});
