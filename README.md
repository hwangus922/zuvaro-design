# Zuvaro Design

Interactive UI prototype and design canvas for **Zuvaro** — daily dares, quest chains, leaderboards, and proof submission.

**Canonical version:** `Zuvaro Painted v3 light.html` (light theme)

## Quick start

```bash
cd zuvaro-app
npm run serve
```

Open [http://127.0.0.1:8765/](http://127.0.0.1:8765/) — redirects to the v3 light canvas.

Or double-click `Open Zuvaro v3 Light.command` on macOS.

## What's in the canvas

| # | Screen |
|---|--------|
| 01 | Splash |
| 02–04 | Onboarding (welcome, TOS, sign-up) |
| 05 | Home |
| 06 | Leaderboard |
| 07 | Profile |
| 08–09 | Sign in, email auth |
| 10 | Challenge detail |
| 11 | Challenge complete |
| 12 | Quest chain |
| 13 | Dare in progress (timer) |
| 14 | Submit proof |
| 15 | Search |
| 16 | Settings |
| ◉ | **Interactive prototype** — full clickable flow |

## Edit workflow

Source modules live in `.jsx` files at the repo root. The HTML canvases bundle those modules for offline / `file://` use.

After editing any `.jsx` file:

```bash
npm run bundle:all
```

Then commit both the `.jsx` sources **and** the updated HTML files.

## Versions

| File | Theme |
|------|-------|
| `Zuvaro Painted v3 light.html` | **Current** — white, pink, magenta, orange |
| `Zuvaro Painted v2.html` | Dark v2 |
| `Zuvaro Painted.html` | Original v1 |

## Live preview (GitHub Pages)

After enabling Pages in the repo settings (Source: **GitHub Actions**), pushes to `main` deploy automatically.

Public URL: `https://hwangus922.github.io/zuvaro-design/`

## Project structure

```
zuvaro-v2-proto.jsx      # Interactive prototype router
zuvaro-v2-flows.jsx      # Challenge, auth, search, settings screens
zuvaro-v2-app.jsx        # Home, leaderboard, profile
zuvaro-v2-onboarding.jsx # Onboarding screens
zuvaro-v3-theme-light.jsx # v3 light design tokens
design-canvas.jsx        # Figma-style canvas wrapper
ios-frame.jsx            # iPhone device chrome
scripts/bundle-painted-html.js
```

## Stack

Static HTML + React 18 (CDN) + Babel standalone. No build step required to view — only to rebundle after JSX edits.
