// Zuvaro — interactive prototype shell.
// Wraps the screen components in a tiny router so one frame is fully clickable.

function ZuvaroProto({ initial = 'welcome' } = {}) {
  const [route, setRoute] = React.useState(initial);
  const go = (r) => setRoute(r);

  // simple cross-fade between screens
  return (
    <div style={{ position: 'absolute', inset: 0 }}>
      <Fader keyName={route}>
        {route === 'welcome'  && <WelcomeA   onContinue={() => go('signup')} onSignIn={() => go('home')} />}
        {route === 'welcomeB' && <WelcomeB   onContinue={() => go('signup')} onSignIn={() => go('home')} />}
        {route === 'signup'   && <SignUpScreen
          onBack={() => go('welcome')}
          onApple={() => go('home')} onGoogle={() => go('home')} onEmail={() => go('home')} />}
        {route === 'home'     && <HomeScreen        onOpenBoard={() => go('board')} onOpenEntry={() => go('me')} />}
        {route === 'board'    && <LeaderboardScreen onBack={() => go('home')} onOpenProfile={() => go('me')} />}
        {route === 'me'       && <ProfileScreen     onBack={() => go('board')} onHome={() => go('home')} onBoard={() => go('board')} />}
      </Fader>
    </div>
  );
}

function Fader({ keyName, children }) {
  return (
    <div key={keyName} style={{
      position: 'absolute', inset: 0,
      animation: 'zfade .26s ease-out both',
    }}>{children}</div>
  );
}

Object.assign(window, { ZuvaroProto, Fader });
