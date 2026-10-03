#!/usr/bin/env bash
set -euo pipefail
root=${FUSION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/fusion360}
libexec=${FUSION_LIBEXEC:?}
umask 077
mkdir -p "$root" "$root/logs"
umask 077
mkdir -p "$root/logs"
uri=${1:-}
scheme=${uri%%:*}
printf '%s callback received (scheme=%s)\n' "$(date -Is)" "$scheme" >> "$root/logs/callback.log"
if [[ "${FUSION_CALLBACK_PROBE:-0}" == 1 && "$uri" == adskidmgr://codex-handler-check ]]; then
  printf '%s desktop handoff probe succeeded\n' "$(date -Is)" >> "$root/logs/callback.log"
  exit 0
fi
case "${1:-}" in adsk:*|adskidmgr:*|adsk.idmgr:*) ;; *) exit 1 ;; esac
mapfile -t managers < <(find "$root/compat/pfx/drive_c" -name AdskIdentityManager.exe -type f)
(( ${#managers[@]} == 1 ))
printf '%s forwarding to Identity Manager\n' "$(date -Is)" >> "$root/logs/callback.log"
exec bash "$libexec/fusion-proton.sh" "${managers[0]}" "$1"
