# Fuxi H3 Linux Audio Fix

Fix stereo audio and synchronize the hardware PCM volume control with the desktop volume slider for the **Fuxi H3 USB headset** on Linux.

This project addresses a setup where changing the desktop volume does not correctly update the headset's ALSA PCM control, while preserving stereo output.

> **Test status:** The original procedure was developed and tested on Bazzite with the Fuxi H3. Other Linux distributions using PipeWire, WirePlumber, ALSA and systemd user services may work, but are not yet independently verified.

## Features

- Synchronizes the Fuxi H3 ALSA `PCM,1` control with the default PipeWire audio sink volume.
- Runs as a systemd user service and starts automatically at login.
- Does not require root privileges for installation.
- Includes an uninstall script.
- Checks for the expected headset and required commands before installation.

## Quick install

Open a terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/leoogolas/fuxi-h3-linux-audio-fix/main/install.sh -o /tmp/fuxi-h3-install.sh
less /tmp/fuxi-h3-install.sh
bash /tmp/fuxi-h3-install.sh
```

The installer checks the downloaded script's contents before execution. You can also clone or download this repository and run `bash install.sh` locally.

## Requirements

- Fuxi H3 USB headset connected.
- ALSA identifies the card as `FuxiH3`.
- The card exposes the ALSA mixer control `PCM,1`.
- `wpctl` (PipeWire/WirePlumber), `amixer` (ALSA utilities), `systemctl`, and Bash.
- A Linux session with systemd user services.

The installer does not install missing system packages automatically. Install the relevant PipeWire/WirePlumber and ALSA utilities packages through your distribution's package manager if needed.

## What the installer does

1. Checks the required commands.
2. Detects the Fuxi H3 ALSA card and verifies the `PCM,1` mixer control.
3. Creates `~/.local/bin/fuxi-volume-sync.sh`.
4. Installs a systemd user service at `~/.config/systemd/user/fuxi-h3-fix.service`.
5. Enables and starts the service.

No system-wide configuration files are changed.

## Verify

Check the service:

```bash
systemctl --user status fuxi-h3-fix.service
```

Inspect the ALSA PCM control:

```bash
amixer -c FuxiH3 sget 'PCM,1'
```

Change the desktop volume slider and check whether the PCM percentage follows it.

View service logs:

```bash
journalctl --user -u fuxi-h3-fix.service -f
```

## Uninstall

Download and inspect the uninstall script, then run it:

```bash
curl -fsSL https://raw.githubusercontent.com/leoogolas/fuxi-h3-linux-audio-fix/main/uninstall.sh -o /tmp/fuxi-h3-uninstall.sh
less /tmp/fuxi-h3-uninstall.sh
bash /tmp/fuxi-h3-uninstall.sh
```

It stops and disables the user service and removes the two files installed by this project. It does not remove ALSA, PipeWire, or other system packages.

## Troubleshooting

**The installer cannot find the headset**

Make sure the Fuxi H3 is connected, then run:

```bash
cat /proc/asound/cards
```

The card should have the identifier `FuxiH3`.

**The PCM control is missing**

Run:

```bash
amixer -c FuxiH3 scontrols
```

This project currently expects the control named `PCM,1`. If your device exposes a different control, open an issue with the output of these commands.

**The service is not running**

```bash
systemctl --user status fuxi-h3-fix.service
journalctl --user -u fuxi-h3-fix.service --no-pager -n 50
```

## Compatibility and limitations

The script follows the default PipeWire sink reported by `wpctl` and writes its volume percentage to the Fuxi H3 ALSA PCM control. It clamps values above 100% to 100%.

The service polls the volume periodically. This is a lightweight workaround, not a native PipeWire integration. If you use multiple audio outputs, the default sink must be the Fuxi H3 for the expected behavior.

## Search keywords

Fuxi H3 Linux, Fuxi H3 Bazzite, Fuxi H3 audio fix, Fuxi H3 stereo, USB headset mono audio fix, Linux USB headset stereo, PipeWire volume synchronization, ALSA PCM volume, Bazzite audio troubleshooting, Fedora headset audio, Linux headset volume control.

## Contributing

Bug reports and tested compatibility notes for other distributions are welcome. Please include your distribution, desktop environment, audio stack, and the output of `cat /proc/asound/cards` and `amixer -c FuxiH3 scontrols`.

## License

MIT. See [LICENSE](LICENSE).
