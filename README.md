# RoadWatch BD

Your Roads. Your Community. Your Safety.

**Work in progress. Not ready for public use.**

A mobile-first community road intelligence platform for Bangladesh, starting in Dhaka.

## Current implementation

- Next.js / TypeScript map interface with MapLibre and OpenStreetMap attribution
- Responsive bottom-sheet reporting UI and mobile navigation
- On-demand browser location with permission error feedback
- Device-local report draft saving
- Initial Bangla category labels and desktop theme control

Authentication, live reports, confirmation, moderation, route-aware alerts, search, and saved places are not implemented yet. No fictional incidents are shown.

## Development

Use Node.js 24 or later.

```sh
npm ci
npm run dev
```

```sh
npx tsc --noEmit
npm run build
```

The current public OSM tile endpoint is for low-volume development; review its usage policy and select a suitable licensed provider before a public beta. Do not bulk-download or prefetch tiles.

See [architecture](docs/ARCHITECTURE.md) for the intended data and privacy design and release gates.
