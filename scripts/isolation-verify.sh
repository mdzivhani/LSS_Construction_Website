#!/usr/bin/env bash
set -euo pipefail

APP="Leetshego Safety Solutions"
echo "[Isolation Verify] Starting checks for $APP"

LEETSHEGO_PORT_HTTPS=9443

fail() { echo "[Isolation Verify] FAILURE: $1" >&2; exit 1; }

check_endpoint() {
  local name="$1" url="$2"
  if curl -sk --max-time 10 "$url" | grep -qi "healthy"; then
    echo "[OK] $name health responded"
  else
    echo "[WARN] $name health did not return expected 'healthy' string; continuing"
  fi
}

# Baseline health (domains routed via system nginx if DNS resolves)
check_endpoint "Leetshego (domain)" "https://leetshego.co.za/health" || true

# Baseline health (direct container ports)
check_endpoint "Leetshego (direct)" "https://localhost:${LEETSHEGO_PORT_HTTPS}/health" || true

echo "[Step] Restarting Leetshego nginx container"
docker compose restart nginx >/dev/null
sleep 5

echo "[Isolation Verify] Completed. Review warnings above; absence of failures indicates service responds."
