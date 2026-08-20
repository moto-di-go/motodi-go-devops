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

## CI secrets (Docker Smoke)

`Docker Smoke` checks out the sibling application repositories and builds them with Compose. Those repos are private, so the default `GITHUB_TOKEN` of `motodi-go-devops` cannot read them. GitHub then answers `404 Not Found` on `GET /repos/{owner}/{repo}` while checkout tries to resolve the default branch.

Create a fine-grained PAT (or a GitHub App installation token) with `contents: read` on:

- `motodi-go-backend-core`
- `motodi-go-backend-ai`
- `motodi-go-api-gateway`
- `motodi-go-admin-dashboard`

Store it as the repository or organization secret `CROSS_REPO_READ_TOKEN` on `motodi-go-devops`. Pinning `ref: main` without this token does not fix the 404.

The smoke job checks out sibling repos at the PR base branch (`dev` / `main`) or at the pushed branch. Keep those branch names in sync across the application repositories.

## Labels

Import labels from `github/labels.yml` using the GitHub CLI or an organization label sync tool.

## Issue Templates

Copy or sync `github/issue-templates/*.yml` into each repository under `.github/ISSUE_TEMPLATE/`.

## Milestones

Recommended milestones:

- `MVP`
- `V1.1`
- `V1.2`
