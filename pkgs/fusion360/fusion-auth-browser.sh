#!/usr/bin/env bash
set -euo pipefail
root=${FUSION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/fusion360}
libexec=${FUSION_LIBEXEC:?}
umask 077
mkdir -p "$root" "$root/logs"
umask 077
mkdir -p "$root/auth-browser-profile"
exec "${FUSION_FIREFOX:?}" --no-remote \
  --name fusion-auth-browser --class fusion-auth-browser \
  --profile "$root/auth-browser-profile" "$@"
