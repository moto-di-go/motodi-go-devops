# Follow-up Tickets To Create In GitHub

These tickets are local source text for GitHub issue creation. The actual issues and branch protections must be configured in GitHub.

## GATE-AUTH-001 - Gateway JWT and RBAC Enforcement

- Protect private `/api/v1/**` routes in the API Gateway.
- Keep health, docs and public Auth endpoints unauthenticated.
- Validate JWT issuer/audience and map roles/profiles for passenger, mototaxi, transporter, agency and admin access.
- Acceptance: private route without JWT returns 401, wrong role returns 403, public docs/Auth routes stay reachable, correlation id remains present.

## MOB-AUTH-001 - Mobile Authentication Screens

- Replace template/example entry screens with MOTO'DI GO register, OTP verify, login, refresh/logout and reset password flows.
- Store tokens with secure storage and call `/api/v1/auth/**` through the gateway.
- Acceptance: Cameroon phone registration can complete OTP verification, duplicate phone is displayed clearly, expired session redirects to login, reset password does not reveal account existence.

## ADMIN-RBAC-001 - Admin Dashboard API and RBAC

- Replace mock admin data with gateway API calls and role-protected admin routes.
- Add login/session handling and admin-only navigation states.
- Acceptance: unauthenticated users cannot access admin data, non-admin tokens are rejected, KYC/moderation/KPI views show API data and loading/error states.

## AI-METRICS-001 - Persistent AI Metrics

- Persist recommendation events and metrics in backend-core or a dedicated storage boundary.
- Expose operational metrics for admin KPI integration.
- Acceptance: AI recommendation events survive service restart, KPI endpoints can aggregate them, and tests cover persistence failure behavior.
