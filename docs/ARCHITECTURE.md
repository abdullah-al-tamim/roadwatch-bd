# RoadWatch BD architecture

Status: implementation in progress; not ready for public use.

Next.js App Router and TypeScript form a modular monolith. MapLibre renders the map. Supabase provides managed authentication and PostgreSQL/PostGIS. The initial deployment has no Python service.

Public reads must be bounded to the visible viewport and exclude removed and expired incidents. Writes require authenticated, non-anonymous accounts. Database policies enforce ownership; validation and rate limits must remain effective when clients bypass the interface.

Precise travel coordinates stay on the device. Foreground alerts require a relevant road segment or route corridor and direction, not just a nearby point. Without sufficient road-matching evidence, suppress automatic alerts. No background reliability claim is made for mobile browsers.

Roadside activity is short lived and must not become a historical enforcement-location database. Photos are excluded. Community confirmation is evidence, not proof of accuracy.

Production starts with no incidents. Fixtures belong only in isolated tests or visibly labelled staging sessions.

## Provisioned resources

- GitHub: https://github.com/abdullah-al-tamim/roadwatch-bd
- Supabase project: tcyuucfwibzibxugtkct (Mumbai)
- Supabase organization: selected by the owner on 2026-10-30

## Delivery gates

Before public beta: test two independent authenticated users, unauthorized writes, report expiry, duplicate/rate-limit races, moderation permissions, foreground route relevance, denied location permissions, intermittent connectivity, and Android viewport layouts. Configure an appropriate licensed tile/geocoding provider and email delivery. No feature is complete solely because its UI exists.
