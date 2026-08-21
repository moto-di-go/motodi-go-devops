#!/usr/bin/env python3
"""Internal sidecar: status + on-demand Photon index refresh via Docker."""

from __future__ import annotations

import json
import os
import subprocess
import threading
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PROJECT = os.environ.get("COMPOSE_PROJECT_NAME", "motodigo")
SERVICE = os.environ.get("PHOTON_SERVICE", "photon")
PHOTON_STATUS_URL = os.environ.get("PHOTON_STATUS_URL", "http://photon:2322/status")
PORT = int(os.environ.get("PORT", "8080"))

_lock = threading.Lock()
_updating = False
_last_error: str | None = None


def _docker(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["docker", *args],
        capture_output=True,
        text=True,
        check=False,
    )


def _container_id() -> str | None:
    result = _docker(
        "ps",
        "-q",
        "--filter",
        f"label=com.docker.compose.project={PROJECT}",
        "--filter",
        f"label=com.docker.compose.service={SERVICE}",
    )
    if result.returncode != 0:
        return None
    lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    return lines[0] if lines else None


def _exec(container: str, *command: str) -> subprocess.CompletedProcess[str]:
    return _docker("exec", container, *command)


def _temp_busy(container: str) -> bool:
    result = _exec(container, "sh", "-c", "ls -A /photon/data/temp 2>/dev/null")
    return bool(result.stdout.strip())


def _photon_ready() -> bool:
    try:
        with urllib.request.urlopen(PHOTON_STATUS_URL, timeout=3) as response:
            return 200 <= response.status < 300
    except (urllib.error.URLError, TimeoutError, ValueError):
        return False


def _status_payload() -> tuple[int, dict[str, object]]:
    container = _container_id()
    updating = _updating or (container is not None and _temp_busy(container))
    ready = _photon_ready()
    if container is None:
        return 200, {
            "ready": False,
            "updating": updating,
            "manualUpdateAvailable": False,
            "message": "Conteneur Photon introuvable.",
        }
    if updating:
        message = "Mise a jour de l'index Photon en cours."
    elif ready:
        message = "Index Photon pret. Les mises a jour automatiques sont desactivees."
    else:
        message = "Photon ne repond pas encore (demarrage ou permutation d'index)."
    return 200, {
        "ready": ready,
        "updating": updating,
        "manualUpdateAvailable": True,
        "message": message,
        "lastError": _last_error,
    }


def _run_update(container: str) -> None:
    global _updating, _last_error
    try:
        result = _exec(
            container,
            "/photon/.venv/bin/python",
            "-c",
            "from src.update import run_update; run_update('PARALLEL')",
        )
        if result.returncode != 0:
            _last_error = (result.stderr or result.stdout or "Echec de la mise a jour Photon.").strip()
            return
        restart = _docker("restart", container)
        if restart.returncode != 0:
            _last_error = (restart.stderr or "Echec du redemarrage Photon apres permutation d'index.").strip()
            return
        _last_error = None
    except Exception as exc:  # noqa: BLE001
        _last_error = str(exc)
    finally:
        with _lock:
            _updating = False


def _start_update() -> tuple[int, dict[str, object]]:
    global _updating, _last_error
    container = _container_id()
    if container is None:
        return 503, {
            "ready": False,
            "updating": False,
            "manualUpdateAvailable": False,
            "message": "Conteneur Photon introuvable.",
        }
    with _lock:
        if _updating or _temp_busy(container):
            return 409, {
                "ready": _photon_ready(),
                "updating": True,
                "manualUpdateAvailable": True,
                "message": "Une mise a jour Photon est deja en cours. Le telechargement actuel n'est pas interrompu.",
            }
        _updating = True
        _last_error = None
    thread = threading.Thread(target=_run_update, args=(container,), daemon=True)
    thread.start()
    return 202, {
        "ready": _photon_ready(),
        "updating": True,
        "manualUpdateAvailable": True,
        "message": "Telechargement de l'index Photon lance en arriere-plan (~1.7 Go, 15 a 40 min).",
    }


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format: str, *args: object) -> None:  # noqa: A003
        print(f"photon-control {self.address_string()} {format % args}")

    def _send(self, status: int, payload: dict[str, object]) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802
        if self.path in {"/health", "/"}:
            self._send(200, {"status": "ok"})
            return
        if self.path == "/status":
            self._send(*_status_payload())
            return
        self._send(404, {"message": "Not found"})

    def do_POST(self) -> None:  # noqa: N802
        if self.path in {"/update", "/status/update"}:
            self._send(*_start_update())
            return
        self._send(404, {"message": "Not found"})


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"photon-control listening on 0.0.0.0:{PORT}")
    server.serve_forever()
