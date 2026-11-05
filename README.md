# Fuxi H3 Linux Audio Fix

A small helper for people using the **Fuxi H3 USB headset on Linux**.

If your headset's sound or volume control is not behaving as expected, this project may help keep the headset's internal volume level in sync with the volume slider on your desktop.

You do not need to be a Linux expert to try it. The installer checks whether your headset is recognized before making any changes.

## Is this for me?

This project was created for the Fuxi H3 USB headset.

It was originally tested on **Bazzite**. It may also work on other Linux distributions, but those have not been tested yet.

If you use a different headset, this project probably is not what you need.

## Install

1. Connect your Fuxi H3 headset to your computer.
2. Open the **Terminal** app. You can usually find it by searching for "Terminal" in your applications.
3. Copy the command below, paste it into the Terminal, and press Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/leoogolas/fuxi-h3-linux-audio-fix/main/install.sh | bash
```

The installer will check whether your Fuxi H3 is detected and whether the required audio tools are available. If something is missing or your headset is not recognized, it will stop and show an error instead of continuing.

**You do not need to run this command with `sudo` or as administrator.**

### Prefer to inspect the installer first?

That is completely fine. You can download the file, read it, and run it yourself:

```bash
curl -fsSL https://raw.githubusercontent.com/leoogolas/fuxi-h3-linux-audio-fix/main/install.sh -o /tmp/fuxi-h3-install.sh
less /tmp/fuxi-h3-install.sh
bash /tmp/fuxi-h3-install.sh
```

In the text viewer, press `q` to exit after reviewing the file.

## What happens after installation?

The helper runs quietly in the background and starts automatically when you log in.

It reads the volume level of your default audio output and updates the Fuxi H3's internal PCM volume control to match it. In everyday use, you should be able to keep using your desktop volume slider as usual.

The installer creates two small files in your personal home folder. It does not change system-wide configuration files or install additional system packages.

## How can I check if it worked?

After installation, change the volume using your normal desktop volume controls.

The helper should keep the headset's internal volume level in sync. You do not need to open the Terminal every time you use your headset.

If the sound still does not behave as expected, see the troubleshooting section below.

## Uninstall

If you want to remove the helper, open the Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/leoogolas/fuxi-h3-linux-audio-fix/main/uninstall.sh | bash
```

This stops the background helper and removes the two files created by the installer. It does not remove or change your system's audio packages.

You can also download and inspect the uninstall script before running it:

```bash
curl -fsSL https://raw.githubusercontent.com/leoogolas/fuxi-h3-linux-audio-fix/main/uninstall.sh -o /tmp/fuxi-h3-uninstall.sh
less /tmp/fuxi-h3-uninstall.sh
bash /tmp/fuxi-h3-uninstall.sh
```

## Troubleshooting

**The installer says it cannot find my headset**

Make sure the Fuxi H3 is connected, then try unplugging it and connecting it again. If the message continues, your Linux system may be identifying the headset differently.

**The installer says a required command is missing**

The installer does not install other programs for you. It needs the audio tools that come with your Linux distribution. If you are not sure how to install them, open an issue and mention which Linux distribution you use.

**Nothing changed after installation**

Try logging out and back in, or restarting your computer. If the problem remains, open an issue and describe what is happening.

When reporting a problem, please mention your Linux distribution (for example, Bazzite or Fedora) and whether the installer displayed an error.

## For advanced users

The helper synchronizes the Fuxi H3 ALSA `PCM,1` mixer control with the default PipeWire audio output reported by `wpctl`. It runs as a systemd user service and checks the volume periodically.

To check whether the service is running:

```bash
systemctl --user status fuxi-h3-fix.service
```

To view its logs:

```bash
journalctl --user -u fuxi-h3-fix.service -f
```

The expected audio setup uses PipeWire, WirePlumber, ALSA utilities, and systemd user services. The default audio output should be the Fuxi H3 for the volume synchronization to behave as expected.

## Help improve this project

This started as a fix for my own Fuxi H3 headset on Bazzite. If you try it on another Linux distribution, please share whether it worked.

You can report a problem or share your experience by opening an issue in this repository. Please include your Linux distribution and a description of what happened.

## License

MIT. See [LICENSE](LICENSE).
