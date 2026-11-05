#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="Fuxi H3 Audio Fix"
SCRIPT_NAME="fuxi-volume-sync.sh"
SERVICE_NAME="fuxi-h3-fix.service"
INSTALL_DIR="${HOME}/.local/bin"
SERVICE_DIR="${HOME}/.config/systemd/user"
SCRIPT_PATH="${INSTALL_DIR}/${SCRIPT_NAME}"
SERVICE_PATH="${SERVICE_DIR}/${SERVICE_NAME}"
CARD_ID="FuxiH3"
MIXER_CONTROL="PCM,1"

log() { printf '[INFO] %s\n' "$*"; }
fail() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

[[ "${EUID}" -ne 0 ]] || fail "Do not run this installer with sudo. It installs a user service."
[[ -n "${HOME:-}" && -d "${HOME}" ]] || fail "Could not determine your home directory."

for cmd in bash wpctl amixer systemctl awk grep date; do
  command -v "$cmd" >/dev/null 2>&1 || fail "A required system tool is missing: $cmd. No changes have been made. Please ask for help with your Linux distribution."
done

[[ -r /proc/asound/cards ]] || fail "Linux audio (ALSA) information is unavailable. No changes have been made."

# ALSA pads card names with spaces, so allow whitespace before the closing bracket.
if ! grep -qE "\\[${CARD_ID}[[:space:]]*\\]" /proc/asound/cards; then
  printf '\nLinux audio devices detected:\n'
  cat /proc/asound/cards
  fail "The Fuxi H3 was not detected. Connect the headset, wait a few seconds, and try again. No files were changed."
fi

amixer -c "$CARD_ID" sget "$MIXER_CONTROL" >/dev/null 2>&1 || fail "The Fuxi H3 was detected, but its expected volume control was not found. No files were changed."

wpctl status >/dev/null 2>&1 || fail "The Linux audio service is not responding. Check that your desktop audio is working, then try again. No files were changed."

# Preserve any files from a previous manual setup before replacing them.
if [[ -e "$SCRIPT_PATH" || -e "$SERVICE_PATH" ]]; then
  BACKUP_DIR="${HOME}/fuxi-h3-audio-fix-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  [[ ! -e "$SCRIPT_PATH" ]] || cp -a "$SCRIPT_PATH" "$BACKUP_DIR/"
  [[ ! -e "$SERVICE_PATH" ]] || cp -a "$SERVICE_PATH" "$BACKUP_DIR/"
  log "Previous files were saved in: $BACKUP_DIR"
fi

mkdir -p "$INSTALL_DIR" "$SERVICE_DIR"

cat > "$SCRIPT_PATH" <<'SCRIPT'
#!/usr/bin/env bash
set -u

CARD_ID="FuxiH3"
MIXER_CONTROL="PCM,1"
LAST=""

while true; do
  if wpctl status >/dev/null 2>&1; then
    AUDIO_INFO="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
    VOLUME="$(awk '
      /Volume:/ {
        for (i = 1; i <= NF; i++) {
          if ($i == "Volume:") {
            value = $(i + 1)
            if (value ~ /^[0-9]+([.][0-9]+)?$/) {
              printf "%d", value * 100 + 0.5
            }
          }
        }
      }
    ' <<< "$AUDIO_INFO")"

    if [[ "$AUDIO_INFO" == *"[MUTED]"* ]]; then
      VOLUME="0"
    fi

    if [[ "$VOLUME" =~ ^[0-9]+$ ]]; then
      (( VOLUME > 100 )) && VOLUME=100

      if [[ "$VOLUME" != "$LAST" ]]; then
        if amixer -c "$CARD_ID" sset "$MIXER_CONTROL" "${VOLUME}%" >/dev/null 2>&1; then
          LAST="$VOLUME"
        fi
      fi
    fi
  fi

  sleep 0.25
done
SCRIPT

chmod 0755 "$SCRIPT_PATH"

cat > "$SERVICE_PATH" <<'SERVICE'
[Unit]
Description=Fuxi H3 volume synchronization
After=pipewire.service wireplumber.service
Wants=pipewire.service wireplumber.service

[Service]
Type=simple
ExecStart=%h/.local/bin/fuxi-volume-sync.sh
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
SERVICE

systemctl --user daemon-reload
systemctl --user enable "$SERVICE_NAME"
systemctl --user restart "$SERVICE_NAME"

if systemctl --user is-active --quiet "$SERVICE_NAME"; then
  log "${APP_NAME} is installed and running."
  printf '\nThe helper runs automatically when you log in.\n'
  printf 'You can check its status with:\n  systemctl --user status %s\n' "$SERVICE_NAME"
  printf 'You can check the headset volume control with:\n  amixer -c %s sget "%s"\n' "$CARD_ID" "$MIXER_CONTROL"
else
  printf '[ERROR] The helper did not start. Recent status information:\n' >&2
  systemctl --user status "$SERVICE_NAME" --no-pager >&2 || true
  journalctl --user -u "$SERVICE_NAME" --no-pager -n 30 >&2 || true
  exit 1
fi
