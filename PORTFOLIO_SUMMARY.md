# RudikCloud Portfolio Summary

Use this file as copy-ready source text for project cards, LinkedIn entries, or resume bullets.

## Project Cards (5)

## Card 1: Platform Infra and Observability

Repos: `infra`

- Built a local multi-repo platform orchestrator with Docker Compose, one-command startup, environment-driven config, and reproducible developer workflows.
- Integrated OpenTelemetry Collector, Prometheus, Tempo, and Grafana with pre-provisioned datasources and starter dashboards.
- Added operational docs and runbooks for end-to-end demos, failure injection, and troubleshooting.

## Card 2: Authentication Service

Repos: `auth-service`

- Implemented cookie-based session authentication in FastAPI with Postgres-backed users and server-side sessions.
- Delivered register/login/logout/me flows with CORS and secure local-dev cookie configuration.
- Added telemetry instrumentation and clear migration/test workflows for standalone service execution.

## Card 3: Orders and Reliability Pipeline

Repos: `orders-service`, `notifications-worker`

- Built authenticated order APIs with per-user data access, checkout variant persistence, and event emission to Redis streams.
- Implemented worker-driven notification processing with retries, exponential backoff, dead-letter queue handling, and idempotency safeguards.
- Exposed notification lifecycle state in API responses to make backend reliability behavior visible in UI demos.

## Card 4: Feature Flags and Rollout Control

Repos: `flags-service`

- Designed a practical feature-flag model with environment scope, enable toggle, allowlist targeting, and percentage rollout.
- Implemented authenticated CRUD and deterministic evaluation logic for user-specific flag decisions.
- Connected flag changes to platform behavior by driving order checkout variant selection.

## Card 5: Audit and Product UI

Repos: `audit-service-java`, `dashboard`

- Built a Java Spring Boot audit service with token-protected ingestion, indexed search, and event detail APIs.
- Added dashboard pages for login, orders, flags, and audit exploration with cookie-aware API proxying.
- Created an operator-friendly demo surface where application behavior, audit trail, and reliability status are visible in one place.

## Resume Bullet Drafts

- Designed and delivered a multi-service platform spanning Python FastAPI, Java Spring Boot, Next.js, Postgres, and Redis with Docker-based local orchestration.
- Implemented session-based authentication, feature flag evaluation, event-driven order processing, and audit logging across service boundaries.
- Built background job reliability controls including retry with exponential backoff, dead-letter handling, and idempotent processing.
- Instrumented distributed services with OpenTelemetry and integrated Grafana, Prometheus, and Tempo for trace and metric visibility.
- Authored production-style runbooks, architecture docs, and demo scripts to enable fast onboarding and recruiter-ready demonstrations.
