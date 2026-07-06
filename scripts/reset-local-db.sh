#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

echo "This will stop the local stack and remove Docker volumes:"
echo "- postgres_data for this Compose project"
echo "- minio_data for this Compose project"
printf "Type RESET to continue: "
read -r CONFIRMATION

if [ "$CONFIRMATION" != "RESET" ]; then
  echo "Aborted."
  exit 0
fi

if [ ! -f ".env" ]; then
  cp ".env.example" ".env"
fi

docker compose down --volumes
echo "Local data volumes removed."
