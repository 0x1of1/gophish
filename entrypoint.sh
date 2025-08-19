#!/bin/sh
set -e

# Use Render-provided PORT if available (fallback to 3333)
ADMIN_PORT="${PORT:-3333}"

# Rewrite admin_server.listen_url in config.json to bind to $PORT
# Assumes the existing value contains ":3333" which we replace
sed -i "s/\"listen_url\": \"0.0.0.0:3333\"/\"listen_url\": \"0.0.0.0:${ADMIN_PORT}\"/" /app/config.json

# Log effective binding
echo "Starting Gophish admin on 0.0.0.0:${ADMIN_PORT}"

# Start gophish
exec /app/gophish
