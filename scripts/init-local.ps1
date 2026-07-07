param(
  [switch]$Detached
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw "Docker is required but was not found in PATH."
}

docker compose version | Out-Null

if (-not (Test-Path -LiteralPath ".env")) {
  Copy-Item -LiteralPath ".env.example" -Destination ".env"
  Write-Host "Created .env from .env.example. Review placeholder values before production use."
}

$argsList = @("compose", "up", "--build")
if ($Detached) {
  $argsList += "-d"
}

& docker @argsList

