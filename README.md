## Infra (Local Dev Orchestration)

This repo runs the local RudikCloud stack for Milestone 0:

- PostgreSQL
- Redis
- `auth-service` (built from `../auth-service`)
- `dashboard` (built from `../dashboard`)
- `orders-service` (built from `../orders-service`)

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

## Ports

- Dashboard: `3000`
- Auth service: `8001`
- Orders service: `8002`
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
- `ORDERS_SERVICE_PORT`: Host port mapped to orders-service container `8002`.
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
- `ORDERS_AUTH_SERVICE_URL`: Internal auth-service URL used by orders-service for `/me` validation.
- `ORDERS_AUTH_REQUEST_TIMEOUT_SECONDS`: Timeout (seconds) for orders-service auth-service calls.

## Notes

- `auth-service` and `dashboard` need their own `Dockerfile` to build successfully.
- Milestone 1 auth defaults are set for local dev: `AUTH_CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000`, `AUTH_COOKIE_SECURE=false`, `AUTH_COOKIE_SAMESITE=lax`.
- This setup is intentionally dev-friendly and not production hardened.
