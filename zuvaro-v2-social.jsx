// Zuvaro v2 — social, community, and settings sub-screens

function ZSubHeader({ title, onBack, right }) {
  return (
    <div style={{
      position: 'absolute', top: 56, left: 24, right: 24,
      display: 'flex', alignItems: 'center', gap: 12,
    }}>
      <button onClick={onBack} style={zIconBtn} aria-label="Back">
        <ZIcons.chevL size={18} stroke={Z.text} sw={2}/>
      </button>
      <span style={{ ...ZT.body(16, 700), flex: 1 }}>{title}</span>
      {right}
    </div>
  );
}

const Z_CHAT_MESSAGES = [
  { who: 'Maya', emoji: '🦊', text: 'who\'s doing the phone dare tonight??', time: '2:14 PM' },
  { dare: true, who: 'Alex', emoji: '🐺', text: 'Let yo bih go thru yo phone', pts: 20, time: '2:18 PM' },
  { who: 'You', emoji: '👑', text: 'already submitted proof lol', time: '2:22 PM', me: true },
  { who: 'Jordan', emoji: '🦝', text: 'LMAO the rejection on mine was brutal', time: '2:31 PM' },
  { dare: true, who: 'Alex', emoji: '🐺', text: 'Text your ex', pts: 10, time: '2:45 PM' },
];

// ─── Group chat ────────────────────────────────────────────────────────────
function ZGroupChat({ onBack, onCreateDare, onOpenDare } = {}) {
  const [draft, setDraft] = React.useState('');

  return (
    <ZScreen>
      <div style={{
        position: 'absolute', top: -80, left: -40, right: -40, height: 240,
        background: `radial-gradient(ellipse at top, ${Z.magenta}44 0%, transparent 70%)`,
        filter: 'blur(40px)', pointerEvents: 'none', opacity: Z.auraScale ?? 1,
      }}/>

      <ZSubHeader title="Chaos Crew" onBack={onBack} right={
        <span style={{ ...ZT.small(11, 600), color: Z.textMute }}>6 online</span>
      }/>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 112, bottom: 100,
        overflow: 'auto', display: 'flex', flexDirection: 'column', gap: 14,
      }}>
        {Z_CHAT_MESSAGES.map((m, i) => (
          <div key={i} style={{
            display: 'flex', flexDirection: m.me ? 'row-reverse' : 'row',
            gap: 10, alignItems: 'flex-end',
          }}>
            {!m.me && (
              <div style={{
                width: 32, height: 32, borderRadius: '50%', flexShrink: 0,
                background: Z.card, border: `1px solid ${Z.strokeHi}`,
                display: 'grid', placeItems: 'center', fontSize: 16,
              }}>{m.emoji}</div>
            )}
            <div style={{ maxWidth: '78%' }}>
              {!m.me && (
                <div style={{ ...ZT.small(11, 600), color: Z.textMute, marginBottom: 4, marginLeft: 4 }}>
                  {m.who} · {m.time}
                </div>
              )}
              {m.dare ? (
                <button onClick={() => onOpenDare?.(0)} style={{
                  all: 'unset', cursor: 'pointer', display: 'block', width: '100%',
                  borderRadius: 16, padding: 14, textAlign: 'left',
                  background: Z_GRAD.cardWarm, color: Z.inkOnWarm || '#0A0508',
                  boxShadow: `0 8px 24px -8px ${Z.pink}`,
                }}>
                  <div style={{ ...ZT.label(9), opacity: 0.7 }}>NEW DARE</div>
                  <div style={{ ...ZT.body(15, 700), marginTop: 4 }}>{m.text}</div>
                  <div style={{ ...ZT.mono(13, 700), marginTop: 8 }}>+{m.pts}pts · tap to accept</div>
                </button>
              ) : (
                <div style={{
                  borderRadius: 16, padding: '10px 14px',
                  background: m.me ? Z_GRAD.warm : Z.card,
                  color: m.me ? (Z.inkOnWarm || '#0A0508') : Z.text,
                  border: m.me ? 'none' : `1px solid ${Z.stroke}`,
                  ...ZT.body(14, 500),
                }}>{m.text}</div>
              )}
            </div>
          </div>
        ))}
      </div>

      <div style={{
        position: 'absolute', left: 16, right: 16, bottom: 36,
        display: 'flex', gap: 8, alignItems: 'center',
      }}>
        <button onClick={onCreateDare} style={{
          width: 44, height: 44, borderRadius: 22, border: 'none', cursor: 'pointer',
          background: Z_GRAD.warm, display: 'grid', placeItems: 'center', flexShrink: 0,
        }} aria-label="Create dare">
          <ZIcons.plus size={20} stroke={Z.inkOnWarm || '#0A0508'} sw={2.5}/>
        </button>
        <div style={{
          flex: 1, display: 'flex', alignItems: 'center', height: 44, borderRadius: 22,
          padding: '0 16px', background: Z.card, border: `1px solid ${Z.strokeHi}`,
        }}>
          <input
            value={draft}
            onChange={(e) => setDraft(e.target.value)}
            placeholder="Send a message…"
            style={{
              flex: 1, border: 'none', outline: 'none', background: 'transparent',
              color: Z.text, ...ZT.body(15, 500),
            }}
          />
        </div>
      </div>
    </ZScreen>
  );
}

