# API

Supabase Data API is used with a publishable key and an authenticated user's JWT for writes. No service-role key is shipped.

- GET /rest/v1/incidents: select only public columns, bound longitude/latitude to viewport, order created_at descending, limit 200. Expired/removed rows are excluded by policy.
- POST /rest/v1/incidents: category, author_id, longitude, latitude, description. Author must match JWT. Timestamp, expiration and status are assigned by a private database trigger. Maximum six reports per hour per account; same-category duplicates within 50 metres are rejected.
- POST /rest/v1/confirmations: incident_id, user_id, kind (confirm, gone, flag). One observation per user per report. Authors cannot confirm themselves. Thirty observations per hour per account. Gone/flag changes state to disputed; confirm records last confirmation without asserting truth.
- saved_places: private CRUD restricted to owner; UI planned.

SQL integration test: run tests/report-lifecycle.sql in an isolated development database with migrations applied. It uses rollback and asserts the returned dispute_passed value. It does not test real email authentication.
