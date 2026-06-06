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
| 05–09 | Home, leaderboard, profile, sign-in, email |
| **Submission · Light** | |
| 10 | Challenge detail |
| 11 | Dare in progress (timer) |
| 12 | Submit proof |
| 12b | Submit proof (photo added) |
| 13 | Uploading |
| 14 | Pending review |
| 15 | Approved (+pts) |
| 16 | Rejected (resubmit) |
| 17 | My submissions |
| 18–21 | Quest chain, dare complete, search, settings |
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

A deploy workflow is in `.github/workflows/pages.yml`. To go live:

1. Repo → **Settings** → **Pages** → Source: **GitHub Actions**
2. Push to `main` (or run the workflow manually)

Public URL will be: `https://hwangus922.github.io/zuvaro-design/`

> Requires a GitHub plan that includes Pages (public repos on free accounts qualify).

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
