$ErrorActionPreference = "Stop"
$Data = Join-Path (Split-Path -Parent $PSScriptRoot) "data"
New-Item -ItemType Directory -Force -Path $Data | Out-Null

$PbfUrl = if ($env:VALHALLA_TILE_URL) { $env:VALHALLA_TILE_URL } else { "https://download.geofabrik.de/africa/cameroon-latest.osm.pbf" }

Write-Host "Downloading Cameroon OSM extract (Geofabrik)..."
Invoke-WebRequest -Uri $PbfUrl -OutFile (Join-Path $Data "cameroon-latest.osm.pbf")

if ($env:PHOTON_REGION) {
    $PhotonRegion = $env:PHOTON_REGION
} else {
    $PhotonRegion = "africa"
}

Write-Host "Photon bootstrap is handled by the container image via PHOTON_REGION."
Write-Host "Current default region: $PhotonRegion"

Write-Host "Done. Files in $Data"
Write-Host "Start geo services with:"
Write-Host "  docker compose -f docker-compose.yml -f docker-compose.geo.yml up --build"
