# GitHub Setup

Create repositories:

- `motodi-go-mobile`
- `motodi-go-backend-core`
- `motodi-go-backend-ai`
- `motodi-go-api-gateway`
- `motodi-go-admin-dashboard`
- `motodi-go-devops`

## Protections

Protect `main` and `develop`:

- Pull request required.
- At least one approving review.
- Required checks: build, tests, lint, dependency or secret scan when available.
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

