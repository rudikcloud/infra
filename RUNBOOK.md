# RudikCloud Demo Runbook

Use this runbook to demo the platform live from a clean terminal.

## 1) Startup

```bash
cd infra
cp -n .env.example .env

docker compose up --build
```

Keep this terminal running to watch logs.

Open these tabs:

- Dashboard: http://localhost:3000
- Grafana: http://localhost:3001
- Prometheus: http://localhost:9090
- Tempo backend health: http://localhost:3200/ready

## 2) UI Demo Script (What to Click)

1. Dashboard `/register`: create a user.
2. Dashboard `/login`: log in.
3. Dashboard `/flags`: create or update `newCheckout` in `dev`.
   - Set `enabled=true`, `rollout_percent=100` for deterministic demo.
4. Dashboard `/orders`: create an order.
5. Dashboard `/orders`: confirm newest order shows checkout variant (`new`) and notification fields.
6. Dashboard `/audit`: filter for `FLAG_UPDATED` or `ORDER_CREATED` and open a detail row.

## 3) CLI Demo Script (Optional Copy/Paste)

From `infra/`:

```bash
# register
curl -i -X POST http://127.0.0.1:8001/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"demo@example.com","password":"password123"}'

# login (save cookie)
curl -i -c cookies.txt -X POST http://127.0.0.1:8001/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"demo@example.com","password":"password123"}'

# set flag ON (create or update)
curl -i -b cookies.txt -X POST http://127.0.0.1:8003/flags \
  -H 'Content-Type: application/json' \
  -d '{"key":"newCheckout","description":"Milestone demo","environment":"dev","enabled":true,"rollout_percent":100,"allowlist":[]}'

# create order
curl -i -b cookies.txt -X POST http://127.0.0.1:8002/orders \
  -H 'Content-Type: application/json' \
  -d '{"item_name":"Demo order","quantity":1}'

# list orders
curl -i -b cookies.txt http://127.0.0.1:8002/orders

# search audit
curl -i 'http://127.0.0.1:8004/audit/events?resourceType=ORDER&limit=20&offset=0' \
  -H 'X-Internal-Token: dev-audit-token'
```

## 4) Failure Injection Scenarios

### Scenario A: Worker forced failures + DLQ

1. Set in `infra/.env`:

```bash
NOTIFICATIONS_FAIL_MODE=always
```

2. Restart worker:

```bash
docker compose up -d --build notifications-worker
```

3. Create a new order (UI or curl).
4. Observe `/orders` notification state transition:
   - `pending` -> `retrying` -> `failed`
5. Observe worker logs:

```bash
docker compose logs -f notifications-worker
```

6. Inspect DLQ:

```bash
docker compose exec -T redis redis-cli XRANGE orders.dlq - +
```

What to highlight:

- controlled failure mode
- retries/backoff and eventual dead-letter behavior
- API surfaces status and attempts

### Scenario B: Recovery from failure mode

1. Set:

```bash
NOTIFICATIONS_FAIL_MODE=off
```

2. Restart worker:

```bash
docker compose up -d --build notifications-worker
```

3. Create another order.
4. Confirm status reaches `sent`.

## 5) Observability Talking Points

### Grafana (http://localhost:3001)

- Login: `admin` / `admin`
- Dashboards: open `RudikCloud Observability Overview`.
- Explore -> Tempo datasource:
  - query by service name (for example `orders-service`, `auth-service`, `flags-service`, `notifications-worker`, `audit-service-java`).

### Prometheus (http://localhost:9090)

Useful queries:

```text
up
otelcol_exporter_sent_spans
otelcol_exporter_send_failed_spans
```

### What to observe in traces during order creation

- request enters `orders-service`
- downstream calls to auth/flags/audit
- worker processing span (`notifications.process_event`) after event emission

## 6) Quick Health Verification

```bash
docker compose ps
curl -i http://127.0.0.1:8001/health
curl -i http://127.0.0.1:8002/health
curl -i http://127.0.0.1:8003/health
curl -i http://127.0.0.1:8004/health
curl -i http://127.0.0.1:9090/-/ready
curl -i http://127.0.0.1:3200/ready
```

## 7) Troubleshooting

### Dashboard says "Failed to fetch"

- Check auth CORS/cookie env in `infra/.env`.
- Ensure dashboard is accessed via `http://localhost:3000` (not mixed origins unless configured).

### Port collision on startup

- Stop local services that use `3000`, `3001`, `5432`, `6379`, `8001-8004`, `9090`, `3200`, `4317`, `4318`.

### Containers run but behavior is stale

```bash
docker compose down
docker compose up --build
```

### Need a full clean reset

```bash
make reset
```

### Migration-related startup issues

- Service containers run migrations on startup.
- If schema is inconsistent, reset volumes and restart from scratch.
