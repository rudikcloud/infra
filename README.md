## Infra (Local Dev Orchestration)

This repo runs the local RudikCloud stack for Milestone 0:

- PostgreSQL
- Redis
- `auth-service` (built from `../auth-service`)
- `dashboard` (built from `../dashboard`)
- `orders-service` (built from `../orders-service`)
- `flags-service` (built from `../flags-service`)
- `audit-service-java` (built from `../audit-service-java`)
- `notifications-worker` (built from `../notifications-worker`)
- OpenTelemetry Collector (`otel-collector`)
- Prometheus
- Tempo
- Grafana

## Quickstart

1. Create local env file:

```bash
cp .env.example .env
```

2. Start the stack from `infra/`:

```bash
docker compose up --build
```

Or with Make:

```bash
make up
```

3. Stop the stack:

```bash
make down
```

4. Follow logs:

```bash
make logs
```

5. Reset containers + volumes:

```bash
make reset
```

6. Quick health check for orders-service:

```bash
curl http://localhost:8002/health
```

7. Quick health check for flags-service:

```bash
curl http://localhost:8003/health
```

8. Open observability UIs:

- Grafana: `http://localhost:3001` (default login `admin` / `admin`)
- Prometheus: `http://localhost:9090`
- Tempo API: `http://localhost:3200`

## Ports

- Dashboard: `3000`
- Auth service: `8001`
- Orders service: `8002` (fixed host mapping)
- Flags service: `8003` (mapped to container `8000`)
- Notifications worker: no host port (background worker only)
- Audit service: `8004` (mapped to container `8000`)
- Grafana: `3001` (mapped to container `3000`)
- Prometheus: `9090`
- Tempo API: `3200`
- OTEL Collector OTLP gRPC: `4317`
- OTEL Collector OTLP HTTP: `4318`
- PostgreSQL: `5432`
- Redis: `6379`

## Environment Variables

Copy `.env.example` to `.env` and adjust if needed.

