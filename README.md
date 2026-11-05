# Fuxi H3 Linux Audio Fix

A small helper for people using the **Fuxi H3 USB headset on Linux**.

This project keeps the headset's internal PCM volume control in sync with the volume slider on your desktop. It was created to help with a volume-control issue on the Fuxi H3.

You do not need to be a Linux expert to try it. The installer checks whether your headset is recognized before making changes.

**Important:** this helper synchronizes volume levels. It does not change Linux's audio channel layout or independently switch mono audio to stereo.

## Is this for me?

This project was created for the Fuxi H3 USB headset.

It was originally tested on **Bazzite**. It may also work on other Linux distributions, but those have not been tested yet.

If you use a different headset, this project probably is not what you need.

## Install

1. Connect your Fuxi H3 headset to your computer.
2. Open the **Terminal** app. You can usually find it by searching for "Terminal" in your applications.
3. Copy the following command, paste it into the Terminal, and press Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/leoogolas/fuxi-h3-linux-audio-fix/main/install.sh | bash
```

The installer checks whether your Fuxi H3 is detected and whether the required audio tools are available. If something is missing or your headset is not recognized, it stops and displays an error.

**You do not need to run this command with `sudo` or as administrator.**

If you already had a manual version of this fix installed, the installer saves copies of the previous script and service file in a backup folder in your home directory before replacing them.

## What happens after installation?

The helper runs quietly in the background and starts automatically when you log in.

It reads the volume level of your default audio output and updates the Fuxi H3's internal PCM volume control to match it. In everyday use, you should be able to keep using your desktop volume slider as usual.

The installer creates two small files in your personal home folder. It does not change system-wide configuration files or install additional system packages.

For the volume synchronization to work as expected, the Fuxi H3 should be selected as your computer's default audio output.

## How can I check if it worked?

After installation, change the volume using your normal desktop volume controls.

The helper should keep the headset's internal volume level in sync. You do not need to open the Terminal every time you use your headset.

If your sound is still mono after installation, this helper alone may not solve that channel-layout issue. See the troubleshooting section or ask for help before changing other audio settings.

## Uninstall

If you want to remove the helper, open the Terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/leoogolas/fuxi-h3-linux-audio-fix/main/uninstall.sh | bash
```

This stops the background helper and removes the two files installed by this project. It does not remove or change your system's audio packages. If the installer created a backup of your previous setup, that backup folder is left in your home directory.

## Troubleshooting

**The installer says it cannot find my headset**

Make sure the Fuxi H3 is connected, wait a few seconds, and try again. If the message continues, your Linux system may be identifying the headset differently.

**The installer says a required tool is missing**

The installer does not install other programs for you. It needs audio tools that are normally provided by your Linux distribution. If you are not sure how to install them, ask for help and mention which Linux distribution you use.

**The sound is still mono**

This helper synchronizes the headset's volume control. It does not change the audio channel layout. If the sound remains mono, tell us which Linux distribution you use and what happens after installation before trying other commands.

**Nothing changed after installation**

Make sure the Fuxi H3 is selected as the default audio output. If the problem remains, ask for help and include any error message shown by the installer.

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