// ─── Create dare ───────────────────────────────────────────────────────────
function ZCreateDare({ onBack, onSubmit } = {}) {
  const [text, setText] = React.useState('');
  const [pts, setPts] = React.useState('20');
  const [rules, setRules] = React.useState('');

  const canSubmit = text.trim().length > 3;

  return (
    <ZScreen>
      <ZSubHeader title="Create dare" onBack={onBack}/>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 120, bottom: 100,
        overflow: 'auto', display: 'flex', flexDirection: 'column', gap: 16,
      }}>
        <p style={{ ...ZT.body(14), color: Z.textMute, margin: 0, lineHeight: 1.45 }}>
          Drop a dare into the group chat. Friends can accept it and earn points for proof.
        </p>

        <label style={{ display: 'block' }}>
          <span style={{ ...ZT.label(10), color: Z.textMute, display: 'block', marginBottom: 8 }}>Dare</span>
          <input
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="e.g. FaceTime your mom and say something unhinged"
            style={{
              width: '100%', height: 48, borderRadius: 14, padding: '0 14px', boxSizing: 'border-box',
              border: `1px solid ${Z.strokeHi}`, background: Z.card, color: Z.text,
              ...ZT.body(15, 500), outline: 'none',
            }}
          />
        </label>

        <label style={{ display: 'block' }}>
          <span style={{ ...ZT.label(10), color: Z.textMute, display: 'block', marginBottom: 8 }}>Points reward</span>
          <div style={{ display: 'flex', gap: 8 }}>
            {['10', '20', '50', '0'].map((p) => (
              <button key={p} onClick={() => setPts(p)} style={{
                flex: 1, height: 40, borderRadius: 12, cursor: 'pointer', border: 'none',
                background: pts === p ? Z_GRAD.warm : Z.cardHi,
                color: pts === p ? (Z.inkOnWarm || '#0A0508') : Z.text,
                ...ZT.body(14, 600),
              }}>{p === '0' ? 'No pts' : `+${p}`}</button>
            ))}
          </div>
        </label>

        <label style={{ display: 'block' }}>
          <span style={{ ...ZT.label(10), color: Z.textMute, display: 'block', marginBottom: 8 }}>Proof rules</span>
          <textarea
            value={rules}
            onChange={(e) => setRules(e.target.value)}
            placeholder="What counts as valid proof?"
            rows={3}
            style={{
              width: '100%', borderRadius: 14, padding: 14, boxSizing: 'border-box', resize: 'none',
              border: `1px solid ${Z.strokeHi}`, background: Z.card, color: Z.text,
              ...ZT.body(14, 500), outline: 'none', fontFamily: 'inherit',
            }}
          />
        </label>
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, bottom: 40 }}>
        <button
          onClick={() => canSubmit && onSubmit?.()}
          disabled={!canSubmit}
          style={{
            ...zCtaPrimary, width: '100%',
            opacity: canSubmit ? 1 : 0.45,
            cursor: canSubmit ? 'pointer' : 'not-allowed',
          }}
        >Post to group chat</button>
      </div>
    </ZScreen>
  );
}

