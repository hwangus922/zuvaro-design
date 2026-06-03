// Zuvaro v2 — interactive prototype shell
// Onboarding → auth → Home; challenge detail → complete; tab nav.

function ZProto({ initial = 'splash' } = {}) {
  const [route, setRoute] = React.useState(initial);
  const [emailMode, setEmailMode] = React.useState('signup');
  const [challengeIdx, setChallengeIdx] = React.useState(0);
  const [questDone, setQuestDone] = React.useState(1);
  const go = (r) => setRoute(r);

  const challenges = window.Z_CHALLENGES || [];
  const activeChallenge = challenges[challengeIdx] || challenges[0];
  const activePts = activeChallenge?.pts ?? null;

  React.useEffect(() => {
    if (route !== 'splash') return;
    const id = setTimeout(() => setRoute('welcome'), 1400);
    return () => clearTimeout(id);
  }, [route]);

  const openChallenge = (idx) => {
    setChallengeIdx(idx);
    go('challenge');
  };

  const finishChallenge = () => {
    setQuestDone((n) => Math.min(5, n + 1));
    go('complete');
  };

  return (
    <div style={{ position: 'absolute', inset: 0 }}>
      <ZFader keyName={route}>
        {route === 'splash'   && <ZOnboarding1 />}
        {route === 'welcome'  && <ZOnboarding2
          onContinue={() => go('agreed')}
          onSignIn={() => { setEmailMode('signin'); go('signin'); }}
        />}
        {route === 'agreed'   && <ZOnboarding3
          onContinue={() => go('signup')}
          onSignIn={() => { setEmailMode('signin'); go('signin'); }}
        />}
        {route === 'signup'   && <ZOnboarding4
          onEmail={() => { setEmailMode('signup'); go('email'); }}
          onGoogle={() => go('home')}
          onSignIn={() => { setEmailMode('signin'); go('signin'); }}
        />}
        {route === 'signin'   && <ZSignIn
          onBack={() => go('welcome')}
          onEmail={() => { setEmailMode('signin'); go('email'); }}
          onGoogle={() => go('home')}
          onSignUp={() => go('signup')}
        />}
        {route === 'email'    && <ZEmailAuth
          mode={emailMode}
          onBack={() => go(emailMode === 'signin' ? 'signin' : 'signup')}
          onSubmit={() => go('home')}
          onToggleMode={() => setEmailMode((m) => (m === 'signup' ? 'signin' : 'signup'))}
        />}
        {route === 'home'     && <ZHome
          onOpenBoard={() => go('board')}
          onOpenMe={() => go('me')}
          onOpenChallenge={openChallenge}
          onOpenQuestChain={() => go('quest')}
        />}
        {route === 'quest'    && <ZQuestChain
          questDone={questDone}
          onBack={() => go('home')}
          onSelectChallenge={(idx) => openChallenge(idx)}
        />}
        {route === 'challenge' && <ZChallengeDetail
          challenge={activeChallenge}
          questIndex={questDone}
          questTotal={5}
          onBack={() => go('home')}
          onAccept={finishChallenge}
          onQuestChain={() => go('quest')}
        />}
        {route === 'complete' && <ZChallengeComplete
          points={activePts}
          questDone={questDone}
          onHome={() => go('home')}
          onNext={() => go('home')}
        />}
        {route === 'board'    && <ZLeaderboard onBack={() => go('home')} onMe={() => go('me')}/>}
        {route === 'me'       && <ZProfile onBack={() => go('home')} onHome={() => go('home')} onBoard={() => go('board')}/>}
      </ZFader>
    </div>
  );
}

function ZFader({ keyName, children }) {
  return (
    <div key={keyName} style={{
      position: 'absolute', inset: 0, animation: 'zfadev2 .28s ease-out both',
    }}>{children}</div>
  );
}

Object.assign(window, { ZProto, ZFader });
