#!/usr/bin/env bash
# ============================================================
# Health check script for Evolution API
# Returns exit 0 if API is responding, 1 otherwise
# ============================================================
set -euo pipefail

BASE_URL="${1:-http://localhost:8080}"

if wget -qO- "${BASE_URL}/" > /dev/null 2>&1; then
  echo "✅ Evolution API is healthy at ${BASE_URL}"
  exit 0
else
  echo "❌ Evolution API is NOT responding at ${BASE_URL}"
  exit 1
fi
