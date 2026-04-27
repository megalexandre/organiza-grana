#!/usr/bin/env sh
set -eu

# Optional runtime injection for web builds that use __API_BASE_URL__ placeholder.
if [ -n "${API_BASE_URL:-}" ]; then
  echo "[entrypoint] Substituindo http://localhost:3000 por $API_BASE_URL nas saídas do build web."
  find /usr/share/nginx/html -type f \( -name "*.js" -o -name "*.html" \) -print0 \
    | xargs -0 sed -i "s|http://localhost:3000|${API_BASE_URL}|g"
fi

exec "$@"
