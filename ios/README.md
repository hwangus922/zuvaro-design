# Zuvaro iOS App

Native **SwiftUI** iOS app built from the v3 light design prototype.

## Open in Xcode

1. Open `ios/Zuvaro.xcodeproj` in Xcode
2. Select the **Zuvaro** scheme
3. Choose an iPhone simulator (iOS 17+)
4. Press **Run** (⌘R)

## First-time setup

1. Select the **Zuvaro** target → **Signing & Capabilities**
2. Set your **Team** (Apple ID) for code signing
3. Optionally change **Bundle Identifier** from `com.zuvaro.app`

## What's implemented

| Area | Status |
|------|--------|
| v3 light theme (pink / magenta / orange) | ✅ |
| Onboarding splash → welcome → sign-up | ✅ |
| Tab bar (Home, Board, Me) | ✅ |
| Quest chain + challenge cards | ✅ |
| Full dare flow (detail → timer → proof → upload → pending → approved/rejected) | ✅ |
| Photo picker for proof submission | ✅ |
| Group chat + create dare | ✅ |
| Notifications, invite friends | ✅ |
| Settings + sub-screens | ✅ |
| Search, my submissions | ✅ |

Data is **mock/local** for now — ready to wire to a backend (Supabase, Firebase, or custom API).

## Project structure

```
Zuvaro/
  ZuvaroApp.swift          App entry
  App/                     Navigation state + routes
  Theme/                   Colors, gradients, shared UI
  Models/                  Challenge, Submission, etc.
  Data/MockData.swift      Prototype copy + sample dares
  Components/              Tab bar, cards, buttons
  Views/
    Onboarding/
    Tabs/                  Home, Leaderboard, Profile
    Challenge/             Dare + proof flow
    Social/                Chat, notifications, invite
    Settings/
```

## Next steps (backend)

1. Add **Sign in with Apple** + email auth
2. Replace `MockData` with API calls
3. Upload proof photos to cloud storage (S3 / Supabase Storage)
4. Push notifications for dare refresh + proof approval
5. Real-time group chat (WebSocket or Firebase)

## Requirements

- Xcode 15+
- iOS 17.0+ deployment target
- macOS for building and simulator
