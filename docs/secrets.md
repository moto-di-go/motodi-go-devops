# Secrets Policy

Do not commit real secrets to this repository.

Examples of sensitive values:

- Database passwords.
- JWT signing keys.
- OTP pepper values.
- SMS provider API keys.
- Mobile Money API credentials.
- Mobile Money callback HMAC secrets (`MTN_CALLBACK_HMAC_SECRET`, `ORANGE_CALLBACK_HMAC_SECRET`, `AGGREGATOR_CALLBACK_HMAC_SECRET`).
- Push notification credentials.
- TLS private keys.
- Object storage access keys.

## Allowed in Git

- `.env.example` with placeholders.
- Documentation naming required variables.
- Local-only dummy values clearly marked as placeholders.

## Required Storage

Use one of these for real values:

- GitHub Actions Secrets.
- VPS environment variables.
- Docker secret files mounted outside the repository.
- A managed secret store when available.

## Rotation

Rotate secrets after:

- Suspected exposure.
- Team member offboarding.
- Provider credential regeneration.
- Production incident.

## Validation

Before release, run a secret scan and manually review changes touching:

- `.env*`
- Docker Compose files.
- CI/CD workflows.
- Nginx and TLS configuration.