// ─── Notifications ─────────────────────────────────────────────────────────
const Z_NOTIFS = [
  { type: 'proof', title: 'Proof approved', body: '+20pts for "Let yo bih go thru yo phone"', time: '2m ago', unread: true },
  { type: 'dare', title: 'New dare in Chaos Crew', body: 'Alex posted "Text your ex" · +10pts', time: '18m ago', unread: true },
  { type: 'board', title: 'You dropped a rank', body: 'Jordan passed you on the Friends board', time: '1h ago', unread: true },
  { type: 'friend', title: 'Maya joined Zuvaro', body: 'Invite accepted — say hi in the group chat', time: 'Yesterday', unread: false },
  { type: 'proof', title: 'Proof under review', body: 'Your submission for "Run 10 km" is pending', time: 'Yesterday', unread: false },
];

function ZNotifications({ onBack, onOpenChat, onOpenSubmissions } = {}) {
  return (
    <ZScreen>
      <ZSubHeader title="Notifications" onBack={onBack}/>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 112, bottom: 40,
        overflow: 'auto', display: 'flex', flexDirection: 'column', gap: 8,
      }}>
        {Z_NOTIFS.map((n, i) => (
          <button key={i} onClick={() => {
            if (n.type === 'dare') onOpenChat?.();
            else if (n.type === 'proof') onOpenSubmissions?.();
          }} style={{
            all: 'unset', cursor: 'pointer', width: '100%',
            borderRadius: 16, padding: 14, textAlign: 'left',
            background: n.unread ? `${Z.pink}0A` : Z.card,
            border: `1px solid ${n.unread ? Z.pink + '33' : Z.stroke}`,
            display: 'flex', gap: 12, alignItems: 'flex-start',
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10, flexShrink: 0,
              background: n.type === 'proof' ? `${Z.orange}18` : n.type === 'dare' ? `${Z.pink}18` : Z.cardHi,
              display: 'grid', placeItems: 'center',
            }}>
              {n.type === 'proof' && <ZIcons.check size={16} stroke={Z.orange} sw={2}/>}
              {n.type === 'dare' && <ZIcons.bolt size={16} stroke={Z.pink} sw={2}/>}
              {n.type === 'board' && <ZIcons.trophy size={16} stroke={Z.text} sw={2}/>}
              {n.type === 'friend' && <ZIcons.users size={16} stroke={Z.text} sw={2}/>}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ ...ZT.body(14, 600), color: Z.text }}>{n.title}</span>
                {n.unread && (
                  <span style={{
                    width: 8, height: 8, borderRadius: '50%', background: Z.pink, flexShrink: 0,
                  }}/>
                )}
              </div>
              <div style={{ ...ZT.body(13), color: Z.textMute, marginTop: 4, lineHeight: 1.4 }}>{n.body}</div>
              <div style={{ ...ZT.small(11), color: Z.textDim, marginTop: 6 }}>{n.time}</div>
            </div>
          </button>
        ))}
      </div>
    </ZScreen>
  );
}

// ─── Invite friends ────────────────────────────────────────────────────────
const Z_SUGGESTED = [
  { name: 'Maya Chen', handle: '@mayaaa', emoji: '🦊' },
  { name: 'Jordan Lee', handle: '@jordy', emoji: '🦝' },
  { name: 'Sam Park', handle: '@sampark', emoji: '🐸' },
];

