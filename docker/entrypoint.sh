#!/usr/bin/env sh
set -eu

if [ -n "${API_BASE_URL:-}" ]; then
  echo "[entrypoint] Substituindo __API_BASE_URL__ por $API_BASE_URL"
  find /usr/share/nginx/html -type f \( -name "*.js" -o -name "*.html" \) -print0 \
    | xargs -0 sed -i "s|__API_BASE_URL__|${API_BASE_URL}|g"
fi

exec "$@"
