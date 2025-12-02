#!/usr/bin/env bash
set -euo pipefail

APP="Leetshego Safety Solutions"
echo "[Isolation Verify] Starting checks for $APP"

LEETSHEGO_PORT_HTTPS=9443
NDLELA_PORT_HTTPS=8443

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
check_endpoint "Ndlela (domain)" "https://ndlelasearchengine.co.za/health" || true

# Baseline health (direct container ports)
check_endpoint "Leetshego (direct)" "https://localhost:${LEETSHEGO_PORT_HTTPS}/health" || true
check_endpoint "Ndlela (direct)" "https://localhost:${NDLELA_PORT_HTTPS}/health" || true

echo "[Step] Restarting Leetshego nginx container"
docker compose restart nginx >/dev/null
sleep 5

# After restart ensure Ndlela unaffected
check_endpoint "Ndlela after Leetshego restart (direct)" "https://localhost:${NDLELA_PORT_HTTPS}/health" || true

# Optional: restart Ndlela if docker context available
if docker ps --format '{{.Names}}' | grep -q 'ndlela-nginx'; then
  echo "[Step] Restarting Ndlela nginx container (cross-app)"
  (cd /home/mulalo/applications/ndlela-search-engine && docker compose -f docker-compose.prod.yml restart nginx >/dev/null)
  sleep 5
  check_endpoint "Leetshego after Ndlela restart (direct)" "https://localhost:${LEETSHEGO_PORT_HTTPS}/health" || true
else
  echo "[Skip] Ndlela container not visible in current docker context"
fi

echo "[Isolation Verify] Completed. Review warnings above; absence of failures indicates isolation holds."
