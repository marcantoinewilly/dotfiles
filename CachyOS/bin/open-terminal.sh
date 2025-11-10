#!/usr/bin/env bash
set -euo pipefail
# Fast terminal opener for Niri MOD+RETURN: reuse existing kitty instance when possible.
# Falls back to starting a new instance, and finally to $TERMINAL/xterm if needed.

launch_cmd() {
  sh -lc "$*"
}

if command -v kitty >/dev/null 2>&1; then
  # If a kitty instance is running, ask it to launch a new OS window (fast).
  if kitty @ ls >/dev/null 2>&1; then
    exec kitty @ launch --type os-window
  fi
  # Otherwise, start (or reuse) a single instance.
  exec kitty -1
fi

# Fallbacks
if [ -n "${TERMINAL:-}" ] && command -v "$TERMINAL" >/dev/null 2>&1; then
  exec "$TERMINAL"
fi
exec xterm
