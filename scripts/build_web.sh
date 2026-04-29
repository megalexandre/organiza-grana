#!/usr/bin/env sh
set -eu

flutter build web --release \
  --dart-define=API_BASE_URL=__API_BASE_URL__
