#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but was not found in PATH." >&2
  exit 1
fi

docker compose version >/dev/null

if [ ! -f ".env" ]; then
  cp ".env.example" ".env"
  echo "Created .env from .env.example. Review placeholder values before production use."
fi

docker compose up --build "$@"

