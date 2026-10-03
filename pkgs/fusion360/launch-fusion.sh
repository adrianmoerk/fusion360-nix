#!/usr/bin/env bash
set -euo pipefail
root=${FUSION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/fusion360}
export FUSION_HOME="$root"
libexec=${FUSION_LIBEXEC:?}
umask 077
mkdir -p "$root" "$root/logs"
exec 9>"$root/launch.lock"
if ! flock -n 9; then
  printf 'Fusion is already running from this launcher.\n' >&2
  exit 0
fi
if [[ ! -d "$root/compat/pfx" ]]; then
  echo "Fusion is not installed. Run fusion360-install first." >&2
  exit 1
fi
production="$root/compat/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/webdeploy/production"
mapfile -t executables < <(find "$production" -maxdepth 2 -name Fusion360.exe -type f)
if (( ${#executables[@]} != 1 )); then
  printf 'Expected one installed Fusion executable; found %d.\n' "${#executables[@]}" >&2
  exit 1
fi
python3 "$libexec/prepare-prefix.py"
python3 "$libexec/browser-listener.py" 9>&- >> "$root/logs/browser.log" 2>&1 &
listener=$!
trap 'kill "$listener" 2>/dev/null || true' EXIT
if [[ "${FUSION_WINE_DESKTOP:-1}" == 1 ]]; then
  bash "$libexec/fusion-proton.sh" explorer /desktop=Fusion,${FUSION_DESKTOP_SIZE:-1600x1000} "${executables[0]}" "$@" 9>&- >> "$root/logs/fusion.log" 2>&1
else
  bash "$libexec/fusion-proton.sh" "${executables[0]}" "$@" 9>&- >> "$root/logs/fusion.log" 2>&1
fi
