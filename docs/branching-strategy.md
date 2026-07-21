# Branching Strategy

## Branches

- `main`: production-ready code and release tags.
- `dev`: integration branch for the next delivery.
- `feature/<ticket-id>-short-name`: feature implementation.
- `fix/<ticket-id>-short-name`: bug fixes.
- `release/<version>`: final hardening before a release tag.

## Pull Requests

Every pull request should include:

- Linked ticket.
- Summary of changes.
- Tests run.
- Screenshots for UI changes.
- Migration or configuration notes when relevant.

## Releases

Release tags use semantic versioning:

```text
v0.1.0
v0.2.0
v1.0.0
```

Deployment pipelines should build immutable images and deploy by tag, not by mutable branch name.
