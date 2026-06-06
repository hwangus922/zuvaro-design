# Zuvaro Design

Interactive UI prototype and design canvas for **Zuvaro** — daily dares, quest chains, leaderboards, group chat, and proof submission.

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
| **Social · Light** | |
| 22 | Group chat |
| 23 | Create dare |
| 24 | Notifications |
| 25 | Invite friends |
| 26 | Edit profile |
| 27 | Privacy |
| 28 | Blocked users |
| 29 | Help & support |
| ◉ | **Interactive prototype** — full clickable flow |

## Interactive prototype paths

- **Dare loop:** Home → dare → Accept → timer → proof → upload → pending → approve/reject
- **Social:** Home → chat icon → group chat → + create dare
- **Notifications:** Home → bell icon
- **Profile:** Me → submissions / invite friends / settings → sub-screens

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

A deploy workflow is in `.github/workflows/pages.yml`. It skips quietly until Pages is enabled.

**This repo is private.** GitHub Pages on private repos requires **GitHub Pro** (paid). Free alternative: make the repo **public**.

To enable:

1. **Settings** → **General** → change visibility to Public *(or upgrade to Pro)*
2. **Settings** → **Pages** → Source: **GitHub Actions**
3. Push to `main` — the workflow deploys automatically

Public URL: `https://hwangus922.github.io/zuvaro-design/`

## Project structure

```
zuvaro-v2-proto.jsx      # Interactive prototype router
zuvaro-v2-flows.jsx      # Challenge, auth, search, settings, submission screens
zuvaro-v2-social.jsx     # Group chat, notifications, invites, settings sub-screens
zuvaro-v2-app.jsx        # Home, leaderboard, profile
zuvaro-v2-onboarding.jsx # Onboarding screens
zuvaro-v3-theme-light.jsx # v3 light design tokens
design-canvas.jsx        # Figma-style canvas wrapper
ios-frame.jsx            # iPhone device chrome
scripts/bundle-painted-html.js
```

## Stack

Static HTML + React 18 (CDN) + Babel standalone. No build step required to view — only to rebundle after JSX edits.
