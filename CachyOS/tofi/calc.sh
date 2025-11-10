#!/usr/bin/env bash
set -euo pipefail
choice=$(tofi-run --prompt-text "" --require-match=false || true)
[ -z "${choice:-}" ] && exit 0

trimmed=$(printf '%s' "$choice" | sed 's/^\s\+//;s/\s\+$//')

maybe_calc=0
if printf '%s' "$trimmed" | grep -Eq '^='; then
  maybe_calc=1
elif printf '%s' "$trimmed" | grep -Eq '[0-9][[:space:]]*[\+\-\*/\^%()]'; then
  maybe_calc=1
fi

if [ "$maybe_calc" -eq 1 ]; then
  expr="$trimmed"
  expr=${expr#=}
  expr=$(printf '%s' "$expr" | sed 's/^\s\+//;s/\s\+$//')
  if [ -z "$expr" ]; then
    exit 0
  fi
  result=""
  if command -v bc >/dev/null 2>&1; then
    result=$(printf '%s\n' "$expr" | bc -l 2>/dev/null || true)
    result=$(printf '%s' "$result" | tr -d '\n' || true)
  fi
  if [ -z "$result" ] && command -v python3 >/dev/null 2>&1; then
    result=$(python3 - "$expr" 2>/dev/null <<'PY'
import sys, math
expr = sys.argv[1]
ns = {k:getattr(math,k) for k in dir(math) if not k.startswith('_')}
ns.update({'pi': math.pi, 'e': math.e})
try:
    val = eval(expr, {'__builtins__': {}}, ns)
    if isinstance(val, float):
        print(f"{val:.10g}")
    else:
        print(val)
except Exception:
    sys.exit(1)
PY
    ) || true
  fi
  if [ -z "$result" ]; then
    command -v notify-send >/dev/null 2>&1 && notify-send "Tofi Calculator" "Could not evaluate: $expr"
    exit 1
  fi
  command -v wl-copy >/dev/null 2>&1 && printf '%s' "$result" | wl-copy
  command -v notify-send >/dev/null 2>&1 && notify-send "Tofi Calculator" "$expr = $result"
  exit 0
fi

cmd="$trimmed"


run_in_terminal=0
if printf '%s' "$cmd" | grep -Eq '^(term:|!|t\s)'; then
  run_in_terminal=1
  cmd=$(printf '%s' "$cmd" | sed -E 's/^(term:|!|t\s+)//')
fi

if [ "$run_in_terminal" -eq 0 ]; then
  first_word=$(printf '%s' "$cmd" | awk '{print $1}')
  case "$first_word" in
    nmtui|htop|btop|lazygit|nnn|ranger|yazi|vifm|mc|alsamixer|ncmpcpp|pulsemixer|top|tig)
      run_in_terminal=1;
    ;;
  esac
fi

if [ "$run_in_terminal" -eq 1 ]; then
  if [ -n "${TERMINAL:-}" ] && command -v "$TERMINAL" >/dev/null 2>&1; then
    exec "$TERMINAL" -e sh -lc "$cmd"
  fi
  if command -v kitty >/dev/null 2>&1; then exec kitty -e sh -lc "$cmd"; fi
  if command -v ghostty >/dev/null 2>&1; then exec ghostty -e sh -lc "$cmd"; fi
  if command -v foot >/dev/null 2>&1; then exec foot -e sh -lc "$cmd"; fi
  if command -v alacritty >/dev/null 2>&1; then exec alacritty -e sh -lc "$cmd"; fi
  if command -v wezterm >/dev/null 2>&1; then exec wezterm start -- sh -lc "$cmd"; fi
  if command -v gnome-terminal >/dev/null 2>&1; then exec gnome-terminal -- sh -lc "$cmd"; fi
  if command -v kgx >/dev/null 2>&1; then exec kgx -- sh -lc "$cmd"; fi
  if command -v konsole >/dev/null 2>&1; then exec konsole -e sh -lc "$cmd"; fi
  if command -v xterm >/dev/null 2>&1; then exec xterm -e sh -lc "$cmd"; fi
fi

exec sh -lc "$cmd"
