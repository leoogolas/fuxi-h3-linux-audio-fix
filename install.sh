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

for cmd in bash wpctl amixer systemctl awk grep; do
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd. Install the relevant package for your distribution."
done

[[ -r /proc/asound/cards ]] || fail "Cannot read /proc/asound/cards. Is ALSA available?"

if ! grep -qE "\\[\${CARD_ID}\\]" /proc/asound/cards; then
  printf '\nDetected ALSA cards:\n'
  cat /proc/asound/cards
  fail "Fuxi H3 card identifier '${CARD_ID}' was not found. Connect the headset and try again."
fi

amixer -c "$CARD_ID" sget "$MIXER_CONTROL" >/dev/null 2>&1 || fail "Mixer control '${MIXER_CONTROL}' was not found on ${CARD_ID}."

wpctl status >/dev/null 2>&1 || fail "wpctl cannot communicate with PipeWire/WirePlumber. Check your audio session."

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
Description=Fuxi H3 volume and stereo synchronization
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
systemctl --user enable --now "$SERVICE_NAME"

if systemctl --user is-active --quiet "$SERVICE_NAME"; then
  log "${APP_NAME} installed and running."
  printf '\nCheck status with:\n  systemctl --user status %s\n' "$SERVICE_NAME"
  printf 'Check the headset PCM control with:\n  amixer -c %s sget "%s"\n' "$CARD_ID" "$MIXER_CONTROL"
else
  printf '[ERROR] The service did not start. Recent logs:\n' >&2
  systemctl --user status "$SERVICE_NAME" --no-pager >&2 || true
  journalctl --user -u "$SERVICE_NAME" --no-pager -n 30 >&2 || true
  exit 1
fi
