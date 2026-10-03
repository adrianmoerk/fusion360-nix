#!/usr/bin/env bash
set -euo pipefail
root=${FUSION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/fusion360}
libexec=${FUSION_LIBEXEC:?}
umask 077
mkdir -p "$root" "$root/logs"
umask 077
mkdir -p "$root/browser-requests"
case "${1:-}" in
  https://*|http://*)
    request=$(mktemp "$root/browser-requests/url.XXXXXX.partial")
    printf '%s' "$1" > "$request"
    mv "$request" "${request%.partial}.ready"
    ;;
  *) exit 1 ;;
esac
