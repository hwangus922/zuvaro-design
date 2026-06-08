# Zuvaro Marketing Site

React + Vite landing page for the Zuvaro iOS app.

## Local dev

```bash
npm install
npm run dev
```

Open [http://127.0.0.1:3000/zuvaro-design/](http://127.0.0.1:3000/zuvaro-design/)

## Production build

```bash
npm run build
```

Deployed via [`.github/workflows/zuvaro-website.yml`](../.github/workflows/zuvaro-website.yml) on pushes to `main`.

Live URL (after merge): **https://hwangus922.github.io/zuvaro-design/**

## Config

Copy `.env.example` → `.env.local` and set `VITE_INSTALL_URL` to your App Store or TestFlight link when ready.

## Mockup screenshots

Regenerate app UI PNGs from HTML mockups:

```bash
node scripts/capture-mockups.mjs
```

Requires Playwright Chromium (`npx playwright install chromium` once).
