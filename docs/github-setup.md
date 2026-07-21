# GitHub Setup

Create repositories:

- `motodi-go-mobile`
- `motodi-go-backend-core`
- `motodi-go-backend-ai`
- `motodi-go-api-gateway`
- `motodi-go-admin-dashboard`
- `motodi-go-devops`

## Protections

Protect `main` and `dev`:

- Pull request required.
- At least one approving review.
- Required checks per repository:
  - backend-core: `Build and Unit Tests`, `Auth Integration Tests`, `Secret Scan`.
  - api-gateway: `Build and Tests`, `Secret Scan`.
  - backend-ai: `Quality and Tests`, `Secret Scan`.
  - admin-dashboard: `Check and Build`, `Secret Scan`.
  - devops: `Docker Compose Config`, `Docker Smoke`, `Secret Scan`.
  - mobile: existing analyze/test/build and secret/dependency checks.
- No force push.
- Delete branch after merge.

## Labels

Import labels from `github/labels.yml` using the GitHub CLI or an organization label sync tool.

## Issue Templates

Copy or sync `github/issue-templates/*.yml` into each repository under `.github/ISSUE_TEMPLATE/`.

## Milestones

Recommended milestones:

- `MVP`
- `V1.1`
- `V1.2`
