# Environments

MOTO'DI GO uses three environment levels:

- `local`: developer workstation with Docker Compose, local ports, placeholder values.
- `staging`: VPS or shared environment for integration tests before release.
- `production`: public environment with TLS, backups, monitoring, and protected secrets.

## Local

Run from `motodi-go-devops`:

```bash
cp .env.example .env
docker compose up --build
```

Default local endpoints:

- API Gateway: `http://localhost:8080`
- Admin dashboard: `http://localhost:3000`
- Backend core: `http://localhost:8081`
- Backend AI: `http://localhost:8000`
- PostgreSQL/PostGIS: `localhost:5432`
- MinIO API: `http://localhost:9000`
- MinIO console: `http://localhost:9001`

## Staging

Use the staging override:

```bash
docker compose -f docker-compose.yml -f docker-compose.staging.yml config
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

Staging should use images from the registry and environment variables injected by the host or CI.

## Production

Production must not use `.env.example` values. Required controls:

- TLS certificates installed outside Git.
- Database backups tested before releases.
- GitHub Actions deployment gated by tests and review.
- Healthchecks for gateway, core, AI and dashboard.

