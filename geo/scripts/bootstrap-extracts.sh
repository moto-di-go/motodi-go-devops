#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA="${ROOT}/data"
mkdir -p "${DATA}"

PBF_URL="${VALHALLA_TILE_URL:-https://download.geofabrik.de/africa/cameroon-latest.osm.pbf}"

echo "Downloading Cameroon OSM extract (Geofabrik)..."
curl -L --fail --retry 3 -o "${DATA}/cameroon-latest.osm.pbf" "${PBF_URL}"

echo "Photon bootstrap is handled by the container image via PHOTON_REGION."
echo "Current default region: ${PHOTON_REGION:-africa}"

echo "Done. Files in ${DATA}"
echo "Start geo services with:"
echo "  docker compose -f docker-compose.yml -f docker-compose.geo.yml up --build"
