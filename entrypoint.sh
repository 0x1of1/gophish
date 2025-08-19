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

# Rewrite admin_server.listen_url in config.json to bind to $PORT
# Use | as sed delimiter and escape replacement content
SED_LISTEN_FROM='"listen_url": "0.0.0.0:3333"'
SED_LISTEN_TO='"listen_url": "0.0.0.0:'"${ADMIN_PORT}"'""'
sed -i "s|$SED_LISTEN_FROM|$SED_LISTEN_TO|" /app/config.json || true

# If we have an external URL, set trusted_origins accordingly
if [ -n "$EXTERNAL_URL" ]; then
  # JSON-escape any double quotes in EXTERNAL_URL (unlikely) and use sed with | delimiter
  ESC_URL="$EXTERNAL_URL"
  # Replace an empty array with the external URL; if already set, leave as-is
  if grep -q '"trusted_origins": \[\]' /app/config.json; then
    sed -i "s|\"trusted_origins\": \[\]|\"trusted_origins\": [\"$ESC_URL\"]|" /app/config.json || true
  fi
  echo "Configured trusted_origins to include: ${EXTERNAL_URL}"
else
  echo "RENDER_EXTERNAL_URL not set; leaving trusted_origins as-is"
fi

# Log effective binding
echo "Starting Gophish admin on 0.0.0.0:${ADMIN_PORT}"

# Start gophish
exec /app/gophish
