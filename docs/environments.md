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

Open-source map stack (Photon, Valhalla, local style endpoint):

```bash
docker compose -f docker-compose.yml -f docker-compose.geo.yml up --build
```

See `docs/geo-stack.md` for keys, costs and extract URLs.

Default local endpoints:

- API Gateway: `http://localhost:8080`
- Admin dashboard: `http://localhost:3000`
- Backend core: `http://localhost:8081`
- Backend AI: `http://localhost:8000`
- PostgreSQL/PostGIS: `localhost:5432`
- MinIO API: `http://localhost:9000`
- MinIO console: `http://localhost:9001`
- Photon (geo overlay): `http://localhost:2322`
- Valhalla (geo overlay): `http://localhost:8002`
- Tiles style (geo overlay): `http://localhost:8088/styles/motodigo.json`

## Staging

Use the staging override:

```bash
docker compose -f docker-compose.yml -f docker-compose.staging.yml config
docker compose --env-file .env.staging -f docker-compose.yml -f docker-compose.staging.yml up -d
```

Staging should use images from the registry and environment variables injected by the host or CI.
The staging override intentionally requires external values for database, object storage, JWT, OTP/SMS and CORS settings.

OTP SMS in staging is sent only through Africa's Talking Bulk (`OTP_PROVIDER=africas-talking`).
The backend still generates and validates OTP codes; `OTP_PROVIDER=log` is rejected outside `local`/`test`.
Copy `.env.staging.example` to `.env.staging` (gitignored) and inject real `AFRICAS_TALKING_USERNAME`, `AFRICAS_TALKING_API_KEY` and `AFRICAS_TALKING_SENDER_ID`.

Set `AFRICAS_TALKING_BASE_URL=https://api.africastalking.com` only (host, no `/version1/messaging/bulk` suffix). The backend appends that path itself.

### Sender ID

Use `AFRICAS_TALKING_SENDER_ID=AFRICASTKNG` until Africa's Talking approves the custom alphanumeric sender (`MOTODIGO`). Switching too early returns `402 InvalidSenderId`. After approval, change the variable in local and staging env files and send one test SMS. No code change is required.

### API key rotation

If an Africa's Talking API key was ever pasted in chat, a ticket, or a shared screenshot, rotate it before staging or production:

1. Open the Africa's Talking dashboard, Settings, API Key, and generate a new key.
2. Replace `AFRICAS_TALKING_API_KEY` in `motodi-go-backend-core/.env` (local `mvn` runs) and in `motodi-go-devops/.env` or `.env.staging` (Compose).
3. Restart backend-core so the new key is loaded.
4. Confirm the old key no longer works.

Do not commit `.env` files. Never log the API key or the OTP message body.

### Local real SMS

For a local smoke test against a Cameroonian number, set `OTP_PROVIDER=africas-talking` in `motodi-go-backend-core/.env` (profile `local` still allows this). Register via `POST /api/v1/auth/register`, then verify with `POST /api/v1/auth/otp/verify`. Switch back to `OTP_PROVIDER=log` if you do not want live SMS on every local registration.

## Production

Production must not use `.env.example` values. Required controls:

- TLS certificates installed outside Git.
- Database backups tested before releases.
- GitHub Actions deployment gated by tests and review.
- Healthchecks for gateway, core, AI and dashboard.
