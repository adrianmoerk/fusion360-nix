#!/usr/bin/env bash
set -euo pipefail
root=${FUSION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/fusion360}
export FUSION_HOME="$root"
umask 077
mkdir -p "$root/logs" "$root/downloads"
exec 9>"$root/launch.lock"
if ! flock -n 9; then
  echo 'Close Fusion before running its installer.' >&2
  exit 1
fi
if [[ ! -f "$root/compat/pfx/system.reg" ]]; then
  FUSION_PROTON_MODE=run bash "$FUSION_LIBEXEC/fusion-proton.sh" wineboot -u 9>&- >> "$root/logs/install.log" 2>&1
fi
runner="$FUSION_LIBEXEC/fusion-proton.sh"
printf 'Preparing browser integration…\n'
bash "$runner" reg add 'HKCU\Software\Wine\WineBrowser' /v Browsers /t REG_SZ /d "$FUSION_LIBEXEC/browser-request.sh" /f 9>&- >> "$root/logs/install.log" 2>&1
bash "$runner" reg add 'HKCU\Software\Wine\AppDefaults\msedgewebview2.exe' /v Version /t REG_SZ /d win8 /f 9>&- >> "$root/logs/install.log" 2>&1
webview="$root/compat/pfx/drive_c/Program Files (x86)/Microsoft/EdgeWebView/Application"
if ! find "$webview" -name msedgewebview2.exe -type f -print -quit 2>/dev/null | grep -q .; then
  printf 'Downloading and installing Microsoft WebView2…\n'
  bootstrap="$root/downloads/MicrosoftEdgeWebview2Setup.exe"
  curl --fail --location --retry 3 'https://go.microsoft.com/fwlink/p/?LinkId=2124703' -o "$bootstrap"
  bash "$runner" "$bootstrap" /silent /install 9>&- >> "$root/logs/install.log" 2>&1
  # The bootstrapper can return before its download/install worker finishes.
  for attempt in {1..60}; do
    if find "$webview" -name msedgewebview2.exe -type f -print -quit 2>/dev/null | grep -q .; then break; fi
    sleep 2
  done
  if ! find "$webview" -name msedgewebview2.exe -type f -print -quit 2>/dev/null | grep -q .; then
    echo "WebView2 installation did not complete. See $root/logs/install.log" >&2
    exit 1
  fi
fi
printf 'Downloading and installing Autodesk Fusion…\n'
installer="$root/downloads/FusionClientDownloader.exe"
curl --fail --location --retry 3 'https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Client%20Downloader.exe' -o "$installer"
python3 "$FUSION_LIBEXEC/browser-listener.py" 9>&- >> "$root/logs/browser.log" 2>&1 &
listener=$!
trap 'kill "$listener" 2>/dev/null || true' EXIT
bash "$FUSION_LIBEXEC/fusion-proton.sh" "$installer" "$@" 9>&- >> "$root/logs/install.log" 2>&1

python3 "$FUSION_LIBEXEC/prepare-prefix.py"
printf 'Installation complete. Run fusion360 and sign in with your Autodesk account.\n'
