#!/usr/bin/env bash
set -Eeuo pipefail

SERVICE_NAME="fuxi-h3-fix.service"
SCRIPT_PATH="${HOME}/.local/bin/fuxi-volume-sync.sh"
SERVICE_PATH="${HOME}/.config/systemd/user/${SERVICE_NAME}"

if [[ "${EUID}" -eq 0 ]]; then
  printf '[ERROR] Do not run this script with sudo.\n' >&2
  exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user disable --now "$SERVICE_NAME" 2>/dev/null || true
  systemctl --user daemon-reload
  systemctl --user reset-failed "$SERVICE_NAME" 2>/dev/null || true
fi

rm -f "$SCRIPT_PATH" "$SERVICE_PATH"

printf 'Fuxi H3 Audio Fix has been removed from your user account.\n'
printf 'No system packages or system-wide configuration files were changed.\n'