function ZInviteFriends({ onBack } = {}) {
  const [copied, setCopied] = React.useState(false);
  const link = 'zuvaro.app/join/chaos-crew';

  const copyLink = () => {
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <ZScreen>
      <ZSubHeader title="Invite friends" onBack={onBack}/>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 120, bottom: 40,
        overflow: 'auto',
      }}>
        <div style={{
          borderRadius: 20, padding: 20, textAlign: 'center',
          background: Z_GRAD.cardWarm, color: Z.inkOnWarm || '#0A0508',
        }}>
          <div style={{ fontSize: 36 }}>🎉</div>
          <div style={{ ...ZT.body(16, 700), marginTop: 12 }}>Bring your crew to Chaos Crew</div>
          <div style={{ ...ZT.body(13, 500), opacity: 0.75, marginTop: 6 }}>
            Share your link — when they join, you both get +15pts
          </div>
        </div>

        <div style={{
          marginTop: 16, borderRadius: 16, padding: 14,
          background: Z.card, border: `1px solid ${Z.stroke}`,
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <span style={{ ...ZT.mono(13, 600), color: Z.text, flex: 1, overflow: 'hidden', textOverflow: 'ellipsis' }}>
            {link}
          </span>
          <button onClick={copyLink} style={{
            padding: '8px 14px', borderRadius: 10, border: 'none', cursor: 'pointer',
            background: copied ? (Z.success || '#22C55E') : Z_GRAD.warm,
            color: copied ? '#fff' : (Z.inkOnWarm || '#0A0508'),
            ...ZT.body(13, 700),
          }}>{copied ? 'Copied!' : 'Copy'}</button>
        </div>

        <div style={{ ...ZT.label(10), color: Z.textMute, margin: '24px 0 10px' }}>Suggested friends</div>
        {Z_SUGGESTED.map((f, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '12px 0',
            borderTop: i ? `1px solid ${Z.stroke}` : 'none',
          }}>
            <div style={{
              width: 40, height: 40, borderRadius: '50%', background: Z.card,
              border: `1px solid ${Z.strokeHi}`, display: 'grid', placeItems: 'center', fontSize: 18,
            }}>{f.emoji}</div>
            <div style={{ flex: 1 }}>
              <div style={{ ...ZT.body(15, 600), color: Z.text }}>{f.name}</div>
              <div style={{ ...ZT.small(12), color: Z.textMute }}>{f.handle}</div>
            </div>
            <button style={{
              padding: '8px 16px', borderRadius: 999, border: 'none', cursor: 'pointer',
              background: Z.cardHi, color: Z.text, ...ZT.body(13, 600),
            }}>Invite</button>
          </div>
        ))}

        <button style={{
          ...zCtaPrimary, width: '100%', marginTop: 24,
        }}>Share via Messages</button>
      </div>
    </ZScreen>
  );
}

// ─── Edit profile ──────────────────────────────────────────────────────────
function ZEditProfile({ onBack, onSave } = {}) {
  const [name, setName] = React.useState('John Winner');
  const [handle, setHandle] = React.useState('@IloveMyGTA6too');
  const [bio, setBio] = React.useState('Professional chaos agent. 23-day streak holder.');

  return (
    <ZScreen>
      <ZSubHeader title="Edit profile" onBack={onBack}/>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 120, bottom: 100,
        overflow: 'auto', display: 'flex', flexDirection: 'column', gap: 16, alignItems: 'center',
      }}>
        <div style={{ position: 'relative' }}>
          <Avatar size={80} emoji="👑" ring={Z.orange} glow/>
          <button style={{
            position: 'absolute', bottom: -2, right: -6, width: 32, height: 32, borderRadius: '50%',
            background: Z.bg, border: `2px solid ${Z.pink}`, cursor: 'pointer',
            display: 'grid', placeItems: 'center',
          }}>
            <ZIcons.edit size={14} stroke={Z.pink} sw={2}/>
          </button>
        </div>

        {[
          { label: 'Display name', value: name, set: setName },
          { label: 'Username', value: handle, set: setHandle },
        ].map((f) => (
          <label key={f.label} style={{ display: 'block', width: '100%' }}>
            <span style={{ ...ZT.label(10), color: Z.textMute, display: 'block', marginBottom: 8 }}>{f.label}</span>
            <input
              value={f.value}
              onChange={(e) => f.set(e.target.value)}
              style={{
                width: '100%', height: 48, borderRadius: 14, padding: '0 14px', boxSizing: 'border-box',
                border: `1px solid ${Z.strokeHi}`, background: Z.card, color: Z.text,
                ...ZT.body(15, 500), outline: 'none',
              }}
            />
          </label>
        ))}

        <label style={{ display: 'block', width: '100%' }}>
          <span style={{ ...ZT.label(10), color: Z.textMute, display: 'block', marginBottom: 8 }}>Bio</span>
          <textarea
            value={bio}
            onChange={(e) => setBio(e.target.value)}
            rows={3}
            style={{
              width: '100%', borderRadius: 14, padding: 14, boxSizing: 'border-box', resize: 'none',
              border: `1px solid ${Z.strokeHi}`, background: Z.card, color: Z.text,
              ...ZT.body(14, 500), outline: 'none', fontFamily: 'inherit',
            }}
          />
        </label>
      </div>

      <div style={{ position: 'absolute', left: 24, right: 24, bottom: 40 }}>
        <button onClick={() => onSave?.()} style={{ ...zCtaPrimary, width: '100%' }}>Save changes</button>
      </div>
    </ZScreen>
  );
}

