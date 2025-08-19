#!/bin/sh
set -e

# Use Render-provided PORT if available (fallback to 3333)
ADMIN_PORT="${PORT:-3333}"

# Determine external URL for trusted origins
EXTERNAL_URL="${RENDER_EXTERNAL_URL:-}"
if [ -z "$EXTERNAL_URL" ] && [ -n "$RENDER_EXTERNAL_HOSTNAME" ]; then
  EXTERNAL_URL="https://${RENDER_EXTERNAL_HOSTNAME}"
fi
# Trim trailing slash if present
EXTERNAL_URL="${EXTERNAL_URL%/}"

# Safely update config.json using jq
TMP_CFG="/app/config.json.tmp"
# Start from current config
cp /app/config.json "$TMP_CFG"

# Update listen_url
jq \
  --arg port "$ADMIN_PORT" \
  '.admin_server.listen_url = ("0.0.0.0:" + $port)' \
  "$TMP_CFG" > "$TMP_CFG.1" && mv "$TMP_CFG.1" "$TMP_CFG"

# If EXTERNAL_URL is provided, set trusted_origins to that value when currently empty
if [ -n "$EXTERNAL_URL" ]; then
  jq \
    --arg url "$EXTERNAL_URL" \
    'if (.admin_server.trusted_origins | length) == 0 then .admin_server.trusted_origins = [$url] else . end' \
    "$TMP_CFG" > "$TMP_CFG.1" && mv "$TMP_CFG.1" "$TMP_CFG"
  echo "Configured trusted_origins to include: ${EXTERNAL_URL}"
else
  echo "RENDER_EXTERNAL_URL not set; leaving trusted_origins as-is"
fi

# Replace original config
mv "$TMP_CFG" /app/config.json

# Log effective binding
echo "Starting Gophish admin on 0.0.0.0:${ADMIN_PORT}"

# Start gophish
exec /app/gophish
