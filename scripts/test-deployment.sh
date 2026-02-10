#!/usr/bin/env bash
# ============================================================
# Evolution API — Deployment Test Script
#
# Usage:
#   ./scripts/test-deployment.sh <BASE_URL> <API_KEY>
#
# Example:
#   ./scripts/test-deployment.sh https://your-app.up.railway.app 429683C4C977415CAAFCCE10F7D57E11
# ============================================================
set -euo pipefail

BASE_URL="${1:?Usage: $0 <BASE_URL> <API_KEY>}"
API_KEY="${2:?Usage: $0 <BASE_URL> <API_KEY>}"
INSTANCE_NAME="test_instance"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}✅ PASS${NC} — $1"; }
fail() { echo -e "${RED}❌ FAIL${NC} — $1"; }
info() { echo -e "${YELLOW}ℹ️  INFO${NC} — $1"; }

echo ""
echo "========================================"
echo "  Evolution API — Deployment Tests"
echo "  URL: ${BASE_URL}"
echo "========================================"
echo ""

# ---- 1. Health Check ----
echo "1️⃣  Health Check (/ping)"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/")
if [ "$HTTP_CODE" = "200" ]; then
  pass "Health check returned 200"
else
  fail "Health check returned ${HTTP_CODE}"
  echo "   API may not be running. Aborting."
  exit 1
fi

# ---- 2. Create Instance ----
echo ""
echo "2️⃣  Create Instance"
CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}/instance/create" \
  -H "Content-Type: application/json" \
  -H "apikey: ${API_KEY}" \
  -d "{
    \"instanceName\": \"${INSTANCE_NAME}\",
    \"integration\": \"WHATSAPP-BAILEYS\",
    \"qrcode\": true
  }")

if echo "$CREATE_RESPONSE" | grep -qi "instance"; then
  pass "Instance created successfully"
  info "Response: $(echo "$CREATE_RESPONSE" | head -c 200)"
else
  fail "Instance creation failed"
  info "Response: ${CREATE_RESPONSE}"
fi

# ---- 3. Connection State ----
echo ""
echo "3️⃣  Connection State"
STATE_RESPONSE=$(curl -s -X GET "${BASE_URL}/instance/connectionState/${INSTANCE_NAME}" \
  -H "apikey: ${API_KEY}")

if echo "$STATE_RESPONSE" | grep -qi "state"; then
  pass "Connection state retrieved"
  info "State: ${STATE_RESPONSE}"
else
  fail "Could not retrieve connection state"
  info "Response: ${STATE_RESPONSE}"
fi

# ---- 4. Get QR Code ----
echo ""
echo "4️⃣  Connect / QR Code"
QR_RESPONSE=$(curl -s -X GET "${BASE_URL}/instance/connect/${INSTANCE_NAME}" \
  -H "apikey: ${API_KEY}")

if echo "$QR_RESPONSE" | grep -qi "base64\|qrcode\|pairingCode"; then
  pass "QR code / pairing code available"
  info "Scan the QR code with your WhatsApp to connect"
else
  info "QR response (may need WhatsApp scan): $(echo "$QR_RESPONSE" | head -c 200)"
fi

# ---- 5. Fetch Groups (will be empty until WhatsApp is connected) ----
echo ""
echo "5️⃣  Fetch All Groups"
GROUPS_RESPONSE=$(curl -s -X GET "${BASE_URL}/group/fetchAllGroups/${INSTANCE_NAME}?getParticipants=false" \
  -H "apikey: ${API_KEY}")

if echo "$GROUPS_RESPONSE" | grep -qi "error\|unauthorized"; then
  info "Groups fetch returned error (expected if not connected): $(echo "$GROUPS_RESPONSE" | head -c 200)"
else
  pass "Groups endpoint responded"
  info "Response: $(echo "$GROUPS_RESPONSE" | head -c 200)"
fi

# ---- 6. Test Send Media (dry-run — will fail without connection, but validates endpoint) ----
echo ""
echo "6️⃣  Send Media (dry-run, expects failure without WhatsApp connection)"
SEND_RESPONSE=$(curl -s -X POST "${BASE_URL}/message/sendMedia/${INSTANCE_NAME}" \
  -H "Content-Type: application/json" \
  -H "apikey: ${API_KEY}" \
  -d '{
    "number": "120363000000000000@g.us",
    "mediatype": "image",
    "media": "https://via.placeholder.com/300",
    "caption": "Test image from Evolution API",
    "mimetype": "image/png",
    "fileName": "test.png"
  }')

if echo "$SEND_RESPONSE" | grep -qi "error\|not connected\|Bad Request"; then
  info "Send media endpoint responded (expected error without connection)"
  info "Response: $(echo "$SEND_RESPONSE" | head -c 200)"
else
  pass "Send media returned unexpected success"
  info "Response: $(echo "$SEND_RESPONSE" | head -c 200)"
fi

# ---- Summary ----
echo ""
echo "========================================"
echo "  Tests Complete"
echo "  Next step: Scan the QR code to"
echo "  connect your WhatsApp account"
echo "========================================"
echo ""
