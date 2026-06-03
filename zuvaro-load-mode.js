// On http://localhost (dev): load live .jsx files. On file:// (offline): keep inlined bundle.
(function () {
  var cfg = window.ZUVARO_LOAD_CONFIG;
  if (!cfg || !cfg.modules || !cfg.modules.length) return;
  if (location.protocol === 'file:' || location.protocol === 'data:') return;

  var bundle = document.getElementById('zuvaro-modules-bundle');
  if (bundle) bundle.remove();

  var anchor = document.getElementById('zuvaro-app-script');
  cfg.modules.forEach(function (src) {
    var s = document.createElement('script');
    s.type = 'text/babel';
    s.setAttribute('data-presets', 'react');
    s.src = src;
    if (anchor) document.body.insertBefore(s, anchor);
    else document.body.appendChild(s);
  });
})();
