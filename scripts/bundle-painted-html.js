#!/usr/bin/env node
/**
 * Inlines external .jsx modules into painted HTML so file:// opens work
 * (browsers block Babel from fetching sibling scripts on file://).
 *
 * Usage: node scripts/bundle-painted-html.js "Zuvaro Painted v3 light.html"
 */

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');

const BUNDLES = {
  'Zuvaro Painted v3 light.html': [
    'ios-frame.jsx',
    'design-canvas.jsx',
    'zuvaro-v3-theme-light.jsx',
    'zuvaro-v2-onboarding.jsx',
    'zuvaro-v2-flows.jsx',
    'zuvaro-v2-social.jsx',
    'zuvaro-v2-app.jsx',
    'zuvaro-v2-proto.jsx',
  ],
  'Zuvaro Painted v2.html': [
    'ios-frame.jsx',
    'design-canvas.jsx',
    'zuvaro-v2-theme.jsx',
    'zuvaro-v2-onboarding.jsx',
    'zuvaro-v2-flows.jsx',
    'zuvaro-v2-social.jsx',
    'zuvaro-v2-app.jsx',
    'zuvaro-v2-proto.jsx',
  ],
  'Zuvaro Painted.html': [
    'ios-frame.jsx',
    'design-canvas.jsx',
    'zuvaro-theme.jsx',
    'zuvaro-onboarding.jsx',
    'zuvaro-app.jsx',
    'zuvaro-proto.jsx',
  ],
};

const MARKER_START = '<!-- ZUVARO_BUNDLE_START -->';
const MARKER_END = '<!-- ZUVARO_BUNDLE_END -->';

function bundleFile(htmlName) {
  const scripts = BUNDLES[htmlName];
  if (!scripts) {
    console.error(`Unknown HTML file: ${htmlName}`);
    console.error('Known:', Object.keys(BUNDLES).join(', '));
    process.exit(1);
  }

  const htmlPath = path.join(ROOT, htmlName);
  let html = fs.readFileSync(htmlPath, 'utf8');

  const parts = scripts.map((file) => {
    const p = path.join(ROOT, file);
    if (!fs.existsSync(p)) throw new Error(`Missing ${file}`);
    return `;// ── ${file} ──\n${fs.readFileSync(p, 'utf8')}`;
  });
  const bundleBody = parts.join('\n\n');
  const bundleScript =
    `${MARKER_START}\n` +
    `<script type="text/babel" data-presets="react" id="zuvaro-modules-bundle">\n${bundleBody}\n</script>\n` +
    `${MARKER_END}`;

  const srcBlockRe =
    /<!-- ZUVARO_BUNDLE_START -->[\s\S]*?<!-- ZUVARO_BUNDLE_END -->|<script type="text\/babel" src="[^"]+\.jsx"><\/script>\n?/g;

  if (!html.match(/<script type="text\/babel" src="[^"]+\.jsx">/)) {
    if (!html.includes(MARKER_START)) {
      throw new Error(`${htmlName}: no external babel scripts or bundle markers found`);
    }
  }

  if (html.includes(MARKER_START)) {
    html = html.replace(srcBlockRe, bundleScript);
  } else {
    const firstSrc = html.indexOf('<script type="text/babel" src="');
    const lastSrc = html.lastIndexOf('<script type="text/babel" src="');
    const lastEnd = html.indexOf('</script>', lastSrc) + '</script>'.length;
    html = html.slice(0, firstSrc) + bundleScript + '\n' + html.slice(lastEnd);
  }

  fs.writeFileSync(htmlPath, html);
  console.log(`Bundled ${scripts.length} files into ${htmlName}`);
}

const args = process.argv.slice(2);
if (args.includes('--all')) {
  Object.keys(BUNDLES).forEach(bundleFile);
} else {
  bundleFile(args[0] || 'Zuvaro Painted v3 light.html');
}
