#!/usr/bin/env bash
set -euo pipefail
root=${FUSION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/fusion360}
export FUSION_HOME="$root"
libexec=${FUSION_LIBEXEC:?}
umask 077
mkdir -p "$root" "$root/logs"
proton=${FUSION_PROTON:?}
export STEAM_COMPAT_DATA_PATH="$root/compat"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
export STEAM_COMPAT_APP_ID=0 SteamAppId=0 SteamGameId=0
export PROTON_NO_SECCOMP=1 PROTON_USE_XALIA=0
export TZ=UTC
export WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS='--no-sandbox --disable-gpu --disable-gpu-compositing'
export QTWEBENGINE_DISABLE_SANDBOX=1
export QTWEBENGINE_CHROMIUM_FLAGS='--no-sandbox --use-gl=angle --use-angle=gl --disable-direct-composition'
export QSG_RHI_BACKEND=opengl
export NEUTRON_GRAPHICS_API=GLCORE
export WINEDLLOVERRIDES='bcp47langs=;winhttp=b;icuuc,icuin,icudt=n,b'
export BROWSER="$libexec/browser-request.sh"
export FUSION_RUNTIME_SOCKET_DIR="$root/runtime-tmp"
mkdir -p "$STEAM_COMPAT_DATA_PATH" "$root/logs" "$root/runtime-tmp"
chmod 700 "$root/runtime-tmp"
exec "${FUSION_RUNTIME:?}/bin/steam-run" "$proton" "${FUSION_PROTON_MODE:-runinprefix}" "$@"