// ─── Privacy ───────────────────────────────────────────────────────────────
function ZPrivacy({ onBack } = {}) {
  const [opts, setOpts] = React.useState({
    profile: true, board: true, activity: false, dms: true,
  });

  const rows = [
    { k: 'profile', label: 'Public profile', sub: 'Anyone can view your stats' },
    { k: 'board', label: 'Show on leaderboards', sub: 'Appear on Friends, Club, and Global' },
    { k: 'activity', label: 'Share activity feed', sub: 'Friends see completed dares' },
    { k: 'dms', label: 'Allow group invites', sub: 'Others can add you to chats' },
  ];

  return (
    <ZScreen>
      <ZSubHeader title="Privacy" onBack={onBack}/>

      <div style={{ position: 'absolute', left: 24, right: 24, top: 120, bottom: 40, overflow: 'auto' }}>
        <div style={{
          borderRadius: 20, background: Z.card, border: `1px solid ${Z.stroke}`, overflow: 'hidden',
        }}>
          {rows.map((r, i) => (
            <div key={r.k} style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px',
              borderTop: i ? `1px solid ${Z.stroke}` : 'none',
            }}>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ ...ZT.body(15, 600), color: Z.text }}>{r.label}</div>
                <div style={{ ...ZT.small(12), color: Z.textMute, marginTop: 2 }}>{r.sub}</div>
              </div>
              <button
                onClick={() => setOpts(n => ({ ...n, [r.k]: !n[r.k] }))}
                style={{
                  width: 48, height: 28, borderRadius: 14, border: 'none', cursor: 'pointer', padding: 2,
                  background: opts[r.k] ? Z_GRAD.warm : Z.cardHi,
                  transition: 'background .15s',
                }}
              >
                <div style={{
                  width: 24, height: 24, borderRadius: 12, background: '#fff',
                  transform: opts[r.k] ? 'translateX(20px)' : 'translateX(0)',
                  transition: 'transform .15s',
                  boxShadow: '0 1px 3px rgba(0,0,0,0.15)',
                }}/>
              </button>
            </div>
          ))}
        </div>
      </div>
    </ZScreen>
  );
}

// ─── Blocked users ─────────────────────────────────────────────────────────
const Z_BLOCKED = [
  { name: 'Spam Bot 3000', handle: '@notreal', emoji: '🤖' },
  { name: 'Toxic Tim', handle: '@toxictim', emoji: '🐍' },
];

