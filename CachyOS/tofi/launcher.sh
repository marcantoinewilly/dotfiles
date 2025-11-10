#!/usr/bin/env bash
set -euo pipefail

selection=$(compgen -c | sort -u | tofi --prompt-text "Run" || true)
[ -z "${selection}" ] && exit 0

niri msg spawn -- sh -lc "${selection}"