- `POSTGRES_DB`: PostgreSQL database name.
- `POSTGRES_USER`: PostgreSQL username.
- `POSTGRES_PASSWORD`: PostgreSQL password (dev-only default).
- `POSTGRES_PORT`: Host port mapped to container Postgres `5432`.
- `REDIS_PORT`: Host port mapped to container Redis `6379`.
- `AUTH_SERVICE_PORT`: Host port mapped to auth-service container `8001`.
- `DASHBOARD_PORT`: Host port mapped to dashboard container `3000`.
- `FLAGS_SERVICE_PORT`: Host port mapped to flags-service container `8000`.
- `AUDIT_SERVICE_PORT`: Host port mapped to audit-service-java container `8000`.
- `GRAFANA_PORT`: Host port mapped to Grafana container `3000`.
- `PROMETHEUS_PORT`: Host port mapped to Prometheus container `9090`.
- `TEMPO_PORT`: Host port mapped to Tempo API container `3200`.
- `OTEL_COLLECTOR_OTLP_GRPC_PORT`: Host port mapped to OpenTelemetry Collector OTLP gRPC (`4317`).
- `OTEL_COLLECTOR_OTLP_HTTP_PORT`: Host port mapped to OpenTelemetry Collector OTLP HTTP (`4318`).
- `GRAFANA_ADMIN_USER`: Grafana admin username for local dev.
- `GRAFANA_ADMIN_PASSWORD`: Grafana admin password for local dev.
- `OTEL_EXPORTER_OTLP_ENDPOINT`: OTLP gRPC endpoint used by Python services (`auth-service`, `orders-service`, `flags-service`, `notifications-worker`).
- `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`: OTLP traces endpoint used by `audit-service-java`.
- `OTEL_SERVICE_VERSION`: Common service version attribute for telemetry resource data.
- `OTEL_ENVIRONMENT`: Common deployment environment resource attribute.
- `OTEL_TRACES_SAMPLER`: Trace sampling strategy (`always_on` by default for local dev).
- `AUTH_DATABASE_URL`: DB URL used by auth-service.
- `AUTH_REDIS_URL`: Redis URL used by auth-service.
- `AUTH_JWT_SECRET`: JWT signing secret for auth-service (dev placeholder).
- `AUTH_JWT_ISSUER`: JWT issuer value for auth-service.
- `AUTH_CORS_ORIGINS`: Allowed CORS origins for auth-service (default includes both `localhost:3000` and `127.0.0.1:3000`).
- `AUTH_SESSION_COOKIE_NAME`: Auth session cookie name.
- `AUTH_SESSION_TTL_SECONDS`: Session lifetime in seconds.
- `AUTH_COOKIE_SECURE`: Whether auth cookie requires HTTPS.
- `AUTH_COOKIE_SAMESITE`: SameSite value for auth cookie.
- `NEXT_PUBLIC_AUTH_BASE_URL`: Browser-facing auth-service URL used by dashboard (default `http://localhost:8001`).
- `ORDERS_DATABASE_URL`: DB URL used by orders-service.
- `ORDERS_REDIS_URL`: Redis URL used by orders-service.
- `ORDERS_EVENTS_STREAM`: Stream name where orders-service emits `order.created`.
- `ORDERS_AUTH_SERVICE_URL`: Internal auth-service URL used by orders-service for `/me` validation.
- `ORDERS_AUTH_REQUEST_TIMEOUT_SECONDS`: Timeout (seconds) for orders-service auth-service calls.
- `ORDERS_FLAGS_SERVICE_URL`: Internal flags-service URL used by orders-service.
- `ORDERS_FLAGS_REQUEST_TIMEOUT_SECONDS`: Timeout (seconds) for orders-service flags-service calls.
- `ORDERS_AUDIT_REQUEST_TIMEOUT_SECONDS`: Timeout (seconds) for orders-service audit-service calls.
- `FLAGS_DATABASE_URL`: DB URL used by flags-service.
- `FLAGS_AUTH_SERVICE_URL`: Internal auth-service URL used by flags-service for `/me` validation.
- `FLAGS_AUTH_REQUEST_TIMEOUT_SECONDS`: Timeout (seconds) for flags-service auth-service calls.
- `FLAGS_AUDIT_REQUEST_TIMEOUT_SECONDS`: Timeout (seconds) for flags-service audit-service calls.
- `AUDIT_DATABASE_URL`: JDBC URL used by audit-service-java.
- `AUDIT_INGEST_TOKEN`: Shared internal header token used by audit ingestion (`X-Internal-Token`).
- `AUDIT_SERVICE_URL`: Internal base URL for audit-service-java (for service-to-service usage).
- `NOTIFICATIONS_DATABASE_URL`: DB URL used by notifications-worker.
- `NOTIFICATIONS_REDIS_URL`: Redis URL used by notifications-worker.
- `NOTIFICATIONS_ORDERS_EVENTS_STREAM`: Incoming stream consumed by notifications-worker.
- `NOTIFICATIONS_ORDERS_RETRY_ZSET`: Retry queue zset name.
- `NOTIFICATIONS_ORDERS_DLQ_STREAM`: Dead-letter queue stream name.
- `NOTIFICATIONS_MAX_ATTEMPTS`: Max attempts before worker writes to DLQ.
- `NOTIFICATIONS_WORKER_POLL_INTERVAL_MS`: Poll interval for worker stream/retry processing.
- `NOTIFICATIONS_FAIL_MODE`: Failure simulation mode (`off`, `always`, `random`).

## Notes

- `auth-service` and `dashboard` need their own `Dockerfile` to build successfully.
- Milestone 1 auth defaults are set for local dev: `AUTH_CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000`, `AUTH_COOKIE_SECURE=false`, `AUTH_COOKIE_SAMESITE=lax`.
- Milestone 4 worker demo: set `NOTIFICATIONS_FAIL_MODE=always` in `infra/.env`, restart `notifications-worker`, create an order, then inspect DLQ with:
  `docker compose exec -T redis redis-cli XRANGE orders.dlq - +`.
- Milestone 5 audit quick check: `curl -i http://localhost:8004/health`.
- Milestone 6 observability:
  - Prometheus scrapes the OTEL collector metrics endpoint (`otel-collector:9464`).
  - Tempo receives traces from OTEL collector (`tempo:4317`).
  - Grafana is pre-provisioned with Prometheus + Tempo datasources and a starter dashboard (`RudikCloud Observability Overview`).
  - Instrumented services (`auth-service`, `orders-service`, `flags-service`, `notifications-worker`, `audit-service-java`) send traces/metrics via OTLP using compose-wired `OTEL_*` env vars.
- This setup is intentionally dev-friendly and not production hardened.

## Observability Usage

1. Start stack:

```bash
docker compose up --build
```

2. Generate traffic:

```bash
curl -i http://localhost:8001/health
curl -i http://localhost:8002/health
curl -i http://localhost:8003/health
curl -i http://localhost:8004/health
```

3. View metrics in Prometheus (`http://localhost:9090`):

- Query `up`
- Query `otelcol_receiver_accepted_spans`

4. View traces in Grafana (`http://localhost:3001`):

- Login with `admin` / `admin`
- Open Explore, choose `Tempo`
- Filter by service name, e.g. `service.name=orders-service`
