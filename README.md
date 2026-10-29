# RoadWatch BD

Your Roads. Your Community. Your Safety.

**Development preview — not a public beta or a driving-safety service.**

## Implemented

Next.js and TypeScript application with a responsive MapLibre map initially centred on Dhaka, on-demand location, reporting sheet, device-local draft saving, partial Bangla labels, and desktop light/dark controls. Supabase email-link authentication and report submission are wired. Current reports load within the viewport and expose detail and confirm/dispute/flag actions.

PostGIS migration includes categories, reports, confirmations, private saved-place storage, spatial indexes, configurable category expiration, duplicate checks, account rate limits and row-level access policies. Confirmation count alone never promotes a report to verified. Administrator promotion is not implemented.

## Verification

- TypeScript validation passed.
- Production build passed with Webpack (default compiler failed on this Windows environment).
- Database transaction test: user A submits; user B flags; report becomes disputed. Test rolls back all records.
- Supabase security advisor returned no findings.
- Browser: map renders at 390 × 844 and desktop dimensions; reporting sheet opens and sign-in is required.
- Real email delivery, two-user browser submission, denied GPS and offline recovery are **not yet verified**.

## Run locally

Use Node.js 24 or newer. Copy `.env.example` to `.env.local` and supply the project's public URL and publishable key.

```sh
npm ci
npm run dev
npm run typecheck
npm run build
```

MapLibre worker assets are copied automatically after dependency installation.

## Deployment

Import this repository into Vercel as Next.js. Set both `NEXT_PUBLIC_` variables from `.env.example` for the intended environment. Build with `npm run build`. Configure Supabase Authentication Site URL and allowed redirect URLs to match the deployment, and configure SMTP for real users. Google sign-in requires OAuth configuration and is not implemented in the UI.

The current public OpenStreetMap tile endpoint is used for low-volume development with attribution. Before public launch, select a provider appropriate to expected traffic and comply with its tile and geocoding licence. Do not prefetch or bulk-download public OSM tiles.

## Known limitations / next milestones

1. Complete email delivery and two-user end-to-end browser tests.
2. Add protected moderation, appeals, account deletion, profile preferences and saved-place UI.
3. Add true road/route matching and tested foreground visual/voice alerts. No automatic alert is currently generated and no background GPS claim is made.
4. Implement search, functional filters, clustering, draft restoration, full Bangla translation, mobile theme controls and PWA offline shell.
5. Add spatial viewport RPC, stronger concurrent duplicate handling, location plausibility checks, and broader security/abuse tests.
6. Perform accessibility and performance audits before public beta.

Search, filter, Activity, Saved, and Profile panels still contain explicitly labelled planned functionality. They must not be presented as completed.

## Retention

Expired records are excluded by database read policy. Automatic permanent deletion is **disabled at the owner's request**. Therefore roadside-activity history remains stored privately; resolve retention before public beta. No photos or precise travel histories are collected.

See [architecture](docs/ARCHITECTURE.md), [API](docs/API.md), [security](SECURITY.md), [roadmap](ROADMAP.md), and [contributing](CONTRIBUTING.md).