function ZBlockedUsers({ onBack } = {}) {
  const [blocked, setBlocked] = React.useState(Z_BLOCKED);

  return (
    <ZScreen>
      <ZSubHeader title="Blocked users" onBack={onBack}/>

      <div style={{ position: 'absolute', left: 24, right: 24, top: 120, bottom: 40, overflow: 'auto' }}>
        {!blocked.length ? (
          <div style={{
            padding: 32, borderRadius: 16, textAlign: 'center',
            background: Z.card, border: `1px solid ${Z.stroke}`,
          }}>
            <div style={{ ...ZT.body(15, 600), color: Z.text }}>No blocked users</div>
            <div style={{ ...ZT.body(13), color: Z.textMute, marginTop: 6 }}>You're living peacefully.</div>
          </div>
        ) : blocked.map((u, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '14px 0',
            borderTop: i ? `1px solid ${Z.stroke}` : 'none',
          }}>
            <div style={{
              width: 44, height: 44, borderRadius: '50%', background: Z.card,
              border: `1px solid ${Z.strokeHi}`, display: 'grid', placeItems: 'center', fontSize: 20,
            }}>{u.emoji}</div>
            <div style={{ flex: 1 }}>
              <div style={{ ...ZT.body(15, 600), color: Z.text }}>{u.name}</div>
              <div style={{ ...ZT.small(12), color: Z.textMute }}>{u.handle}</div>
            </div>
            <button
              onClick={() => setBlocked(b => b.filter((_, j) => j !== i))}
              style={{
                padding: '8px 14px', borderRadius: 10, cursor: 'pointer',
                background: 'transparent', border: `1px solid ${Z.strokeHi}`,
                color: Z.textMute, ...ZT.body(13, 600),
              }}
            >Unblock</button>
          </div>
        ))}
      </div>
    </ZScreen>
  );
}

// ─── Help & support ────────────────────────────────────────────────────────
const Z_FAQ = [
  { q: 'How do I earn points?', a: 'Complete dares and submit photo proof. Points are credited after moderator approval, usually within 24 hours.' },
  { q: 'Can I create my own dares?', a: 'Yes — open your group chat and tap + to post a dare for your friends.' },
  { q: 'Why was my proof rejected?', a: 'Your photo must clearly show the dare was completed. Check the proof rules on the submit screen and resubmit.' },
  { q: 'How does the Quest Chain work?', a: 'Five daily dares refresh every 3 hours. Complete them all for bonus streak credit.' },
];

function ZHelpSupport({ onBack } = {}) {
  const [open, setOpen] = React.useState(0);

  return (
    <ZScreen>
      <ZSubHeader title="Help & support" onBack={onBack}/>

      <div style={{
        position: 'absolute', left: 24, right: 24, top: 120, bottom: 40,
        overflow: 'auto', display: 'flex', flexDirection: 'column', gap: 8,
      }}>
        {Z_FAQ.map((f, i) => (
          <div key={i} style={{
            borderRadius: 16, background: Z.card, border: `1px solid ${Z.stroke}`, overflow: 'hidden',
          }}>
            <button onClick={() => setOpen(open === i ? -1 : i)} style={{
              all: 'unset', cursor: 'pointer', width: '100%',
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '14px 16px',
            }}>
              <span style={{ ...ZT.body(14, 600), color: Z.text, paddingRight: 12 }}>{f.q}</span>
              <span style={{
                display: 'inline-flex',
                transform: open === i ? 'rotate(180deg)' : 'none',
                transition: 'transform .15s',
              }}>
                <ZIcons.chevD size={16} stroke={Z.textMute} sw={2}/>
              </span>
            </button>
            {open === i && (
              <div style={{
                padding: '0 16px 14px', ...ZT.body(13), color: Z.textMute, lineHeight: 1.5,
              }}>{f.a}</div>
            )}
          </div>
        ))}

        <button style={{
          ...zCtaPrimary, width: '100%', marginTop: 16,
        }}>Contact support</button>
        <div style={{ ...ZT.small(12), color: Z.textMute, textAlign: 'center', marginTop: 8 }}>
          support@zuvaro.app · avg response 24h
        </div>
      </div>
    </ZScreen>
  );
}

Object.assign(window, {
  ZGroupChat, ZCreateDare, ZNotifications, ZInviteFriends,
  ZEditProfile, ZPrivacy, ZBlockedUsers, ZHelpSupport,
});
