[![CI](https://github.com/rudikcloud/infra/actions/workflows/ci.yml/badge.svg)](https://github.com/rudikcloud/infra/actions/workflows/ci.yml)

# RudikCloud Infra: System Tour

RudikCloud is a multi-repo, production-style microservices platform built for portfolio demonstration. It shows how independent services can coordinate authentication, feature flags, order processing, background jobs, audit logging, and observability in a single local environment.

This `infra` repo is the local control plane: it orchestrates every service with Docker Compose so a reviewer can run one command and walk through a complete platform story from UI actions to backend traces.

## Quickstart (One Command)

From `infra/`:

```bash
docker compose up --build
```

That command builds and starts dashboard, APIs, worker, data stores, and observability.

Useful helpers:

```bash
make up
make down
make logs
make reset
```

## System URLs and Ports

| Component | URL | Notes |
|---|---|---|
| Dashboard | http://localhost:3000 | Main UI (`/login`, `/orders`, `/flags`, `/audit`) |
| Auth Service | http://localhost:8001 | Cookie session auth (`/auth/*`, `/me`) |
| Orders Service | http://localhost:8002 | Orders API + notification status |
| Flags Service | http://localhost:8003 | Feature flag CRUD + evaluation |
| Audit Service (Java) | http://localhost:8004 | Audit ingest/search |
| Grafana | http://localhost:3001 | Login: `admin` / `admin` |
| Prometheus | http://localhost:9090 | Metrics query UI |
| Tempo (Trace Backend API) | http://localhost:3200 | Trace storage backend |
| Postgres | localhost:5432 | Shared DB for platform data |
| Redis | localhost:6379 | Streams, cache, retry queues |
| OTEL Collector gRPC | localhost:4317 | OTLP ingest for instrumented services |
| OTEL Collector HTTP | localhost:4318 | OTLP HTTP ingest |

## Services Started by Compose

- `dashboard` (`../dashboard`)
- `auth-service` (`../auth-service`)
- `orders-service` (`../orders-service`)
- `flags-service` (`../flags-service`)
- `audit-service-java` (`../audit-service-java`)
- `notifications-worker` (`../notifications-worker`)
- `postgres`, `redis`
- `otel-collector`, `prometheus`, `tempo`, `grafana`

## Demo Flow (End-to-End)

1. Open dashboard at `http://localhost:3000` and register/login.
2. Create or update `newCheckout` flag in `/flags`.
3. Create an order in `/orders` and observe checkout variant + notification status.
4. Refresh `/orders` and watch notification status move (`pending` to `sent`, or `retrying`/`failed` in fail mode).
5. Open `/audit` and verify flag/order audit entries.
6. Open Grafana (`http://localhost:3001`) and inspect traces/metrics.
7. Run failure injection (`NOTIFICATIONS_FAIL_MODE=always`) and observe retries + DLQ behavior.

Detailed command-by-command script is in `RUNBOOK.md`.

## Environment Configuration

Copy env template once:

```bash
cp .env.example .env
```

`infra/.env.example` documents all variables, including service URLs, DB/Redis settings, auth cookie settings, audit token, worker retry/DLQ settings, and OTEL exporter/sampler settings.

## Troubleshooting

### Port already in use

If startup fails with bind errors (for example `5432` already allocated):

```bash
docker compose down
# free the conflicting local service/process, then
make up
```

### Rebuild after dependency or Dockerfile changes

```bash
docker compose up --build
```

### Reset everything (containers + volumes)

```bash
make reset
```

This removes local Postgres/Redis volume data for a clean slate.

### Migration mismatch / schema drift

Each backend container runs migrations on startup. If data is stale, run `make reset` and restart, or execute service-specific migration commands from each repo README.

### Services are up but dashboard actions fail

- Verify health quickly:

```bash
docker compose ps
curl -i http://localhost:8001/health
curl -i http://localhost:8002/health
curl -i http://localhost:8003/health
curl -i http://localhost:8004/health
```

- Confirm `infra/.env` has matching URLs and tokens.

## Related Docs

- `RUNBOOK.md`: copy/paste demo and failure injection runbook
- `ARCHITECTURE.md`: Mermaid architecture + data flows
- `PORTFOLIO_SUMMARY.md`: project-card and resume-ready summary text
