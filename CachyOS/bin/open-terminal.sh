#!/usr/bin/env bash
set -euo pipefail

launch_cmd() {
  sh -lc "$*"
}

if command -v kitty >/dev/null 2>&1; then
  if kitty @ ls >/dev/null 2>&1; then
    exec kitty @ launch --type os-window
  fi
  exec kitty -1
fi

if [ -n "${TERMINAL:-}" ] && command -v "$TERMINAL" >/dev/null 2>&1; then
  exec "$TERMINAL"
fi
exec xterm
