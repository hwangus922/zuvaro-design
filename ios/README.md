# Zuvaro iOS App

Native **SwiftUI** iOS app with Supabase backend integration.

## Open in Xcode

1. Open `ios/Zuvaro.xcodeproj` in Xcode
2. Select the **Zuvaro** scheme
3. Choose an iPhone simulator (iOS 17+)
4. Press **Run** (⌘R)

## First-time setup

### 1. Code signing

1. Select the **Zuvaro** target → **Signing & Capabilities**
2. Set your **Team** (Apple Developer account)
3. Confirm **Bundle Identifier** (`com.zuvaro.app` or your own)
4. Enable **Sign in with Apple** capability (entitlements file included)

### 2. Supabase credentials

1. Copy `ios/Secrets.xcconfig.template` → `ios/Secrets.xcconfig`
2. Fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY` from your Supabase project dashboard
3. Rebuild — values are injected into Info.plist at build time

Without `Secrets.xcconfig`, the app runs in **mock mode** with local prototype data.

### 3. Supabase project setup

```bash
# Install Supabase CLI: https://supabase.com/docs/guides/cli
cd backend/supabase
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
supabase db seed   # optional — loads challenge catalog from seed.sql
```

In the Supabase dashboard:

1. **Authentication → Providers → Apple** — enable Sign in with Apple
   - Add your Apple Services ID, Team ID, Key ID, and `.p8` key
   - Redirect URL: `zuvaro://auth-callback` (or your custom scheme)
2. **Authentication → URL Configuration** — add redirect `zuvaro://auth-callback`
3. **Storage** — confirm `proofs` bucket exists (created by migration)
4. **Set yourself as admin** (for proof moderation):

```sql
update public.profiles set is_admin = true where id = 'YOUR_USER_UUID';
```

### 4. Admin proof moderation

Submissions start as `pending`. Admins review in Supabase:

```sql
-- Approve
update public.submissions
set status = 'approved', reviewed_at = now()
where id = 'SUBMISSION_UUID';

-- Reject
update public.submissions
set status = 'rejected', review_note = 'Photo unclear', reviewed_at = now()
where id = 'SUBMISSION_UUID';
```

The app polls every 5 seconds while a submission is pending and navigates to approved/rejected automatically.

## Project structure

```
Zuvaro/
  ZuvaroApp.swift
  App/                     AppModel, routes
  Services/                Supabase + mock implementations
  Theme/                   v3 light design tokens
  Models/                  Domain + API DTOs
  Data/MockData.swift      Fallback prototype data
  Components/
  Views/
    Auth/                  Sign in with Apple, email auth
    Onboarding/
    Tabs/
    Challenge/
    Social/
    Settings/
backend/supabase/
  migrations/              Postgres schema, RLS, storage, triggers
  seed.sql                 Challenge catalog
```

## App Store Connect checklist

Before submitting to TestFlight / App Store:

| Item | Notes |
|------|-------|
| Privacy Policy URL | **https://hwangus922.github.io/zuvaro-design/privacy.html** |
| Terms of Service URL | **https://hwangus922.github.io/zuvaro-design/terms.html** |
| App icon | Replace placeholder in `Assets.xcassets/AppIcon` |
| Screenshots | 6.7", 6.5", 5.5" iPhone sizes minimum |
| Age rating | Likely 17+ due to user-generated dare content |
| UGC moderation | Document admin review workflow in App Review notes |
| Sign in with Apple | Required (you offer email auth) |
| Photo library usage | Already declared in Info.plist |
| Push notifications | Entitlement included (development); configure APNs for production |
| Export compliance | Standard encryption (HTTPS) — typically "No" for exempt |

### App Review notes (suggested)

> Zuvaro is a social dare app. Users submit photo proof of completed challenges. All proof photos are reviewed by human moderators before points are awarded. Users can block others and report content via Help & Support. Test account: [provide email/password].

## TestFlight → Production

1. Archive in Xcode (**Product → Archive**)
2. Upload to App Store Connect (**Distribute App**)
3. Complete App Store Connect listing (description, keywords, support URL)
4. Submit build to **TestFlight** internal testing first
5. Fix any crashes / review feedback
6. Submit for **App Review** with moderation documentation
7. Release manually or automatically after approval

## Requirements

- Xcode 15+
- iOS 17.0+ deployment target
- Apple Developer Program membership
- Supabase project (free tier works for development)
