// On http://localhost (dev): load live .jsx modules, then mount the app.
// On file:// (offline): keep inlined bundle; app script mounts immediately.
(function () {
  var cfg = window.ZUVARO_LOAD_CONFIG;
  if (!cfg || !cfg.modules || !cfg.modules.length) return;
  if (location.protocol === 'file:' || location.protocol === 'data:') return;

  var bundle = document.getElementById('zuvaro-modules-bundle');
  if (bundle) bundle.remove();

  var anchor = document.getElementById('zuvaro-app-script');
  var pending = cfg.modules.length;
  var failed = false;

  function done() {
    if (--pending > 0) return;
    var tries = 0;
    function tryMount() {
      if (typeof window.mountZuvaroApp === 'function'
          && typeof window.ZProto === 'function'
          && typeof window.ZSubmitProof === 'function'
          && typeof window.ZProofPending === 'function'
          && typeof window.DesignCanvas === 'function') {
        window.mountZuvaroApp();
      } else if (tries++ < 80) {
        setTimeout(tryMount, 50);
      } else {
        console.error('[zuvaro] modules did not register in time.');
      }
    }
    tryMount();
  }

  cfg.modules.forEach(function (src) {
    var s = document.createElement('script');
    s.type = 'text/babel';
    s.setAttribute('data-presets', 'react');
    s.src = src;
    s.onload = done;
    s.onerror = function () {
      failed = true;
      console.error('[zuvaro] failed to load module:', src);
      done();
    };
    if (anchor) document.body.insertBefore(s, anchor);
    else document.body.appendChild(s);
  });
})();
